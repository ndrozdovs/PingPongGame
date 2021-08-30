.include	"address_map_arm.s"

.global	HEX_DISPLAY_AI

HEX_DISPLAY_AI:
  LDR R0, =HEX5_HEX4_BASE	// based address of HEX display
  LDR R1, =NumberAI
  LDR R1, [R1]
  LDR R5, =ZerosAI
  LDR R5, [R5]

  CMP R1, #0
  BEQ END_HEX_DISPLAY_AI

ZeroAI:
  CMP R5, #0
  BNE OneAI
  LDR R2, =0b0011111100111111 //display zeros
  STR	R2, [R0]
  B END_HEX_DISPLAY_AI

OneAI:
  CMP R1, #1
  BNE TwoAI
  LDR R2, =0b0011111100000110
  STR	R2, [R0]					// display "01"
  LDR R3, =AICheck
  MOV R4, #2
  STR R4, [R3]
  B END_HEX_DISPLAY_AI

TwoAI:
  CMP R1, #2
  BNE ThreeAI
  LDR R2, =0b0011111101011011
  STR	R2, [R0]					// display "02"
  LDR R3, =AICheck
  MOV R4, #3
  STR R4, [R3]
  B END_HEX_DISPLAY_AI

ThreeAI:
  CMP R1, #3
  BNE FourAI
  LDR R2, =0b0011111101001111
  STR	R2, [R0]					// display "03"
  LDR R3, =AICheck
  MOV R4, #4
  STR R4, [R3]
  B END_HEX_DISPLAY_AI

FourAI:
  CMP R1, #4
  BNE Loser
  LDR R2, =0b0011111101100110
  STR	R2, [R0]					// display "04"
  LDR R3, =AICheck
  MOV R4, #5
  STR R4, [R3]
  B END_HEX_DISPLAY_AI

Loser:
  CMP R1, #5
  BNE END_HEX_DISPLAY_AI
  LDR R2, =0b0011100000111111 // LO
  STR	R2, [R0]
	LDR R0, =HEX3_HEX0_BASE
  LDR R2, =0b01101101011110010101000000000000 //SEr
  STR R2, [R0]
  MOV R2, #1
  LDR R5, =Zeros
  STR R2, [R5]
  LDR R3, =AICheck
  MOV R4, #5
  STR R4, [R3]
  LDR R2, =EndCheck //makes end variable == 1, menaing game is over, which initiates the flashing led sequence
  MOV R3, #1
  STR R3, [R2]
  B END_HEX_DISPLAY_AI

END_HEX_DISPLAY_AI:
  MOV PC, lr



NumberAI:
           .word 1
.global NumberAI

AICheck:
           .word 0
.global AICheck

ZerosAI:
           .word 0
.global ZerosAI

EndCheck:
           .word 0
.global EndCheck

.end
