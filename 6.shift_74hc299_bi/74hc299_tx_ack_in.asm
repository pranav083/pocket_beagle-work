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
#define OE		2   			/* P8_5  34 GPIO 1_2  mode 7 */ //OE1 AND OE2
#define S0      13  			/* P8_11 45 GPIO 1_13 mode 7 */
#define S1      12  			/* P8_12 44 GPIO 1_12 mode 7 */
#define MR      15  			/* P8_15 47 GPIO 1_15 mode 7 */
#define CP      14  			/* P8_16 46 GPIO 1_14 mode 7 */
#define CK_LED  31  			/* P8_20 63 GPIO 1_31 mode 7 */


//---------------------------------------------------------------------------------------
//***************************************************************************************
start:

	// Enable the OCP master port,

  	lbco r0, CPRUCFG, 4, 4   	// read SYSCFG
  	clr  r0.t4               	// clear SYSCFG[STANDBY_INIT]
  	sbco r0, CPRUCFG, 4, 4   	// enable OCP master port

  	// move the no of bits to be store in the memory
  	MOV r0, NUMBER_OF_BITS

	// STORE THE BIT DATA IN THE  REGISTER
	//TAKING THE REGISTER BIT AS(FROM LSB TO MSB)
	// TWO BITS BIT 0 ANS BIT 1 WILL BE COMMON IN BOTH CONTROL REGISTER MODE AND DATA REGISTER MODE
	// FOR CONTROL REGISTER BITS FOR MASTER (SENDING CTRL BITS FROM TX TO RX)
	// DESCRIPTION    		BIT NO.    		STATE
	//	CTRL/DATA MODE		0			1    (COMMON to control and data line)
	//	ACK			1			0    (COMMON to control and data line)
	//	STROBE			2			1
	//	RE/WR			3			0
	//	RES.			4			-
	//	RES.			5			-
	//	RES.			6			-
	//	RES.			7			-

	// FOR CONTROL REGISTER BITS FOR SLAVE (SENDING CTRL BITS FROM RX TO TX) FOR SUCCESSFUL HANDSAKING
	// DESCRIPTION   		 BIT NO.    		STATE
	//	CTRL/DATA MODE		0			1    (COMMON)
	//	ACK			1			1    (COMMON)
	//	STROBE			2			0
	//	RE/WR			3			1
	//	RES.			4			-
	//	RES.			5			-
	//	RES.			6			-
	//	RES.			7			-

	// FOR DATA REGISTER BITS FOR MASTER (SENDING DATA FROM TX TO RX)
	// DESCRIPTION    		BIT NO.    		STATE
	//	CTRL/DATA MODE		0			0    (COMMON)
	//	ACK			1			1    (COMMON)
	//	DATA			2			-
	//	DATA			3			-
	//	DATA			4			-
	//	DATA			5			-
	//	DATA			6			-
	//	DATA			7			-


	// FOR DATA REGISTER BITS FOR MASTER (SENDING DATA FROM TX TO RX)
	// DESCRIPTION    		BIT NO.    		STATE
	//	CTRL/DATA MODE		0			0    (COMMON)
	//	ACK			1			0    (COMMON)
	//	DATA			2			-
	//	DATA			3			-
	//	DATA			4			-
	//	DATA			5			-
	//	DATA			6			-
	//	DATA			7			-

//WAITING FOR ACK. (BIT 1) TO GET FROM THE RECEIVER SIDE FOR SUCCESSFUL TRANSMISSION AND MASTER IN PARALLEL LOAD MODE


	MOV r6.b0, 0b00000101 		// CONTROL BITS WHICH MAKES IT MASTER FOR COMMUNICATION
	MOV r6.b1, 0b00001011 		// CONTROL BITS WHICH MAKES IT SLAVE  FOR COMMUNICATION
  	MOV r6.b2, 0b00000010 		// COMPARING THE DATA BIT TO FOR SUCCESFUL ACK OF DATA
  	MOV r6.b3, 0b00000000 		// MOVE 0 INITIAL VALUE TO R6


