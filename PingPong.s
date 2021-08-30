//Copied from interrupt_example.s

.include	"address_map_arm.s"
.include	"interrupt_ID.s"

/* ********************************************************************************
* This program demonstrates use of interrupts with assembly language code.
* The program responds to interrupts from the pushbutton KEY port in the FPGA.
*
* The interrupt service routine for the pushbutton KEYs indicates which KEY has
* been pressed on the HEX0 display.
********************************************************************************/

.section .vectors, "ax"

B 			_start					// reset vector
B 			SERVICE_UND				// undefined instruction vector
B 			SERVICE_SVC				// software interrrupt vector
B 			SERVICE_ABT_INST		// aborted prefetch vector
B 			SERVICE_ABT_DATA		// aborted data vector
.word 	0							// unused vector
B 			SERVICE_IRQ				// IRQ interrupt vector
B 			SERVICE_FIQ				// FIQ interrupt vector

.text
.global	_start
.global EXIT_IRQ

_start:
/* Set up stack pointers for IRQ and SVC processor modes */
MOV		R1, #0b11010010					// interrupts masked, MODE = IRQ
MSR		CPSR_c, R1							// change to IRQ mode
LDR		SP, =A9_ONCHIP_END - 3			// set IRQ stack to top of A9 onchip memory
/* Change to SVC (supervisor) mode with interrupts disabled */
MOV		R1, #0b11010011					// interrupts masked, MODE = SVC
MSR		CPSR, R1								// change to supervisor mode
LDR		SP, =DDR_END - 3					// set SVC stack to top of DDR3 memory

BL			CONFIG_GIC							// configure the ARM generic interrupt controller

