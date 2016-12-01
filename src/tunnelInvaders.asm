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
	JSR useInput
	;JSR updateship  ;draw changes to ship
    JSR updatedata  ;based off Reg Y update certain blocks
	JSR filltop
	JSR fillbottom
	JSR hitdetect	;Check if hit
	JSR updateScore
	JSR printScoreLevel
	JSR waitTurn
    ;JSR clearscreen
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

useInput
	CPY #$02
	BNE tryDown
	LDA shipcoY
	CMP #$00
	BEQ endUse
	DEC shipcoY
	LDA #$00
	BEQ endUse
tryDown
	CPY #$03
	BNE tryLeft
	LDA shipcoY
	CMP #$15
	BEQ endUse
	INC shipcoY
	LDA #$00
	BEQ endUse
tryLeft
	CPY #$04
	BNE tryRight
	LDA shipcoX
	CMP #$00
	BEQ endUse
	DEC shipcoX
	LDA #$00
	BEQ endUse
tryRight
	CPY #$05
	BNE endUse
	LDA shipcoX
	CMP #$15
	BEQ endUse
	INC shipcoX
	LDA #$00
	BEQ endUse
endUse
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
    LDA topset,x
    STA topset,y
    LDA emptyset,x
    STA emptyset,y
    INX
    INY
    CPX #$16
    BMI rfupdate
    LDA genvalue
    LDX #$15
    ;STA topset,x
    STA emptyset,x
    CMP #$0B
    BEQ resetgenvalue
    ADC #$01
    STA genvalue
    BVC updatedone
resetgenvalue
    LDA #$04
    STA genvalue
updatedone
    RTS

updateship                ;this just draws our ship
	LDY shipcoY				;deciding which drawing function to call based on Y
	CPY #$09				;we need 2 because we cannot use 1 offset for the whole screen
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
    STA $1E00,x			;processing input
    LDA #$20
	STA $1E01,x

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
	STA $1E00,x
	LDA #$23
	STA $1E01,x
	LDA #$01				;Change char to white
	STA $9600,x
	STA $9601,x
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
	STA $1EB0,x			;processing input, because the process alters the offset
	LDA #$20
	STA $1EB1,x

	;This is called immediately after getinput, so the Y value contains the direction
	LDY inputval
	CPY #$02
	BNE updatedown1
	DEC shipcoY				;Decrementing the Y counter, also checking if you go above the limit because
	LDA shipco1				;then you need to print it with the other function, drawship0, since
	SBC #$16				;it is then in that half
	STA shipco1				;Also adds the appropriate amount to the offset to position the ship
	LDA shipcoY
	CMP #$08
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
	STA $1EF2,x
	LDA #$23
	STA $1EF3,x
	LDA #$01				;Change char to white
	STA $96F2,x
	STA $96F3,x
	RTS

hitdetect
	LDX shipcoX			;Load X
	LDY shipcoY			;Load Y
	CPY #$0B
	BMI hitTop		;If Y is in top half, jump there
	CLC
	LDA shipcoY
	SBC #$0A		;Else subtract 10 from Y so it is a usable value
	TAY
	LDA #$00
	BEQ hitBottom
hitTop
	LDA topset,x
	STA internum
	CPY internum
	BMI hitTrue
	LDA emptyset,x
	STA internum
	CPY internum
	BPL hitTrue
	RTS
hitBottom
	LDA #$0C
	CLC
	SBC emptyset,x
	STA internum
	CPY internum
	BMI hitTrue
	LDA #$0C
	CLC
	SBC topset,x
	STA internum
	CPY internum
	BPL hitTrue
	RTS
hitTrue
	JMP gameOver			;Jump to the end of game screen

colortop	;Changes color of char printed, Y val should be internum+1, X is internum+
	CPX shipcoX
	BNE blackt
	CPY shipcoY
	BEQ whitet
blackt
	LDA topset,x
	STA internum
	CPY internum
	BMI whitet			;Check if Y is above tunnel
	LDA emptyset,x
	STA internum
	CPY internum
	BPL whitet			;Check if Y is below tunnel
	TXA
	STY internum
	PHA
	JSR	mul22
	PLA
	CLC
	ADC internum
	TAX
	LDA #$00
	STA $9600,x			;Print character as
	RTS
whitet
	TXA
	STY internum
	PHA
	JSR mul22
	PLA
	CLC
	ADC internum
	TAX
	LDA #$01
	STA $9600,x			;Print character as
	RTS