//example data of the register that will be transfer via shift register
	MOV R10 , 0xf0f0f0f0

	//set DS0 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 6     		//DS0
	SBBO r2, r3, 0, 4

	//set S0 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 13    		//S0
	SBBO r2, r3, 0, 4

	//set S1 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 12    		//S1
	SBBO r2, r3, 0, 4

	//set OE1 and OE2 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 2    		//OE1 and OE2
	SBBO r2, r3, 0, 4

	//set CP pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 14     		//CP
	SBBO r2, r3, 0, 4

	//set COMMON for Q0 and Q7 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	SET r2, r2, 7     		//INPUT
	SBBO r2, r3, 0, 4

	//set CHECK LED pin to ouput here
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 31     		//CHECK LED  //MR
	SBBO r2, r3, 0, 4

	//set MASTER RESET pin to ouput here
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 15     		//MASTER RESET
	SBBO r2, r3, 0, 4


	//setting the register for data high and   GPIO1
	MOV r4, GPIO1 | GPIO_CLEARDATAOUT
	MOV r5, GPIO1 | GPIO_SETDATAOUT

//---------------------------------------------------------------------------------------
//***************************************************************************************

	// LOAD THE INPUT SHIFT REGISTER IN SHIFT RIGHT MODE

	//Setting the value the out pin S0
	MOV  r2, 1 << 13     		//move out pin to
	SBBO r2, r5, 0, 4    		// the p8_11 pin is HIGH

	//Setting the value the out pin S1
	MOV  r2, 1 << 12     		//move out pin to
	SBBO r2, r4, 0, 4    		// the p8_12 pin is LOW

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     		//move out pin to
	SBBO r2, r5, 0, 4    		// the p8_11 pin is HIGH

	//Setting the value the out pin MR
	MOV  r2, 1 << 31     		//move out pin to
	SBBO r2, r5, 0, 4    		// the p8_15 pin is HIGH

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    			//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_3 pin is LOW
//***************************************************************************************
	//NOW THE DATA OUT MODE TO THE LED CONNECTED FIRST REGISTER

	// THE MODE OF 74HC299 FROM LOAD TO SHIFT RIGHT MODE

	// SETTING UP THE DELAY
	MOV r1,OFF_DURATION             // set up for  the delay

    	// perform a LOOP for delay
LM2:
	SUB r1, r1, 1               // subtract 1 from R1
	QBNE LM2, r1, 0             // is R1 == 0? if no, then goto L1

L_OUT2:
	// NOW THE DATA STORE IN THE REGISTER IS MADE TO THE DATA PIN OF THE SHIFT REGISTER R6


	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to
	SBBO r2, r5, 0, 4   		// the p8_16 pin is HIGH

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    			//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_3 pin is LOW

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION        // set up for  the delay

    // perform a LOOP for delay
LM3:
	SUB r1, r1, 1               // subtract 1 from R1
   	QBNE LM3, r1, 0             // is R1 == 0? if no, then goto L1

	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_16 pin is LOW


//***************************************************************************************
JUMP_MAS:
	//CHECK FOR THE CONTROL BIT WRITTING TO THE MASTER SHIFT REGISTER
   	QBBS DATA_SET, r6.t7    	// if the bit is high, jump to BIT_HIGH
   	QBBC DATA_CLR, r6.t7        // if the bit is low,  jump to BIT_LOW

JUMP_SLV:
	//CHECK FOR THE CONTROL BIT WRITTING TO THE SLAVE SHIFT REGISTER
   	QBBS DATA_SET, r6.t7    	// if the bit is high, jump to BIT_HIGH
   	QBBC DATA_CLR, r6.t7        // if the bit is low,  jump to BIT_LOW
//***************************************************************************************

DATA_SET:

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    			//move out pin to
	SBBO r2, r5, 0, 4   		// the p8_3 pin is HIGH

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION         // set up for  the delay

    	// perform a LOOP for delay
LM4:
	SUB r1, r1, 1               // subtract 1 from R1
    QBNE LM4, r1, 0             // is R1 == 0? if no, then goto L1

	//shift the bit store in the r6 to the RIGHT
	LSL  r6, r6, 1

	// decrement the value of bits to be store and check its value
	SUB  r0, r0, 1
    QBEQ OUT_E, r0, 0
    QBNE L_OUT2, r0, 0

DATA_CLR:

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_3 pin is LOW

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION            // set up for  the delay
    	// perform a LOOP for delay

LM5:
	SUB r1, r1, 1                   // subtract 1 from R1
	QBNE LM5, r1, 0                  // is R1 == 0? if no, then goto L1

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
	MOV  r2, 1 << 6    			//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_3 pin is LOW

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_11 pin is LOW

	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to
	SBBO r2, r5, 0, 4   		// the p8_16 pin is HIGH

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION        // set up for a .9 second delay

    // perform a LOOP for delay
