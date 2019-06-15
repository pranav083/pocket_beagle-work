
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

#define LED_PIN_BIT 23
#define CPRUCFG  c4

#define INS_PER_MS    500 * 1000
#define ON_DURATION   250 * INS_PER_MS
#define OFF_DURATION  250 * INS_PER_MS

// P9_24 gpio0[15] 0x984 pr1_pru0_pru_r31_16
// P9_23 gpio1[17] 0x844
// P8_13 gpio0[23] 0x824
start:
    lbco r0, CPRUCFG, 4, 4   // read SYSCFG
    clr  r0.t4               // clear SYSCFG[STANDBY_INIT]
    sbco r0, CPRUCFG, 4, 4   // enable OCP master port;

//set direction to ouput
MOV r3, GPIO0 | GPIO_OE
LBBO r2, r3, 0, 4
CLR r2, r2, LED_PIN_BIT
SBBO r2, r3, 0, 4

MOV r2, 1 << LED_PIN_BIT
MOV r3, GPIO0 | GPIO_SETDATAOUT
MOV r4, GPIO0 | GPIO_CLEARDATAOUT

AGAIN:
// turn on
SBBO r2, r3, 0, 4
// try EGPIO
SET r30, r30, 15
MOV r0, ON_DURATION

DELAY_ON:
SUB r0, r0, 1
QBNE DELAY_ON, r0, 0

// turn off
SBBO r2, r4, 0, 4
// try EGPIO
CLR r30, r30, 15
MOV r0, OFF_DURATION

DELAY_OFF:
SUB r0, r0, 1
QBNE DELAY_OFF, r0, 0

QBA AGAIN
