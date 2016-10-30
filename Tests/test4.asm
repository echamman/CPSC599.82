; Clear Screen, Print Hello world at mid top.
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

    LDY data1   ;store y = 0
loop1
    LDA #$20	;load 'space' char
    JSR $FFD2
    INY         ;inc y
    CPY #$FD    ; compare it with dec 23*22
    BNE loop1   ; loop until end of row

    LDA data2   ; if data2 is 1 then we done
    CMP #$01
    BEQ print
    LDX data2   ; else load data2
    INX         ; inc data2
    STX data2   ; store it back
    BNE loop1   ; finish 2nd half of clear

    ;first iterate through all channels and open them. ie the character slots


print
    LDA #$08    ;H
    STA $1E05
    LDA #$05    ;E
    STA $1E06
    LDA #$0C    ;L
    STA $1E07
    LDA #$0C    ;L
    STA $1E08
    LDA #$0F    ;O
    STA $1E09
    LDA #$20    ;_
    STA $1E0A
    LDA #$17    ;W
    STA $1E0B
    LDA #$0F    ;O
    STA $1E0C
    LDA #$12    ;R
    STA $1E0D
    LDA #$0C    ;L
    STA $1E0E
    LDA #$04    ;D
    STA $1E0F
    LDA #$21    ;!
    STA $1E10

    LDA #$21
    STA $1FF7

finish
	BNE finish	;loop so it doesn't go back into main BASIC program



data1
    .BYTE #$00
data2
    .BYTE #$00
