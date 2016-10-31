;The full game

	processor 6502

	seg
	org $1001

	;This is the stub, it calls SYS 4110
stub	.BYTE #$0	;New line
	.BYTE #$0C	;arbitary link values (Non-zero)
	.BYTE #$0A
	.BYTE #$0	;new line
	.BYTE #$9E	;SYS
	.BYTE #$20	;space
	.BYTE #$34	;4
	.BYTE #$31	;1
	.BYTE #$31	;1
	.BYTE #$30	;0
	.BYTE #$0	;END CODE
	.BYTE #$0
	.BYTE #$0

	seg code
	org $100E	;Address 4110, right after stub

    JSR intro
gameloop
    JSR main
    LDA #$01
    BNE gameloop

intro
	LDA #$8		;Storing 8 into 36879, full black screen
	STA $900F

 	LDX #$FF	;color1 and color2 change the character colors to white all across the screen - Appendix E
color1	LDA #$1
	STA $95FE,X
	DEX
	CPX #$0
	BNE color1

	LDX #$FF
color2	LDA #$1
	STA $9700,X
	DEX
	CPX #$0
	BNE color2

    JSR clearscreen

msg			;Prints 'PRESS START' - Appendix E
	LDA #$10
	STA $1EB6
	LDA #$12
	STA $1EB7
	LDA #$5
	STA $1EB8
	LDA #$13
	STA $1EB9
	LDA #$13
	STA $1EBA
	LDA #$20
	STA $1EBB
	LDA #$13
	STA $1EBC
	LDA #$14
	STA $1EBD
	LDA #$1
	STA $1EBE
	LDA #$12
	STA $1EBF
	LDA #$14
	STA $1EC0

	LDA #$00		;port input mask
	STA $9113		;store to VIA#1 DDR
quitIntro
	LDA $9111		;load joystick input
	EOR #$DF		;XOR against fire button bitmask
	BNE intro		;branch up on no input
    RTS

clearscreen
	LDX #$FF	;print1 and print2 are printing ' ' to the screen - Appendix E
print1	LDA #$20
	STA $1DFE,X
	DEX
	CPX #$0
	BNE print1

	LDX #$FF
print2	LDA #$20
	STA $1EFD,X
	DEX
	CPX #$0
	BNE print2
    RTS

checkInput			;Stores direction/fire value to Y register
	LDA #$00		;port input mask
	STA $9113		;store to VIA#1 DDR
	LDX $9122		;load VIA#2 DDR to X
	STA $9122		;store to VIA#2 DDR
psf
	LDA $9111		;load joystick input
	EOR #$DF		;XOR against bitmask
	BNE psu			;branch to next check
	STY #$01		;1 is stored to Y if fire is held down
	BEQ endInput
psu
	LDA $9111		;load joystick input
	EOR #$FB		;XOR against bitmask
	BNE psd			;branch to next check
	STY #$02		;2 is stored to Y if up is held down
	BEQ endInput
psd
	LDA $9111		;load joystick input
	EOR #$F7		;XOR against bitmask
	BNU psl			;branch to next check
	STY #$03		;3 is stored to Y if down is held down
	BEQ endInput
psl
	LDA $9111		;load joystick input
	EOR #$EF		;XOR against bitmask
	BEQ psr			;branch to next check
	STY #$04		;4 is stored to Y if left is held down
	BEQ endInput
psr
	LDA $9120		;load joystick input (VIA2)
	EOR #$7F		;XOR against bitmask
	BEQ noPush		;branch to next check
	STY #$05		;5 is stored to Y if right is held down
	BEQ endInput
noPush
	STY #$00		;0 is stored to Y if nothing is pushed
endInput
	STX $9122		;else restore VIA#2
	RTS

main
    JSR clearscreen
    JSR checkInput
    RTS
    ;memory the spaceship
    ;print it to screen.
