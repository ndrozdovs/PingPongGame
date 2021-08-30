.include	"address_map_arm.s"

.global	HEX_DISPLAY_ME

HEX_DISPLAY_ME:
  LDR R0, =HEX3_HEX0_BASE	// based address of HEX display
  LDR R1, =Number
  LDR R1, [R1]
  LDR R5, =Zeros
  LDR R5, [R5]

  CMP R1, #0
  BEQ END_HEX_DISPLAY

Zero:
  CMP R5, #0
  BNE One
  LDR R2, =0b0011111100111111 // display zeros
  STR	R2, [R0]
  B END_HEX_DISPLAY

One:
  CMP R1, #1
  BNE Two
  LDR R2, =0b0011111100000110
  STR	R2, [R0]					// display "01"
  LDR R3, =Check
  MOV R4, #2
  STR R4, [R3]
  B END_HEX_DISPLAY

Two:
  CMP R1, #2
  BNE Three
  LDR R2, =0b0011111101011011
  STR	R2, [R0]					// display "02"
  LDR R3, =Check
  MOV R4, #3
  STR R4, [R3]
  B END_HEX_DISPLAY

Three:
  CMP R1, #3
  BNE Four
  LDR R2, =0b0011111101001111
  STR	R2, [R0]					// display "03"
  LDR R3, =Check
  MOV R4, #4
  STR R4, [R3]
  B END_HEX_DISPLAY

Four:
  CMP R1, #4
  BNE Nice
  LDR R2, =0b0011111101100110
  STR	R2, [R0]					// display "04"
  LDR R3, =Check
  MOV R4, #5
  STR R4, [R3]
  B END_HEX_DISPLAY

Nice:
  CMP R1, #5
  BNE END_HEX_DISPLAY
  LDR R2, =0b00000110001110010111100100000000 // ICE/
  STR	R2, [R0]
	LDR	R0, =HEX5_HEX4_BASE
	LDR R2, =0b0000000001010100 // /n
  STR	R2, [R0]
  MOV R2, #1
  LDR R5, =ZerosAI
  STR R2, [R5]
  LDR R3, =Check
  MOV R4, #5
  STR R4, [R3]
  LDR R2, =EndCheck
  MOV R3, #1
  STR R3, [R2]
  B END_HEX_DISPLAY

END_HEX_DISPLAY:
  MOV PC, lr






Number:
           .word 1
.global Number

Check:
           .word 0
.global Check

Zeros:
           .word 0
.global Zeros

.end
