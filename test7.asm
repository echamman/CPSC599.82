;Prints strings, though can only be up to length 255. We can seem to figure out finding a EOL character.
;Also memory is tested and works here.
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
        LDX #$00
RD      JSR $FFCF ;get input
        ;LDX #$00
        ;can only do one char until we learn how to store memory

        STA data1,X
        INX
        CMP #$0D
        BNE RD
        CPX #$FF
        BEQ print

        LDX #$00
print
        LDA data1,X
        JSR $FFD2
        INX
        CMP #$0D
        BNE print
        CPX #$FF
        BEQ finish

finish
	BNE finish	;loop so it doesn't go back into main BASIC program

data1
    .byte   #$00
    .byte   #$00
    .byte   #$00
    .byte   #$00
    .byte   #$00
    .byte   #$00
    .byte   #$00
    .byte   #$00
    .byte   #$00
    .byte   #$00
    .byte   #$00
    .byte   #$00
    .byte   #$00
    .byte   #$00
    .byte   #$00
    .byte   #$00
    .byte   #$00
    .byte   #$00
    .byte   #$00
    .byte   #$00
    .byte   #$00
