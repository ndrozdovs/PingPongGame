.include	"address_map_arm.s"

.global	HexPlusSwitches

HexPlusSwitches:

  LDR R0, =SW_BASE
  LDR R0, [R0]

  LDR R2, =HEX3_HEX0_BASE	// based address of HEX display
  LDR R3, =HEX5_HEX4_BASE	// based address of HEX display

Switch0:
  MOV R1, #0b0000000001 //all of these check which switch is on
  ANDS R1, R1, R0
  BEQ Switch1
  LDR R4, =0b00111000001111110111111000000000 //LOw
  STR R4, [R2]
  LDR R4, =0b0000000001101101 //S
  STR R4, [R3]
Switch1:
  MOV R1, #0b0000000010
  ANDS R1, R1, R0
  BEQ Switch2
  LDR R4, =0b01110111000001100101000000000000 //AIr
  STR R4, [R2]
  LDR R4, =0b0000000001110001 //F
  STR R4, [R3]
Switch2:
  MOV R1, #0b0000000100
  ANDS R1, R1, R0
  BEQ Switch4
  LDR R4, =0b01110111011011010111100000000000 //ASt
  STR R4, [R2]
  LDR R4, =0b0000000001110001 //F
  STR R4, [R3]
Switch4:
  MOV R1, #0b0000010000
  ANDS R1, R1, R0
  BEQ Switch7
  LDR R4, =0b01111000011110000111100101010000 //ttEr
  STR R4, [R2]
  LDR R4, =0b0111011000000110 //HI
  STR R4, [R3]
Switch7:
  MOV R1, #0b0010000000
  ANDS R1, R1, R0
  BEQ Switch8
  LDR R4, =0b01110111011011010110111000000000 //ASY
  STR R4, [R2]
  LDR R4, =0b0000000001111001 //E
  STR R4, [R3]
Switch8:
  MOV R1, #0b0100000000
  ANDS R1, R1, R0
  BEQ Switch9
  LDR R4, =0b01110111000001100101000000000000 //AIr
  STR R4, [R2]
  LDR R4, =0b0000000001110001 //F
  STR R4, [R3]
Switch9:
  MOV R1, #0b1000000000
  ANDS R1, R1, R0
  BEQ EXIT_HexPlusSwitches
  LDR R4, =0b01110111010100000101111000000000 //Ard
  STR R4, [R2]
  LDR R4, =0b0000000001110110 //H
  STR R4, [R3]


EXIT_HexPlusSwitches:
  MOV PC, lr