colorbottom	;Changes color of char printed
	CPX shipcoX
	BNE blackb
	LDA shipcoY
	CMP #$0B
	BMI blackb
	CLC
	SBC #$0A
	STA internum
	CPY internum
	BEQ whiteb
blackb
	LDA #$0C
	CLC
	SBC emptyset,x
	STA internum
	CPY internum
	BMI whiteb			;Check if Y is above tunnel
	LDA #$0B
	SBC topset,x
	STA internum
	CPY internum
	BPL whiteb			;Check if Y is below tunnel
	TXA
	STY internum
	PHA
	JSR	mul22
	PLA
	CLC
	ADC internum
	TAX
	LDA #$00
	STA $96F2,x			;Print character as black
	RTS
whiteb
	TXA
	STY internum
	PHA
	JSR mul22
	PLA
	CLC
	ADC internum
	TAX
	LDA #$01
	STA $96F2,x			;Print character as white
	RTS

filltop		;Fills top half with columns, prints either black or white block depending on data
	LDX #$00 			;Length along top moved
	LDY #$00			;Depth of columns
fillcol
	TXA
	PHA
	TYA
	PHA
	JSR colortop
	PLA
	TAY
	PLA
	TAX
	STY depth			;Keep Y in the depth for later use
	STY internum
	TXA
	PHA					;Push X to stack
	JSR mul22
	PLA					;Pull X
	TAX
	CLC
	ADC internum		;Adding the x value to the y val for offset
	PHA					;Push this to stack
	LDY depth
	CPX shipcoX
	BNE drawBlock
	CPY shipcoY
	BEQ drawship
drawBlock
	PLA
	TAY
	LDA #$00			;;Block to print
	STA $1E00,y			;Print at offset
	LDA #$00
	BEQ cont
drawship
	PLA
	TAY
	LDA #$23
	STA $1E00,y			;Print at offset
cont
	LDY depth
	INY
	CPY #$0B			;Compare Y to 11
	BMI fillcol
	INX
	LDY #$00
	CPX #$16			;Compare x to 23
	BMI fillcol
	RTS

fillbottom
	LDX #$00 			;Length along top moved
	LDY #$00			;Depth of columns
fillcolb
	TXA
	PHA
	TYA
	PHA
	JSR colorbottom
	PLA
	TAY
	PLA
	TAX
	STY depth			;Keep Y in the depth for later use
	STY internum
	TXA
	PHA					;Push X to stack
	JSR mul22
	PLA					;Pull X
	TAX
	CLC
	ADC internum		;Adding the x value to the y val for offset
	PHA					;Push this to stack
	LDY depth
	CPX shipcoX
	BNE drawBlockb
	LDA shipcoY
	CMP #$0B
	BMI drawBlockb
	CLC
	SBC #$0A
	STA internum
	CPY internum
	BEQ drawshipb
drawBlockb
	PLA
	TAY
	LDA #$00			;;Block to print
	STA $1EF2,y			;Print at offset
	LDA #$00
	BEQ contb
drawshipb
	PLA
	TAY
	LDA #$23
	STA $1EF2,y			;Print at offset
contb
	LDY depth
	INY
	CPY #$0B			;Compare Y to 11
	BMI fillcolb
	INX
	LDY #$00
	CPX #$16			;Compare x to 23
	BMI fillcolb
	RTS

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

    LDA #$0B            ;loads depth 11
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
    LDX #$0B            ;Depth
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
    STA $1E16,y;+((depth-1)*22)         ;print block at y; will need to
    LDY oldy
    JMP dfnextcol       ;to next elem
dfdone
    RTS

updateScore
    LDA currTurn
    CMP #$0A    ;compare to 10
    BEQ addOneToScore
    ADC #$01
    STA currTurn
    BVC updateScoreEnd
addOneToScore
    LDA #$00
    STA currTurn
    LDA currScoreOnes
    CMP #$09
    BEQ addTenToScore
    ADC #$01
    STA currScoreOnes
    BVC updateScoreEnd
addTenToScore
    LDA #$00
    STA currScoreOnes
    LDA currScoreTens
    CMP #$09
    BEQ addHunToScore
    ADC #$01
    STA currScoreTens
    BVC updateScoreEnd