LE1:
	SUB r1, r1, 1                // subtract 1 from R1

	// SETTING UP THE DELAY
	MOV r8, 10                      		//RUN THE LOOP 4 TIMES
LE2:
	SUB r8, r8, 1                       	// subtract 1 from R1
    QBNE LE2, r8, 0                      	// is R8 == 0? if no, then goto L1
    QBNE LE1, r1, 0              // is R1 == 0? if no, then goto L1


	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_16 pin is LOW


//---------------------------------------------------------------------------------------
//***************************************************************************************
	//RESETING THE SHIFT REGISTER FOR PARALLEL LOAD

TX_MR:
	//Setting the value the out pin MR
	MOV  r2, 1 << 31     		//move out pin to
	SBBO r2, r5, 0, 4    		// the p8_20 pin is LOW

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION            // set up for  the delay
    	// perform a LOOP for delay

LMR1:
	SUB r1, r1, 1                   // subtract 1 from R1
	QBNE LMR1, r1, 0                  // is R1 == 0? if no, then goto L1


	//Setting the value the out pin MR
	MOV  r2, 1 << 31     		//move out pin to
	SBBO r2, r5, 0, 4    		// the p8_20 pin is HIGH


//---------------------------------------------------------------------------------------
//***************************************************************************************
			// SETTING THE REGISTER TO PARALLEL LOAD MODE
			//
TX_LOAD:
	//Setting the value the out pin S0
	MOV  r2, 1 << 13 			//move out pin to
	SBBO r2, r5, 0, 4   			// the p8_11 pin is HIGH

	//Setting the value the out pin S1
	MOV  r2, 1 << 12  			//move out pin to
	SBBO r2, r5, 0, 4   			// the p8_12 pin is HIGH

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_11 pin is LOW


	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    			//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_3 pin is LOW
//***************************************************************************************

	//Setting the value the out pin CP
	MOV  r2, 1 << 14    			//move out pin to
	SBBO r2, r5, 0, 4   			// the p8_16 pin is HIGH

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION            // set up for  the delay
    	// perform a LOOP for delay

LTL1:
	SUB r1, r1, 1                    // subtract 1 from R1
	QBNE LTL1, r1, 0                  // is R1 == 0? if no, then goto L1

	//Setting the value the out pin CP
	MOV  r2, 1 << 14    			//move out pin to
	SBBO r2, r4, 0, 4   			// the p8_16 pin is LOW

//***************************************************************************************
//    CLKING IN THE DATA GIVEN BY RECEIVER SHIFT REGISTER

	// SETTING UP THE DELAY
	MOV r1, ON_DURATION        // set up for a .9 second delay

    // perform a LOOP for delay
LTL2:
	SUB r1, r1, 1                // subtract 1 from R1

	// SETTING UP THE DELAY
	MOV r8, 4                      		//RUN THE LOOP 4 TIMES

        // perform a LOOP for delay
LTL3:
	SUB r8, r8, 1                       	// subtract 1 from R1
    QBNE LTL3, r8, 0                      	// is R8 == 0? if no, then goto L1

    QBNE LTL2, r1, 0              // is R1 == 0? if no, then goto L1

	//Setting the value the out pin CP
	MOV  r2, 1 << 14    			//move out pin to
	SBBO r2, r5, 0, 4   			// the p8_16 pin is HIGH

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION            // set up for  the delay
    	// perform a LOOP for delay

LTL4:
	SUB r1, r1, 1                    // subtract 1 from R1
	QBNE LTL4, r1, 0                  // is R1 == 0? if no, then goto L1

	//Setting the value the out pin CP
	MOV  r2, 1 << 14    			//move out pin to
	SBBO r2, r4, 0, 4   			// the p8_16 pin is LOW

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION            // set up for  the delay
    	// perform a LOOP for delay

LTL5:
	SUB r1, r1, 1                    // subtract 1 from R1
	QBNE LTL5, r1, 0                  // is R1 == 0? if no, then goto L1

//---------------------------------------------------------------------------------------
//***************************************************************************************
			// SETTING THE REGISTER TO SHIFT LEFT MODE TO LOAD THE ACK DATA
TX_STORE:

	//Setting the value   the out pin S0
	MOV  r2, 1 << 13  			//move out pin to
	SBBO r2, r5, 0, 4   		// the p8_11 pin is HIGH

	//Setting the value   the out pin S1
	MOV  r2, 1 << 12  			//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_12 pin is LOW

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     		//move out pin to
	SBBO r2, r4, 0, 4    		// the p8_11 pin is HIGH


	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    			//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_3 pin is LOW
	//DATA NOW GET OUT FROM THE Q0 PIN OF THE SHIFT REGISTER

