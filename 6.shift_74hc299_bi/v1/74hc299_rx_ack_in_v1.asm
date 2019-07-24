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

#define INS_PER_MS    500 * 100
#define ON_DURATION   250 * INS_PER_MS
#define OFF_DURATION  250 * INS_PER_MS

#define CPRUCFG  c4

//STORE THE NO. OF TIME INPUT BUTTON TO STORE
#define NUMBER_OF_BITS 8

#define DS0     6   			/* P8_3  38 GPIO 1_6  mode 7 */
#define INPUT   7   			/* P8_4  39 GPIO 1_7  mode 7 */
#define OE	2   			/* P8_5  34 GPIO 1_2  mode 7 */ //OE1 AND OE2
#define S0      13  			/* P8_11 45 GPIO 1_13 mode 7 */
#define S1      12  			/* P8_12 44 GPIO 1_12 mode 7 */
#define MR      15  			/* P8_15 47 GPIO 1_15 mode 7 */
#define CP      14  			/* P8_16 46 GPIO 1_14 mode 7 */
#define CK_LED  31  			/* P8_20 63 GPIO 1_31 mode 7 */


//---------------------------------------------------------------------------------------
//***************************************************************************************
start:

	// Enable the OCP master port,

  	lbco r0, CPRUCFG, 4, 4   		// read SYSCFG
  	clr  r0.t4               		// clear SYSCFG[STANDBY_INIT]
  	sbco r0, CPRUCFG, 4, 4   		// enable OCP master port

  	// move the no of bits to be store in the memory
  	MOV r0, NUMBER_OF_BITS

	// STORE THE BIT DATA IN THE  REGISTER
	//TAKING THE REGISTER BIT AS(FROM LSB TO MSB)
	// TWO BITS BIT 0 ANS BIT 1 WILL BE COMMON IN BOTH CONTROL REGISTER MODE AND DATA REGISTER MODE
	// FOR CONTROL REGISTER BITS FOR MASTER (SENDING CTRL BITS FROM TX TO RX)
	// 	DESCRIPTION    		BIT NO.  		STATE
	//	CTRL/DATA MODE		0			1    (COMMON)
	//	ACK			1			0    (COMMON)
	//	STROBE			2			1
	//	RE/WR			3			0
	//	RES.			4			-
	//	RES.			5			-
	//	RES.			6			-
	//	RES.			7			-

	// FOR CONTROL REGISTER BITS FOR SLAVE (SENDING CTRL BITS FROM RX TO TX) FOR SUCCESSFUL HANDSAKING
	// 	DESCRIPTION    		BIT NO.  		STATE
	//	CTRL/DATA MODE		0			1    (COMMON)
	//	ACK			1			1    (COMMON)
	//	STROBE			2			0
	//	RE/WR			3			1
	//	RES.			4			-
	//	RES.			5			-
	//	RES.			6			-
	//	RES.			7			-

	// FOR DATA REGISTER BITS FROM MASTER (SENDING DATA FROM TX TO RX)
	// 	DESCRIPTION    		BIT NO.  		STATE
	//	CTRL/DATA MODE		0			0    (COMMON)
	//	ACK			1			0    (COMMON)
	//	DATA			2			-
	//	DATA			3			-
	//	DATA			4			-
	//	DATA			5			-
	//	DATA			6			-
	//	DATA			7			-


	// FOR DATA REGISTER BITS FROM SLAVE (SENDING DATA FROM TX TO RX)
	// 	DESCRIPTION    	BIT NO.  		STATE
	//	CTRL/DATA MODE		0			0    (COMMON)
	//	ACK			1			1    (COMMON)
	//	DATA			2			-
	//	DATA			3			-
	//	DATA			4			-
	//	DATA			5			-
	//	DATA			6			-
	//	DATA			7			-

