
.origin 0
.entrypoint start

#define LED_PIN_BIT 13
#define CPRUCFG  c4

#define INS_PER_MS    300 * 1000
#define ON_DURATION   550 * INS_PER_MS
#define OFF_DURATION  550 * INS_PER_MS

start:
    lbco r0, CPRUCFG, 4, 4   // read SYSCFG
    clr  r0.t4               // clear SYSCFG[STANDBY_INIT]
    sbco r0, CPRUCFG, 4, 4   // enable OCP master port;
    
	MOV r0, ON_DURATION
	
DELAY_ON:SUB r0, r0, 1
	 QBNE DELAY_ON, r0, 0
	
		// try EGPIO
		SET r30, r30, 14
	    MOV r0, OFF_DURATION
	    
DELAY_OFF:SUB r0, r0, 1
	  QBNE DELAY_OFF, r0, 0
	
		// try EGPIO
		CLR r30, r30, 14
	    MOV r0, ON_DURATION
QBA DELAY_ON	 		  
