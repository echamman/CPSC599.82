;Beeps when fire is held down
	processor 6502

	seg
	org $1001

;This is the stub, it calls SYS 4400, 4400 being the arbitrary address we are writing our machine code at
stub	.BYTE #$0	;New line
	.BYTE #$0C	;arbitary link values (Non-zero)
	.BYTE #$0A
	.BYTE #$0	;new line
	.BYTE #$9E	;SYS
	.BYTE #$20	;space
	.BYTE #$34	;4
	.BYTE #$34	;4
	.BYTE #$30	;0
	.BYTE #$30	;0
	.BYTE #$0	;END CODE
	.BYTE #$0
	.BYTE #$0

	seg code
	org $1130	;Address 4400
code	LDA #$00	;zero volume value
	STA $900E		;store volume
	LDA #$00		;port input mask
	STA $9113		;store to VIA#1 DDR
	LDA $9111		;load joystick input
	EOR #$DF		;XOR against fire button bitmask
	BNE code		;branch up on no input
	LDA #$0F		;load volume 15
	STA $900E		;store volume
	LDA #$87		;load tone value
	STA $900A		;store to speaker 1
	LDA #$8F		;load tone value
	STA $900B		;store to speaker 2
	BNE code	;main loop
