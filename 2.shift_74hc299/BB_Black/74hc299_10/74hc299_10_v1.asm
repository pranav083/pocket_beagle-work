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
#define S0      2   			/* P8_5  34 GPIO 1_2  mode 7 */ 
#define S1      3   			/* P8_6  35 GPIO 1_3  mode 7 */
#define OE1     13  			/* P8_11 45 GPIO 1_13 mode 7 */ 
#define OE2     12  			/* P8_12 44 GPIO 1_12 mode 7 */
#define CP      15  			/* P8_15 47 GPIO 1_15 mode 7 */
#define DS7     14  			/* P8_16 46 GPIO 1_14 mode 7 */
#define CK_LED  31  			/* P8_20 63 GPIO 1_31 mode 7 */


///////////////////////////////////////////////////////////
start:

	// Enable the OCP master port, 
        
  	lbco r0, CPRUCFG, 4, 4   	// read SYSCFG
  	clr  r0.t4               	// clear SYSCFG[STANDBY_INIT]
  	sbco r0, CPRUCFG, 4, 4   	// enable OCP master port
  	
  	// move the no of bits to be store in the memory
  	MOV r0, NUMBER_OF_BITS

	// STORE THE BIT DATA IN THE  REGISTER
	MOV r6.b0, 0b11110000 		// MOVE 0 INITIAL VALUE TO R6 
	MOV r6.b1, 0b00000000 		// MOVE 0 INITIAL VALUE TO R6 
  	MOV r6.b2, 0b00000000 		// MOVE 0 INITIAL VALUE TO R6 
  	MOV r6.b3, 0b00000000 		// MOVE 0 INITIAL VALUE TO R6 
  		 	
  		 
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
	CLR r2, r2, 2    		//OE1 
	SBBO r2, r3, 0, 4 		
	
	//set CP pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 14     		//CP
	SBBO r2, r3, 0, 4
	
	//set DS7 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 15     		//DS7
	SBBO r2, r3, 0, 4
			
	//set CHECK LED pin to ouput here
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 31     		//CHECK LED
	SBBO r2, r3, 0, 4		 
	
	//setting the register for data high and   GPIO1
	MOV r4, GPIO1 | GPIO_CLEARDATAOUT	
	MOV r5, GPIO1 | GPIO_SETDATAOUT
		
//////////////////////////////////////////////////////////////////
	// LOAD THE INPUT SHIFT REGISTER 
	
	//Setting the value the out pin S0
	MOV  r2, 1 << 13     		//move out pin to  
	SBBO r2, r5, 0, 4    		// the p8_11 pin is HIGH	
	
	//Setting the value the out pin S1
	MOV  r2, 1 << 12     		//move out pin to  
	SBBO r2, r4, 0, 4    		// the p8_12 pin is LOW	

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     		//move out pin to  
	SBBO r2, r5, 0, 4    		// the p8_11 pin is HIGH	
	
	//Setting the value the out pin OE2
//	MOV  r2, 1 << 3     		//move out pin to  
//	SBBO r2, r4, 0, 4    		// the p8_12 pin is LOW	
		
///////////////////////////////////////////////////////////////////
	//NOW THE DATA OUT MODE TO THE LED CONNECTED FIRST REGISTER	
	
	// THE MODE OF 74HC299 FROM LOAD TO SHIFT RIGHT MODE		
			
	//Setting the value the out pin CHECK LED
	MOV  r2, 1 << 31    		//move out pin to  
	SBBO r2, r5, 0, 4   		// the p8_20 pin is HIGH
					
	// SETTING UP THE DELAY
	MOV r1,  100000                 // set up for  the delay				

    	// perform a LOOP for delay
L2: 
	SUB r1, r1, 1                   // subtract 1 from R1
	QBNE L2, r1, 0                  // is R1 == 0? if no, then goto L1
        
	//Setting the value   the out pin CHECK LED
	MOV  r2, 1 << 31    		//move out pin to  
	SBBO r2, r4, 0, 4   		// the p8_20 pin is LOW
       			
L_OUT2:
	// NOW THE DATA STORE IN THE REGISTER IS MADE TO THE DATA PIN OF THE SHIFT REGISTER R6
		
	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    		//move out pin to  
	SBBO r2, r4, 0, 4   		// the p8_3 pin is LOW

	// SETTING UP THE DELAY
	MOV r1, OFF_DURATION            // set up for  the delay				

    // perform a LOOP for delay
