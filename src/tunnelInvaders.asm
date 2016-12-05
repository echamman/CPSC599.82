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
    JSR hitdetect	;Check if hit
    JSR checkInput  ;returns user input to Reg Y
	JSR useInput    ;needs comments in function
  	JSR hitdetect	;Check if hit
	JSR musicLoop   ;da beats!
    JSR updatedata  ;based off Reg Y update certain blocks -> needs comments in function
	JSR fillscreen
	JSR updateScore
	JSR printScoreLevel
	JSR waitTurn
    LDA #$01
    BNE gameloop

gameOver
	JSR clearscreen
	LDA #$0
gameOver1
    LDA #$00
    STA $900E
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

hitstart			      ;Prints 'PRESS START' - Appendix E
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
quitIntro2
    LDA $9111
    EOR #$FF
    BNE quitIntro2
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

setchars            ;Store the character set in RAM
    LDA #$FF        ;Tell vic to read chars from RAM
    STA $9005       ;poke 36869,255
    LDA #$1C        ;securing charset location
    STA $0034       ;poke 52,28
    LDA #$1C        ;securing charset location
    STA $0038       ;poke 56,28: CLR
    LDX #$00        ; load x=255 for for loop; loop from 0-511
setchar1
    LDA $8000,x   ;load each char from ROM
    STA $1C00,x    ;store them in 7168-7423
    INX
    CPX #$FF
    BNE setchar1
    LDX #$00
setchar2
    LDA $8100,x
    STA $1D00,x    ;store them in 7424-7680
    INX
    CPX #$FF
    BNE setchar2
storeship          ;function that draws the screen based on whats stored
    LDX #$0
storeship1
    LDA ship,x      ;Chatset location 27 or dec 7440-7448. 9 char change
    STA $1D10,x
    INX
    CPX #$08       ;dec 72 = 1*8
    BNE storeship1
    LDX #$00
block              ;put block char in to screen code 0
    LDA $8330,x
    STA $1C00,x
    INX
    CPX #$08
    BNE block
powerup_obj
    LDX #$0
powerup1
    LDA powerup,x      ;Chatset location 28 or dec 7449-7456
    STA $1D18,x
    INX
    CPX #$08       ;dec 8 = 1*8
    BNE powerup1
falling_obs_obj
    LDX #$0
fallingobs1
    LDA fallingobs,x      ;Chatset location 29 or dec 7457-7464
    STA $1D20,x
    INX
    CPX #$08       ;dec 8 = 1*8
    BNE fallingobs1
static_obs_obj
    LDX #$0
staticobs1
    LDA staticobs,x      ;Chatset location 30 or dec 7465-7472
    STA $1D28,x
    INX
    CPX #$08       ;dec 8 = 1*8
    BNE staticobs1
bullet_obj
    LDX #$0
bullet1
    LDA bullet,x      ;Chatset location 31 or dec 7473-7480
    STA $1D30,x
    INX
    CPX #$08       ;dec 8 = 1*8
    BNE bullet1
    RTS

checkInput			;Stores direction/fire value to Y register
	LDA #$00		;port input mask
	STA $9113		;store to VIA#1 DDR
	LDX $9122		;load VIA#2 DDR to X
	STA $9122		;store to VIA#2 DDR
psf
	;LDA #$00		;zero volume value
	;STA $900A		;store volume
	LDA $9111		;load joystick input
	EOR #$DF		;XOR against bitmask
	BNE psu			;branch to next check
    JSR fireBullet
	;LDA #$0F		;load volume 15
	;STA $900E		;store volume
	;LDA #$87		;load tone value
	;STA $900A		;store to speaker 1
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

fireBullet
    LDA bulletFlag
    CMP #$01
    BEQ fireBulletEnd
    LDA bulletAmmo
    CMP #$00
    BEQ fireBulletEnd
    dec bulletAmmo
    LDA #$01        ;set flag to say bullet is on screen
    STA bulletFlag
    LDA shipcoX     
    STA bulletX     ;set original location of bullet
    LDA shipcoY
    STA bulletY
fireBulletEnd
    RTS
    
updateBullet
    LDA bulletFlag          ;load flag
    CMP #$01                ;check if flag is set
    BNE updateBulletEnd     ;if 0 then do nothing
    INC bulletX             ;else inc bullet x pos
    LDA bulletX             ;
    CMP #$18                ;check to see if offscreen
    BMI updateBulletEnd     ;if not end
    LDA #$00                ;else store that it is offscreen
    STA bulletFlag
