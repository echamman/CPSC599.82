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
    JSR updatedata  ;based off Reg Y update certain blocks
	JSR drawroof
	JSR drawfloor
	;JSR hitdetect	;Check if hit
	JSR printScoreLevel
	JSR waitTurn
    JSR clearscreen
    LDA #$01
    BNE gameloop

gameOver
	JSR clearscreen

	LDA #$0
	BEQ gameOver

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
	LDA #$00		;zero volume value
	STA $900E		;store volume
	LDA $9111		;load joystick input
	EOR #$DF		;XOR against bitmask
	BNE psu			;branch to next check
	LDA #$0F		;load volume 15
	STA $900E		;store volume
	LDA #$F1		;load tone value
	STA $900A		;store to speaker 1
	;LDA #$ED		;load tone value
	;STA $900B		;store to speaker 2
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


;1) load col + 1 in to memory
;2) clear col
;something here
;3) store col = col + 1

updatedata
    LDX #$01
    LDY #$00
rfupdate
    LDA topscreen,x
    STA topscreen,y
    LDA bottomscreen,x
    STA bottomscreen,y
    INX
    INY
    CPX #$17
    BMI rfupdate
    LDA genvalue
    LDX #$15
    STA topscreen,x
    STA bottomscreen,x
    CMP #$0A
    BEQ resetgenvalue
    ADC #$01
    STA genvalue
    BVC updatedone
resetgenvalue
    LDA #$01
    STA genvalue
updatedone
    RTS

updateship                ;this just draws our ship
	LDY shipcoY				;deciding which drawing function to call based on Y
	CPY #$08				;we need 2 because we cannot use 1 offset for the whole screen
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
	LDX shipco0			;Clearing ship based on offset, done before
    STA $1E16,x			;processing input
    LDA #$20
	STA $1E17,x

updates
	;This is called immediately after getinput, so the Y value contains the direction
	LDY inputval
	CPY #$02
	BNE updatedown
	LDA shipcoY			;check if the Y is 00, if it is don't move up
	CMP #$00
	BEQ drawship01
	DEC shipcoY			;alter Y counter and also offset
	LDA shipco0
	SBC #$16
	STA shipco0
	BEQ drawship01
updatedown
	CPY #$03
	BNE updateleft		;Update Y counter and offset
	LDA shipco0
	ADC #$15
	STA shipco0
	INC shipcoY
	BEQ drawship01
updateleft
	CPY #$04
	BNE updateright
	LDX shipcoX					;Update X counter, and alter offset
	CPX #$0						;also bounds-check X
	BEQ drawship01
	DEC shipcoX
	DEC shipco0
	DEC shipco1
	BEQ drawship01
updateright
	CPY #$05
	BNE drawship01			;Update X counter and offset
	LDX shipcoX
	CPX #$13
	BEQ drawship01
	INC shipcoX
	INC shipco0
	INC shipco1

drawship01
	LDA #$22
	LDX shipco0				;reprint ship based on offset
	STA $1E16,x
	LDA #$23
	STA $1E17,x
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
	LDX shipco1			;Clears ship based on offset, must be one before
	STA $1EC6,x			;processing input, because the process alters the offset
	LDA #$20
	STA $1EC7,x

	;This is called immediately after getinput, so the Y value contains the direction
	LDY inputval
	CPY #$02
	BNE updatedown1
	DEC shipcoY				;Decrementing the Y counter, also checking if you go above the limit because
	LDA shipco1				;then you need to print it with the other function, drawship0, since
	SBC #$16				;it is then in that half
	STA shipco1				;Also adds the appropriate amount to the offset to position the ship
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
	CMP #$12				;modified to allow score space -CJH
	BEQ drawship11
	INC shipcoY
	LDA shipco1
	ADC #$16
	STA shipco1
	BEQ drawship11
updateleft1
	CPY #$04
	BNE updateright1		;Update X counter and offset
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
	LDX shipcoX				;Update X counter and offset
	CPX #$13
	BEQ drawship11
	INC shipcoX
	INC shipco0
	INC shipco1

drawship11
	LDA #$22
	LDX shipco1				;Redraws ship based on offset
	STA $1EC6,x
	LDA #$23
	STA $1EC7,x
	RTS

hitdetect
	LDY shipcoY				;deciding which offset to ceheck based on Y
	CPY #$08
	BMI detectTop
	JMP detectBottom
detectTop					;Hit detection works by checking the square the ship is in after
	LDX shipco0				;drawing the roof and floor
	LDA #$00
	EOR $1E16,x				;Roof and floor clear all squares when drawing, so if the square that the ship is in
	BEQ hitTrue				;is empty, there was no hit
	LDA #$00				;Checks this by XORing the square with 0
	EOR $1E17,x
	BEQ hitTrue
	RTS
detectBottom
	LDX shipco1
	LDA #$00
	EOR $1EC6,x
	BEQ hitTrue
	LDA #$00
	EOR $1EC7,x
	BEQ hitTrue
	RTS
hitTrue
	JMP gameOver			;Jump to the end of game screen

drawroof
    LDX #$00            ;Depth
drnextrow
    INX                 ;increase depth
    CPX #$0C            ;compare depth and elem to 11,21
    BEQ drdone            ;if both 0 then done
    LDY #$FF            ;block element
    STX depth           ;Store depth
