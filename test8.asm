;get 1 char input then print it
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
        LDX #$00
        JSR $FFCF ;get input
        JSR $FFD2 ;print input that is in acc
 
finish
	BNE finish	;loop so it doesn't go back into main BASIC program
 