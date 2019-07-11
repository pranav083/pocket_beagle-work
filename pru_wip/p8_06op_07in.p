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

#define BUTTON  7 /* P8_16 46 GPIO 1_14 mode 7 */ 
#define BULB    6 /* P8_12 44 GPIO 1_12 mode 7 */

#define CPRUCFG  c4

        // this label is where the code execution starts
START:
        // Enable the OCP master port, 
        
  	     lbco r0, CPRUCFG, 4, 4   // read SYSCFG
  		 clr  r0.t4               // clear SYSCFG[STANDBY_INIT]
  		 sbco r0, CPRUCFG, 4, 4   // enable OCP master port;

		//set OUT pin to ouput
		MOV  r3, GPIO1 | GPIO_OE
		LBBO r2, r3, 0, 4
		CLR  r2, r2, 6   // setting as a output pin
		SBBO r2, r3, 0, 4
		

		//set IN pin to for button
		MOV r3, GPIO1 | GPIO_OE
		LBBO r2, r3, 0, 4
		SET r2, r2, 7   // setting as a output pin
		SBBO r2, r3, 0, 4

		//setting the register for data high and low for GPIO0
		MOV r5, GPIO1 | GPIO_SETDATAOUT
		MOV r4, GPIO1 | GPIO_CLEARDATAOUT
L1:						
		//set IN pin to INPUT
		MOV  r3, GPIO1 | GPIO_DATAIN
		LBBO r2, r3, 0, 4

        // Now monitor the state of R31 bit 14, this corresponds to header 8 pin 16

        QBBS      LED_HIGH, r2.t7         // if the bit is high, jump to LED_HIGH
        QBBC      LED_LOW, r2.t7          // if the bit is low, jump to LED_LOW
        JMP       L1                        // we should never get here unless the bit
                                            // changes between tests

LED_HIGH:
		//Setting the value for the out pin
		MOV  r2, 1 << 6  //move out pin to  
		SBBO r2, r4, 0, 4   // the p8_12 pin is low
		
        JMP  L1                             // test again

LED_LOW:
		//Setting the value for the out pin
		MOV  r2, 1 << 6  //move out pin to  
		SBBO r2, r5, 0, 4   // the p8_12 pin is HIGH

        JMP       L1                        // test again                                            