updateBulletEnd
    RTS
 
musicLoop
  	LDA #$0F		        ;load volume 15
	STA $900E		        ;store volume                      ;volume
    LDX musicLoopOffset
    LDA sonata,X		;load tone value
	STA $900B		    ;store to speaker 2
    CPX #$34            ;number of notes
    BNE musicLoop1
    LDX #$00
    STX musicLoopOffset
    RTS
musicLoop1
    INX
    STX musicLoopOffset
    RTS

useInput
tryUp
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

;1) load col + 1 in to memory
;2) clear col
;something here
;3) store col = col + 1

updatedata
    LDX #$01
    LDY #$00
    JSR updateBullet
rfupdate
    LDA topset,x
    STA topset,y
    LDA emptyset,x
    STA emptyset,y
    INX
    INY
    CPX #$16
    BMI rfupdate
    JSR algomain
    ;LDA genvalue
    ;LDX #$15
    ;STA emptyset,x
    ;CMP #$0B
    ;BEQ resetgenvalue
    ;ADC #$01
    ;STA genvalue
    ;BVC updatedone
resetgenvalue
    ;LDA #$04
    ;STA genvalue
updatedone
    RTS

algomain
    LDA currLevel
    CMP #$01
    BNE checkAlgo2
	LDA upFlag		;Only update every second loop
	CMP #$02
	BMI noUpdate
	LDA #$00
	STA upFlag
    JSR algo1
checkAlgo2
	LDA currLevel
    CMP #$02
    BNE checkAlgo3
	LDA upFlag		;Only update every third loop
	CMP #$02
	BMI noUpdate
	LDA #$00
	STA upFlag
    JMP algo2
checkAlgo3
	LDA upFlag		;Only update every fourth loop
	CMP #$03
	BMI noUpdate
	LDA #$00
	STA upFlag
    JMP algo3
noUpdate
	INC upFlag
	RTS


algo1
    LDX #$14
    LDA topset,x
    CLC
    CMP #$02
    BMI setDirectionDown
    CMP #$07
    BPL setDirectionUp
    BVC algo1Gen
setDirectionDown
    LDA #$01
    STA drawDirection
    BVC algo1Gen
setDirectionUp
    LDA #$00
    STA drawDirection
    BVC algo1Gen
algo1Gen
    LDA drawDirection
    CMP #$01
    BEQ algo1GenDown
    LDA topset,x
    SEC
    SBC currSubLevel
    LDX #$15
    STA topset,x
    CLC
    ADC #$06
    STA emptyset,x
    BVC algo1done
algo1GenDown
    LDA topset,x
    CLC
    ADC currSubLevel
    LDX #$15
    STA topset,x
    CLC
    ADC #$06
    STA emptyset,x
algo1done
    RTS

algo2
	LDX #$14
	LDA topset,x
	CLC
	CMP #$02
	BMI setDirectionDown2
	CMP #$08
	BPL setDirectionUp2
	BVC algo2Gen
setDirectionDown2
	LDA #$01
	STA drawDirection
	BVC algo2Gen
setDirectionUp2
	LDA #$00
	STA drawDirection
	BVC algo2Gen
algo2Gen
	LDA drawDirection
	CMP #$01
	BEQ algo2GenDown
	JSR getrng
	STY internum
	LDA topset,x
	SEC
	SBC currSubLevel
	SEC
	SBC internum
	LDX #$15
	STA topset,x
	JSR getrng				;0 means add 6, 1 means add 4
	LDX #$15
	CPY #$01
	BEQ add4
	LDA topset,x
	CLC
	ADC #$06
	STA emptyset,x
	BVC algo2done
add4
	LDA topset,x
	CLC
	ADC #$05
	STA emptyset,x
	BVC algo2done
algo2GenDown
	JSR getrng
	STY internum
	LDX #$15
	LDA topset,x
	CLC
	ADC currSubLevel
	CLC
	ADC internum
	LDX #$15
	STA topset,x
	JSR getrng
	LDX #$15
	CPY #$01
	BEQ add4d
	LDA topset,x
	CLC
	ADC #$06
	LDX #$15
	STA emptyset,x
	BVC algo2done
add4d
	LDA topset,x
	CLC
	ADC #$05
	LDX #$15
	STA emptyset,x
