	;program ticks every 4.25 seconds (255*(1/60)s)
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
code
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

curr
	.byte
time1
	.byte
time2
	.byte
time3
	.byte #$00
