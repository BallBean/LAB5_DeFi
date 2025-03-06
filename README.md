# RPSLS Smart Contract  

rpsls (rock-paper-scissors-lizard-spock) เป็น smart contract ที่พัฒนาต่อยอดจากเกมเป่ายิ้งฉุบแบบปกติ โดยเพิ่มกติกา rpsls ให้เลือกได้ 5 ตัวเลือกแทน 3 ตัวเลือกแบบเดิม และมีระบบ commit-reveal เพื่อป้องกันการโกง (front-running) รวมถึงกลไกการถอนเงินป้องกันเงินถูกล็อกค้างไว้ใน contract หากผู้เล่นไม่ยอมเล่นต่อ  

## รายละเอียดฟังก์ชัน  

### 1. ป้องกันเงินค้างอยู่ใน contract  
ปัญหาหลักของ smart contract เกมพนันคือเงินที่ถูกลงเดิมพันอาจติดค้างอยู่ใน contract ถ้าผู้เล่นไม่ทำตามขั้นตอนให้ครบ วิธีแก้ปัญหาคือใช้ฟังก์ชันถอนเงินอัตโนมัติหลังจากเวลาที่กำหนด  

- **Withdrawduringcommitphase()**  
  - ถ้าผู้เล่น commit แล้วไม่มีใครมา join ภายใน 5 วินาที จะสามารถถอนเงินคืนได้  
  - ถ้าสำเร็จ เกมจะรีและเปิดให้เล่นใหม่  

- **Withdrawduringrevealphase()**  
  - ถ้าผู้เล่นหนึ่งคน reveal แล้วแต่ฝ่ายตรงข้ามไม่ reveal ภายในเวลาที่กำหนด  
  - ผู้เล่นที่ reveal สามารถกดเพื่อได้เป็นผ่ายชนะและได้เงินทั้งหมด  

- **Resetgame()**  
  - เมื่อเกมจบ (มีผู้ชนะ เสมอ หรือมีคนถอนตัว)  
  - contract จะ reset ค่าให้พร้อมเริ่มรอบใหม่  

### 2. ซ่อน choice ของผู้เล่นก่อน reveal  
ปัญหาของเกมบน blockchain คือทุกธุรกรรมจะเปิดเผยต่อสาธารณะ ถ้า submit ตัวเลือกไปตรงๆ ฝ่ายตรงข้ามสามารถดูได้และเลือก counter-move ได้ทันที วิธีแก้คือใช้ commit-reveal  

- **ขั้นตอน commit**  
  - ใช้ `gethash()` สร้างค่า hash จาก (ตัวเลือกที่เลือก+ค่าลับ)  
  - ส่งค่า hash ผ่าน `addplayer()` เพื่อป้องกันการรู้ล่วงหน้า  

- **ขั้นตอน reveal**  
  - ผู้เล่นต้องส่งค่าเดิมที่ใช้ hash มา reveal ผ่าน `Revealchoice()`  
  - contract ตรวจสอบว่าค่า hash ตรงกันหรือไม่ ถ้าไม่ตรงถือว่าโกง