algo2done
	RTS

algo3
	LDX #$14
	LDA topset,x
	CLC
	CMP #$04
	BMI setDirectionDown3
	CMP #$05
	BPL setDirectionUp3
	BVC algo3Gen
setDirectionDown3
	LDA #$01
	STA drawDirection
	BVC algo3Gen
setDirectionUp3
	LDA #$00
	STA drawDirection
	BVC algo3Gen
algo3Gen
	LDA drawDirection
	CMP #$01
	BEQ algo3GenDown
	LDA topset,x
	SEC
	SBC #$01
	LDX #$15
	STA topset,x
	LDA #$0D
	STA emptyset,x
	BVC algo3done
algo3GenDown
	LDA topset,x
	CLC
	ADC #$01
	LDX #$15
	STA topset,x
	LDA #$0D
	STA emptyset,x
algo3done
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

colortop	            ;Changes color of char printed, Y val should be internum+1, X is internum+
	CPX shipcoX
	BNE bullett
	CPY shipcoY
	BEQ whitet
bullett
    CPX bulletX
    BNE blackt
    CPY bulletY
    BEQ whitet
blackt
	LDA topset,x
	STA internum
	CPY internum
	BMI colort			;Check if Y is above tunnel
	LDA emptyset,x
	STA internum
	CPY internum
	BPL colort			;Check if Y is below tunnel
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
colort
	TXA
	STY internum
	PHA
	JSR mul22
	PLA
	CLC
	ADC internum
	TAX
	LDA levelcolor
	STA $9600,x			;Print character as level color
	RTS

colorbottom	            ;Changes color of char printed
	CPX shipcoX
	BNE bulletb
	LDA shipcoY
	CMP #$0B
	BMI bulletb
	CLC
	SBC #$0A
	STA internum
	CPY internum
	BEQ whiteb
bulletb
	CPX bulletX
	BNE blackb
	LDA bulletY
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
	BMI colorb			;Check if Y is above tunnel
	LDA #$0C
    CLC
	SBC topset,x
	STA internum
	CPY internum
	BPL colorb			;Check if Y is below tunnel
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
colorb
	TXA
	STY internum
	PHA
	JSR mul22
	PLA
	CLC
	ADC internum
	TAX
	LDA levelcolor
	STA $96F2,x			;Print character as the level color
	RTS

fillscreen				;Keeps an X counter for moving horizontally across screen
	LDX #$00			;Calls filltop and fillbottom to print screen column by column
screenloop
	LDY #$00
	JSR filltop
	LDY #$00
	JSR fillbottom
	INX
	CPX #$16
	BMI screenloop
	RTS

filltop		;Fills top half with columns, prints either black or white block depending on data
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
	CPX shipcoX         ;check to see if we want to draw ship
	BNE drawbullet1
	CPY shipcoY
	BEQ drawship        ;if yes draw ship
drawbullet1
    CPX bulletX         ;check to see if we want to draw bullet
    BNE drawBlock   
    CPY bulletY
    BEQ drawbullet      ;if yes draw bullet
drawBlock
	PLA
	TAY
	LDA #$00			;;Block to print
	STA $1E00,y			;Print at offset
	JMP cont
drawbullet
    PLA
    TAY
    LDA #$22            ; bullet block
    STA $1E00,y
    JMP cont
drawship
	PLA
	TAY
	LDA #$22            ;ship block
	STA $1E00,y			;Print at offset
cont
	LDY depth
	INY
	CPY #$0B			;Compare Y to 11
	BMI fillcol
	RTS

fillbottom
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
	BNE drawbullet1b
	LDA shipcoY
	CMP #$0B
	BMI drawbullet1b
	CLC
	SBC #$0A
	STA internum
	CPY internum
	BEQ drawshipb
drawbullet1b
	CPX bulletX
	BNE drawBlockb
	LDA bulletY
	CMP #$0B
	BMI drawBlockb
	CLC
	SBC #$0A
	STA internum
	CPY internum
	BEQ drawbulletb  
drawBlockb
	PLA
	TAY
	LDA #$00			;;Block to print
	STA $1EF2,y			;Print at offset
	JMP contb
drawshipb
	PLA
	TAY
	LDA #$22
	STA $1EF2,y			;Print at offset
    JMP contb
drawbulletb
    PLA
    TAY
    LDA #$26
    STA $1EF2,y
