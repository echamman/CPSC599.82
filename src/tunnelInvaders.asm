;The full game
;STUB 4096-4110; Code 4110-6144; DATA 6144-7168; Charset 7168-7680
	processor 6502

	seg
	org $1001

	;This is the stub, it calls SYS 4110
stub	.BYTE #$0	;New line
	.BYTE #$0C	;arbitary link values (Non-zero)
	.BYTE #$0A
	.BYTE #$0	;new line
	.BYTE #$9E	;SYS
	.BYTE #$20	;space
	.BYTE #$34	;4
	.BYTE #$31	;1
	.BYTE #$31	;1
	.BYTE #$30	;0
	.BYTE #$0	;END CODE
	.BYTE #$0
	.BYTE #$0

	seg code
	org $100E	;Address 4110, right after stub

    JSR setchars     ;Loads charset from ROM to RAM
    JSR intro
gameloop            ;check input,update data, draw data to screen
    JSR checkInput  ;returns user input to Reg Y
	JSR updateship  ;draw changes to ship
    ;JSR updatedata  ;based off Reg Y update certain blocks
	JSR brendan
	JSR drawfloor
	JSR waitTurn
    LDA #$01
    BNE gameloop

intro
	LDA #$8		;Storing 8 into 36879, full black screen
	STA $900F

 	LDX #$FF	;color1 and color2 change the character colors to white all across the screen - Appendix E
color1	LDA #$1
	STA $95FE,X
	DEX
	CPX #$0
	BNE color1

	LDX #$FF
color2	LDA #$1
	STA $9700,X
	DEX
	CPX #$0
	BNE color2

    JSR clearscreen

msg			        ;Prints 'PRESS START' - Appendix E
	LDA #$10
	STA $1EB6
	LDA #$12
	STA $1EB7
	LDA #$5
	STA $1EB8
	LDA #$13
	STA $1EB9
	LDA #$13
	STA $1EBA
	LDA #$20
	STA $1EBB
	LDA #$13
	STA $1EBC
	LDA #$14
	STA $1EBD
	LDA #$1
	STA $1EBE
	LDA #$12
	STA $1EBF
	LDA #$14
	STA $1EC0

	LDA #$00		;port input mask
	STA $9113		;store to VIA#1 DDR
quitIntro
	LDA $9111		;load joystick input
	EOR #$DF		;XOR against fire button bitmask
	BNE quitIntro		;branch up on no input
    JSR clearscreen
    RTS

clearscreen
	LDX #$FF	    ;print1 and print2 are printing ' ' to the screen - Appendix E
print1
    LDA #$20        ;#$20 is space
	STA $1DFE,X
	DEX
	CPX #$0
	BNE print1

	LDX #$FF
print2
    LDA #$20
	STA $1EFD,X
	DEX
	CPX #$0
	BNE print2
    RTS

checkInput			;Stores direction/fire value to Y register
	LDA #$00		;port input mask
	STA $9113		;store to VIA#1 DDR
	LDX $9122		;load VIA#2 DDR to X
	STA $9122		;store to VIA#2 DDR
psf
	LDA $9111		;load joystick input
	EOR #$DF		;XOR against bitmask
	BNE psu			;branch to next check
	LDY #$01		;1 is stored to Y if fire is held down
	STY inputval
	BNE endInput
psu
	LDA $9111		;load joystick input
	EOR #$FB		;XOR against bitmask
	BNE psd			;branch to next check
	LDY #$02		;2 is stored to Y if up is held down
	STY inputval
	BNE endInput
psd
	LDA $9111		;load joystick input
	EOR #$F7		;XOR against bitmask
	BNE psl			;branch to next check
	LDY #$03		;3 is stored to Y if down is held down
	STY inputval
	BNE endInput
psl
	LDA $9111		;load joystick input
	EOR #$EF		;XOR against bitmask
	BNE psr			;branch to next check
	LDY #$04		;4 is stored to Y if left is held down
	STY inputval
	BNE endInput
psr
	LDA $9120		;load joystick input (VIA2)
	EOR #$7F		;XOR against bitmask
	BNE noPush		;branch to next check
	LDY #$05		;5 is stored to Y if right is held down
	STY inputval
	BNE endInput
noPush
	LDY #$00		;0 is stored to Y if nothing is pushed
	STY inputval
endInput
	STX $9122		;else restore VIA#2
	RTS

setchars             ;Store the character set in RAM
    LDA #$FF        ;Tell vic to read chars from RAM
    STA $9005       ;poke 36869,255
    LDA #$1C        ;securing charset location
    STA $0034       ;poke 52,28
    LDA #$1C        ;securing charset location
    STA $0038       ;poke 56,28: CLR

    LDX #$00        ; load x=255 for for loop; loop from 0-511
