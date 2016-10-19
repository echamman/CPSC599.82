	processor 6502

	seg
	org $1001

stub	.BYTE #$0	;Link stuff
	.BYTE #$0C
	.BYTE #$0A
	.BYTE #$0
	.BYTE #$9E	;SYS 4400
	.BYTE #$20
	.BYTE #$34
	.BYTE #$34
	.BYTE #$30
	.BYTE #$30
	.BYTE #$0
	.BYTE #$0
	.BYTE #$0

	seg code
	org $1130
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
