
.origin 0
.entrypoint START

// this is the address of the BBB GPIO Bank1 Register. We set bits in special locations in offsets
// here to put a GPIO high or low. It so happens that the BBB USR LED3 is tied to the 24th bit.
// Note GPIO's still have to be enabled in the PINMUX if you want to see the signal on the 
// BBB P8 and P9 Headers. The USR LED3 is usually mux'ed in by default so it is a good one to
// use as an example.
#define GPIO_BANK1 0x4804c000

// set up a value that has a 1 in bit 24. We will later use this to toggle the state of LED3
#define GPIO1_LED3BIT 1<<24

// at this offset various GPIOs are associated with a bit position. Writing a 32 bit value to 
// this offset enables them (sets them high) if there is a 1 in a corresponding bit. A zero 
// in a bit position here is ignored - it does NOT turn the associated GPIO off.
#define GPIO_SETDATAOUT 0x194

// you may think that you turn off (set low) a GPIO by writing a 0 somewhere. After all, you set it
// high with a 1 so why not set it low with a 0. That is NOT the way it works. 
// We set a GPIO low by writing to this offset. In the 32 bit value we write, if a bit is 1 the 
// GPIO goes low. If a bit is 0 it is ignored. Thus we can write the same value (GPIO1_LED3BIT 
// in this example) to two different registers in order to turn it on and then off again.
#define GPIO_CLEARDATAOUT 0x190

// this defines a memory location inside the PRU's address space which we can use to enable
// the PRU to see the BBB's memory as if it were the PRU's memory (and other things too).
#define REGISTER_PRUCFG 0x00026000

        // this label is where the code execution starts
START:

        // Enable the OCP master port, this is what allows the PRU to read/write to the 
        // BBB's main memory (rather than the PRU's own memory). The BBB main memory
        // will be mapped into the PRU address space and you can use it in the PRU as
        // if it belonged to the PRU. Note that the code below will only permit the 
        // PRU to access BBB memory addresses above 0x0008_0000 unless you go to a bit 
        // of extra trouble. This is because below 0x0008_0000 you are hitting the 
        // PRU's own memory regions. See the PRM page 19 Section 3.1.1

        MOV       r3, REGISTER_PRUCFG       // mov the address of the PRUs CFG register into R3
        LBBO      r0, r3, 4, 4              // use R3 to get the contents of the PRUCFG register into R0
        CLR       r0, r0, 4                 // Clear bit 4. This will enable the OCP master port
                                            //     see the PRM page 272 section 10.1.2
        SBBO      r0, r3, 4, 4              // write the modified contents back out

        // Now monitor the state of R31 bit 14, this corresponds to header 8 pin 16
L1:
        QBBS      LED_HIGH, R31.t14         // if the bit is high, jump to LED_HIGH
        QBBC      LED_LOW, R31.t14          // if the bit is low, jump to LED_LOW
        JMP       L1                        // we should never get here unless the bit
                                            // changes between tests

LED_HIGH:
        // turn the LED3 on
        MOV R2, GPIO1_LED3BIT               // reload R2 with the USR3 LEDs enable/disable bit
        MOV R3, GPIO_BANK1+GPIO_SETDATAOUT  // load the address to we wish to set. Note that the
                                            // operation GPIO_BANK1+GPIO_SETDATAOUT is performed
                                            // by the assembler at compile time and the resulting  
                                            // constant value is used. The addition is NOT done 
                                            // at runtime by the PRU!
        SBBO R2, R3, 0, 4                   // write the contents of R2 out to the memory address
                                            // contained in R3. Use no offset from that address
                                            // and copy all 4 bytes of R2
        SET r30.t15                         // R30 bit 15 (header 8 pin 11) also goes high
        JMP  L1                             // test again

LED_LOW:
        // turn the LED3 off
        MOV R2, GPIO1_LED3BIT               // reload R2 with the USR3 LEDs enable/disable bit
        MOV R3, GPIO_BANK1+GPIO_CLEARDATAOUT// load the address we wish to write to. Note that every
                                            // bit that is a 1 will turn off the associated GPIO
                                            // we do NOT write a 0 to turn it off. 0's are simply ignored.
        SBBO R2, R3, 0, 4                   // write the contents of R2 out to the memory address
                                            // contained in R3. Use no offset from that address
                                            // and copy all 4 bytes of R2
        CLR r30.t15                         // R30 bit 15 (header 8 pin 11) also goes low
        JMP       L1                        // test again                                            