addHunToScore
    LDA #$00
    STA currScoreTens
    LDA currScoreHuns
    CMP #$09
    BEQ addThouToScore
    ADC #$01
    STA currScoreHuns
    JSR updateLevel
    BVC updateScoreEnd
addThouToScore
    LDA #$00
    STA currScoreHuns
    LDA currScoreThous
    CMP #$09
    BEQ addTThousToScore
    ADC #$01
    STA currScoreThous
    BVC updateScoreEnd
addTThousToScore
    LDA #$00
    STA currScoreThous
    LDA currScoreTThous
    CMP #$09
    BEQ updateScoreEnd
    ADC #$01
    STA currScoreTThous
updateScoreEnd
    RTS

updateLevel
    ;LDA levelCounter
    ;CMP #$F0            ;120 loops = 360 jiffies = 1 min WRONG
    ;BEQ nextSubLevel
    ;ADC #$01
    ;STA levelCounter
    ;BVC endUpdateLevel
nextSubLevel
    LDA #$00
    STA levelCounter
    LDA currSubLevel
    CMP #$03
    BEQ nextLevel
    ADC #$01
    STA currSubLevel
    JSR nextLevelHandler
    BVC endUpdateLevel
nextLevel                   ;incs by two for reasons...
    LDA #$01
    STA currSubLevel
    ;LDA currLevel
    ;CMP #$05
    ;BEQ gameWon ;place somewhere to end the game
    LDA currLevel
    ADC #$01
    STA currLevel
    JSR nextLevelHandler
endUpdateLevel
    RTS

nextLevelHandler ;functionality for level/sublevels here
    RTS
	;begins at 1FE4, will later run from memory locations for score/level numbers.
	;Need to write int to output conversion method before
printScoreLevel
	LDA #$13		;S
	STA $1FE4
	LDA #$03		;C
	STA $1FE5
	LDA #$0F		;O
	STA $1FE6
	LDA #$12		;R
	STA $1FE7
	LDA #$05		;E
	STA $1FE8
	CLC
	LDA currScoreTThous		;0 //currScoreHundredThousands
	ADC #$30
	STA $1FEA
	LDA currScoreThous		;0 //currScoreTenThousands
	ADC #$30
	STA $1FEB
	LDA currScoreHuns		;0 //currScoreOnes
	ADC #$30
	STA $1FEC
	LDA currScoreTens		;0 //currScoreTens
	ADC #$30
	STA $1FED
	LDA currScoreOnes       ;0 //currScoreHuns
	ADC #$30
	STA $1FEE

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
	CLC
	LDA currLevel		;1
	ADC #$30
	STA $1FF6
	LDA #$2D		;-
	STA $1FF7
	LDA currSubLevel		;1
	ADC #$30
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
currTurn
    .BYTE #$00

levelCounter
    .BYTE #$00

currLevel
    .BYTE #$01
currSubLevel
    .BYTE #$01

currScoreOnes
	.BYTE #$00
currScoreTens
	.BYTE #$00
currScoreHuns
	.BYTE #$00
currScoreThous
	.BYTE #$00
currScoreTThous
	.BYTE #$00

inputval
	.BYTE

ship
    .BYTE   $7C,$23,$10,$08,$08,$10,$23,$7C ;[0][0]
    .BYTE   $00,$F8,$24,$36,$01,$01,$FE,$00 ;[0][1]
    .BYTE   $00,$F8,$24,$36,$01,$01,$FE,$00 ;[0][1]

genvalue
    .BYTE #$07

topscreen	;22 bytes showing the depth of the roof for each spot ($00 = single depth - $0B = 11 depth)
	.BYTE $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.BYTE $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0A

bottomscreen	;22 bytes showing the depth of the floor for each spot ($0B = single height - $00 = 11 height)
	.BYTE $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B
	.BYTE $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $01

topset	;gives information on how many blocks to draw on the top
    .BYTE $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
    .BYTE $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02

emptyset	;gives information on how many empty blocks to draw after top. Val must be bigger than corresponding topset val
	.BYTE $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07
    .BYTE $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07

;ycoord
    ;.WORD $

shipco0					;offset of ship for top half
	.BYTE #$00

shipco1					;offset of ship for bottom half
	.BYTE #$00

shipcoX					;X position of ship
	.BYTE #$00

shipcoY					;Y position of ship
	.BYTE #$12

depth
    .WORD $00
topoffset
    .WORD $00
emptyoffset
    .WORD $00



internum
    .BYTE $00,$00,$00,$00,$00