//***************************************************************************************

	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to
	SBBO r2, r5, 0, 4   		// the p8_16 pin is HIGH

	MOV r1,OFF_DURATION 			// set up for a delay

    // perform a half second delay
LTS1:
     SUB r1, r1, 1				// subtract 1 from R1
     QBNE LTS1, r1, 0				// is R1 == 0? if no, then goto L1


	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_16 pin is LOW

	// move the no of bits to be store in the memory
	MOV r0, 8

	// AS THE DATA IS BEING LOADED FROM THE SHIFT REGISTER TO PRU REGISTER IN SHIFT LEFT MODE

	MOV r1,OFF_DURATION 			// set up for a delay

        // perform a half second delay
LTS2:
     SUB r1, r1, 1				// subtract 1 from R1
     QBNE LTS2, r1, 0				// is R1 == 0? if no, then goto L1

BIT_D:

	//Setting the value the out pin CP
	MOV  r2, 1 << 14			//move out pin to
	SBBO r2, r5, 0, 4			// the p8_16 pin is HIGH

	//set IN pin to INPUT
	MOV  r3, GPIO1 | GPIO_DATAIN
	LBBO r7, r3, 0, 7			// P8_04

    MOV r1, OFF_DURATION 			// set up of delay

LTS3:
	SUB r1, r1, 1				// subtract 1 from R1
    QBNE LTS3, r1, 0				// is R1 == 0? if no, then goto L1

	//Setting the value the out pin CP
	MOV  r2, 1 << 14			//move out pin to
	SBBO r2, r4, 0, 4			// the p8_16 pin is LOW


    // TAKE THE ACK BIT INTO THE REGISTER FOR THE CONFORMATION OF HAND SAKING
	QBBS BIT_SET, r7.t0			// if the bit is high, jump to LED_HIGH
	QBBC BIT_CLR, r7.t0			// if the bit is low,  jump to LED_LOW


	// STORE 1 VALUE IN THE REGISTER
BIT_SET:
	//PERFORM THE LEFT SHIFT OPERATION ON THE REGISTER R6
	LSL r9, r9, 1

    ADD  r9, r9.b0, 0b00000001

    MOV r1, OFF_DURATION 			// set up of delay

LTS4:
 	SUB r1, r1, 1				// subtract 1 from R1
    QBNE LTS4, r1, 0				// is R1 == 0? if no, then goto L1


    SUB r0, r0, 1
    QBEQ TX_TEST, r0, 0
    QBNE BIT_D, r0, 0

	//STORE 0 VALUE IN THE REGISTER
BIT_CLR:
	//PERFORM THE LEFT SHIFT OPERATION ON THE REGISTER R6
	LSL r9, r9, 1

    MOV r1, OFF_DURATION 			// set up of delay

LTS5:
	SUB r1, r1, 1				// subtract 1 from R1
    QBNE LTS5, r1, 0				// is R1 == 0? if no, then goto L1

    SUB r0, r0, 1
    QBEQ TX_TEST, r0, 0
    QBNE BIT_D, r0, 0

//---------------------------------------------------------------------------------------
//THE DATA GET LOADED TO THE REGISTER R9
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//***************************************************************************************

	//TESTING FOR THE HIGH BIT 1 ACK BIT AT BIT 1 IN REGISTER R9

TX_TEST:


	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     		//move out pin to
	SBBO r2, r4, 0, 4    		// the p8_11 pin is HIGH


	QBBC TX_MR, r9.t1			// if the bit is low,  jump to TX_MR (MASTER RESET AND AGAIN TEST IT)

//---------------------------------------------------------------------------------------
//***************************************************************************************
TX_DATA:

   	// AS THE ACK IS IS RECEIVED ITS FOR THE DATA TRANSMISSION
   	//FOR 8 BIT SHIFT REGISTER DATA IS TRANMITTED 6 BIT AT A TIME
	// OTHER TWO BIT ARE RESERVED FOR ack AND control/data MODE SIGNAL

	// LOAD THE INPUT SHIFT REGISTER IN SHIFT RIGHT MODE

	//Setting the value the out pin S0
	MOV  r2, 1 << 13     		//move out pin to
	SBBO r2, r5, 0, 4    		// the p8_11 pin is HIGH

	//Setting the value the out pin S1
	MOV  r2, 1 << 12     		//move out pin to
	SBBO r2, r4, 0, 4    		// the p8_12 pin is LOW

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     		//move out pin to
	SBBO r2, r5, 0, 4    		// the p8_11 pin is HIGH

	//Setting the value the out pin MR
	MOV  r2, 1 << 31     		//move out pin to
	SBBO r2, r5, 0, 4    		// the p8_15 pin is HIGH

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    			//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_3 pin is LOW

