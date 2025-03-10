# RPSLS Smart Contract  

**งานนี้เป็นส่วนหนึ่งของวิชา DeFi (204496/219493) ของปี 2567 ที่มหาวิทยาลัยเกษตรศาสตร์
จัดทำโดย อภิภู ชูเจริญประกิจ 6510503891**

rpsls (rock-paper-scissors-lizard-spock) เป็น smart contract ที่พัฒนาต่อยอดจากเกมเป่ายิ้งฉุบแบบปกติ กำเนิดจาก Sam Kass and Karen Bryla ได้ปรากฎในเรื่อง The Big Bang Theory จำนวนหลายตอน ซึ่งผมก็ไม่เคยดูเหมือนกัน ): โดยเพิ่มกติกาใหม่คือให้เลือกได้ 5 ตัวเลือกแทน 3 ตัวเลือกแบบเดิม และมีระบบ commit-reveal เพื่อป้องกันการโกง (front-running) รวมถึงกลไกการถอนเงินป้องกันเงินถูกล็อกค้างไว้ใน contract หากผู้เล่นไม่ยอมเล่นต่อ

- เริ่มต้นเกม ผู้เล่นที่ต้องการเข้าร่วมต้องเป็นหนึ่งใน 4 บัญชีที่ได้รับอนุญาต เท่านั้น และต้อง commit ตัวเลือกของตัวเองโดยส่งค่า hash ของ (ตัวเลือก+ค่าลับ) เข้าไปยัง contract ผ่านฟังก์ชัน `Addplayer()` พร้อมกับวางเดิมพัน 1 ETH เมื่อมีผู้เล่นครบ 2 คน เกมจะเข้าสู่เฟส commit ซึ่งหมายความว่า ไม่มีใครสามารถเห็นตัวเลือกของกันและกัน ได้

- เมื่อถึงเวลาที่ต้องเปิดเผยตัวเลือก ผู้เล่นต้องใช้ฟังก์ชัน `Revealchoice()` โดยส่งค่าตัวเลือกที่แท้จริงและค่าลับของตนเองไปที่ contract ซึ่งจะนำค่าที่ได้รับไปตรวจสอบกับค่า hash ที่ commit ไว้ตอนแรก ถ้าค่าตรงกัน ระบบจะบันทึกตัวเลือกของผู้เล่น ถ้ามีผู้เล่นเปิดเผยตัวเลือกครบ 2 คน ระบบจะใช้กติกาของ RPSLS เพื่อตัดสินผู้ชนะ

- ระบบจะใช้ฟังก์ชัน `Checkwinnerandpay()` เพื่อตรวจสอบผลลัพธ์โดยใช้ฟังก์ชัน `Getmoveresult()` ซึ่งเป็นฟังก์ชันที่คำนวณว่าผู้เล่นคนไหนชนะ โดยเปรียบเทียบตัวเลือกของทั้งสองฝ่ายตามกฎของเกม Rock-Paper-Scissors-Lizard-Spock ถ้าผู้เล่นทั้งสองเลือกเหมือนกัน เกมจะเสมอและคืนเงินเดิมพันคนละครึ่ง ถ้ามีผู้ชนะ เงินเดิมพันทั้งหมดจะถูกโอนไปยังบัญชีของผู้ชนะ

- นอกจากนี้ หากมีผู้เล่น ไม่เปิดเผยตัวเลือกภายในเวลาที่กำหนด อีกฝ่ายสามารถถือว่าชนะโดยอัตโนมัติ หรือถ้าไม่มีใครเปิดเผยตัวเลือกเลย ระบบสามารถ reset เกมได้เพื่อให้ไม่มีเงินค้างใน contract การใช้ contract นี้ช่วยให้มั่นใจว่า ทุกเกมสามารถดำเนินไปตามกฎที่กำหนดไว้ ไม่มีใครโกงได้ และไม่มีเงินถูกล็อกอยู่ในระบบ