//WAITING FOR ACK. (BIT 1) TO GET FROM THE RECEIVER SIDE FOR SUCCESSFUL TRANSMISSION AND MASTER IN PARALLEL LOAD MODE


	MOV r6.b0, 0b00000101 				// CONTROL BITS WHICH MAKES IT MASTER FOR COMMUNICATION
	MOV r6.b1, 0b00001011 				// CONTROL BITS WHICH MAKES IT SLAVE  FOR COMMUNICATION
  	MOV r6.b2, 0b00000010 				// SENDING THE DATA BIT TO FOR SUCCESFUL ACK OF DATA
  	MOV r6.b3, 0b00000000 				// MOVE 0 INITIAL VALUE TO R6


    MOV R10.b0 	, 0X5					//MOV 5 TO THE REGISTER ,IT IS THE NO. OF TIMES A LOOP FOR DATA STORAGE WILL RUN
	MOV R11 	, 0x0				//MOV O TO THE REGISTER
	
	//set DS0 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 6     				//DS0
	SBBO r2, r3, 0, 4

	//set S0 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 13    				//S0
	SBBO r2, r3, 0, 4

	//set S1 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 12    				//S1
	SBBO r2, r3, 0, 4		

	//set OE1 and OE2 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 2    				//OE1 and OE2
	SBBO r2, r3, 0, 4

	//set CP pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 14     				//CP
	SBBO r2, r3, 0, 4

	//set COMMON for Q0 and Q7 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	SET r2, r2, 7     				//INPUT
	SBBO r2, r3, 0, 4

	//set CHECK LED pin to ouput here
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 31     				//CHECK LED
	SBBO r2, r3, 0, 4

	//set MASTER RESET pin to ouput here
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 15     				//MASTER RESET
	SBBO r2, r3, 0, 4


	//setting the register for data high and   GPIO1
	MOV r4, GPIO1 | GPIO_CLEARDATAOUT
	MOV r5, GPIO1 | GPIO_SETDATAOUT
//---------------------------------------------------------------------------------------
//***************************************************************************************
	//RESETING THE SHIFT REGISTER FOR PARALLEL LOAD

RX_MRC:
	//Setting the value the out pin MR
	MOV  r2, 1 << 15     				//move out pin to
	SBBO r2, r4, 0, 4    				// the p8_15 pin is LOW
		
	CALL DELAY					// CALL THE DELAY FUNCTION

	//Setting the value the out pin MR
	MOV  r2, 1 << 15     				//move out pin to
	SBBO r2, r5, 0, 4    				// the p8_15 pin is HIGH

//---------------------------------------------------------------------------------------
//***************************************************************************************

//---------------------------------------------------------------------------------------
//***************************************************************************************
// SETTING THE REGISTER TO PARALLEL LOAD MODE
//INITIALIZATION OF pins
RX_LOAD:
	//Setting the value the out pin S0
	MOV  r2, 1 << 13 				//move out pin to
	SBBO r2, r5, 0, 4   				// the p8_11 pin is HIGH

	//Setting the value the out pin S1
	MOV  r2, 1 << 12  				//move out pin to
	SBBO r2, r5, 0, 4   				// the p8_12 pin is HIGH

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     				//move out pin to
	SBBO r2, r4, 0, 4   				// the P8_5 pin is LOW

	//Setting the value the out pin CP
	MOV  r2, 1 << 14    				//move out pin to
	SBBO r2, r4, 0, 4   				// the p8_16 pin is LOW
//***************************************************************************************
//    CHECKING IN THE DATA GIVEN BY RECEIVER SHIFT REGISTER

// perform a LOOP for delay of 1 sec just for testing
	CALL DELAY1					// CALL THE DELAY1 FUNCTION
// Rising edge of clock to load the data
	CALL CP_PULSE					// CALL FOR CLK PULSE

//---------------------------------------------------------------------------------------
//***************************************************************************************

//---------------------------------------------------------------------------------------
//***************************************************************************************
			// SETTING THE REGISTER TO SHIFT RIGHT MODE TO LOAD THE CONTROL REGISTER DATA
RX_STORE:
	//Setting the value   the out pin S1
	MOV  r2, 1 << 12  				//move out pin to
	SBBO r2, r4, 0, 4   				// the p8_12 pin is LOW

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     				//move out pin to
	SBBO r2, r5, 0, 4    				// the P8_5 pin is HIGH
	
	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    				//move out pin to
	SBBO r2, r4, 0, 4   				// the p8_3 pin is LOW

//***************************************************************************************
//DATA NOW GET OUT FROM THE Q7 PIN OF THE SHIFT REGISTER
	// AS THE DATA IS BEING LOADED FROM THE SHIFT REGISTER TO PRU REGISTER IN SHIFT RIGHT MODE
	// move the no of bits as 8 to be store for running the loop
	MOV r0		, NUMBER_OF_BITS
    MOV R9.b0  	, 0X0					//MOV O TO THE REGISTER

