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

#define INS_PER_MS    500 * 1000
#define ON_DURATION   250 * INS_PER_MS
#define OFF_DURATION  250 * INS_PER_MS

#define CPRUCFG  c4

//STORE THE NO. OF TIME INPUT BUTTON TO STORE
#define NUMBER_OF_BITS 8

#define DS0     6   /* P8_3  38 GPIO 1_6  mode 7 */
#define INPUT   7   /* P8_4  39 GPIO 1_7  mode 7 */
#define S0      2   /* P8_5  34 GPIO 1_2  mode 7 */ 
#define S1      3   /* P8_6  35 GPIO 1_3  mode 7 */
//#define OE1     13  /* P8_11 45 GPIO 1_13 mode 7 */  //s0
//#define OE2     12  /* P8_12 44 GPIO 1_12 mode 7 */  //s1 
#define CP      15  /* P8_15 47 GPIO 1_15 mode 7 */
#define DS7     14  /* P8_16 46 GPIO 1_14 mode 7 */
#define CK_LED  31  /* P8_20 63 GPIO 1_31 mode 7 */


///////////////////////////////////////////////////////////
start:

	// Enable the OCP master port, 
        
  	lbco r0, CPRUCFG, 4, 4   // read SYSCFG
  	clr  r0.t4               // clear SYSCFG[STANDBY_INIT]
  	sbco r0, CPRUCFG, 4, 4   // enable OCP master port
  	
  	// move the no of bits to be store in the memory
  	MOV r0, NUMBER_OF_BITS

	// STORE THE BIT DATA IN THE  REGISTER
	MOV r6.b0, 0b00000000 // MOVE 0 INITIAL VALUE TO R6.b0 
		MOV r6.b1, 0b00000000 // MOVE 0 INITIAL VALUE TO R6.b1 
  		 	MOV r6.b2, 0b00000000 // MOVE 0 INITIAL VALUE TO R6.b2 
  		 		MOV r6.b3, 0b00000000 // MOVE 0 INITIAL VALUE TO R6.b3 
  		 	
 //--------------------------------------------------------------------
 //SETTING THE INPUT / OUPUT MODE  OF THE PINS
 //--------------------------------------------------------------------
 		 	
	//set DS0 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 6     //DS0
	SBBO r2, r3, 0, 4
	
	//set INPUT pin to INPUT
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	SET r2, r2, 7    //INPUT 
	SBBO r2, r3, 0, 4
		
	//set S0 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 2    //S0 not used now 
	SBBO r2, r3, 0, 4

	//set S1 pin to ouput
	MOV r3, GPIO0 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 3    //S1 not used now
	SBBO r2, r3, 0, 4
	
	//set OE1 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 13    //s0 
	SBBO r2, r3, 0, 4
			
	//set OE2 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 12    //s1
	SBBO r2, r3, 0, 4	  		
	
	//set CP pin to ouput
	MOV r3, GPIO0 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 15     //CP NOT USED NOW
	SBBO r2, r3, 0, 4
	
	//set DS7 pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 14       //CP
	SBBO r2, r3, 0, 4
			
	//set CHECK LED pin to ouput
	MOV r3, GPIO1 | GPIO_OE
	LBBO r2, r3, 0, 4
	CLR r2, r2, 31     //CHECK LED
	SBBO r2, r3, 0, 4		 
	
	//setting the register for data high and   GPIO1
	MOV r4, GPIO1 | GPIO_CLEARDATAOUT	
	MOV r5, GPIO1 | GPIO_SETDATAOUT

//-----------------------------------------------------------
//SET THE REGISTER IN THE PARALLEL LOAD MODE
//-----------------------------------------------------------

//////////////////////////////////////////////////////////////////
		// PARALLEL LOAD MODE OF THE SHIFT REGISTER 
	
L_LOAD:
////////////////////////////////////////////////////////////////////
		// SETTING THE REGISTER TO LOAD MODE
		
		//Setting the value   the out pin S0
		MOV  r2, 1 << 13  //move out pin to  
		SBBO r2, r5, 0, 4   // the p8_11 pin is HIGH	
		
		//Setting the value   the out pin S1
		MOV  r2, 1 << 12  //move out pin to  
		SBBO r2, r5, 0, 4   // the p8_12 pin is HIGH	