//***************************************************************************************
	//NOW THE DATA IS TRANSMIT TO OTHER BEAGLEBONE PRU REGISTER

	// THE MODE OF 74HC299 FROM LOAD TO SHIFT RIGHT MODE

	//LENGTH OF DATA TO BE TRANSFER
	MOV R0, 32

	// SETTING UP THE DELAY
	MOV r1,OFF_DURATION             // set up for  the delay

    	// perform a LOOP for delay
LD1:
	SUB r1, r1, 1               // subtract 1 from R1
	QBNE LD1, r1, 0             // is R1 == 0? if no, then goto L1

TX_OUT1:
	// NOW THE DATA STORE IN THE REGISTER IS MADE TO THE DATA PIN OF THE SHIFT REGISTER R6


	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to
	SBBO r2, r5, 0, 4   		// the p8_16 pin is HIGH

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    			//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_3 pin is LOW

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION        // set up for  the delay

    // perform a LOOP for delay
LD3:
	SUB r1, r1, 1               // subtract 1 from R1
   	QBNE LD3, r1, 0             // is R1 == 0? if no, then goto L1

	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_16 pin is LOW


//***************************************************************************************
JUMP_DATA:
	//CHECK FOR THE CONTROL BIT WRITTING TO THE MASTER SHIFT REGISTER
   	QBBS DATA_S, r10.t5    	// if the bit is high, jump to BIT_HIGH
   	QBBC DATA_C, r10.t5        // if the bit is low,  jump to BIT_LOW

//***************************************************************************************

DATA_SET:

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    			//move out pin to
	SBBO r2, r5, 0, 4   		// the p8_3 pin is HIGH

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION         // set up for  the delay

    	// perform a LOOP for delay
LM4:
	SUB r1, r1, 1               // subtract 1 from R1
    QBNE LM4, r1, 0             // is R1 == 0? if no, then goto L1

	//shift the bit store in the r6 to the RIGHT
	LSL  r6, r6, 1

	// decrement the value of bits to be store and check its value
	SUB  r0, r0, 1
    QBEQ EXIT, r0, 0
    QBNE TX_OUT1, r0, 0

DATA_CLR:

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_3 pin is LOW

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION            // set up for  the delay
    	// perform a LOOP for delay

LM5:
	SUB r1, r1, 1                   // subtract 1 from R1
	QBNE LM5, r1, 0                  // is R1 == 0? if no, then goto L1

	//shift the bit store in the r6 to the RIGHT
	LSL  r6, r6, 1

	// decrement the value of bits to be store and check its value
	SUB  r0, r0, 1
	QBEQ EXIT, r0, 0
    QBNE TX_OUT1, r0, 0

//***************************************************************************************
// CHANGING THE STATE OF THE ENABLE PIN

OUT_E:
	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    			//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_3 pin is LOW

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_11 pin is LOW

	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to
	SBBO r2, r5, 0, 4   		// the p8_16 pin is HIGH

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION        // set up for a .9 second delay

    // perform a LOOP for delay
LE1:
	SUB r1, r1, 1                // subtract 1 from R1

	// SETTING UP THE DELAY
	MOV r8, 10                      		//RUN THE LOOP 4 TIMES
LE2:
	SUB r8, r8, 1                       	// subtract 1 from R1
    QBNE LE2, r8, 0                      	// is R8 == 0? if no, then goto L1
    QBNE LE1, r1, 0              // is R1 == 0? if no, then goto L1


	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_16 pin is LOW






//-------------------------------------------------------------------------------------------------
// THIS IS THE HALT OF THE PROGRAM WITH SUSSESSFUL INDICATION SHOWS  BLINKING OF LIGHT AT P8_20 PIN
EXIT:
	//Setting the value   the out pin CHECK LED
	MOV  r2, 1 << 15    			//move out pin to
	SBBO r2, r5, 0, 4   			// the p8_20 pin is HIGH

	HALT

