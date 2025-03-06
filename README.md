# RPSLS Smart Contract  

rpsls (rock-paper-scissors-lizard-spock) เป็น smart contract ที่พัฒนาต่อยอดจากเกมเป่ายิ้งฉุบแบบปกติ กำเนิดจาก Sam Kass and Karen Bryla ได้ปรากฎในเรื่อง The Big Bang Theory จำนวนหลายตอน ซึ่งผมก็ไม่เคยดูเหมือนกัน ): โดยเพิ่มกติกาใหม่คือให้เลือกได้ 5 ตัวเลือกแทน 3 ตัวเลือกแบบเดิม และมีระบบ commit-reveal เพื่อป้องกันการโกง (front-running) รวมถึงกลไกการถอนเงินป้องกันเงินถูกล็อกค้างไว้ใน contract หากผู้เล่นไม่ยอมเล่นต่อ

เมื่อ smart contract RPSLS เริ่มทำงาน มันจะรอให้มีผู้เล่นสองคนเข้ามาเข้าร่วมเกม โดยผู้เล่นที่เข้ามาจะต้องใช้บัญชีที่ได้รับอนุญาตเท่านั้น และต้อง commit ตัวเลือกของตัวเองก่อนโดยใช้ค่า hash ซึ่งเป็นการเข้ารหัสข้อมูลเพื่อป้องกันการโกง จากนั้นจะต้องวางเงินเดิมพัน 1 ETH เพื่อให้ระบบเริ่มดำเนินการต่อ ถ้าผู้เล่นคนแรกเข้ามาแล้วแต่ไม่มีผู้เล่นคนที่สองเข้ามาในเวลาที่กำหนด (เช่น 5 วินาที) ผู้เล่นสามารถถอนตัวออกจากเกมและรับเงินคืนได้โดยการกดปุ่ม Withdraw()

เมื่อมีผู้เล่นครบสองคนและทั้งสองได้ commit ตัวเลือกของตัวเอง เกมจะเข้าสู่ phase ของ commit ซึ่งในเฟสนี้ผู้เล่นทั้งสองจะต้องเก็บตัวเลือกของตัวเองไว้เป็นความลับจนกว่าจะถึงเวลา reveal ในระหว่างนี้ไม่มีใครรู้ว่าผู้เล่นคนอื่นเลือกอะไร เพราะค่าที่บันทึกไว้ใน contract เป็นเพียงค่า hash ซึ่งไม่สามารถอ่านค่าเดิมกลับมาได้ หากมีผู้เล่นคนใดไม่ทำการ commit ตัวเลือก ระบบจะไม่สามารถดำเนินเกมต่อไปได้ และอีกฝ่ายสามารถถอนตัวออกจากเกมเพื่อรับเงินคืนได้

เมื่อทั้งสองฝ่าย commit แล้ว เกมจะเข้าสู่ phase ของ reveal ในช่วงนี้ผู้เล่นแต่ละคนต้องเปิดเผยตัวเลือกของตัวเองโดยส่งค่าที่แท้จริง (choice + secret) เพื่อให้ smart contract ตรวจสอบว่าตรงกับค่าที่ commit ไว้ก่อนหน้านี้หรือไม่ หากค่าที่ส่งมาไม่ตรงกัน contract จะถือว่าเป็นการพยายามโกงและไม่อนุญาตให้ระบบยอมรับค่า reveal นั้น ถ้ามีผู้เล่นเพียงคนเดียวที่ reveal และอีกคนไม่ทำอะไรภายในเวลาที่กำหนด อีกฝ่ายจะถูกปรับแพ้โดยอัตโนมัติ และเงินเดิมพันทั้งหมดจะถูกโอนไปให้ผู้ที่ reveal แล้ว

หลังจากที่ผู้เล่นทั้งสองเปิดเผยตัวเลือกแล้ว ระบบจะใช้กติกาของ Rock-Paper-Scissors-Lizard-Spock ในการตัดสินผลแพ้ชนะ โดยเปรียบเทียบค่าที่เปิดเผยออกมา ถ้าทั้งสองเลือกเหมือนกัน ระบบจะถือว่าเสมอและคืนเงินเดิมพันให้ทั้งสองฝ่ายคนละครึ่ง ถ้ามีฝ่ายใดฝ่ายหนึ่งชนะ ระบบจะโอนเงินเดิมพันทั้งหมดไปให้ฝ่ายที่ชนะ และสุดท้ายเมื่อเกมจบลงไม่ว่าจะเป็นการชนะ แพ้ หรือเสมอ ระบบจะ reset เกมเพื่อให้สามารถเริ่มรอบใหม่ได้ทันทีโดยไม่ต้อง deploy contract ใหม่

ดังนั้นโค้ดของ smart contract ที่พัฒนาอยู่ตอนนี้สามารถรองรับแทบจะทุกสถานการณ์ ไม่ว่าจะเป็นการป้องกันการโกงจากการรู้ผลล่วงหน้า ป้องกันเงินติดค้างในระบบ และทำให้เกมสามารถดำเนินไปได้อย่างราบรื่นโดยไม่ต้องพึ่งพาบุคคลที่สาม ทุกอย่างจะเป็นไปตามเงื่อนไขที่กำหนดไว้ใน contract โดยอัตโนมัติ

## รายละเอียดฟังก์ชัน  

### 1. ป้องกันเงินค้างอยู่ใน contract  
ปัญหาหลักของ smart contract เกมพนันคือเงินที่ถูกลงเดิมพันอาจติดค้างอยู่ใน contract ถ้าผู้เล่นไม่ทำตามขั้นตอนให้ครบ วิธีแก้ปัญหาคือใช้ฟังก์ชัน **Withdraw()** เพื่อจัดการ

- **ถ้าอยู่ใน commit phase (ยังไม่มีใคร reveal) และผ่านไป 5 วินาที**  
  - ผู้เล่นสามารถกด Withdraw() เพื่อ **ถอนตัวออกจากเกม** และได้เงินคืน  
  - ระบบจะรีเกมอัตโนมัติ เพื่อให้เริ่มรอบใหม่ได้ทันที  

- **ถ้าอยู่ใน reveal phase (มีคน reveal แล้ว แต่มีคนยังไม่ reveal)**  
  - ผู้เล่นที่ reveal แล้วสามารถกด **Withdraw()** เพื่อ **รับชัยชนะอัตโนมัติ**  
  - ระบบจะปรับให้อีกฝ่ายที่ไม่ reveal เป็นผู้แพ้ และโอนเงินรางวัลทั้งหมดให้ผู้ชนะ  
  - ถ้าผู้เล่นทั้งสองคน reveal ระบบจะไม่อนุญาตให้กด withdraw  

- **ถ้าเกมจบไปแล้ว**  
  - ระบบจะรีให้อัตโนมัติ และสามารถเริ่มรอบใหม่ได้เลย  

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
4. ถ้ามีคนไม่ reveal ใช้ `Withdrawduringrevealphase()`  

## สรุปงานที่ได้ทำในครั้งนี้
- ใช้กติกา rpsls ให้ตัวเลือกหลากหลายขึ้น  
- ใช้ commit-reveal ป้องกัน front-running  
- มีฟังก์ชันถอนเงินถ้าผู้เล่นไม่ครบ ป้องกันเงินถูกล็อก  
- มีระบบ reset เกมให้เล่นได้เรื่อยๆ  
