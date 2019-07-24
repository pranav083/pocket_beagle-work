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

#define DS0     6   			/* P8_3  38 GPIO 1_6  mode 7 OUTPUT */
#define INPUT   7   			/* P8_4  39 GPIO 1_7  mode 7 INPUT  */
#define OE		2   			/* P8_5  34 GPIO 1_2  mode 7 OUTPUT */ //OE1 AND OE2
#define S0      13  			/* P8_11 45 GPIO 1_13 mode 7 OUTPUT */
#define S1      12  			/* P8_12 44 GPIO 1_12 mode 7 OUTPUT */
#define MR      15  			/* P8_15 47 GPIO 1_15 mode 7 OUTPUT */
#define CP      14  			/* P8_16 46 GPIO 1_14 mode 7 OUTPUT */
#define CK_LED  31  			/* P8_20 63 GPIO 1_31 mode 7 OUTPUT */


#define STROBE  5				/* P8_22 37 GPIO 1_5 mode 7 INPUT/OUTPUT */
#define RDWR    4				/* P8_23 36 GPIO 1_4 mode 7 INPUT/OUTPUT */
#define ACK     1				/* P8_24 33 GPIO 1_1 mode 7 INPUT/OUTPUT */

//---------------------------------------------------------------------------------------
//***************************************************************************************
start:

	// Enable the OCP master port,

  	lbco r0, CPRUCFG, 4, 4   	// read SYSCFG
  	clr  r0.t4               	// clear SYSCFG[STANDBY_INIT]
  	sbco r0, CPRUCFG, 4, 4   	// enable OCP master port

	// FOR DATA REGISTER BITS FROM MASTER (SENDING DATA BETWEEN MASTER AND SLAVE)
	// STROBE  RD/WR   ACK		DESCRIPTION
	//	0		0		0		SLAVE  MODE, SLAVE  IS WRITING, MASTER IS STORING DATA, ACK BIT TO BE RECEIVED FROM THE MASTER
	//	0		0		1		SLAVE  MODE, SLAVE  IS WRITING, MASTER IS STORING DATA, ACK BIT IS RECEIVED FROM THE MASTER
	//	0		1		0		SLAVE  MODE, MASTER IS WRITING, SLAVE  IS STORING DATA, ACK BIT TO BE RECEIVED FROM THE SLAVE
	//	0		1		1		SLAVE  MODE, MASTER IS WRITING, SLAVE  IS STORING DATA, ACK BIT IS RECEIVED FROM THE SLAVE
	//	1		0		0		MASTER MODE, MASTER IS WRITING, SLAVE  IS STORING DATA, ACK BIT TO BE RECEIVED FROM THE SLAVE
	//	1		0		1		MASTER MODE, MASTER IS WRITING, SLAVE  IS STORING DATA, ACK BIT IS RECEIVED FROM THE SLAVE
	//	1		1		0		MASTER MODE, SLAVE  IS WRITING, MASTER IS STORING DATA, ACK BIT TO BE RECEIVED FROM THE MASTER
	//	1		1		1		MASTER MODE, SLAVE  IS WRITING, MASTER IS STORING DATA, ACK BIT IS RECEIVED FROM THE MASTER

	// FOR DATA REGISTER ON THE DATA LINES in shift register
	// DESCRIPTION    BIT NO.    STATE
	//	DATA 			0			-
	//	DATA			1			-
	//	DATA			2			-
	//	DATA			3			-
	//	DATA			4			-
	//	DATA			5			-
	//	DATA			6			-
	//	DATA			7			-

//----------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------


	//TO STORE THE PREVIOUS VALUE OF THE SYSTEM A FLAG REGISTER IS CREATED
	MOV r6.b0, 0b00000000 			// FLAG REGISTER TO STORE THE PREVIOUS DATA BEFORE CHANGING THE STATE
	MOV r6.b1, 0b00001011 			// CONTROL BITS WHICH MAKES IT SLAVE  FOR COMMUNICATION
  	MOV r6.b2, 0b00000010 			// SENDING THE DATA BIT TO FOR SUCCESFUL ACK OF DATA
  	MOV r6.b3, 0b00000001 			// SENDING TO SHIFT THE SYSTEM TO CONTROL MODE


