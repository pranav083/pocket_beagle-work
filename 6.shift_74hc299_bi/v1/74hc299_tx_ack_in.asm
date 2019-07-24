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
	// 	DESCRIPTION    		BIT NO.  		STATE
	//	CTRL/DATA MODE		0			0    (COMMON)
	//	ACK			1			1    (COMMON)
	//	DATA			2			-
	//	DATA			3			-
	//	DATA			4			-
	//	DATA			5			-
	//	DATA			6			-
	//	DATA			7			-

//----------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------


// THESE ARE COMMON FOR BOTH rx AND tx
	MOV r6.b0, 0b00000101 		// CONTROL BITS WHICH MAKES IT MASTER FOR COMMUNICATION
	MOV r6.b1, 0b00001011 		// CONTROL BITS WHICH MAKES IT SLAVE  FOR COMMUNICATION
  	MOV r6.b2, 0b00000010 		// SENDING THE DATA BIT TO FOR SUCCESFUL ACK OF DATA
  	MOV r6.b3, 0b00000001 		// SENDING TO SHIFT THE SYSTEM TO CONTROL MODE


//example data of the register that will be transfer via shift register
    MOV R9  	, 0X0				//MOV O TO THE REGISTER
    MOV R10.b0 	, 0X7				//MOV 7 TO THE REGISTER ,AS THE DATA NEED TO SENT 6 TIMES AND ACK NEED TO RECEIVE 7 TIMES
	MOV R11.b0 	, 0b00000000		//MOV O TO THE REGISTER
	MOV R12 	, 0X0F0F0F0F		//MOV THE DATA THAT NEED TO BE SENT


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

	//set COMMON for Q0 and Q7 pin to INPUT
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	SET r2, r2, 7     		//INPUT
	SBBO r2, r3, 0, 4

	//set CHECK LED pin to ouput here
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 31     		//CHECK LED
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
		//LOAD THE CONTROL BITS IN SHIFT REGISTER
TX_CLOAD:
	// LOAD THE INPUT SHIFT REGISTER IN SHIFT RIGHT MODE

	//Setting the value the out pin S0
	MOV  r2, 1 << 13     		//move out pin to
	SBBO r2, r5, 0, 4    		// the p8_11 pin is HIGH

	//Setting the value the out pin S1
	MOV  r2, 1 << 12     		//move out pin to
	SBBO r2, r4, 0, 4    		// the p8_12 pin is LOW

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     		//move out pin to
	SBBO r2, r5, 0, 4    		// the p8_5 pin is HIGH

	//Setting the value the out pin MR
	MOV  r2, 1 << 15     		//move out pin to
	SBBO r2, r5, 0, 4    		// the p8_15 pin is HIGH

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    			//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_3 pin is LOW

	//Setting the value   the out pin CHECK LED
	MOV  r2, 1 << 31    			//move out pin to
	SBBO r2, r5, 0, 4   			// the p8_20 pin is HIGH
//***************************************************************************************
	//NOW THE DATA OUT MODE TO THE CONNECTED SHIFT REGISTER FORN BEING USED AS TX

	// THE MODE OF 74HC299 FROM LOAD TO SHIFT RIGHT MODE

	// SETTING UP THE DELAY
	MOV r1,OFF_DURATION             // set up for  the delay

    	// perform a LOOP for delay
LTCM2:
	SUB r1, r1, 1               // subtract 1 from R1
	QBNE LTCM2, r1, 0             // is R1 == 0? if no, then goto L1

TX_OUT2:
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
LTCM3:
	SUB r1, r1, 1               // subtract 1 from R1
   	QBNE LTCM3, r1, 0             // is R1 == 0? if no, then goto L1

	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_16 pin is LOW


//***************************************************************************************
//JUMP_MAS:
	//CHECK FOR THE CONTROL BIT WRITTING TO THE MASTER SHIFT REGISTER
   	QBBS TX_CSET, r6.t7    	// if the bit is high, jump to BIT_HIGH
   	QBBC TX_CCLR, r6.t7        // if the bit is low,  jump to BIT_LOW

//JUMP_SLV:
	//CHECK FOR THE CONTROL BIT WRITTING TO THE SLAVE SHIFT REGISTER
   //	QBBS DATA_SET, r6.t15    	// if the bit is high, jump to BIT_HIGH
   //	QBBC DATA_CLR, r6.t15        // if the bit is low,  jump to BIT_LOW
//***************************************************************************************

TX_CSET:

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    			//move out pin to
	SBBO r2, r5, 0, 4   		// the p8_3 pin is HIGH

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION         // set up for  the delay

    	// perform a LOOP for delay