setchar1
    LDA $8000,x   ;load each char from ROM
    ;LDA #$FF        ;make each char a block
    STA $1C00,x    ;store them in 7168-7423
    INX
    CPX #$FF
    BNE setchar1

    LDX #$00
setchar2
    LDA $8100,x
    ;LDA #$FF
    STA $1D00,x    ;store them in 7424-7680
    INX
    CPX #$FF
    BNE setchar2

storeship          ;function that draws the screen based on whats stored
    LDX #$0
storeship1
    LDA ship,x      ;Chatset location 27 or dec 7195-7267. 9 char change
    STA $1D10,x
    INX
    CPX #$48       ;dec 72 = 9*8
    BNE storeship1

    LDX #$00
block              ;but block char in to screen code 0
    LDA $8330,x
    STA $1C00,x
    INX
    CPX #$08
    BNE block

    RTS



updatedata


    RTS

updateship                ;this just draws our ship
	LDY shipcoY
	CPY #$08
	BMI drawship0
	JMP drawship1

drawship0
	LDY inputval		;Skip updating ship if no movement
	CPY #$00
	BNE clearship0
	CPY #$01
	BNE clearship0
	JMP drawship01

clearship0
    LDA #$20
	LDX shipco0
    STA $1E16,x
    LDA #$20
	STA $1E17,x
    LDA #$20
    STA $1E18,x
    LDA #$20
    STA $1E2C,x
    LDA #$20
    STA $1E2D,x
    LDA #$20
    STA $1E2E,x
    LDA #$20
    STA $1E42,x
    LDA #$20
    STA $1E43,x
    LDA #$20
    STA $1E44,x

updates
	;This is called immediately after getinput, so the Y value contains the direction
	LDY inputval
	CPY #$02
	BNE updatedown
	LDA shipcoY			;check if the Y is 00, if it is don't move up
	CMP #$00
	BEQ drawship01
	DEC shipcoY
	LDA shipco0
	SBC #$16
	STA shipco0
	BEQ drawship01
updatedown
	CPY #$03
	BNE updateleft
	LDA shipco0
	ADC #$15
	STA shipco0
	INC shipcoY
	BEQ drawship01
updateleft
	CPY #$04
	BNE updateright
	LDX shipcoX
	CPX #$0
	BEQ drawship01
	DEC shipcoX
	DEC shipco0
	DEC shipco1
	BEQ drawship01
updateright
	CPY #$05
	BNE drawship01
	LDX shipcoX
	CPX #$13
	BEQ drawship01
	INC shipcoX
	INC shipco0
	INC shipco1

drawship01
	LDA #$22
	LDX shipco0
	STA $1E16,x
	LDA #$23
	STA $1E17,x
	LDA #$24
	STA $1E18,x
	LDA #$25
	STA $1E2C,x
	LDA #$26
	STA $1E2D,x
	LDA #$27
	STA $1E2E,x
	LDA #$28
	STA $1E42,x
	LDA #$29
	STA $1E43,x
	LDA #$2A
	STA $1E44,x

	RTS
    ;memory the spaceship
    ;print it to screen.

drawship1
	LDY inputval		;Skip updating ship if no movement
	CPY #$00
	BNE clearship1
	CPY #$01
	BNE clearship1
	JMP drawship11

clearship1
	LDA #$20
	LDX shipco1
	STA $1EC6,x
	LDA #$20
	STA $1EC7,x
	LDA #$20
	STA $1EC8,x
	LDA #$20
	STA $1EDC,x
	LDA #$20
	STA $1EDD,x
	LDA #$20
	STA $1EDE,x
	LDA #$20
	STA $1EF2,x
	LDA #$20
	STA $1EF3,x
	LDA #$20
	STA $1EF4,x

	;This is called immediately after getinput, so the Y value contains the direction
	LDY inputval
	CPY #$02
	BNE updatedown1
	DEC shipcoY
	LDA shipco1
	SBC #$16
	STA shipco1
	LDA shipcoY
	CMP #$09
	BPL tempskip
	JMP drawship0
tempskip
	BEQ drawship11
updatedown1
	CPY #$03
	BNE updateleft1
	LDA shipcoY				;Don't move down if ship is at bottom of screen
	CMP #$12
	BEQ drawship11
	INC shipcoY
	LDA shipco1
	ADC #$16
	STA shipco1
	BEQ drawship11
updateleft1
	CPY #$04
	BNE updateright1
	LDX shipcoX
	CPX #$0
	BEQ drawship11
	DEC shipcoX
	DEC shipco0
	DEC shipco1
	BEQ drawship11
updateright1
	CPY #$05
	BNE drawship11
	LDX shipcoX
	CPX #$13
	BEQ drawship11
	INC shipcoX
	INC shipco0
	INC shipco1