BIT_D:
	CALL CP_PULSE					// CALL FOR CLK PULSE

	//set IN pin to INPUT FOR Q7 PIN INPUT
	MOV  r3, GPIO1 | GPIO_DATAIN
	LBBO r7, r3, 0, 4				// P8_04
	MOV  R7, R7 >> 7

	OR  R9, R7, R9
	MOV R9, R9 << 1

	SUB r0, r0, 1
	QBEQ RX_TEST, r0, 0
	QBNE BIT_D, r0, 0

//---------------------------------------------------------------------------------------
//THE DATA GET LOADED TO THE REGISTER R9
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//***************************************************************************************
	//TESTING FOR THE HIGH BIT 0 ctrl BIT AT BIT 1 IN REGISTER R9

RX_TEST:
	MOV  R11.b1, R9.b0				// STORE THE SLAVE BIT FOR REFERNCE
	QBBC RX_MR, r11.t8				// if the bit is low, jump to RX_MR (MASTER RESET AND AGAIN TEST IT)

//---------------------------------------------------------------------------------------
//***************************************************************************************

RX_ACK:
	// LOAD THE DATA INTO THE SHIFT REGISTER IN SHIFT RIGHT MODE
	//Setting the value the out pin S1
	MOV  r2, 1 << 12     				//move out pin to
	SBBO r2, r4, 0, 4    				// the p8_12 pin is LOW

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     				//move out pin to
	SBBO r2, r5, 0, 4    				// the P8_5 pin is HIGH

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    				//move out pin to
	SBBO r2, r4, 0, 4   				// the p8_3 pin is LOW
//***************************************************************************************
	//NOW THE DATA is being written TO THE  SHIFT REGISTER

	// THE MODE OF 74HC299 FROM LOAD TO SHIFT RIGHT MODE
	MOV r0, NUMBER_OF_BITS
L_OUT2:
	// NOW THE DATA STORE IN THE REGISTER IS MADE TO THE DATA PIN OF THE SHIFT REGISTER R6
	CALL DELAY					// CALL THE DELAY FUNCTION
	CALL CP_PULSE					// CALL FOR CLK PULSE

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    				//move out pin to
	SBBO r2, r4, 0, 4   				// the p8_3 pin is LOW
//***************************************************************************************
	QBBS RX_CTRL, R9.t0
	QBBC RX_ACKB , R9.t0

RX_CTRL:
	QBBC RX_SLV , R9.t2
	QBBS RX_MAS , R9.t2
RX_SLV:
	//CHECK FOR THE CONTROL BIT WRITTING TO THE SLAVE SHIFT REGISTER
   	QBBS DATA_SET, r6.t15    			// if the bit is high, jump to BIT_HIGH
   	QBBC DATA_CLR, r6.t15        			// if the bit is low,  jump to BIT_LOW
RX_MAS:
	//CHECK FOR THE CONTROL BIT WRITTING TO THE MASTER SHIFT REGISTER
  	QBBS DATA_SET, r6.t7    			// if the bit is high, jump to BIT_HIGH
  	QBBC DATA_CLR, r6.t7        			// if the bit is low,  jump to BIT_LOW
RX_ACKB:
	//CHECK FOR THE CONTROL BIT WRITTING TO THE SLAVE SHIFT REGISTER
   	QBBS RX_ASET, r6.t23    			// if the bit is high, jump to BIT_HIGH
   	QBBC RX_ACLR, r6.t23        			// if the bit is low,  jump to BIT_LOW
//***************************************************************************************

DATA_SET:
	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    				//move out pin to
	SBBO r2, r5, 0, 4   				// the p8_3 pin is HIGH

	//shift the bit store in the r6 to the RIGHT
	LSL  r6, r6, 1
	// decrement the value of bits to be store and check its value
	SUB  r0, r0, 1
	QBEQ OUT_E, r0, 0
	QBNE L_OUT2, r0, 0