LTCM4:
	SUB r1, r1, 1               // subtract 1 from R1
    QBNE LTCM4, r1, 0             // is R1 == 0? if no, then goto L1

	//shift the bit store in the r6 to the RIGHT
	LSL  r6, r6, 1

	// decrement the value of bits to be store and check its value
	SUB  r0, r0, 1
    QBEQ TX_OUT_E, r0, 0
    QBNE TX_OUT2, r0, 0

TX_CCLR:

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_3 pin is LOW

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION            // set up for  the delay
    	// perform a LOOP for delay

LTCM5:
	SUB r1, r1, 1                   // subtract 1 from R1
	QBNE LTCM5, r1, 0                  // is R1 == 0? if no, then goto L1

	//shift the bit store in the r6 to the RIGHT
	LSL  r6, r6, 1

	// decrement the value of bits to be store and check its value
	SUB  r0, r0, 1
	QBEQ TX_OUT_E, r0, 0
    QBNE TX_OUT2, r0, 0

//***************************************************************************************
// CHANGING THE STATE OF THE ENABLE PIN

TX_OUT_E:
	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    			//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_3 pin is LOW

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_5 pin is LOW

	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to
	SBBO r2, r5, 0, 4   		// the p8_16 pin is HIGH

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION        // set up for a .9 second delay

    // perform a LOOP for delay
LTCE1:
	SUB r1, r1, 1                // subtract 1 from R1

	// SETTING UP THE DELAY
	MOV r8, 10                      		//RUN THE LOOP 4 TIMES
LTCE2:
	SUB r8, r8, 1                       	// subtract 1 from R1
    QBNE LTCE2, r8, 0                      	// is R8 == 0? if no, then goto L1
    QBNE LTCE1, r1, 0              // is R1 == 0? if no, then goto L1


	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_16 pin is LOW

//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
	//Setting the value   the out pin CHECK LED
	MOV  r2, 1 << 31    			//move out pin to
	SBBO r2, r4, 0, 4   			// the p8_20 pin is LOW
//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------
//***************************************************************************************
	//RESETING THE SHIFT REGISTER FOR PARALLEL LOAD MODE
TX_MR:
	//Setting the value the out pin MR
	MOV  r2, 1 << 15     		//move out pin to
	SBBO r2, r4, 0, 4    		// the p8_20 pin is LOW

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION            // set up for  the delay
    	// perform a LOOP for delay

LMR1:
	SUB r1, r1, 1                   // subtract 1 from R1
	QBNE LMR1, r1, 0                  // is R1 == 0? if no, then goto L1


	//Setting the value the out pin MR
	MOV  r2, 1 << 15     		//move out pin to
	SBBO r2, r5, 0, 4    		// the p8_20 pin is HIGH

//---------------------------------------------------------------------------------------
//***************************************************************************************
			// SETTING THE REGISTER TO PARALLEL LOAD MODE

TX_PLOAD:
	//Setting the value the out pin S0
	MOV  r2, 1 << 13 			//move out pin to
	SBBO r2, r5, 0, 4   			// the p8_11 pin is HIGH

	//Setting the value the out pin S1
	MOV  r2, 1 << 12  			//move out pin to
	SBBO r2, r5, 0, 4   			// the p8_12 pin is HIGH

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_5 pin is LOW


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

LTP1:
	SUB r1, r1, 1                    // subtract 1 from R1
	QBNE LTP1, r1, 0                  // is R1 == 0? if no, then goto L1

	//Setting the value the out pin CP
	MOV  r2, 1 << 14    			//move out pin to
	SBBO r2, r4, 0, 4   			// the p8_16 pin is LOW

//***************************************************************************************
//    CLKING IN THE DATA GIVEN BY RECEIVER SHIFT REGISTER

	// SETTING UP THE DELAY
	MOV r1, ON_DURATION        // set up for a .9 second delay

    // perform a LOOP for delay
LTP2:
	SUB r1, r1, 1                // subtract 1 from R1

	// SETTING UP THE DELAY
	MOV r8, 4                      		//RUN THE LOOP 4 TIMES

        // perform a LOOP for delay
LTP3:
	SUB r8, r8, 1                       	// subtract 1 from R1
    QBNE LTP3, r8, 0                      	// is R8 == 0? if no, then goto L1

    QBNE LTL2, r1, 0              // is R1 == 0? if no, then goto L1


	//Setting the value the out pin CP
	MOV  r2, 1 << 14    			//move out pin to
	SBBO r2, r5, 0, 4   			// the p8_16 pin is HIGH


	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION            // set up for  the delay
    	// perform a LOOP for delay

LTP4:
	SUB r1, r1, 1                    // subtract 1 from R1
	QBNE LTP4, r1, 0                  // is R1 == 0? if no, then goto L1

	//Setting the value the out pin CP
	MOV  r2, 1 << 14    			//move out pin to
	SBBO r2, r4, 0, 4   			// the p8_16 pin is LOW

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION            // set up for  the delay
    	// perform a LOOP for delay

