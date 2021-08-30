.include	"address_map_arm.s"

.global	HEX_DISPLAY_NEWMODE

HEX_DISPLAY_NEWMODE:
  LDR R0, =HEX5_HEX4_BASE	// based address of HEX display
  LDR R1, =0b0000000000000000 // turn off the left most hex Displays, in case they are on from Ping Pong game
  STR	R1, [R0]

  LDR R0, =HEX3_HEX0_BASE	// based address of HEX display
  LDR R1, =Count_New //this variable keeps track of which variable between 1-9 to display
  LDR R4, [R1]
  LDR R2, =ZerosNew //displays 00
  LDR R2, [R2]
  LDR R5, =Left_Number //dictates which number should be on HEX 1, aka to the left of 1-9 number (01-09, 10-19, 20-29...)
  LDR R6, [R5]

  CMP R6, #0
  BNE LeftOne
  LDR R7, =0b00111111 //if left number is 0, the load R7 with the number for 0 on hex display
LeftOne:
  CMP R6, #1
  BNE LeftTwo
  LDR R7, =0b00000110 //and so on up to 9
LeftTwo:
  CMP R6, #2
  BNE LeftThree
  LDR R7, =0b01011011
LeftThree:
  CMP R6, #3
  BNE LeftFour
  LDR R7, =0b01001111
LeftFour:
  CMP R6, #4
  BNE LeftFive
  LDR R7, =0b01100110
LeftFive:
  CMP R6, #5
  BNE LeftSix
  LDR R7, =0b01101101
LeftSix:
  CMP R6, #6
  BNE LeftSeven
  LDR R7, =0b01111101
LeftSeven:
  CMP R6, #7
  BNE LeftEight
  LDR R7, =0b00000111
LeftEight:
  CMP R6, #8
  BNE LeftNine
  LDR R7, =0b01111111
LeftNine:
  CMP R6, #9
  BNE Zero_New
  LDR R7,=0b01101111


Zero_New:
  CMP R2, #0 //compares if zeros is 0 or 1
  BNE One_New
  LSL R7, R7, #8 //left shift r7 (Left_Number), so we get the number and then 8 zeros to the right of this binary number
  LDR R3, =0b00111111 //load R3 with the number we want to display, zero in this case
  ADD R3, R7, R3 //add them thus we get a 16 bit binary number to display on HEX0 and HEX1
  STR R3, [R0] //store that number into Hex0-Hex3 adress
  B END_HEX_DISPLAY_NEWMODE
One_New:
  CMP R4, #1 //compares count to 1 through 10
  BNE Two_New
  LSL R7, R7, #8
  LDR R3, =0b00000110 //same thing as last one but different number on the HEX0, and so on down low
  ADD R3, R7, R3
  STR R3, [R0]
  ADD R4, R4, #1
  STR R4, [R1]
  B END_HEX_DISPLAY_NEWMODE
Two_New:
  CMP R4, #2
  BNE Three_New
  LSL R7, R7, #8
  LDR R3, =0b01011011
  ADD R3, R7, R3
  STR R3, [R0]
  ADD R4, R4, #1
  STR R4, [R1]
  B END_HEX_DISPLAY_NEWMODE
Three_New:
  CMP R4, #3
  BNE Four_New
  LSL R7, R7, #8
  LDR R3, =0b01001111
  ADD R3, R7, R3
  STR R3, [R0]
  ADD R4, R4, #1
  STR R4, [R1]
  B END_HEX_DISPLAY_NEWMODE
Four_New:
  CMP R4, #4
  BNE Five_New
  LSL R7, R7, #8
  LDR R3, =0b01100110
  ADD R3, R7, R3
  STR R3, [R0]
  ADD R4, R4, #1
  STR R4, [R1]
  B END_HEX_DISPLAY_NEWMODE
Five_New:
  CMP R4, #5
  BNE Six_New
  LSL R7, R7, #8
  LDR R3, =0b01101101
  ADD R3, R7, R3
  STR R3, [R0]
  ADD R4, R4, #1
  STR R4, [R1]
  B END_HEX_DISPLAY_NEWMODE
Six_New:
  CMP R4, #6
  BNE Seven_New
  LSL R7, R7, #8
  LDR R3, =0b01111101
  ADD R3, R7, R3
  STR R3, [R0]
  ADD R4, R4, #1
  STR R4, [R1]
  B END_HEX_DISPLAY_NEWMODE
Seven_New:
  CMP R4, #7
  BNE Eight_New
  LSL R7, R7, #8
  LDR R3, =0b00000111
  ADD R3, R7, R3
  STR R3, [R0]
  ADD R4, R4, #1
  STR R4, [R1]
  B END_HEX_DISPLAY_NEWMODE
Eight_New:
  CMP R4, #8
  BNE Nine_New
  LSL R7, R7, #8
  LDR R3, =0b01111111
  ADD R3, R7, R3
  STR R3, [R0]
  ADD R4, R4, #1
  STR R4, [R1]
  B END_HEX_DISPLAY_NEWMODE
Nine_New:
  CMP R4, #9
  BNE Ten_New
  LSL R7, R7, #8
  LDR R3, =0b01101111
  ADD R3, R7, R3
  STR R3, [R0]
  ADD R4, R4, #1
  STR R4, [R1]
  ADD R6, R6, #1 //make Left_Number one digit bigger, thus we go from 09 to 10
  STR R6, [R5]
  B END_HEX_DISPLAY_NEWMODE
Ten_New:
  CMP R4, #10
  BNE END_HEX_DISPLAY_NEWMODE
  LSL R7, R7, #8
  LDR R3, =0b00111111 //this displays zero on HEX0
  ADD R3, R7, R3
  STR R3, [R0] //thus we get "10  or 20 or 30..." because Left_Number is increasing in step before
  SUB R4, R4, #9 //subtract 9 from count, thus we can go from 10 to 1, and then get 11 on display when we return to One_New
  STR R4, [R1]

END_HEX_DISPLAY_NEWMODE:
  MOV PC, lr


Count_New:
            .word 1
.global Count_New
ZerosNew:
            .word 0
.global ZerosNew
Left_Number:
            .word 0
.global Left_Number



.end
