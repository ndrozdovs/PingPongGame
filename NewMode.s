.include	"address_map_arm.s"

.global	New_Mode

New_Mode:
  LDR R0, =Go_To_End //Get the value of Go_to_End
  LDR R0, [R0]
  CMP R1, R0 //If Go_To_End is 1, go to END_GAME_NEW
  PUSH {R0-R5,lr} //Need to push this in order to make everythign else work
  BEQ END_GAME_NEW
  POP {R0-R5,lr} //POP either way

  LDR R0, =LEDR_BASE //LED Base
  LDR R1, =Count //Counter
  LDR R2, [R1]

  PUSH {R0-R7, lr} //Display Zeros on the hex display for me
  LDR R0, =ZerosNew //initialize global variable, and only execute if it is 0
  LDR R0, [R0]
  CMP R0, #0
  BNE POP_New //If ZerosNew is 1, skip the hex display
  BL HEX_DISPLAY_NEWMODE
  POP {R0-R7, lr}
  B New_GameNext

  POP_New:
    POP {R0-R7, lr}

New_GameNext:
  CMP R2, #1 //if last LED on the right is on, go to End_Game_New
  PUSH {R0-R5, lr}
  BEQ END_GAME_NEW
  POP {R0-R5, lr}
  CMP R2, #2 //if second last led on the right is on, go to check if I pressed KEY0
  BEQ CheckME_New
  CMP R8, #1 //if check variable is 1, go left
  BEQ GoLeft_New

GoRight_New:
  MOV R9, #0 //initiliaze KEY0 as 0
  MOV R10, #0 //initiliaze KEY1 as 0
  MOV R8, #0 //make check variable zero
  MOV R2, R2, LSR #1 //move led right
  B Write_New

GoLeft_New:
  MOV R9, #0 //initiliaze KEY0 as 0
  MOV R10, #0 //initiliaze KEY1 as 0
  CMP R2, #256 //if second led on the left is on, go right
  BEQ GoRight_New
  MOV R2, R2, LSL #1 //move led left
  MOV R8, #1 //check variable is one
  B Write_New

CheckME_New:
  CMP R9, #1 //if KEY0 is one, go to HEX_New
  BEQ HEX_New
  B GoRight_New //otherwise go right, always

HEX_New:
  PUSH {R0-R7, lr}
  LDR R0, =ZerosNew //make ZerosNew == 1, thus zeros arent dispalyed on the hex display anymore, until ZerosNew == 0
  MOV R1, #1
  STR R1, [R0]
  BL HEX_DISPLAY_NEWMODE //display the score in thsi file
  POP {R0-R7, lr}
  B GoLeft_New

Write_New:
  STR R2, [R0] //Displays LEDS
  STR R2, [R1] //save Count
  B EXIT_IRQ

EXIT_END_GAME_NEW: //need this to POP what I pished before going into END_GAME_NEW
  POP {R0-R5,lr}
  B EXIT_IRQ

END_GAME_NEW:
  LDR R0, =LEDR_BASE //LED Base
  LDR R1, =End
  LDR R2, [R1] //End variable dictates which Step should be executed


StepA_NEW:
  CMP R2, #1
  BNE StepB_NEW
  LDR R3, =0b1111111111 //light all of the lights
  MOV R4, #2 //this number will be assigned to End later on in order for it to go to StepB on the next cycle
  B END_END_GAME_NEW
StepB_NEW:
  CMP R2, #2
  BNE StepC_NEW
  LDR R3, =0b1111001111 //lights up all of light except for2, and so on
  MOV R4, #3
  B END_END_GAME_NEW
StepC_NEW:
  CMP R2, #3
  BNE StepD_NEW
  LDR R3, =0b1110000111
  MOV R4, #4
  B END_END_GAME_NEW
StepD_NEW:
  CMP R2, #4
  BNE StepE_NEW
  LDR R3, =0b1100000011
  MOV R4, #5
  B END_END_GAME_NEW
StepE_NEW:
  CMP R2, #5
  BNE StepF_NEW
  LDR R3, =0b1000000001
  MOV R4, #6
  B END_END_GAME_NEW
StepF_NEW:
  LDR R3, =0b0000000000
  STR R3, [R0] //Displays LEDS
  STR R4, [R1]
  LDR R3, =Go_To_End
  MOV R4, #1
  STR R4, [R3] //Makes Go_To_End 1, in order for it to skip everything and go staright to END_GAME
  CMP R10, #1 //checks KEY1
  BEQ Reset_Game_NEW
  POP {R0-R5, lr}
  B EXIT_IRQ

END_END_GAME_NEW:
  STR R3, [R0] //Displays LEDS
  STR R4, [R1]
  B EXIT_END_GAME_NEW

Reset_Game_NEW:
  LDR R0, =Count //all these lines just reset all the gloabl, local variables to their initial values
  LDR R1, =512
  STR R1, [R0]

  LDR R0, =NumberAI
  LDR R1, =AICheck
  LDR R2, =ZerosAI
  LDR R3, =EndCheck
  MOV R4, #0
  MOV R5, #1
  STR R5, [R0]
  STR R4, [R1]
  STR R4, [R2]
  STR R4, [R3]

  LDR R0, =Number
  LDR R1, =Check
  LDR R2, =Zeros
  STR R5, [R0]
  STR R4, [R1]
  STR R4, [R2]

  LDR R0, =Variable
  LDR R1, =End
  LDR R2, =Go_To_End
  LDR R3, =Start_Check
  STR R4, [R0]
  STR R5, [R1]
  STR R4, [R2]
  STR R4, [R3]

  LDR R0, =Count_New
  LDR R1, =ZerosNew
  LDR R2, =Left_Number
  STR R5, [R0]
  STR R4, [R1]
  STR R4, [R2]

  MOV R8, #0
  MOV R9, #0
  MOV R10, #0

  POP {R0-R5,lr}

  B EXIT_IRQ



.end
