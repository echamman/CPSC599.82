; Clear Screen, Print Hello world at mid top. 
	processor 6502

	seg
	org $1001

stub	.BYTE #$0	;Link stuff
	.BYTE #$0C      ;Link stuff
	.BYTE #$0A      ;10
	.BYTE #$0       ;0
	.BYTE #$9E	;SYS 4400
	.BYTE #$20  ;space
	.BYTE #$34  ;4
	.BYTE #$34  ;4
	.BYTE #$30  ;0
	.BYTE #$30  ;0
	.BYTE #$0   ;END
	.BYTE #$0   ;END
	.BYTE #$0   ;END

	seg code
	org $1130
    
    LDY #$00    ;store y = 0
loop1
    LDA #$20	;load 'space' char
	STA $1E00,y	;store the screen location
    INY         ;inc y
    CPY #$1FA    ; compare it with dec 23*22
    BNE loop1   ; loop until end of row
    
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
    
finish
	BNE finish	;loop so it doesn't go back into main BASIC program

    
    
    
    