.origin 0
.entrypoint start

#define GPIO0 0x44E07000
#define GPIO1 0x4804C000
#define GPIO2 0x481AC000
#define GPIO3 0x481AE000

#define GPIO_OE 0x134
#define GPIO_DATAIN 0x138
#define GPIO_CLEARDATAOUT 0x190
#define GPIO_SETDATAOUT 0x194

#define INS_PER_MS    200 * 1000
#define ON_DURATION   250 * INS_PER_MS
#define OFF_DURATION  250 * INS_PER_MS

#define SRCLR 13 /* P8_11 45 GPIO 1_13 no pull mode 7 */ 
#define SRCLK 12 /* P8_12 44 GPIO 1_12 no pull mode 7 */
#define OE    23 /* P8_13 23 GPIO 0_23 no pull mode 7 */
#define RCLK  15 /* P8_15 47 GPIO 1_15 no pull mode 7 */
#define SER   14 /* P8_16 46 GPIO 1_14 no pull mode 7 */
#define CPRUCFG  c4

start:
    lbco r0, CPRUCFG, 4, 4   // read SYSCFG
    clr  r0.t4               // clear SYSCFG[STANDBY_INIT]
    sbco r0, CPRUCFG, 4, 4   // enable OCP master port;

	//set SRCLR pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, SRCLR
	SBBO r2, r3, 0, 4
	
	//set SRCLK pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, SRCLK
	SBBO r2, r3, 0, 4

	//set OE pin to ouput
	MOV r3, GPIO0 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, OE
	SBBO r2, r3, 0, 4
	
	//set RCLK pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, RCLK
	SBBO r2, r3, 0, 4
	
	//set SER pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, SER
	SBBO r2, r3, 0, 4
	
	//setting the register for data high and low for GPIO0
	MOV r3, GPIO0 | GPIO_SETDATAOUT
	MOV r4, GPIO0 | GPIO_CLEARDATAOUT
	
	
	//Setting the value for the register FOR Output enable register low state
	MOV r2, 1 << OE    // the output enable pin
	SBBO r2, r4, 0, 4  // the OE pin is low

	//setting the register for data high and low for GPIO1
	MOV r3, GPIO1 | GPIO_SETDATAOUT
	MOV r4, GPIO1 | GPIO_CLEARDATAOUT
	
	//Setting the value for the register serial clear register high state
	MOV  r2, 1 << SRCLR //move SRCLR pin to  
	SBBO r2, r3, 0, 4   // the SRCLR pin is HIGH
	
	//the defined pins SRCLK RCLK and SER associated with GPIO1_bank
	MOV r2, 1 << SRCLK  // data clk pin
	MOV r5, 1 << RCLK   // data latch output pin
	MOV r6, 1 << SER    // data input pin

	MOV r0, ON_DURATION


DELAY_0:
	SUB r0, r0, 1
	QBNE DELAY_0, r0, 0
	MOV r0, ON_DURATION
 
// LATCH_IN:
	SBBO r5, r3, 0, 4 	// keep latch pin down(RCLK) 

//DELAY_1:
	//SUB r0, r0, 10
	//QBNE DELAY_1, r0, 0
	//MOV r0, ON_DURATION
 
// CLK_D:
	SBBO r2, r4, 0, 4 	//keep clk pin low for data in (SRCLK)

DELAY_2:
	SUB r0, r0, 4
	QBNE DELAY_2, r0, 0
	MOV r0, ON_DURATION
	
// DATA_1:
	SBBO r6, r3, 0, 4   //keep data pin high for data in (SER)

DELAY_3:
	SUB r0, r0, 4
	QBNE DELAY_3, r0, 0
	MOV r0, ON_DURATION
 
// CLK_D:
	SBBO r2, r3, 0, 4 	//keep clk pin high for data in (SRCLK)

DELAY_4:
	SUB r0, r0, 4
	QBNE DELAY_4, r0, 0
	MOV r0, ON_DURATION	

// LATCH_IN:
	SBBO r5, r4, 0, 4 	// keep latch pin up(RCLK)
	
// DATA_1:
	SBBO r6, r4, 0, 4   //keep data pin high for data in (SER)
QBA DELAY_0
