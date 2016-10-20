;Prints strings, though can only be up to length 255. We can seem to figure out finding a EOL character.
;Also memory is tested and works here.
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

    