drnextcol
    INY
    CLC
    CPY #$16            ;compare y with 22 outtabounds
    BEQ drnextrow        ;if equal to 22 then set y=0, x++

    LDA topscreen,y     ;load the contents of the element of topscreen[y]
    CMP depth           ;compare A with depth
    BMI drnextcol        ;if depth > A then try next element
                ;this chunck is prep for mul22
    TXA                 ;move x -> a
    PHA                 ;push x to stack
    TYA                 ;move y -> a
    PHA                 ;push y to stack
    DEX
    STX internum        ;store (depth-1) -> internum[0]
    JSR mul22           ;calc the mul22 and store in internum[0]
    PLA                 ;pop y off stack to a
    TAY                 ;move a -> y
    PLA                 ;pop x off stack to a
    TAX                 ;move a-> x

    STY oldy
    LDA internum
    ADC oldy
    TAY
    LDA #$00            ;else depth <= A then draw; store block in A
    STA $1E00,y;+((depth-1)*22)         ;print block at y; will need to
    LDY oldy
    JMP drnextcol        ;to next elem
drdone
    RTS

               ;mul22 takes input in at internum[0],output at internum[0]
mul22                   ;assume input is y. F(y) = y*22 = x1 + x2 + x3
    LDA internum
    LDX #$02            ;x=2
    ASL
    ASL
    ASL
    ASL
    STA internum,x      ;internum[2] = x1
    LDA internum
    ASL
    ASL
    DEX
    STA internum,x      ;internum[1] = x2
    LDA internum
    ASL
    ADC internum,x      ;x = x3 + x2
    INX                 ;X = 0
    ADC internum,x      ;x = x + x1
    STA internum
    RTS

drawfloor
    LDX #$0C            ;Depth
dfnextrow
    DEX    ;increase depth
    CPX #$00            ;compare depth and elem to 11,21
    BEQ dfdone            ;if both 0 then done
    LDY #$FF            ;block element
    STX depth           ;Store depth
dfnextcol
    INY
    CLC
    CPY #$16            ;compare y with 22 outtabounds
    BEQ dfnextrow       ;if equal to 22 then set y=0, x++

    LDA bottomscreen,y  ;load the contents of the element of topscreen[y]
    CMP depth           ;compare A with depth
    BPL dfnextcol        ;if depth > A then try next element
                ;this chunck is prep for mul22
    TXA                 ;move x -> a
    PHA                 ;push x to stack
    TYA                 ;move y -> a
    PHA                 ;push y to stack
    DEX
    STX internum        ;store (depth-1) -> internum[0]
    JSR mul22           ;calc the mul22 and store in internum[0]
    PLA                 ;pop y off stack to a
    TAY                 ;move a -> y
    PLA                 ;pop x off stack to a
    TAX                 ;move a-> x

    STY oldy
    LDA internum
    ADC oldy
    TAY
    LDA #$00            ;else depth <= A then draw; store block in A
    STA $1EF2,y;+((depth-1)*22)         ;print block at y; will need to
    LDY oldy
    JMP dfnextcol       ;to next elem
dfdone
    RTS

	;begins at 1FE4, will later run from memory locations for score/level numbers.
	;Need to write int to output conversion method before
printScoreLevel
	LDA #$13		;S
	STA $1FE5
	LDA #$03		;C
	STA $1FE6
	LDA #$0F		;O
	STA $1FE7
	LDA #$12		;R
	STA $1FE8
	LDA #$05		;E
	STA $1FE9
	LDA #$30		;0
	STA $1FEB
	LDA #$30		;0
	STA $1FEC
	LDA #$30		;0
	STA $1FED

	LDA #$0C		;L
	STA $1FF0
	LDA #$05		;E
	STA $1FF1
	LDA #$16		;V
	STA $1FF2
	LDA #$05		;E
	STA $1FF3
	LDA #$0C		;L
	STA $1FF4
	LDA #$31		;1
	STA $1FF6
	LDA #$2D		;-
	STA $1FF7
	LDA #$31		;1
	STA $1FF8

	RTS

waitTurn
	LDA $00A2		;load least sig byte of system clock
	ADC #$03
	STA currTime
hold
	LDA $00A2		;load least sig byte of system clock
	CMP currTime
	BNE hold
	RTS

;=============================================================================
;note: might be better to just store in data the multiples of 22...
;mul22 works fine
;=============================================================================
;DATA
    org $1800        ;dec  6144

oldy
    .WORD $00

currTime
	.BYTE #$00

currScoreOnes
	.BYTE #$00
currScoreTens
	.BYTE #$00
currScoreHuns
	.BYTE #$00

inputval
	.BYTE

ship
    .BYTE   $7C,$23,$10,$08,$08,$10,$23,$7C ;[0][0]
    .BYTE   $00,$F8,$24,$36,$01,$01,$FE,$00 ;[0][1]
    .BYTE   $00,$F8,$24,$36,$01,$01,$FE,$00 ;[0][1]

genvalue
    .BYTE #$03

topscreen	;22 bytes showing the depth of the roof for each spot ($00 = single depth - $0B = 11 depth)
	.BYTE $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.BYTE $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0A

bottomscreen	;22 bytes showing the depth of the floor for each spot ($0B = single height - $00 = 11 height)
	.BYTE $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B
	.BYTE $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $01

;ycoord
    ;.WORD $

shipco0					;offset of ship for top half
	.BYTE #$00

shipco1					;offset of ship for bottom half
	.BYTE #$00

shipcoX					;X position of ship
	.BYTE #$00

shipcoY					;Y position of ship
	.BYTE #$00

depth
    .WORD $00

internum
    .BYTE $00,$00,$00