DATA_CLR:
	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    				//move out pin to
	SBBO r2, r4, 0, 4   				// the p8_3 pin is LOW

	//shift the bit store in the r6 to the RIGHT
	LSL  r6, r6, 1
	// decrement the value of bits to be store and check its value
	SUB  r0, r0, 1
	QBEQ OUT_E, r0, 0
	QBNE L_OUT2, r0, 0

//***************************************************************************************
// CHANGING THE STATE OF THE ENABLE PIN

OUT_E:
	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    				//move out pin to
	SBBO r2, r4, 0, 4   				// the p8_3 pin is LOW

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     				//move out pin to
	SBBO r2, r4, 0, 4   				// the P8_5 pin is LOW

	CALL DELAY					// CALL THE DELAY FUNCTION
	CALL CP_PULSE					// CALL FOR CLK PULSE

	QBEQ EXIT , R10.b0, 0				// THIS SHOWS THAT ALL THE DATA IS RECEIVED
   	QBBS RX_MRC, r11.t0    				// if the bit is high, jump to BIT_HIGH
   	QBBC RX_MRD, r11.t0        			// if the bit is low,  jump to BIT_LOW
//***************************************************************************************
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//***************************************************************************************
	//RESETING THE SHIFT REGISTER FOR PARALLEL LOAD FOR STORING THE DATA BITS

RX_MRD:
	//Setting the value the out pin MR
	MOV  r2, 1 << 15     				//move out pin to
	SBBO r2, r4, 0, 4    				// the p8_15 pin is LOW

	CALL DELAY					// CALL THE DELAY FUNCTION
	//Setting the value the out pin MR
	MOV  r2, 1 << 15     				//move out pin to
	SBBO r2, r5, 0, 4    				// the p8_15 pin is HIGH

//---------------------------------------------------------------------------------------
//***************************************************************************************
// SETTING THE REGISTER TO PARALLEL LOAD MODE FOR STORING THE DATA BITS
//
RX_DATA:
	//Setting the value the out pin S1
	MOV  r2, 1 << 12  				//move out pin to
	SBBO r2, r5, 0, 4   				// the p8_12 pin is HIGH

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     				//move out pin to
	SBBO r2, r4, 0, 4   				// the P8_5 pin is LOW
//***************************************************************************************
//    CHECKING IN THE DATA GIVEN BY RECEIVER SHIFT REGISTER

	CALL DELAY1					// CALL THE DELAY1 FUNCTION
	CALL CP_PULSE					// CALL FOR CLK PULSE
//---------------------------------------------------------------------------------------
//***************************************************************************************
// SETTING THE REGISTER TO SHIFT RIGHT MODE TO LOAD THE DATA BITS
RX_DATAS:
	//Setting the value   the out pin S1
	MOV  r2, 1 << 12  				//move out pin to
	SBBO r2, r4, 0, 4   				// the p8_12 pin is LOW

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     				//move out pin to
	SBBO r2, r5, 0, 4    					// the P8_5 pin is HIGH

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    				//move out pin to
	SBBO r2, r4, 0, 4   				// the 	p8_3 pin is LOW
	//DATA NOW GET OUT FROM THE Q0 PIN OF THE SHIFT REGISTER

//***************************************************************************************
	// move the no of bits to be store in the memory OR THE NO. OF TIMES LOOP RUNS
	MOV r0, NUMBER_OF_BITS

	// AS THE DATA IS BEING LOADED FROM THE SHIFT REGISTER TO PRU REGISTER IN SHIFT LEFT MODE

DBIT_D:
	CALL CP_PULSE					// CALL FOR CLK PULSE

	//set IN pin to INPUT FOR Q7 PIN INPUT
	MOV  r3, GPIO1 | GPIO_DATAIN
	LBBO r7, r3, 0, 4				// P8_04
	MOV  R7, R7 >> 7

	OR  R9, R7, R9
	MOV R9, R9 << 1

	SUB r0, r0, 1
	QBEQ RX_DTEST, r0, 0
	QBNE DBIT_D, r0, 0

RX_DTEST1:
	MOV R11.b0  , R9.b0
	QBBC RX_MRD , r11.t1				// if the bit is low,  jump to RX_MRD (MASTER RESET AND AGAIN TEST IT FOR DATA BITS)
	MOV R10.b1	, 0X6				// THIS LOOP WILL RUN FOR 6 TIME TO STORE ALL SIX BIT OF DATA IN ONE REGISTER OF PRU
	QBEQ RX_WR2 , R10.b0, 0				// THIS SHOWS THAT ALL THE DATA IS RECEIVED

