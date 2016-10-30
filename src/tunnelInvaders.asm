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
start	;LDA #$FF	;Nuke character map
	;STA $9005

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

input
	LDA $9111		;load joystick input
	EOR #$DF		;XOR against fire button bitmask
	BNE input		;branch up on no input
