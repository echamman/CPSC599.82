;Beeps a godawful note
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
	LDA #$0F    ;volume 15
	STA $900E   ;store the volume in volume memory
	LDA #$87    ;music note C
	STA $900A   ;store into speaker 1
	LDA #$8F    ;load music note C#
	STA $900B   ;store into speaker 2
	BNE code
