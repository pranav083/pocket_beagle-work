.origin 0
.entrypoint START


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

// set up a value that has a 1 in bit 24. We will later use this to toggle the state of LED3
#define GPIO1_LED3BIT 1<<24

#define CPRUCFG  c4

// the number of times we want button to be pressed
#define NUMBER_OF_BITS 8

#define BUTTON   7  /* P8_16 46 GPIO 1_14 mode 7 */ 
#define BULB1    6  /* P8_3 38 GPIO 1_6 mode 7 */
#define BULB2    12 /* P8_12 44 GPIO 1_12 mode 7 */
#define BULB3    15 /* P8_15 47 GPIO 1_15 mode 7 */



        // this label is where the code execution starts
START:
        // Enable the OCP master port, 
        
  	     lbco r0, CPRUCFG, 4, 4   // read SYSCFG
  		 clr  r0.t4               // clear SYSCFG[STANDBY_INIT]
  		 sbco r0, CPRUCFG, 4, 4   // enable OCP master port;

        MOV r0, NUMBER_OF_BITS            // this is the number of bits you wants to add        
        MOV r7, 1 << 2
        
		//set OUT pin to ouput
		MOV r3, GPIO1 | GPIO_OE
		LBBO r2, r3, 0, 4
		CLR r2, r2, 6   // setting as a output pin
		SBBO r2, r3, 0, 4
		
		//set OUT pin to ouput
		MOV r3, GPIO1 | GPIO_OE
		LBBO r2, r3, 0, 4
		CLR r2, r2, 12   // setting as a output pin
		SBBO r2, r3, 0, 4

		
		//set OUT pin to ouput
		MOV r3, GPIO1 | GPIO_OE
		LBBO r2, r3, 0, 4
		CLR r2, r2, 15   // setting as a output pin
		SBBO r2, r3, 0, 4
			
        
        //set IN pin to for button
		MOV r3, GPIO1 | GPIO_OE
		LBBO r2, r3, 0, 4
		SET r2, r2, 7   // setting as a input pin
		SBBO r2, r3, 0, 4

		//setting the register for data high and low for GPIO0
		MOV r4, GPIO1 | GPIO_CLEARDATAOUT
		MOV r5, GPIO1 | GPIO_SETDATAOUT



BIT_D:  	
		//Setting the value for the out pin
		MOV  r6, 1 << 12  //move out pin to  
		SBBO r6, r4, 0, 4   // the p8_12 pin is high
		
		//Setting the value for the out pin
		MOV  r6, 1 << 6  	//move out pin to  
		SBBO r6, r4, 0, 4   // the p8_4 pin is high
		
		//Setting the value for the out pin
		MOV  r6, 1 << 15  	//move out pin to  
		SBBO r6, r5, 0, 4   // the p8_15 pin is high
			
		//set IN pin to INPUT
		MOV  r3, GPIO1 | GPIO_DATAIN
		LBBO r2, r3, 0, 4    // P8_04


		MOV r1, 50000000                    // set up for a .9 second delay

        // perform a half second delay
L1:     SUB r1, r1, 1                       // subtract 1 from R1
        QBNE L1, r1, 0                      // is R1 == 0? if no, then goto L1
        					


        QBBS BIT_SET, r2.t7                  // if the bit is high, jump to LED_HIGH
        QBBC BIT_CLR, r2.t7         	 	 // if the bit is low,  jump to LED_LOW

BIT_SET:
		//Setting the value for the out pin
		MOV  r6, 1 << 6  	//move out pin to  
		SBBO r6, r5, 0, 4   // the p8_4 pin is high
		
        ADD  r7, r7, 1
        
        MOV r1, 20000000                    // set up for a .4 second delay

        // perform a half second delay
L2:     SUB r1, r1, 1                       // subtract 1 from R1
        QBNE L2, r1, 0                      // is R1 == 0? if no, then goto L1
      		
        SUB r0, r0, 1
        QBEQ END, r0, 0 
        QBNE BIT_D, r0, 0 

BIT_CLR:
		//CHECK FOR FAULTS
		//Setting the value for the out pin
		MOV  r6, 1 << 12  //move out pin to  
		SBBO r6, r5, 0, 4   // the p8_12 pin is high
		

		//Setting the value for the out pin
		MOV  r6, 1 << 15  	//move out pin to  
		SBBO r6, r4, 0, 4   // the p8_15 pin is low
		

         MOV r1, 20000000                    // set up for a half second delay

        // perform a half second delay
        
L3:     SUB r1, r1, 1                       // subtract 1 from R1
        QBNE L3, r1, 0                      // is R1 == 0? if no, then goto L1
        JMP  BIT_D                          // test again      	
        		 
END:
				
		HALT          
        