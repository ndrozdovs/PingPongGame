.include	"address_map_arm.s"

.global	SWITCHES789

SWITCHES789:
  LDR R0, =Variable //timer variable
  LDR R2, [R0]

  LDR R0, =SW_BASE
  LDR R0, [R0]


  ADD R2, R2, #1 //adds 1 to timer varriable
  AND R6, R2, #1 //this is basically MOD 2
  CMP R6, #0
  BNE SW7
  AND R6, R2, #2 //(If R6 is 0 in both of the MOD's then miss, if it is anything but zero, hit back)

SW7:
  MOV R1, #0b0010000000
  ANDS R1, R1, R0
  BEQ SW8
  AND R6, R2, #1 //this is basically MOD 2, easy

SW8:
  MOV R1, #0b0100000000
  ANDS R1, R1, R0
  BEQ SW9
  AND R6, R2, #1 //this is basically MOD 2
  CMP R6, #0
  BNE SW9
  AND R6, R2, #2 //(If R6 is 0 in both of the MOD's then miss, if it is anything but zero, hit back), fair

SW9:
  MOV R1, #0b1000000000
  ANDS R1, R1, R0
  BEQ EXIT_SWITCHES
  AND R6, R2, #1 //this is basically MOD 2
  CMP R6, #0
  BNE EXIT_SWITCHES
  AND R6, R2, #2
  CMP R6, #0
  BNE EXIT_SWITCHES //hard
  AND R6, R2, #4
  CMP R6, #0
  BNE EXIT_SWITCHES
  AND R6, R2, #8

EXIT_SWITCHES:
  LDR R0, =Variable //timer variable
  STR R2, [R0] //update the Variable
  MOV PC, lr