L3: 
	SUB r1, r1, 1                   // subtract 1 from R1
    	QBNE L3, r1, 0                  // is R1 == 0? if no, then goto L1
        
	//Setting the value the out pin CHECK LED
	MOV  r2, 1 << 31    		//move out pin to  
	SBBO r2, r4, 0, 4   		// the p8_20 pin is LOW
					
	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to  
	SBBO r2, r4, 0, 4   		// the p8_16 pin is LOW	
				
	//CHECK FOR THE SET BIT AND CLEAR BIT ON THE PIN
    	QBBS DATA_SET, r6.t0    	// if the bit is high, jump to BIT_HIGH
    	QBBC DATA_CLR, r6.t0            // if the bit is low,  jump to BIT_LOW		 					
		
DATA_SET:
		
	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    		//move out pin to  
	SBBO r2, r5, 0, 4   		// the p8_3 pin is HIGH

	// SETTING UP THE DELAY
	MOV r1, ON_DURATION             // set up for  the delay				

    	// perform a LOOP for delay
L4: 
	SUB r1, r1, 1                   // subtract 1 from R1
    	QBNE L4, r1, 0                  // is R1 == 0? if no, then goto L1
        
	//Setting the value   the out pin CHECK LED
	MOV  r2, 1 << 31    		//move out pin to  
	SBBO r2, r4, 0, 4   		// the p8_20 pin is LOW
		
	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to  
	SBBO r2, r5, 0, 4   		// the p8_16 pin is HIGH	
				
	//shift the bit store in the r6 to the RIGHT
	LSR  r6, r6, 1		

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

L5:
	SUB r1, r1, 1                   // subtract 1 from R1
	QBNE L5, r1, 0                  // is R1 == 0? if no, then goto L1
        
	//Setting the value   the out pin CHECK LED
	MOV  r2, 1 << 31    		//move out pin to  
	SBBO r2, r4, 0, 4   		// the p8_20 pin is LOW
						
	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to  
	SBBO r2, r5, 0, 4   		// the p8_16 pin is HIGH	
				
	//shift the bit store in the r6 to the RIGHT
	LSR  r6, r6, 1				

	// decrement the value of bits to be store and check its value		
	SUB  r0, r0, 1
	QBEQ OUT_E, r0, 0 
    	QBNE L_OUT2, r0, 0 

//---------------------------------------------------------------------------
// CHANGING THE STATE OF THE ENABLE PIN
 
OUT_E:

	//Setting the value the out pin DS0
	MOV  r2, 1 << 6    		//move out pin to  
	SBBO r2, r4, 0, 4   		// the p8_3 pin is LOW	

	// SETTING UP THE DELAY
	MOV r1, 100000                  // set up for a .9 second delay				

    	// perform a LOOP for delay
LL3:     
	SUB r1, r1, 1                   // subtract 1 from R1
    	QBNE LL3, r1, 0                 // is R1 == 0? if no, then goto L1					
						
	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to  
	SBBO r2, r4, 0, 4   		// the p8_16 pin is LOW	

	//Setting the value the out pin OE1 and OE2
	MOV  r2, 1 << 2     		//move out pin to  
	SBBO r2, r4, 0, 4   		// the p8_11 pin is LOW		
	
	// SETTING UP THE DELAY
	MOV r1, 100000                  // set up for a .9 second delay				

    	// perform a LOOP for delay
LL4:     
	SUB r1, r1, 1                   // subtract 1 from R1
    	QBNE LL4, r1, 0                 // is R1 == 0? if no, then goto L1					

	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to  
	SBBO r2, r5, 0, 4   		// the p8_16 pin is HIGH	

	
	// SETTING UP THE DELAY
	MOV r1, 100000                  // set up for a .9 second delay				

    	// perform a LOOP for delay
LL5:     
	SUB r1, r1, 1                   // subtract 1 from R1
    	QBNE LL5, r1, 0                 // is R1 == 0? if no, then goto L1					


	//Setting the value the out pin CP
	MOV  r2, 1 << 14    		//move out pin to  
	SBBO r2, r4, 0, 4   		// the p8_16 pin is LOW				

//-------------------------------------------------------------------------------------------------				
// THIS IS THE HALT OF THE PROGRAM WITH SUSSESSFUL INDICATION SHOWS  BLINKING OF LIGHT AT P8_20 PIN


	// SETTING UP THE DELAY
	MOV r1, 100000                  // set up for a .9 second delay				

    	// perform a LOOP for delay
LL6:     
	SUB r1, r1, 1                   // subtract 1 from R1
    	QBNE LL6, r1, 0                 // is R1 == 0? if no, then goto L1	

	//Setting the value   the out pin CHECK LED
	MOV  r2, 1 << 31    		//move out pin to  
	SBBO r2, r5, 0, 4   		// the p8_20 pin is HIGH
						
	HALT				
