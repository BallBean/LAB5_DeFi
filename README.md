# RPSLS Smart Contract  

rpsls (rock-paper-scissors-lizard-spock) เป็น smart contract ที่พัฒนาต่อยอดจากเกมเป่ายิ้งฉุบแบบปกติ กำเนิดจาก Sam Kass and Karen Bryla ได้ปรากฎในเรื่อง The Big Bang Theory จำนวนหลายตอน ซึ่งผมก็ไม่เคยดูเหมือนกัน ): โดยเพิ่มกติกาใหม่คือให้เลือกได้ 5 ตัวเลือกแทน 3 ตัวเลือกแบบเดิม และมีระบบ commit-reveal เพื่อป้องกันการโกง (front-running) รวมถึงกลไกการถอนเงินป้องกันเงินถูกล็อกค้างไว้ใน contract หากผู้เล่นไม่ยอมเล่นต่อ

## รายละเอียดฟังก์ชัน  

### 1. ป้องกันเงินค้างอยู่ใน contract  
ปัญหาหลักของ smart contract เกมพนันคือเงินที่ถูกลงเดิมพันอาจติดค้างอยู่ใน contract ถ้าผู้เล่นไม่ทำตามขั้นตอนให้ครบ ซึ่งวิธีแก้ปัญหาคือใช้ฟังก์ชันถอนเงินอัตโนมัติหลังจากเวลาที่กำหนด  

- **Withdrawduringcommitphase()**  
  - ถ้าผู้เล่น commit แล้วไม่มีใครมา join ภายใน 5 วินาที จะสามารถถอนเงินคืนได้  
  - ถ้าสำเร็จ เกมจะรีและเปิดให้เล่นใหม่  

- **Withdrawduringrevealphase()**  
  - ถ้าผู้เล่นหนึ่งคน reveal แล้วแต่ฝ่ายตรงข้ามไม่ reveal ภายในเวลาที่กำหนด  
  - ผู้เล่นที่ reveal สามารถกดเพื่อได้เป็นผ่ายชนะและได้เงินทั้งหมด  

- **Resetgame()**  
  - เมื่อเกมจบ (มีผู้ชนะ เสมอ หรือมีคนถอนตัว)  
  - contract จะรีค่าให้พร้อมเริ่มรอบใหม่  

### 2. ซ่อน choice ของผู้เล่นก่อน reveal  
ปัญหาของเกมบน blockchain คือทุกธุรกรรมจะเปิดเผยต่อสาธารณะ ถ้า submit ตัวเลือกไปตรงๆ ฝ่ายตรงข้ามสามารถดูได้และเลือก counter-move ได้ทันที วิธีแก้คือใช้ commit-reveal  

- **ขั้นตอน commit**  
  - ใช้ `gethash()` สร้างค่า hash จาก (ตัวเลือกที่เลือก+ค่าลับ)  
  - ส่งค่า hash ผ่าน `addplayer()` เพื่อป้องกันการรู้ล่วงหน้า  

- **ขั้นตอน reveal**  
  - ผู้เล่นต้องส่งค่าเดิมที่ใช้ hash มา reveal ผ่าน `Revealchoice()`  
  - contract ตรวจสอบว่าค่า hash ตรงกันหรือไม่ ถ้าไม่ตรงถือว่าโกง

### 3. จัดการปัญหาผู้เล่นไม่ครบ  
ถ้าผู้เล่นคนใดคนหนึ่ง commit แล้ว แต่อีกคนไม่เข้ามาเล่นหรือไม่ยอม reveal จะทำให้เกมหยุดติดขัดและเงินนั้นถูกล็อกไว้ใน contract ซึ่งเป็นปัญหาใหญ่มาก  

- ถ้าผู้เล่น commit แล้วแต่ไม่มีใครมาเล่นต่อภายใน 5 วินาที ผู้เล่นสามารถถอนเงินคืนไดโดยใช้ฟังก์ชันถอนตัว  
- ถ้าผู้เล่น reveal แล้ว แต่ฝ่ายตรงข้ามไม่ยอม reveal ภายในเวลาที่กำหนด ระบบจะถือว่าอีกฝ่ายแพ้ และโอนเงินรางวัลให้ผู้ที่ reveal แล้ว  
- ถ้าทั้งสองฝ่าย commit แล้วแต่ไม่มีใคร reveal ภายในเวลาที่กำหนด เกมจะรีและเปิดให้เริ่มใหม่  

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

```function Getmoveresult(uint Movea, uint Moveb) private pure returns (uint) {
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
    }```

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
4. ถ้ามีคนไม่ reveal ใช้ `Withdrawduringrevealphase()`  

## สรุปงานที่ได้ทำในครั้งนี้
- ใช้กติกา rpsls ให้ตัวเลือกหลากหลายขึ้น  
- ใช้ commit-reveal ป้องกัน front-running  
- มีฟังก์ชันถอนเงินถ้าผู้เล่นไม่ครบ ป้องกันเงินถูกล็อก  
- มีระบบ reset เกมให้เล่นได้เรื่อยๆ  
