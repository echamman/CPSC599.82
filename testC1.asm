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
code
	LDA #$00		;port input mask
	STA $9113		;store to VIA#1 DDR
	LDX $9122		;load VIA#2 DDR to X
	STA $9122		;store to VIA#2 DDR

	LDA $9111		;load joystick input
	EOR #$DF		;XOR against bitmask
	BEQ fire		;branch to fire
psf
	LDA $9111		;load joystick input
	EOR #$FB		;XOR against bitmask
	BEQ up			;branch to up
psu	
	LDA $9111		;load joystick input
	EOR #$F7		;XOR against bitmask
	BEQ down		;branch to down
psd	
	LDA $9111		;load joystick input
	EOR #$EF		;XOR against bitmask
	BEQ left		;branch to left
psl		
	LDA $9120		;load joystick input (VIA2)
	EOR #$7F		;XOR against bitmask
	BEQ right		;branch to right on input
	STX $9122		;else restore VIA#2
	BNE code		;main loop
fire
	LDA #$46		;load F
	JSR $FFD2		;print
	BNE psf			;branch post fire
up
	LDA #$55		;load U
	JSR $FFD2		;print
	BNE psu			;branch post up	
down
	LDA #$44		;load D
	JSR $FFD2		;print
	BNE psd			;branch post down
left
	LDA #$4C		;load L
	JSR $FFD2		;print
	BNE psl			;branch post left
right
	LDA #$52		;load R
	JSR $FFD2		;print
	STX $9122		;restore VIA#2
	BNE code		;main loop