////////////////////////////////////////////////////////////////////


		//Setting the value the out pin CP
		MOV  r2, 1 << 14    //move out pin to  
		SBBO r2, r4, 0, 4   // the p8_16 pin is LOW
				
		//Setting the value   the out pin CHECK LED
		MOV  r2, 1 << 31    //move out pin to  
		SBBO r2, r5, 0, 4   // the p8_20 pin is HIGH		
		
		
		// SETTING UP THE DELAY
		MOV r1, 90000000                    // set up for a .9 second delay				

        // perform a LOOP for delay
L1:     SUB r1, r1, 1                       // subtract 1 from R1
		
		// SETTING UP THE DELAY
		MOV r8, 4                      //RUN THE LOOP 9 TIMES				

        // perform a LOOP for delay
L2:     SUB r8, r8, 1                       // subtract 1 from R1
        QBNE L2, r8, 0                      // is R8 == 0? if no, then goto L1

        QBNE L1, r1, 0                      // is R1 == 0? if no, then goto L1


		//Setting the value the out pin CHECK LED
		MOV  r2, 1 << 31    //move out pin to  
		SBBO r2, r4, 0, 4   // the p8_20 pin is LOW


		//Setting the value the out pin CP
		MOV  r2, 1 << 14    //move out pin to  
		SBBO r2, r5, 0, 4   // the p8_16 pin is HIGH

		// SETTING UP THE DELAY
		MOV r1, 300000                    // set up for a .9 second delay				

        // perform a LOOP for delay
L3:     SUB r1, r1, 1                       // subtract 1 from R1
        QBNE L3, r1, 0                      // is R1 == 0? if no, then goto L1

		//Setting the value the out pin CP
		MOV  r2, 1 << 14    //move out pin to  
		SBBO r2, r4, 0, 4   // the p8_16 pin is LOW


//--------------------------------------------------------------------
//NOW LOAD THE STORE VALUE FROM THE SHIFT REGISTER TO PRU
//--------------------------------------------------------------------




L_LOAD1:
//////////////////////////////////////////////////////////////////////
		// SETTING THE REGISTER TO SHIFT RIGHT MODE
		
		//Setting the value   the out pin S0
		MOV  r2, 1 << 13  //move out pin to  
		SBBO r2, r5, 0, 4   // the p8_11 pin is HIGH	
		
		//Setting the value   the out pin S1
		MOV  r2, 1 << 12  //move out pin to  
		SBBO r2, r4, 0, 4   // the p8_12 pin is LOW	
////////////////////////////////////////////////////////////////////////

				
  		// move the no of bits to be store in the memory
  		MOV r0, NUMBER_OF_BITS

				
		//as data is being loaded from shift register s
		
		//Setting the value the out pin DS0
		MOV  r2, 1 << 6    //move out pin to  
		SBBO r2, r4, 0, 4   // the p8_3 pin is LOW
		
		

BIT_D:  	
		//Setting the value for the out pin
		MOV  r2, 1 << 31  	//move out pin to  
		SBBO r2, r5, 0, 4   // the p8_20 pin is HIGH
		
		
		//Setting the value the out pin DS0
		MOV  r2, 1 << 6    //move out pin to  
		SBBO r2, r4, 0, 4   // the p8_3 pin is LOW		


		//Setting the value the out pin CP
		MOV  r2, 1 << 14    //move out pin to  
		SBBO r2, r4, 0, 4   // the p8_16 pin is LOW	    		
		        					
					
		//set IN pin to INPUT
		MOV  r3, GPIO1 | GPIO_DATAIN
		LBBO r7, r3, 0, 4    // P8_04


		MOV r1, 50000000                    // set up for a .9 second delay

        // perform a half second delay
LL1:     SUB r1, r1, 1                       // subtract 1 from R1
        QBNE LL1, r1, 0                      // is R1 == 0? if no, then goto L1
 
		//Setting the value for the out pin
		MOV  r2, 1 << 31  	//move out pin to  
		SBBO r2, r4, 0, 4   // the p8_20 pin is LOW
        					
        QBBS BIT_SET, r7.t7                  // if the bit is high, jump to LED_HIGH
        QBBC BIT_CLR, r7.t7         	 	 // if the bit is low,  jump to LED_LOW
    
        
        