- ดังนั้นโค้ดของ smart contract ที่พัฒนาอยู่ตอนนี้สามารถรองรับแทบจะทุกสถานการณ์ ไม่ว่าจะเป็นการป้องกันการโกงจากการรู้ผลล่วงหน้า ป้องกันเงินติดค้างในระบบ และทำให้เกมสามารถดำเนินไปได้อย่างราบรื่นโดยไม่ต้องพึ่งพาบุคคลที่สาม ทุกอย่างจะเป็นไปตามเงื่อนไขที่กำหนดไว้ใน contract โดยอัตโนมัติ

## รายละเอียดฟังก์ชัน  

### 1. ป้องกันเงินค้างอยู่ใน contract  
ปัญหาหลักของ smart contract เกมพนันคือเงินที่ถูกลงเดิมพันอาจติดค้างอยู่ใน contract ถ้าผู้เล่นไม่ทำตามขั้นตอนให้ครบ วิธีแก้ปัญหาคือใช้ฟังก์ชัน **Withdraw()** เพื่อจัดการ

- **ถ้าอยู่ใน commit phase (ยังไม่มีใคร reveal) และผ่านไป 5 วินาที**  
  - ผู้เล่นสามารถกด `Withdraw()` เพื่อ **ถอนตัวออกจากเกม** และได้เงินคืน  
  - ระบบจะรีเกมอัตโนมัติ เพื่อให้เริ่มรอบใหม่ได้ทันที  

- **ถ้าอยู่ใน reveal phase (มีคน reveal แล้ว แต่มีคนยังไม่ reveal)**  
  - ผู้เล่นที่ reveal แล้วสามารถกด `Withdraw()` เพื่อ **รับชัยชนะอัตโนมัติ**  
  - ระบบจะปรับให้อีกฝ่ายที่ไม่ reveal เป็นผู้แพ้ และโอนเงินรางวัลทั้งหมดให้ผู้ชนะ  
  - ถ้าผู้เล่นทั้งสองคน reveal ระบบจะไม่อนุญาตให้กด withdraw  

- **ถ้าเกมจบไปแล้ว**  
  - ระบบจะรีให้อัตโนมัติ และสามารถเริ่มรอบใหม่ได้เลย

ตัวอย่างโค้ด
```solidity
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
```

### 2. ซ่อน choice ของผู้เล่นก่อน reveal  
ปัญหาของเกมบน blockchain คือทุกธุรกรรมจะเปิดเผยต่อสาธารณะ ถ้า submit ตัวเลือกไปตรงๆ ฝ่ายตรงข้ามสามารถดูได้และเลือก counter-move ได้ทันที วิธีแก้คือใช้ commit-reveal  

- **ขั้นตอน commit**  
  - ใช้ `getHash()` สร้างค่า hash จาก (ตัวเลือกที่เลือก+ค่าลับ)  
  - ส่งค่า hash ผ่าน `addplayer()` เพื่อป้องกันการรู้ล่วงหน้า  

- **ขั้นตอน reveal**  
  - ผู้เล่นต้องส่งค่าเดิมที่ใช้ hash มา reveal ผ่าน `Revealchoice()`  
  - contract ตรวจสอบว่าค่า hash ตรงกันหรือไม่ ถ้าไม่ตรงถือว่าโกง

### 3. จัดการปัญหาผู้เล่นไม่ครบ  
ถ้าผู้เล่นคนใดคนหนึ่ง commit แล้ว แต่อีกคนไม่เข้ามาเล่นหรือไม่ยอม reveal จะทำให้เกมหยุดติดขัดและเงินนั้นถูกล็อกไว้ใน contract ซึ่งเป็นปัญหาใหญ่มาก  

  - หากมีการ commit ครบ 2 คนแล้ว แต่มีเพียง 1 คนที่ reveal ให้ผู้เล่นที่ reveal ใช้ Withdraw() เพื่อปรับให้ตัวเองชนะ
  - หากไม่มีใคร reveal ภายในเวลาที่กำหนด ใช้ Resetgame() เพื่อคืนเงินและเปิดเกมใหม่

ตัวอย่างโค้ด
```solidity
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
```