LTP5:
	SUB r1, r1, 1                    // subtract 1 from R1
	QBNE LTP5, r1, 0                  // is R1 == 0? if no, then goto L1

//---------------------------------------------------------------------------------------
//***************************************************************************************
			// SETTING THE REGISTER TO SHIFT RIGHT MODE TO LOAD THE ACK DATA
TX_ASTORE1:

	//Setting the value   the out pin S0
	MOV  r2, 1 << 13  			//move out pin to
	SBBO r2, r5, 0, 4   		// the p8_11 pin is HIGH

	//Setting the value   the out pin S1
	MOV  r2, 1 << 12  			//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_12 pin is LOW

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     		//move out pin to
	SBBO r2, r4, 0, 4    		// the p8_5 pin is LOW


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
LTAS1:
     SUB r1, r1, 1				// subtract 1 from R1
     QBNE LTAS1, r1, 0				// is R1 == 0? if no, then goto L1


	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_16 pin is LOW

	// move the no of bits to be store in the memory
	MOV r0, 8

	// AS THE DATA IS BEING LOADED FROM THE SHIFT REGISTER TO PRU REGISTER IN SHIFT LEFT MODE

	MOV r1,OFF_DURATION 			// set up for a delay

        // perform a half second delay
LTAS2:
     SUB r1, r1, 1				// subtract 1 from R1
     QBNE LTAS2, r1, 0				// is R1 == 0? if no, then goto L1

TX_ABIT:

	//Setting the value the out pin CP
	MOV  r2, 1 << 14			//move out pin to
	SBBO r2, r5, 0, 4			// the p8_16 pin is HIGH

	//set IN pin to INPUT
	MOV  r3, GPIO1 | GPIO_DATAIN
	LBBO r7, r3, 0, 7			// P8_04

    MOV r1, OFF_DURATION 			// set up of delay

LTAS3:
	SUB r1, r1, 1				// subtract 1 from R1
    QBNE LTAS3, r1, 0				// is R1 == 0? if no, then goto L1

	//Setting the value the out pin CP
	MOV  r2, 1 << 14			//move out pin to
	SBBO r2, r4, 0, 4			// the p8_16 pin is LOW


    // TAKE THE ACK BIT INTO THE REGISTER FOR THE CONFORMATION OF HAND SAKING
	QBBS TX_ABIT_SET, r7.t0			// if the bit is high, jump to LED_HIGH
	QBBC TX_ABIT_CLR, r7.t0			// if the bit is low,  jump to LED_LOW


	// STORE 1 VALUE IN THE REGISTER
TX_ABIT_SET:
	//PERFORM THE LEFT SHIFT OPERATION ON THE REGISTER R6
	LSL r9, r9, 1

    ADD  r9, r9.b0, 0b00000001

    MOV r1, OFF_DURATION 			// set up of delay

LTAS4:
 	SUB r1, r1, 1				// subtract 1 from R1
    QBNE LTAS4, r1, 0				// is R1 == 0? if no, then goto L1


    SUB r0, r0, 1
    QBEQ TX_ATEST, r0, 0
    QBNE TX_ABIT, r0, 0
	//STORE 0 VALUE IN THE REGISTER
TX_ABIT_CLR:
	//PERFORM THE LEFT SHIFT OPERATION ON THE REGISTER R6
	LSL r9, r9, 1

    MOV r1, OFF_DURATION 			// set up of delay

LTAS5:
	SUB r1, r1, 1				// subtract 1 from R1
    QBNE LTAS5, r1, 0				// is R1 == 0? if no, then goto L1

    SUB r0, r0, 1
    QBEQ TX_ATEST, r0, 0
    QBNE TX_ABIT, r0, 0

//---------------------------------------------------------------------------------------
//THE DATA GET LOADED TO THE REGISTER R9
//---------------------------------------------------------------------------------------



//---------------------------------------------------------------------------------------
//***************************************************************************************

	//TESTING FOR THE HIGH BIT 1 ACK BIT AT BIT 1 IN REGISTER R9

TX_ATEST:

	QBBC TX_MR, r9.t1			// if the bit is low,  jump to TX_MR (MASTER RESET AND AGAIN TEST IT)

	MOV R10.b1	, 0X6					// THIS LOOP WILL RUN FOR 6 TIME TO STORE ALL SIX BIT OF DATA IN ONE REGISTER OF PRU

    SUB R10.b0, R10.b0, 1	//DECREASE THE VALUE BY ONE AS 6 BIT OF DATA WILL COME OUT FOR ONLY  TIMES
    QBEQ EXIT, R10.b0, 0


