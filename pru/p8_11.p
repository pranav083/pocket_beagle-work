   
 // Boilerplate  
 .origin 0  
 .entrypoint TOP  
   
 TOP:  
  // Writing bit 15 in the magic PRU GPIO output register  
  // PRU0, register 30, bit 15 turns on pin 11 on BeagleBone  
  // header P8.  
  set r30, r30, 15  
   
  // Uncomment to turn the pin off instead.  
  //clr r30, r30, 15  
  ud
  // Interrupt the host so it knows we're done  
  mov r31.b0, 19 + 16  
   
 // Don't forget to halt or the PRU will keep executing and probably  
 // require rebooting the system before it'll work again!  
 halt  
   