### 4. ตรวจสอบผลแพ้ชนะจาก choice ที่ reveal  
หลังจากที่ผู้เล่นทั้งสองคน reveal ระบบจะนำค่าที่ได้ไปตรวจสอบและหาผู้ชนะโดยใช้กติกา rpsls  

- ถ้าทั้งสองคนเลือกเหมือนกันจะถือว่าเสมอ และเงินเดิมพันจะถูกแบ่งให้ทั้งสองฝ่าย 
- ถ้ามีฝ่ายใดฝ่ายหนึ่งเลือกตัวเลือกที่ชนะอีกฝ่ายตามกติกา rpsls ระบบจะโอนเงินรางวัลทั้งหมดให้ผู้ชนะ  
- หลังจากตัดสินผลแพ้ชนะหรือเสมอ ระบบจะรีเกมให้พร้อมเริ่มรอบใหม่

**กติกา rpsls**
- ค้อน (rock) ชนะ กรรไกร (scissors) และจิ้งจก (lizard)
- กระดาษ (paper) ชนะ ค้อน (rock) และสป็อค (spock)
- กรรไกร (scissors) ชนะ กระดาษ (paper) และจิ้งจก (lizard)
- จิ้งจก (lizard) ชนะ สป็อค (spock) และกระดาษ (paper)
- สป็อค (spock) ชนะ ค้อน (rock) และกรรไกร (scissors)

```solidity
    function Getmoveresult(uint Movea, uint Moveb) private pure returns (uint) {
        if (Movea == Moveb) return 0; // tie
        if (
            (Movea == 0 && (Moveb == 2 || Moveb == 3)) || // Rock crushes Scissors, Rock crushes Lizard
            (Movea == 1 && (Moveb == 0 || Moveb == 4)) || // Paper covers Rock, Paper disproves Spock
            (Movea == 2 && (Moveb == 1 || Moveb == 3)) || // Scissors cuts Paper, Scissors decapitates Lizard
            (Movea == 3 && (Moveb == 4 || Moveb == 1)) || // Lizard poisons Spock, Lizard eats Paper
            (Movea == 4 && (Moveb == 0 || Moveb == 2))    // Spock smashes Rock, Spock vaporizes Scissors
        ) {
            return 1; // Movea wins
        }
        return 2; // Moveb wins
    }
```

### 5. การเล่นรอบใหม่หลังจบเกม  
เพื่อให้ผู้เล่นสามารถเล่นได้อย่างต่อเนื่องโดยไม่ต้อง deploy contract ใหม่ ทุกครั้งที่เกมจบลง ไม่ว่าผลเป็นยังไง ระบบจะรีค่าใน contract โดยอัตโนมัติ เพื่อให้สามารถเริ่มเกมใหม่ได้ทันที  

- ผู้เล่นสามารถ commit ตัวเลือกใหม่ได้ทันทีหลังจากรอบที่แล้วจบ  
- ระบบจะจัดการล้างค่าตัวแปรต่างๆ เพื่อให้ไม่มีข้อมูลจากเกมก่อนหน้ามีผลกระทบต่อรอบใหม่  
- ถ้าผู้เล่นไม่ทำอะไร ระบบจะไม่ล็อกเงินไว้ แต่จะคืนเงินให้ถ้าถึงเวลาที่กำหนด  

## วิธีเล่นใน remix  
### 1. คอมไพล์และ deploy contract  
1. เปิด Remix IDE (https://remix.ethereum.org/)  
2. คอมไพล์ไฟล์ `RPSLS.sol`  
3. Deploy contract  

### 2. เล่นเกม  
1. ใช้ `gethash()` เพื่อสร้าง commit hash  
2. ใช้ `addplayer()` ใส่ hash และวางเงินเดิมพัน  
3. หลังจากทั้งสองคน commit ใช้ `revealchoice()` เพื่อเปิดเผยตัวเลือก  
4. ถ้ามีคนไม่ reveal ใช้ `Withdraw()`  

**_NOTE:_** ในงานนี้ได้อ้างอิงจาก repository ของอาจารย์ Paruj Ratanaworabhan เป็นหลัก https://github.com/parujr/RPS 
