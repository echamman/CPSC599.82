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
	LDX #$FF	;I believe start1 and start2 are clearing the screen somehow
start1	LDA #$0
	STA $1DFE,X
	DEX
	CPX #$0
	BNE start1
	LDX #$FF
start2	LDA #$0
	STA $1EFD,X
	DEX
	CPX #$0
	BNE start2


	BEQ start	;Branch to start screen