// STORE 1 VALUE IN THE REGISTER 
BIT_SET:
		//PERFORM THE LEFT SHIFT OPERATION ON THE REGISTER R6
		LSL r6, r6, 1
		
        ADD  r6, r6.b0, 0b00000001
        
		//Setting the value for the out pin
		MOV  r2, 1 << 31  	//move out pin to  
		SBBO r2, r5, 0, 4   // the p8_20 pin is HIGH
		
		        
        
		//Setting the value the out pin CP
		MOV  r7, 1 << 14    //move out pin to  
		SBBO r7, r5, 0, 4   // the p8_16 pin is HIGH        
         
        
        
        MOV r1, 20000000                    // set up for a .4 second delay

        // perform a half second delay
LL2:     SUB r1, r1, 1                       // subtract 1 from R1
        QBNE LL2, r1, 0                      // is R1 == 0? if no, then goto L1
      		

        SUB r0, r0, 1
        QBEQ L_OUT1, r0, 0 
        QBNE BIT_D, r0, 0 






//STORE 0 VALUE IN THE REGISTER
BIT_CLR:
		//PERFORM THE LEFT SHIFT OPERATION ON THE REGISTER R6
		LSL r6, r6, 1		
		
		
		//Setting the value the out pin CP
		MOV  r2, 1 << 14    //move out pin to  
		SBBO r2, r5, 0, 4   // the p8_16 pin is HIGH  

         MOV r1, 20000000                    // set up for a half second delay

        // perform a half second delay
        
LL3:    SUB r1, r1, 1                       // subtract 1 from R1
        QBNE LL3, r1, 0                      // is R1 == 0? if no, then goto L1
        

        SUB r0, r0, 1
        QBEQ L_OUT1, r0, 0 
        QBNE BIT_D, r0, 0      		
	



//--------------------------------------------------------------------
//THE DATA GET LOADED TO THE REGISTER R6
//--------------------------------------------------------------------



//--------------------------------------------------------------------
//OUTPUT OF THE STORE VALUE REFLECTTO THE FIRST SHIFT REGISTER
//--------------------------------------------------------------------

	
L_OUT1:	
		// THE MODE OF 74HC299 FROM LOAD TO SHIFT RIGHT MODE		
		
//////////////////////////////////////////////////////////////////
		// do nothing in THE INPUT SHIFT REGISTER 
	
		//Setting the value   the out pin S0
		MOV  r2, 1 << 13     //move out pin to  
		SBBO r2, r5, 0, 4   // the p8_5 pin is HIGH	
		
		//Setting the value the out pin S1
		MOV  r2, 1 << 12     //move out pin to  
		SBBO r2, r4, 0, 4   // the p8_6 pin is LOW	
////////////////////////////////////////////////////////////


					
		//Setting the value the out pin CP
		MOV  r2, 1 << 14    //move out pin to  
		SBBO r2, r4, 0, 4   // the p8_16 pin is LOW	
		
		
		
	    // move the no of bits to be store in the memory
  		MOV r0, NUMBER_OF_BITS
		
				
		//Setting the value   the out pin CHECK LED
		MOV  r2, 1 << 31    //move out pin to  
		SBBO r2, r5, 0, 4   // the p8_20 pin is HIGH
						
		
		// SETTING UP THE DELAY
		MOV r1, 90000000                    // set up for a .9 second delay				

        // perform a LOOP for delay
LLL1:     SUB r1, r1, 1                       // subtract 1 from R1
	
		// SETTING UP THE DELAY
		MOV r8, 2                      //RUN THE LOOP 9 TIMES				

        // perform a LOOP for delay
LLL2:     SUB r8, r8, 1                       // subtract 1 from R1
        QBNE LLL2, r8, 0                      // is R8 == 0? if no, then goto L1

        QBNE LLL1, r1, 0                      // is R1 == 0? if no, then goto L1

		
L_OUT2:
		// NOW THE DATA STORE IN THE REGISTER IS MADE TO THE DATA PIN OF THE SHIFT REGISTER R6

		
		//Setting the value the out pin DS0
		MOV  r2, 1 << 6    //move out pin to  
		SBBO r2, r4, 0, 4   // the p8_3 pin is LOW


		// SETTING UP THE DELAY
		MOV r1, OFF_DURATION                    // set up for  the delay				

        // perform a LOOP for delay