//---------------------------------------------------------------------------------------
//***************************************************************************************

//---------------------------------------------------------------------------------------
//***************************************************************************************

	//WRITING THE DATA IN THE THE STORAGE REGISTER
	//ONLY THE 6 BIT OF DATA IS OF USE OTHER DATA BIT LIKE BIT 0 IS MODE BIT AND BIT 1 IS ACK BIT
	//WHICH IS COMMON TO BOTH THE COMMAND AND DATA MODE

	//WRITE THE DATA BITS IN THE REGISTER R12
RX_WR1:
	MOV R12.t0, r11.t2
	LSL R12, R12, 1
	LSL R11, R11, 1

	SUB R10.b1, R10.b1, 1
	QBNE RX_WR1, r0, 0
	SUB R10.b0, R10.b0, 1			//DECREASE THE VALUE BY ONE AS 6 BIT OF DATA WILL COME OUT FOR ONLY FIVE TIME LAST TIME 2 BIT OF
    							//DATA BIT WILL ARRIVE
							// TELL THE TX THAT DATA IS BEIGN RECEIVED
	JMP RX_ACK					//RETURN TO THE ACK FUNCTION
//WRITE THE DATA BITS IN THE REGISTER R12 FOR LAST 2 BIT OF DATA
RX_WR2:
	MOV R12.t0, r11.t2
	LSL R12, R12, 1
//BY THIS STEP ALL THE 32 BIT OF DATA  WILL GET FILL IN THE R12 REGISTER THAT IS TX FROM OTHER BB BLACK
	MOV R12.t0, r11.t3

	JMP RX_ACK					//RETURN TO THE ACK FUNCTION

//---------------------------------------------------------------------------------------
//***************************************************************************************

// THIS WILL SEND THE HIGH ACK AT BIT 1 OF THE SHIFT REGISTER TELLING THAT IT HAD RECEIVED THE DATA CORRECTLY
//-------------------------------------------------------------------------------------------------
// THIS IS THE HALT OF THE PROGRAM WITH SUSSESSFUL INDICATION SHOWS  BLINKING OF LIGHT AT P8_20 PIN
EXIT:
	//Setting the value   the out pin CHECK LED
	MOV  r2, 1 << 31    				//move out pin to
	SBBO r2, r5, 0, 4   				// the p8_20 pin is HIGH

	HALT
//---------------------------------------------------------------------------------------
//***************************************************************************************

// CALL FUNCTION HERE
//	CALL FOR A DELAY
DELAY:
		MOV r1, OFF_DURATION        	 	// set up for  the delay
	LRR:
		SUB r1,r1, 1                 		// subtract 1 from R1
		QBNE LRR, r1, 0
	RET

// perform a BIG LOOP for delay
DELAY1:
		MOV r1, OFF_DURATION        	 	// set up for delay
	LRR1:
		SUB r1, r1, 1                		// subtract 1 from R1
		MOV r8, 4                    		//RUN THE LOOP 4 TIMES
	LRR2:
		SUB r8, r8, 1                		// subtract 1 from R1
    	QBNE LRR2, r8, 0           			// is R8 == 0? if no, then goto LRR2
    	QBNE LRR1, r1, 0           			// is R1 == 0? if no, then goto LRR1
	RET

// CALL FOR CLK PULSE
CP_PULSE:
		//Setting the value the out pin CP
		MOV  r2, 1 << 14    			//move out pin to
		SBBO r2, r5, 0, 4   			// the p8_16 pin is HIGH

		MOV r1, OFF_DURATION         		// set up for  the delay
	DELAY3:	
		SUB r1,r1, 1                 		// subtract 1 from R1
		QBNE DELAY3, r1, 0

		//Setting the value the out pin CP
		MOV  r2, 1 << 14    			//move out pin to
		SBBO r2, r4, 0, 4   			// the p8_16 pin is LOW

		MOV r1, OFF_DURATION         		// set up for  the delay
	DELAY4:
		SUB r1,r1, 1                 		// subtract 1 from R1
		QBNE DELAY4, r1, 0

	RET

