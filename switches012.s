.include	"address_map_arm.s"

.global	SWITCHES012

SWITCHES012:

  LDR R0, =SW_BASE
  LDR R0, [R0]

  LDR   R1, =0xFFFEC600  // MPCore private timer base address
  LDR R2, =25000000 //200,000 for load value
  STR R2, [R1] // write to load register


SW0:
  MOV R1, #0b0000000001
  ANDS R1, R1, R0
  BEQ SW1
  LDR   R1, =0xFFFEC600  // MPCore private timer base address
  LDR R2, =35000000 //35,000,000 for load value, slow speed
  STR R2, [R1] // write to load register
SW1:
  MOV R1, #0b0000000010
  ANDS R1, R1, R0
  BEQ SW2
  LDR   R1, =0xFFFEC600  // MPCore private timer base address
  LDR R2, =25000000 //25,000,000 for load value, fair speed
  STR R2, [R1] // write to load register
SW2:
  MOV R1, #0b0000000100
  ANDS R1, R1, R0
  BEQ EXIT_SWITCHES
  LDR   R1, =0xFFFEC600  // MPCore private timer base address
  LDR R2, =15000000 //15,000,000 for load value, fast speed
  STR R2, [R1] // write to load register

EXIT_SWITCHES:
  MOV PC, lr

.end