//example data of the register that will be transfer via shift register
    MOV R9  	, 0X0				//MOV O TO THE REGISTER
    MOV R10.b0 	, 0X4				//MOV 4 TO THE REGISTER ,AS THE DATA NEED TO SENT 4 TIMES AS 8 BIT AT A TIME READ MODE
    MOV R10.b1 	, 0X4				//MOV 4 TO THE REGISTER ,AS THE DATA NEED TO READ 4 TIMES AS 8 BIT AT A TIME WRITE MODE
	MOV R11.b0 	, 0b00000000		//MOV O TO THE REGISTER
	MOV R12 	, 0X0F0F0F0F		//MOV THE DATA THAT NEED TO BE SENT
	MOV R9		, R12

	//set DS0 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 6     									//DS0
	SBBO r2, r3, 0, 4

	//set S0 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 13    									//S0
	SBBO r2, r3, 0, 4

	//set S1 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 12    									//S1
	SBBO r2, r3, 0, 4

	//set OE1 and OE2 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 2    									//OE1 and OE2
	SBBO r2, r3, 0, 4

	//set CP pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 14     									//CP
	SBBO r2, r3, 0, 4

	//set COMMON for Q0 and Q7 pin to INPUT
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	SET r2, r2, 7     									//INPUT
	SBBO r2, r3, 0, 4

	//set CHECK LED pin to ouput here
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 31     									//CHECK LED
	SBBO r2, r3, 0, 4

	//set MASTER RESET pin to ouput here
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 15     									//CHIP RESET
	SBBO r2, r3, 0, 4

//THIS IS MASTER, WRITE , ACK
// THIS MODE IS REQUIRED WHEN THE MASTER IS IN READING STATE
// ALL THE PINS HERE IN THE OUTPUT MODE
	//set STROBE pin to INPUT here
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	SET r2, r2, 5     									//STROBE
	SBBO r2, r3, 0, 4

	//set RD/WR pin to INPUT here
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	SET r2, r2, 4     									//READ/WRITE
	SBBO r2, r3, 0, 4

	//set ACK pin to ouput here
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 1     									//ACK
	SBBO r2, r3, 0, 4


	//setting the register for data high and   GPIO1
	MOV r4, GPIO1 | GPIO_CLEARDATAOUT
	MOV r5, GPIO1 | GPIO_SETDATAOUT

	//Setting the value the out pin CHECK LED
	MOV  r2, 1 << 31    								//move out pin to
	SBBO r2, r4, 0, 4   								// the p8_20 pin is LOW

		//Setting the value the out pin ACK
	MOV  r2, 1 << 1     								//move out pin to
	SBBO r2, r4, 0, 4    								// the p8_24 pin is HIGH

//COMMUNICATION START FROM HERE

//---------------------------------------------------------------------------------------
//***************************************************************************************
RX_SRW:
	//set IN pin to INPUT
	MOV  r3, GPIO1 | GPIO_DATAIN
	LBBO r7, r3, 0, 4									// P8_22, P8_23

	QBBC RX_STROBE, r7.t5								//AS THE BIT GOES HIGH GO TO MASTER

	JMP SRW
//THIS CALLS RX_PLOAD WHEN IT RECEIVE ACK FROM SLAVE
RX_STROBE:
	SUB  R10.b1 , R10.b1, 1 							//THIS TELL THAT THE LOOP IS RUN FOR ONLY 4 TIMES FOR 4 BYTE OF DATA
	QBEQ EXIT, R10.b1, 0								//IT MEANS THAT ALL THE 32 BIT DATA IS BEEN  RECEIVED BY THE SLAVE

	SUB  R10.b1 , R10.b1, 1 							//THIS TELL THAT THE LOOP IS RUN FOR ONLY 4 TIMES FOR 4 BYTE OF DATA
	QBEQ EXIT, R10.b1, 0								//IT MEANS THAT ALL THE 32 BIT DATA IS BEEN  SENT BY THE SLAVE

	//Setting the value the out pin ACK
	MOV  r2, 1 << 1     								//move out pin to
	SBBO r2, r4, 0, 4    								// the p8_24 pin is HIGH

	//set IN pin to INPUT
	MOV  r3, GPIO1 | GPIO_DATAIN
	LBBO r7, r3, 0, 4									// P8_22, P8_23

	QBBS RX_WRITE , r7.t4								//CHECHING THE DATA MODE AS OF READ OR WRITE MODE
	QBBC RX_PLOAD , r7.t4								//CHECHING THE DATA MODE AS OF READ OR WRITE MODE