//---------------------------------------------------------------------------------------
//***************************************************************************************
TX_DATA:

	// GETTING DATA REGISTER BITS REGISTER READY FOR TRANSMISSION

	// THIS LOOP STORE THE 6 BIT OF DATAIN ONE BYTE REGISTER THAT WILL BE TX THROUGH THE SHIFT REGISTER
TX_WR2:
	MOV R11.t0, R12.t31  // TAKE DATA FROM MSB TO LSB
	LSL R11.b0,R11.b0,1  // SHIFT THE DATA BY ONE
	LSL R12, R12, 1      // SHIFT THE DATA BIT BY ONE

    SUB R10.b1, R10.b1, 1	//
    QBNE TX_WR1, r0, 0		// LOOP RUN FOR TAKING 6 BIT OF MSB DATA BITS

    MOV R11.t0, 0  			// THE FIRST BIT IS CONTROL BIT
	LSL R11.b0,R11.b0,1  	// SHIFT THE DATA BY ONE
	MOV R11.t0, 0  			// THE SECOND  BIT AS ACK BIT AT BIT 1

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
	SBBO r2, r5, 0, 4    		// the p8_5 pin is HIGH

	//Setting the value the out pin MR
	MOV  r2, 1 << 15     		//move out pin to
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
LTD1:
	SUB r1, r1, 1               // subtract 1 from R1
	QBNE LTD1, r1, 0             // is R1 == 0? if no, then goto L1

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
LTD3:
	SUB r1, r1, 1               // subtract 1 from R1
   	QBNE LTD3, r1, 0             // is R1 == 0? if no, then goto L1

	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_16 pin is LOW


//***************************************************************************************
JUMP_DATA:
	//CHECK FOR THE CONTROL BIT WRITTING TO THE MASTER SHIFT REGISTER
   	QBBS TX_D_SET, r11.t0    	// if the bit is high, jump to BIT_HIGH
   	QBBC TX_D_CLR, r11.t0        // if the bit is low,  jump to BIT_LOW

//***************************************************************************************

TX_D_SET:

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    			//move out pin to
	SBBO r2, r5, 0, 4   		// the p8_3 pin is HIGH

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION         // set up for  the delay

    	// perform a LOOP for delay
LTD4:
	SUB r1, r1, 1               // subtract 1 from R1
    QBNE LTD4, r1, 0             // is R1 == 0? if no, then goto L1

	//shift the bit store in the r6 to the RIGHT
	LSL  r6, r6, 1

	// decrement the value of bits to be store and check its value
	SUB  r0, r0, 1
    QBEQ EXIT, r0, 0
    QBNE TX_OUT1, r0, 0

TX_D_CLR:

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_3 pin is LOW

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION            // set up for  the delay
    	// perform a LOOP for delay

LTD5:
	SUB r1, r1, 1                   // subtract 1 from R1
	QBNE LTD5, r1, 0                  // is R1 == 0? if no, then goto L1

	//shift the bit store in the r6 to the RIGHT
	LSL  r6, r6, 1

	// decrement the value of bits to be store and check its value
	SUB  r0, r0, 1
	QBEQ EXIT, r0, 0
    QBNE TX_OUT1, r0, 0

//***************************************************************************************
// CHANGING THE STATE OF THE ENABLE PIN

TX_OUT_E1:
	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    			//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_3 pin is LOW

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_5 pin is LOW

	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to
	SBBO r2, r5, 0, 4   		// the p8_16 pin is HIGH

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION        // set up for a .9 second delay

    // perform a LOOP for delay
LTDE1:
	SUB r1, r1, 1                // subtract 1 from R1

	// SETTING UP THE DELAY
	MOV r8, 10                      		//RUN THE LOOP 4 TIMES
LTDE2:
	SUB r8, r8, 1                       	// subtract 1 from R1
    QBNE LTDE2, r8, 0                      	// is R8 == 0? if no, then goto L1
    QBNE LTDE1, r1, 0              // is R1 == 0? if no, then goto L1


	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to
	SBBO r2, r4, 0, 4   		// the p8_16 pin is LOW


	JMP TX_PLOAD				// AGAIN REPEAT THE SAME PROCESS FOR 5 TIMES MORE AS THIS REFLECT THE 32 BIT DATA IS SENT



//-------------------------------------------------------------------------------------------------
// THIS IS THE HALT OF THE PROGRAM WITH SUSSESSFUL INDICATION SHOWS  BLINKING OF LIGHT AT P8_20 PIN
EXIT:
	//Setting the value   the out pin CHECK LED
	MOV  r2, 1 << 31    			//move out pin to
	SBBO r2, r5, 0, 4   			// the p8_20 pin is HIGH

	HALT