contb
	LDY depth
	INY
	CPY #$0B			;Compare Y to 11
	BMI fillcolb
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

addPickupToScore
    LDX #$00
pickupScoreLoop
    JSR addTenPickupToScore
    INX
    CPX #$04            ;score value coeffcient on 10
    BNE pickupScoreLoop
addTenPickupToScore
    LDA currScoreTens
    CMP #$09
    BEQ addHunToScore
    ADC #$01
    STA currScoreTens
    RTS

updateScore
    LDA currTurn
    CMP #$02    ;compare to 2s
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
    ;JSR updateLevel     ;For Testing use
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
    JSR updateLevel     ;change level every 100 points
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
    LDA #$00
    STA levelCounter
    LDA currSubLevel
    CMP #$02
    BEQ nextLevel
    CLC
    ADC #$01
    STA currSubLevel
    JSR nextLevelHandler
    BVC endUpdateLevel
nextLevel
    LDA #$01
    STA currSubLevel
    LDA currLevel
    CMP #$03
    BEQ resetLevel
    LDA currLevel
    CLC
    ADC #$01
    STA currLevel
    JSR nextLevelHandler
    BVC endUpdateLevel
resetLevel
    LDA #$01
    STA currLevel
    JSR nextLevelHandler
endUpdateLevel
    RTS

nextLevelHandler            ;functionality for level/sublevels here
	INC levelcolor			;Increments levelcolor incrementer
	LDA levelcolor
	CMP #$07
	BMI noresetc
	LDA #$01
	STA levelcolor
noresetc
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
	ADC #$02
	STA currTime
hold
	LDA $00A2		;load least sig byte of system clock
	CMP currTime
	BNE hold
	RTS

getrng
	LDY currScoreOnes
	LDA $00A2
rngloop
	ADC musicLoopOffset
	ADC $00A2
	DEY
	CPY #$01
	BMI rngloop
	AND #$01
	TAY
	RTS

;=============================================================================
;DATA
    org $1800        ;dec  6144

inputval
	.BYTE $00

currTime
	.BYTE #$00
currTurn
    .BYTE $00

levelCounter
    .BYTE $00
currLevel
    .BYTE $01
currSubLevel
    .BYTE $01

currScoreOnes
	.BYTE $00
currScoreTens
	.BYTE $00
currScoreHuns
	.BYTE $00
currScoreThous
	.BYTE $00
currScoreTThous
	.BYTE $00

drawDirection
    .BYTE $01

ship
    .BYTE   $00,$18,$24,$F3,$7E,$3C,$00,$00

;genvalue            ;seed for tunnel gen
    ;.BYTE #$07

upFlag
	.BYTE $00

topset	;gives information on how many blocks to draw on the top
    .BYTE $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
    .BYTE $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02

emptyset	;gives information on how many empty blocks to draw after top. Val must be bigger than corresponding topset val
	.BYTE $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07
    .BYTE $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07

shipcoX					;X position of ship
	.BYTE #$00
shipcoY					;Y position of ship
	.BYTE #$12

bulletX
    .BYTE $FF
bulletY
    .BYTE $FF
bulletFlag
    .BYTE $00
bulletAmmo
    .BYTE $01
    
depth
    .WORD $00
internum
    .BYTE $00,$00,$00

powerup                 ; to be determined with 50pts
	.BYTE $3C,$42,$99,$BD,$BD,$99,$42,$3C
fallingobs                ;falling obs (non destroyable)
	.BYTE $FF,$FF,$7E,$7E,$3C,$3C,$18,$18
staticobs                    ;destroable terrain
	.BYTE $FF,$3C,$18,$18,$18,$18,$3C,$FF
bullet
    .BYTE $00,$00,$00,$18,$18,$00,$00,$00
    

    
levelcolor
	.BYTE $01

sonata
    .BYTE $00,$C9,$00,$D1,$DB,$D7,$DB,$DB
    .BYTE $00,$C9,$00,$D1,$DB,$D1,$D7,$00
    .BYTE $D7,$C9,$00,$C9,$D7,$00,$C3,$00
    .BYTE $DB,$DB,$00,$00,$DB,$DB,$DF,$DF
    .BYTE $E1,$DF,$D7,$CF,$D1,$CF,$D1,$D1
    .BYTE $00,$D1,$D1,$9F,$93,$00,$93,$00
    .BYTE $93,$C3,$00,$C9

musicLoopOffset
    .BYTE $00