drawship11
	LDA #$22
	LDX shipco1
	STA $1EC6,x
	LDA #$23
	STA $1EC7,x
	LDA #$24
	STA $1EC8,x
	LDA #$25
	STA $1EDC,x
	LDA #$26
	STA $1EDD,x
	LDA #$27
	STA $1EDE,x
	LDA #$28
	STA $1EF2,x
	LDA #$29
	STA $1EF3,x
	LDA #$2A
	STA $1EF4,x

	RTS

drawroof
	LDX #$00			;horizontal counter
printcolr
	LDA #$00				;Load roof block
	STA $1E00,x				;print roof block
	INX
	CPX #$16
	BNE printcolr
	RTS



brendan
    LDX #$00            ;Depth
brendan2
    INX                 ;increase depth
    CPX #$0B            ;compare depth and elem to 11,21
    BEQ done            ;if both 0 then done
    LDY #$FF            ;block element
    STX depth           ;Store depth
brendan1
    INY
    CPY #$16            ;compare y with 22 outtabounds
    BEQ brendan2        ;if equal to 22 then set y=0, x++
    BNE next            ;if neq to 22 then print block at y
next
    LDA topscreen,y     ;load the contents of the element of topscreen[y]
    CMP depth           ;compare A with depth
    BMI brendan1        ;if depth > A then try next element
    DEX                 ;x--
    STX internum        ;store (depth-1) -> internum[0]
    INX                 ;restore x++
    JSR mul22
    LDA #$00            ;else depth <= A then draw; store block in A
    STA $1E00,y;+((depth-1)*22)         ;print block at y; will need to
    BEQ brendan1        ;to next elem
done
    RTS
                        ;we have to learn how to push to stack to properly
                        ;save x and y in previous subroutine
mul22                   ;assume input is y. F(y) = y*22 = x1 + x2 + x3
    LDA internum
    LDA #$00            ;x=0
    ASL
    ASL
    ASL
    ASL
    STA internum,x      ;internum[0] = x1
    INX                 ;x=1
    TYA
    ASL
    ASL
    STA internum,x      ;internum[1] = x2
    TYA
    ASL
    ADC internum,x      ;x = x3 + x2
    DEX                 ;X = 0
    ADC internum,x      ;x = x + x1
    STA internum,x
    RTS




drawfloor
	LDX #$00			;counter
	LDY topscreen,x		;Load the number of times we will print a block
printcolf
	LDA #$00				;Load roof block
	STA $1FE4,x				;print roof block
	INX
	CPX #$16
	BNE printcolf
	RTS

waitTurn
	LDA $00A2		;load least sig byte of system clock
	ADC #$02
	STA currTime
hold
	LDA $00A2		;load least sig byte of system clock
	CMP currTime
	BNE hold
	RTS

;=============================================================================
;=============================================================================
;DATA
    org $1800        ;dec  6144

currTime
	.BYTE #$00

inputval
	.BYTE

ship
    .BYTE   $00,$00,$00,$01,$07,$0F,$1F,$3F ;[0][0]
    .BYTE   $00,$00,$00,$F8,$FE,$FF,$FF,$FF ;[0][1]
    .BYTE   $00,$00,$00,$00,$00,$00,$80,$C0 ;[0][2]
    .BYTE   $3F,$7F,$7F,$7F,$7F,$7F,$7F,$7F ;[1][0]
    .BYTE   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ;[1][1]
    .BYTE   $E0,$F8,$FC,$FF,$C0,$C0,$C0,$FF ;[1][2]
    .BYTE   $7F,$3F,$3F,$1F,$0F,$07,$01,$00 ;[2][0]
    .BYTE   $FF,$FF,$FF,$FF,$FF,$FF,$FB,$01 ;[2][1]
    .BYTE   $FC,$F8,$E0,$C0,$E0,$F0,$F0,$E0 ;[2][2]

topscreen	;22 bytes showing the depth of the roof for each spot
	.BYTE $01, $02, $03, $04, $03, $04, $05, $06, $05, $04, $03
	.BYTE $03, $04, $05, $06, $07, $06, $05, $04, $03, $02, $01

bottomscreen	;22 bytes showing the depth of the floor for each spot
	.BYTE $0B, $0a, $09, $08, $07, $06, $05, $04, $05, $06, $07
	.BYTE $07, $06, $05, $04, $03, $04, $05, $06, $07, $08, $09

ycoord
    .WORD $

shipco0
	.BYTE #$00

shipco1
	.BYTE #$00

shipcoX
	.BYTE #$00

shipcoY
	.BYTE #$00

depth
    .BYTE $00

internum
    .BYTE $00,$00
