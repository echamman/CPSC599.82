;pauses the ticks on joystick fire button
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
	org $1130
code
	LDA #$00		;port input mask
	STA $9113		;store to VIA#1 DDR
	LDA $9111		;load joystick input
	EOR #$DF		;XOR against bitmask
	BEQ ptog		;branch to fire
pch
	LDA pausebool	;load current pause bool
	CMP #$00		;compare againt not pasued
	BEQ tick		;if so tick
	BNE code		;if not loop
ptog		
	LDA pausebool	;load current pause values
	CMP #$00		;is it not paused
	BEQ set1		;if so set to 1
	LDA #$00		;if not load 0
	STA pausebool	;store to pausebool
	BVC pch			;branch up
set1
	LDA #$01		;load 1
	STA pausebool	;set 1
	BNE pch			;branch up
tick
	LDA $00A2		;load least sig byte of system clock
	EOR #$FF		;check against mask
	BNE code		;loop if not equal
	LDA #$54		;load T
	JSR $FFD2		;print
hold
	LDA $00A2		;busy wait until next tick
	EOR #$FF		;load current tick mask
	BEQ hold		;hold if true
	BNE code		;main loop

pausebool
	.byte #$00