LLL3:     SUB r1, r1, 1                       // subtract 1 from R1
        QBNE LLL3, r1, 0                      // is R1 == 0? if no, then goto L1
        
		//Setting the value   the out pin CHECK LED
		MOV  r2, 1 << 31    //move out pin to  
		SBBO r2, r4, 0, 4   // the p8_20 pin is LOW
					
					
		//Setting the value the out pin CP
		MOV  r2, 1 << 14    //move out pin to  
		SBBO r2, r4, 0, 4   // the p8_16 pin is LOW	
				
		//CHECK FOR THE SET BIT AND CLEAR BIT ON THE PIN
        QBBS DATA_SET, r6.t7                  // if the bit is high, jump to BIT_HIGH
        QBBC DATA_CLR, r6.t7         	 	 // if the bit is low,  jump to BIT_LOW		 					
		
DATA_SET:
		
		//Setting the value the out pin DS0
		MOV  r2, 1 << 6    //move out pin to  
		SBBO r2, r5, 0, 4   // the p8_3 pin is HIGH

		// SETTING UP THE DELAY
		MOV r1, ON_DURATION                    // set up for  the delay				

        // perform a LOOP for delay
LLL4:     SUB r1, r1, 1                       // subtract 1 from R1
        QBNE LLL4, r1, 0                      // is R1 == 0? if no, then goto L1
        
		//Setting the value   the out pin CHECK LED
		MOV  r2, 1 << 31    //move out pin to  
		SBBO r2, r4, 0, 4   // the p8_20 pin is LOW
		
							
		//Setting the value the out pin CP
		MOV  r2, 1 << 14    //move out pin to  
		SBBO r2, r5, 0, 4   // the p8_16 pin is HIGH	
				
		//shift the bit store in the r6 to the RIGHT
		LSL  r6, r6, 1		
					

		// decrement the value of bits to be store and check its value		
		SUB  r0, r0, 1
        QBEQ OUT, r0, 0 
        QBNE L_OUT2, r0, 0 

DATA_CLR:
		
		//Setting the value the out pin DS0
		MOV  r2, 1 << 6    //move out pin to  
		SBBO r2, r4, 0, 4   // the p8_3 pin is LOW

		// SETTING UP THE DELAY
		MOV r1, OFF_DURATION                    // set up for  the delay				

        // perform a LOOP for delay
LLL5:     SUB r1, r1, 1                       // subtract 1 from R1
        QBNE LLL5, r1, 0                      // is R1 == 0? if no, then goto L1
        
		//Setting the value   the out pin CHECK LED
		MOV  r2, 1 << 31    //move out pin to  
		SBBO r2, r4, 0, 4   // the p8_20 pin is LOW
		
							
		//Setting the value the out pin CP
		MOV  r2, 1 << 14    //move out pin to  
		SBBO r2, r5, 0, 4   // the p8_16 pin is HIGH	
				
		//shift the bit store in the r6 to the RIGHT
		LSL  r6, r6, 1		
					

		// decrement the value of bits to be store and check its value		
		SUB  r0, r0, 1
        QBEQ OUT, r0, 0 
        QBNE L_OUT2, r0, 0 
				
// THIS IS THE HALT OF THE PROGRAM WITH SUSSESSFUL INDICATION SHOWS  BLINKING OF LIGHT AT P8_20 PIN

OUT:
		// SETTING UP THE DELAY
		MOV r1, 1000000                    // set up for a .9 second delay		
		
				
        // perform a LOOP for delay
LLLL:   SUB r1, r1, 1                       // subtract 1 from R1
        QBNE LLLL, r1, 0                      // is R1 == 0? if no, then goto L1

		//Setting the value the out pin CHECK LED
		MOV  r2, 1 << 14    //move out pin to  
		SBBO r2, r4, 0, 4   // the p8_16 pin is LOW
 		
	
		//Setting the value the out pin DS0
		MOV  r2, 1 << 6    //move out pin to  
		SBBO r2, r4, 0, 4   // the p8_3 pin is LOW	

				
		//Setting the value   the out pin CHECK LED
		MOV  r2, 1 << 31    //move out pin to  
		SBBO r2, r5, 0, 4   // the p8_20 pin is HIGH
						
		HALT				