// write to the pushbutton KEY interrupt mask register
LDR		R0, =KEY_BASE						// pushbutton KEY base address
MOV		R1, #0xF								// set interrupt mask bits
STR		R1, [R0, #0x8]						// interrupt mask register is (base + 8)

// enable IRQ interrupts in the processor
MOV		R0, #0b01010011					// IRQ unmasked, MODE = SVC
MSR		CPSR_c, R0


LDR   R1, =0xFFFEC600  // MPCore private timer base address
LDR R2, =25000000 //200,000 for load value
STR R2, [R1] // write to load register

MOV R2, #0 //prescalar value
MOV R2, R2, LSL #8
STR R2, [R1, #0x8]

MOV R2, #0b111 // set bits: mode = 1 (auto), enable = 1
STR R2, [R1, #0x8] // write to timer control register


LDR   R1, =0xFFC08000  // HPS timer 0
LDR R2, =23 //25 for load value
STR R2, [R1] // write to load register

MOV R2, #0b011 // set bits
STR R2, [R1, #0x8] // write to timer control register


IDLE:
    B 			IDLE									// main program simply idles

/* Define the exception service routines */

/*--- Undefined instructions --------------------------------------------------*/
SERVICE_UND:
  B SERVICE_UND

/*--- Software interrupts -----------------------------------------------------*/
SERVICE_SVC:
  B SERVICE_SVC

/*--- Aborted data reads ------------------------------------------------------*/
SERVICE_ABT_DATA:
  B SERVICE_ABT_DATA

/*--- Aborted instruction fetch -----------------------------------------------*/
SERVICE_ABT_INST:
  B SERVICE_ABT_INST

/*--- IRQ ---------------------------------------------------------------------*/
SERVICE_IRQ:
  PUSH		{R0-R5, LR}

  /* Read the ICCIAR from the CPU interface */
  LDR		R4, =MPCORE_GIC_CPUIF
  LDR		R5, [R4, #ICCIAR]				// read from ICCIAR


  //go to Timer
  CMP   R5, #MPCORE_PRIV_TIMER_IRQ
  BEQ Timer

  //go to AI
  CMP   R5, #HPS_TIMER0_IRQ
  BEQ AI



FPGA_IRQ1_HANDLER:
  CMP		R5, #KEYS_IRQ
UNEXPECTED:	BNE		UNEXPECTED    					// if not recognized, stop here

  BL			KEY_ISR
EXIT_IRQ:
  /* Write to the End of Interrupt Register (ICCEOIR) */
  STR		R5, [R4, #ICCEOIR]			// write to ICCEOIR

  POP		{R0-R5, LR}
  SUBS		PC, LR, #4

/*--- FIQ ---------------------------------------------------------------------*/
SERVICE_FIQ:
  B			SERVICE_FIQ

Timer:
  LDR R0, =Start_Check //This variable cheks if the game has alreayd been started
  LDR R1, [R0]
  CMP R1, #0 //if it is 1, then it means the game is already started and skip the check KEY0 part
  BNE Skip_Start
  PUSH {R0-R5,lr}
  BL HexPlusSwitches
  POP {R0-R5, lr}
  CMP R9, #1 //check KEY0, this button represents (Start game button) at this instance
  BNE EXIT_IRQ
  MOV R1, #1
  STR R1, [R0] //if KEY0 been pressed make Start_Check == 1

Skip_Start:
  BL SWITCHES012

  LDR R0, =0xFFFEC600 //Private timer adress
  MOV R1, #1
  STR R1, [R0,#0xC] //clear interrupt

  LDR R0, =SW_BASE //if switch 4 is fliiped on, go to the new game mode (hitter)
  LDR R0, [R0]
  MOV R1, #0b0000010000
  ANDS R1, R1, R0
  BNE New_Mode

  LDR R0, =Go_To_End //Get the value of Go_to_End
  LDR R0, [R0]
  MOV R1, #1
  CMP R1, R0 //If Go_To_End is 1, go to END_GAME
  PUSH {R0-R5,lr} //Need to push this in order to make everythign else work
  BEQ END_GAME
  POP {R0-R5,lr} //POP either way

  LDR R0, =LEDR_BASE //LED Base
  LDR R1, =Count //Counter
  LDR R2, [R1]

  PUSH {R0-R5, lr} //Display Zeros on the hex display for me
  LDR R0, =Zeros //initialize global variable, and only execute if it is 0
  LDR R0, [R0]
  CMP R0, #0
  BNE POP //If zeros is 1, skip the hex display
  BL HEX_DISPLAY_ME
  POP {R0-R5, lr}
  B Hex_AI

POP:
    POP {R0-R5, lr}

Hex_AI:
  PUSH {R0-R5, lr} //Display Zeros on the hex display for AI
  LDR R0, =ZerosAI //initialize global variable, and only execute if it is ==0
  LDR R0, [R0]
  CMP R0, #0
  BNE POP_AI
  BL HEX_DISPLAY_AI
  POP {R0-R5, lr}
  B Next

POP_AI:
  POP {R0-R5, lr}

Next:
  CMP R2, #1 //if last LED on the right is on, go to Reset
  BEQ RESET
  LDR R3, =511 //If this count is special value 511, go to reset_ai
  CMP R2, R3
  BEQ RESET_AI
  CMP R2, #2 //if second last led on the right is on, go to check if I pressed KEY0
  BEQ CheckME
  CMP R8, #1 //if check variable is 1, go left
  BEQ GoLeft

GoRight:
  MOV R9, #0 //initiliaze KEY0 as 0
  MOV R10, #0 //initiliaze KEY1 as 0
  MOV R8, #0 //make check variable zero
  MOV R2, R2, LSR #1 //move led right
  B Write

GoLeft:
  MOV R9, #0 //initiliaze KEY0 as 0
  MOV R10, #0 //initiliaze KEY1 as 0
  CMP R2, #256 //if second led on the left, chekc if AI hits back
  BEQ CheckAI
  MOV R2, R2, LSL #1 //move led left
  MOV R8, #1 //check variable is one
  B Write

CheckME:
  CMP R9, #1 //if KEY0 is one, move left
  BEQ GoLeft
  B GoRight //otherwise go right, always

CheckAI:
  CMP R6, #0 //if R6 is zero, them AI misses
  BEQ LOAD_511
  B GoRight

LOAD_511:
  LDR R2, =511 //if misses, make count this special value and go to reset ai
  B RESET_AI

RESET:
  STR R2, [R0] //these lines make an idle loop that light up the last led on the right until KEY1 is pressed
  STR R2, [R1]

  PUSH {R0-R5,lr}
  LDR R0, =ZerosAI //Make that zero variable ==one, thus zeros wont be displayed anymore
  MOV R1, #1
  STR R1, [R0]
  BL HEX_DISPLAY_AI //initiate writing the score to my hex display
  MOV R1, #0 //after score is written, make global variable number as 0, thus the score wont be updated until number is anything else
  LDR R0, =NumberAI
  LDR R2, =EndCheck
  LDR R2, [R2]
  STR R1, [R0]

  CMP R2, #1 //if EndCheck is one, go to END_GAME
  BEQ END_GAME

EXIT_END_GAME:
  POP {R0-R5,lr}
  CMP R10, #1 //Checks if KEY0 is pressed
  BNE EXIT_IRQ

  PUSH {R0-R5}
  LDR R0, =NumberAI
  LDR R1, =AICheck
  LDR R1, [R1]
  STR R1, [R0] //Put check variable into Number, check varible has the value of the next score number,
  POP {R0-R5} //so if score is 1, now Number has value 2 and will be written when RESET_AI is executed again

  MOV R2, #512 //Make count 512, and go right (AI sends the ball back)
  B GoRight

RESET_AI:
  ADD R3, R2, #1 //make that value 511 into 512 and light up the last led on the left in a loop until KEY1 is pressed
  STR R3, [R0]
  STR R2, [R1]

  PUSH {R0-R5,lr}
  LDR R0, =Zeros //Make that zero variable ==one, thus zeros wont be displayed anymore
  MOV R1, #1
  STR R1, [R0]
  BL HEX_DISPLAY_ME //initiate writing the score to my hex display
  MOV R1, #0 //after score is written, make global variable number as 0, thus the score wont be updated until number is anything else
  LDR R0, =Number
  LDR R2, =EndCheck
  LDR R2, [R2]
  STR R1, [R0]

  CMP R2, #1
  BEQ END_GAME

  POP {R0-R5,lr}
  CMP R10, #1 //wait for KEY1 to be pressed
  BNE EXIT_IRQ

  PUSH {R0-R5}
  LDR R0, =Number
  LDR R1, =Check
  LDR R1, [R1]
  STR R1, [R0] //Put check variable into Number, check varible has the value of the next score number,
  POP {R0-R5} //so if score is 1, now Number has value 2 and will be written when RESET_AI is executed again

  MOV R2, #2 //ALL of this just makes sure that when KEY1 is pressed the ball is sent bakc correctly by me
  STR R2, [R0] //as in from LED value 2 towards left
  MOV R2, #4
  STR R2, [R1]
  MOV R8, #1
  B EXIT_IRQ

Write:
  STR R2, [R0] //Displays LEDS
  STR R2, [R1]
  B EXIT_IRQ


//AI Regulator
AI:
  LDR R0, =0xFFC08000 //HPS timer base
  LDR R1, [R0,#0xC] //Read value to clear interrupt

  BL SWITCHES789

  B EXIT_IRQ

END_GAME:
  LDR R0, =LEDR_BASE //LED Base
  LDR R1, =End
  LDR R2, [R1] //End variable dictates which Step should be executed

StepA:
  CMP R2, #1
  BNE StepB
  LDR R3, =0b1111111111 //light all of the lights
  MOV R4, #2 //this number will be assigned to End later on in order for it to go to StepB on the next cycle
  B END_END_GAME
StepB:
  CMP R2, #2
  BNE StepC
  LDR R3, =0b1111001111 //lights up all of light except for2, and so on
  MOV R4, #3
  B END_END_GAME
StepC:
  CMP R2, #3
  BNE StepD
  LDR R3, =0b1110000111
  MOV R4, #4
  B END_END_GAME
StepD:
  CMP R2, #4
  BNE StepE
  LDR R3, =0b1100000011
  MOV R4, #5
  B END_END_GAME
StepE:
  CMP R2, #5
  BNE StepF
  LDR R3, =0b1000000001
  MOV R4, #6
  B END_END_GAME
StepF:
  LDR R3, =0b0000000000
  STR R3, [R0] //Displays LEDS
  STR R4, [R1]
  LDR R3, =Go_To_End
  MOV R4, #1
  STR R4, [R3] //Makes Go_To_End 1, in order for it to skip everything and go staright to END_GAME
  CMP R10, #1 //checks KEY1
  BEQ Reset_Game
  POP {R0-R5, lr}
  B EXIT_IRQ

END_END_GAME:
  STR R3, [R0] //Displays LEDS
  STR R4, [R1]
  B EXIT_END_GAME

Reset_Game:
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






Count:
         .word 512
.global Count

Variable:
         .word 0
.global Variable

End:
         .word 1
.global End

Go_To_End:
         .word 0
.global Go_To_End

Start_Check:
         .word 0
.global Start_Check

.end
