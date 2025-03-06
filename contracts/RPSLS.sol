// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./CommitReveal.sol";
import "./TimeUnit.sol";

contract RPSLS is CommitReveal, TimeUnit {
  uint public Numplayer = 0;
  uint public Reward = 0;
  mapping(address => uint) public Playerchoice;
  mapping(address => bool) public Playerrevealed;
  mapping(address => bool) public Playerwithdrawn;
  address[] public Players;
  uint public Numinput = 0;
  bool public Gameactive = false;
  uint public Commitstarttime;

  address[4] Allowedplayers = [
    0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
    0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
    0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
    0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
  ];

  modifier Onlyallowed() {
    bool Isallowed = false;
    for (uint i = 0; i < Allowedplayers.length; i++) {
      if (msg.sender == Allowedplayers[i]) {
        Isallowed = true;
        break;
      }
    }
    require(Isallowed, "Not an allowed player");
    _;
  }

  function Getmoveresult(uint Movea, uint Moveb) private pure returns (uint) {
    if (Movea == Moveb) return 0; // tie
    if (
      (Movea == 0 && (Moveb == 2 || Moveb == 3)) || // Rock crushes Scissors, Rock crushes Lizard
      (Movea == 1 && (Moveb == 0 || Moveb == 4)) || // Paper covers Rock, Paper disproves Spock
      (Movea == 2 && (Moveb == 1 || Moveb == 3)) || // Scissors cuts Paper, Scissors decapitates Lizard
      (Movea == 3 && (Moveb == 4 || Moveb == 1)) || // Lizard poisons Spock, Lizard eats Paper
      (Movea == 4 && (Moveb == 0 || Moveb == 2)) // Spock smashes Rock, Spock vaporizes Scissors
    ) {
      return 1; // Movea wins
    }
    return 2; // Moveb wins
  }

  function Resetgame() private {
    delete Playerchoice[Players[0]];
    delete Playerchoice[Players[1]];
    delete Playerrevealed[Players[0]];
    delete Playerrevealed[Players[1]];
    delete Playerwithdrawn[Players[0]];
    delete Playerwithdrawn[Players[1]];
    delete commits[Players[0]];
    delete commits[Players[1]];
    delete Players;
    Numplayer = 0;
    Reward = 0;
    Numinput = 0;
    Gameactive = false;
  }

  function Checkwinnerandpay() private {
    uint P0choice = Playerchoice[Players[0]];
    uint P1choice = Playerchoice[Players[1]];
    address payable Account0 = payable(Players[0]);
    address payable Account1 = payable(Players[1]);

    uint Result = Getmoveresult(P0choice, P1choice);

    if (Result == 1) {
      Account0.transfer(Reward);
    } else if (Result == 2) {
      Account1.transfer(Reward);
    } else {
      Account0.transfer(Reward / 2);
      Account1.transfer(Reward / 2);
    }
    Resetgame();
  }

  constructor() {
    setStartTime();
  }

  function Addplayer(bytes32 Commithash) public payable Onlyallowed {
    require(!Gameactive, "Game already in progress");
    require(Players.length < 2, "Game full");
    require(msg.value == 1 ether, "Must send 1 ETH");

    Players.push(msg.sender);
    commit(Commithash);
    Reward += msg.value;

    if (Players.length == 2) {
      Gameactive = true;
      Commitstarttime = block.timestamp;
      setStartTime();
    }
  }

  function Revealchoice(bytes32 Encodeddata) public Onlyallowed {
    require(Gameactive, "No active game");
    require(!Playerrevealed[msg.sender], "Already revealed");

    reveal(Encodeddata);

    bytes1 Lastbyte = Encodeddata[31];
    uint8 Value = uint8(Lastbyte);
    Playerchoice[msg.sender] = uint256(Value);
    Playerrevealed[msg.sender] = true;
    Numinput++;

    if (Numinput == 2) {
      Checkwinnerandpay();
    }
  }

  function Withdraw() public Onlyallowed {
    require(Gameactive, "No active game");
    require(
      msg.sender == Players[0] || msg.sender == Players[1],
      "Must be in game to withdraw"
    );

    if (Numinput == 0) {
      require(block.timestamp >= Commitstarttime + 0, "Cannot withdraw now");
      for (uint i = 0; i < Players.length; i++) {
        payable(Players[i]).transfer(1 ether);
      }
      Resetgame();
    } else if (Numinput == 1) {
      address payable Withdrawer;
      address payable Winner;

      if (msg.sender == Players[0]) {
        Withdrawer = payable(Players[0]);
        Winner = payable(Players[1]);
      } else if (msg.sender == Players[1]) {
        Withdrawer = payable(Players[1]);
        Winner = payable(Players[0]);
      }

      Winner.transfer(Reward);
      Resetgame();
    } else {
      revert("Cannot withdraw at this stage");
    }
  }
}
