.origin 0
.entrypoint START

// the number of times we blink the LED
#define NUMBER_OF_BLINKS 10
#define GPIO_BANK1 0x4804c000
#define GPIO1_LED3BIT 1<<24
#define GPIO_SETDATAOUT 0x194
#define GPIO_CLEARDATAOUT 0x190
#define REGISTER_PRUCFG 0x00026000

START:


        MOV       r3, REGISTER_PRUCFG       // mov the address of the PRUs CFG register into R3
        LBBO      r0, r3, 4, 4              // use R3 to get the contents of the PRUCFG register into R0
        CLR       r0, r0, 4                 // Clear bit 4. This will enable the OCP master port
                                            //     see the PRM page 272 section 10.1.2
        SBBO      r0, r3, 4, 4              // write the modified contents back out

        MOV r0, NUMBER_OF_BLINKS            // this is the number of times we wish to blink   

        // delay loops

BLINK:  MOV R1, 50000000                    // set up for a half second delay

        // perform a half second delay
L1:     SUB R1, R1, 1                       // subtract 1 from R1
        QBNE L1, R1, 0                      // is R1 == 0? if no, then goto L1


        SET r30.t15                         // R30 bit 15 (header 8 pin 11) also goes high

        // now we turn the LED3 on
        MOV R2, GPIO1_LED3BIT               // reload R2 with the USR3 LEDs enable/disable bit
        MOV R3, GPIO_BANK1+GPIO_SETDATAOUT  // load the address to we wish to set. Note that the
                                            // operation GPIO_BANK1+GPIO_SETDATAOUT is performed
                                            // by the assembler at compile time and the resulting  
                                            // constant value is used. The addition is NOT done 
                                            // at runtime by the PRU!
        SBBO R2, R3, 0, 4                   // write the contents of R2 out to the memory address
                                            // contained in R3. Use no offset from that address
                                            // and copy all 4 bytes of R2


        // delay loops

        MOV R1, 50000000                    // set up for a half second delay

        // perform a half second delay
L2:     SUB R1, R1, 1                       // subtract 1 from R1
        QBNE L2, R1, 0                      // is R1 == 0? if no, then goto L1

        CLR r30.t15                         // R30 bit 15 (header 8 pin 11) also goes low


        // now we turn the LED3 off again
        MOV R2, GPIO1_LED3BIT               // reload R2 with the USR3 LEDs enable/disable bit
        MOV R3, GPIO_BANK1+GPIO_CLEARDATAOUT // load the address we wish to write to. Note that every
                                            // bit that is a 1 will turn off the associated GPIO
                                            // we do NOT write a 0 to turn it off. 0s are simply ignored.
        SBBO R2, R3, 0, 4                   // write the contents of R2 out to the memory address
                                            // contained in R3. Use no offset from that address
                                            // and copy all 4 bytes of R2

        // the bottom of the BLINK loop. Note that R0 contains the number of remaining blinks. It
        // is UP TO YOU to remember that and not use R0 for something else in the code above. There 
        // is no safety net in assembler :-)
        SUB R0, R0, 1
        QBNE BLINK, R0, 0

        HALT 