RX_MACK:
	//Setting the value the out pin ACK
	MOV  r2, 1 << 1     								//move out pin to
	SBBO r2, r4, 0, 4    								// the p8_24 pin is LOW

	CALL DELAY0                 						// CALL THE DELAY FUNCTION

	JMP  RX_SRW											// IF ACK IS NOT RECEIVED THEN IT WILL WRITE THE DATA AGAIN


//---------------------------------------------------------------------------------------
//***************************************************************************************



//---------------------------------------------------------------------------------------
//***************************************************************************************
RX_WRITE:
//initilization of the pins
// LOAD THE INPUT SHIFT REGISTER IN SHIFT RIGHT MODE
	//Setting the value the out pin S0
	MOV  r2, 1 << 13     								//move out pin to
	SBBO r2, r5, 0, 4    								// the p8_11 pin is HIGH

	//Setting the value the out pin S1
	MOV  r2, 1 << 12     								//move out pin to
	SBBO r2, r4, 0, 4    								// the p8_12 pin is LOW

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     								//move out pin to
	SBBO r2, r5, 0, 4    								// the p8_5 pin is HIGH

	//Setting the value the out pin MR
	MOV  r2, 1 << 15     								//move out pin to
	SBBO r2, r5, 0, 4    								// the p8_15 pin is HIGH

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    									//move out pin to
	SBBO r2, r4, 0, 4   								// the p8_3 pin is LOW
//***************************************************************************************
	//NOW THE DATA TO THE CONNECTED SHIFT REGISTER IN SHIFT RIGHT MODE
  	// move the NO. OF TIMES THE LOOP TO BE RUN AT A TIME
  	MOV r0, NUMBER_OF_BITS								//NO. OF DATA LINES SHIFT REGISTER HAVE

RX_WRITE1:
// NOW THE DATA STORE IN THE REGISTER IS MADE TO THE DATA PIN OF THE SHIFT REGISTER R6
	CALL DELAY											// CALL THE DELAY FUNCTION
	CALL CP_PULSE										// CALL FOR CLK PULSE

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    									//move out pin to
	SBBO r2, r4, 0, 4   								// the p8_3 pin is LOW
//***************************************************************************************

	QBBC RX_CLR  , R12.t31
	QBBS RX_SET  , R12.t31
//***************************************************************************************

RX_SET:
	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    									//move out pin to
	SBBO r2, r5, 0, 4   								// the p8_3 pin is HIGH

	//shift the bit store in the r6 to the RIGHT
	LSL  r12, r12, 1

	// decrement the value of bits to be store and check its value
	SUB  r0, r0, 1
    QBEQ RX_OUT_E, r0, 0
    QBNE RX_WRITE1, r0, 0

RX_CLR:
	// BY DEFAULT DS0 PIN IS LOW

	//shift the bit store in the r6 to the RIGHT
	LSL  r12, r12, 1

	// decrement the value of bits to be store and check its value
	SUB  r0, r0, 1
	QBEQ RX_OUT_E, r0, 0
    QBNE RX_WRITE1, r0, 0

//***************************************************************************************
// CHANGING THE STATE OF THE ENABLE PIN

RX_OUT_E:
	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    									//move out pin to
	SBBO r2, r4, 0, 4   								// the p8_3 pin is LOW

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     								//move out pin to
	SBBO r2, r4, 0, 4   								// the p8_5 pin is LOW

	CALL	CP_PULSE									//GET THE RISING CLK PULSE

	JMP RX_MACK											//NOW CHECK FOR THE ACK BIT
//---------------------------------------------------------------------------------------
//***************************************************************************************


//---------------------------------------------------------------------------------------
//***************************************************************************************
	// THIS MODE IS REQUIRED WHEN THE MASTER IS IN READING STATE
	//RESETING THE SHIFT REGISTER FOR PARALLEL LOAD MODE

RX_PLOAD:
	//Setting the value the out pin MR
	MOV  r2, 1 << 15     								//move out pin to
	SBBO r2, r4, 0, 4    								// the p8_15 pin is LOW

	CALL DELAY                 							// CALL THE DELAY FUNCTION

	//Setting the value the out pin MR
	MOV  r2, 1 << 15     								//move out pin to
	SBBO r2, r5, 0, 4    								// the p8_15 pin is HIGH

