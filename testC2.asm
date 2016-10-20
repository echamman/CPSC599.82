	;program ticks every 4.25 seconds (255*(1/60)s)
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