//---------------------------------------------------------------------------------------
//***************************************************************************************
// SETTING THE REGISTER TO PARALLEL LOAD MODE

RX_PLOAD1:

	//Setting the value the out pin S1
	MOV  r2, 1 << 12  									//move out pin to
	SBBO r2, r5, 0, 4   								// the p8_12 pin is HIGH

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     								//move out pin to
	SBBO r2, r4, 0, 4   								// the p8_5 pin is LOW

	//CHECKING  IN THE DATA GIVEN BY RECEIVER SHIFT REGISTER
	CALL 	DELAY										// CALL THE DELAY1 FUNCTION
	CALL	CP_PULSE									//GET THE RISING CLK PULSE
//---------------------------------------------------------------------------------------
//***************************************************************************************
// SETTING THE REGISTER TO SHIFT RIGHT MODE TO LOAD THE DATA BITS
RX_PLOAD2:
	//Setting the value   the out pin S1
	MOV  r2, 1 << 12  									//move out pin to
	SBBO r2, r4, 0, 4   								// the p8_12 pin is LOW

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     								//move out pin to
	SBBO r2, r5, 0, 4    								// the P8_5 pin is HIGH
	//DATA NOW GET OUT FROM THE Q0 PIN OF THE SHIFT REGISTER

//***************************************************************************************
	// move the no of bits to be store in the memory
	MOV r0, NUMBER_OF_BITS
// AS THE DATA IS BEING LOADED FROM THE SHIFT REGISTER TO PRU REGISTER IN SHIFT RIGHT MODE
RX_DBIT:
	CALL 	DELAY                 						// CALL THE DELAY FUNCTION
	CALL	CP_PULSE									//GET THE RISING CLK PULSE

	//set IN pin to INPUT
	MOV  r3, GPIO1 | GPIO_DATAIN
	LBBO r7, r3, 0, 4									// P8_04
	MOV  R7, R7 >> 7									// RIGHT SHIFT SEVEN TIMES

	OR  R9, R7, R9										// OR THE DATA WITH R9 REGISTER
	MOV R9, R9 << 1										// SHIFT LEFT DATA BY 1 BIT

    SUB r0, r0, 1

    QBEQ RX_MACK, r0, 0
    QBNE RX_DBIT,  r0, 0

//---------------------------------------------------------------------------------------
//THE DATA GET LOADED SAVED TO THE REGISTER R9
//---------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------
// THIS IS THE HALT OF THE PROGRAM WITH SUSSESSFUL INDICATION SHOWS  BLINKING OF LIGHT AT P8_20 PIN
EXIT:
	//Setting the value   the out pin CHECK LED
	MOV  r2, 1 << 31    								//move out pin to
	SBBO r2, r5, 0, 4   								// the p8_20 pin is HIGH

	HALT

//---------------------------------------------------------------------------------------
//***************************************************************************************

// CALL FUNCTION HERE
//	CALL FOR A DELAY
DELAY0:
		MOV r1, ON_DURATION         					// set up for  the delay
	LRR:
		SUB r1,r1, 1                 					// subtract 1 from R1
		QBNE LRR, r1, 0
	RET

//	CALL FOR A DELAY
DELAY:
		MOV r1, OFF_DURATION         					// set up for  the delay
	LRR:
		SUB r1,r1, 1                 					// subtract 1 from R1
		QBNE LRR, r1, 0
	RET

// CALL FOR CLK PULSE
CP_PULSE:
		//Setting the value the out pin CP
		MOV  r2, 1 << 14    							//move out pin to
		SBBO r2, r5, 0, 4   							// the p8_16 pin is HIGH

		MOV r1, OFF_DURATION         					// set up for  the delay
	DELAY3:
		SUB r1,r1, 1                 					// subtract 1 from R1
		QBNE DELAY3, r1, 0

		//Setting the value the out pin CP
		MOV  r2, 1 << 14    							//move out pin to
		SBBO r2, r4, 0, 4   							// the p8_16 pin is LOW

		MOV r1, OFF_DURATION         					// set up for  the delay
	DELAY4:
		SUB r1,r1, 1                 					// subtract 1 from R1
		QBNE DELAY4, r1, 0

	RET