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
    JSR bulletdetect ; check if bullet hit something
	JSR useInput    ;needs comments in function
  	JSR hitdetect	;Check if hit
    JSR bulletdetect ; check if bullet hit something
	JSR musicLoop   ;da beats!
	JSR spawn		;Calls for spawning of obstables and powerups
    JSR updatedata  ;based off Reg Y update certain blocks -> needs comments in function
	JSR fillscreen	;Draws the screen
	JSR updateScore		;Updates score based on time
	JSR printScoreLevel		;Prints the stats on the bottom of the screen
	JSR waitTurn			;Wait timer
    LDA #$01
    BNE gameloop            ;loop

gameOver
	LDX #$FF	;color3 and color4 change the character colors to white all across the screen - Appendix E
color3
	LDA #$1
	STA $95FE,X
	DEX
	CPX #$0
	BNE color3

	LDX #$FF
color4
	LDA #$1
	STA $9700,X
	DEX
	CPX #$0
	BNE color4
	JSR clearscreen

	LDA #$07   ;G
	STA $1EB6
	LDA #$01    ;A
	STA $1EB7
	LDA #$0D    ;M
	STA $1EB8
	LDA #$05    ;E
	STA $1EB9
	LDA #$0F	;O
	STA $1EBB
	LDA #$16	;V
	STA $1EBC
	LDA #$5		;E
	STA $1EBD
	LDA #$12	;R
	STA $1EBE
	;Print Score
	LDA #$13	;S
	STA $1E47
	LDA #$03	;C
	STA $1E48
	LDA #$0F	;O
	STA $1E49
	LDA #$12	;R
	STA $1E4A
	LDA #$05	;E
	STA $1E4B
	CLC
	LDA currScoreTThous		;0 //currScoreHundredThousands
	ADC #$30
	STA $1E4D
	LDA currScoreThous		;0 //currScoreTenThousands
	ADC #$30
	STA $1E4E
	LDA currScoreHuns		;0 //currScoreOnes
	ADC #$30
	STA $1E4F
	LDA currScoreTens		;0 //currScoreTens
	ADC #$30
	STA $1E50
	LDA currScoreOnes       ;0 //currScoreHuns
	ADC #$30
	STA $1E51
gameOver1
    LDA #$00
    STA $900E
	BEQ gameOver1

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

hitstart			      ;Prints the start screen - Appendix E
	LDA #$14	;T
	STA $1E46
	LDA #$15	;U
	STA $1E47
	LDA #$0E	;N
	STA $1E48
	LDA #$0E	;N
	STA $1E49
	LDA #$05	;E
	STA $1E4A
	LDA #$0C	;L
	STA $1E4B
	LDA #$09	;I
	STA $1E4D
	LDA #$0E	;N
	STA $1E4E
	LDA #$16	;V
	STA $1E4F
	LDA #$01	;A
	STA $1E50
	LDA #$04	;D
	STA $1E51
	LDA #$05	;E
	STA $1E52
	LDA #$12	;R
	STA $1E53
	LDA #$13	;S
	STA $1E54

	LDA #$10    ;P
	STA $1EB6
	LDA #$12    ;R
	STA $1EB7
	LDA #$5     ;E
	STA $1EB8
	LDA #$13    ;S
	STA $1EB9
	LDA #$13	;S
	STA $1EBA
	LDA #$6		;F
	STA $1EBC
	LDA #$9		;I
	STA $1EBD
	LDA #$12	;R
	STA $1EBE
	LDA #$5		;E
	STA $1EBF

	LDA #$02
	STA $96BC
	STA $96BD
	STA $96BE
	STA $96BF


	LDA #$00		;port input mask
	STA $9113		;store to VIA#1 DDR
quitIntro
	LDA $9111		;load joystick input
	EOR #$DF		;XOR against fire button bitmask
	BEQ quitIntro2		;branch up on no input
	LDA $9111
	EOR #$F7			;Check if movement down, gives cheat flag
	BNE quitIntro
	LDA #$01
	STA cheatFlag
quitIntro2
    LDA $9111			;Waits for release of all buttons to start game
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

fireBullet
    LDA bulletFlag
    CMP #$01            ;check if bullet is onscreen
    BEQ fireBulletEnd   ;if so skip
    LDA bulletAmmoOnes  ;else load current ammo
    CMP #$00            ;compare to zero
    BNE continueToFire  ;not zero, fire
    LDA bulletAmmoTens  ;else, check if value is multiple of 10
    CMP #$00
    BEQ fireBulletEnd   ;if also 0, no ammo left
    DEC bulletAmmoTens  ;else dec tens place
    LDA #$0A
    STA bulletAmmoOnes  ;store 10 for immdieiate decriment
continueToFire
    DEC bulletAmmoOnes  ;dec ammo by 1
    LDA #$01
    STA bulletFlag      ;set flag to 1 to say bullet is on screen
    LDA shipcoX         ;load current ship location X
    STA bulletX         ;set original location of bullet
    LDA shipcoY         ;load current ship location Y
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

updatefallingobs
    LDA fallingobsFlag			;Checking if an object is already on screen
    CMP #$01
    BNE updatefallingobsEnd
    DEC fallingobsX				;Moves object left and down
    INC fallingobsY
    LDA fallingobsX
	AND #$7F					;remove neg flag
    CMP #$18					;Removes object when it moves off screen, sets flag to 00
    BMI updatefallingobsEnd
    LDA #$00
    STA fallingobsFlag
updatefallingobsEnd
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
	LDA #$00		;port input mask
	STA $9113		;store to VIA#1 DDR
	;LDX $9122		;load VIA#2 DDR to X
	STA $9122		;store to VIA#2 DDR
tryFire
	LDA $9111		;load joystick input
	EOR #$DF		;XOR against bitmask
	BNE tryUp			;branch to next check
	JSR fireBullet
	JMP endUse
tryUp
	LDA $9111		;load joystick input
	EOR #$FB		;XOR against bitmask
	BNE tryDown
	LDA shipcoY
	CMP #$00		;Won't move up if at top of screen
	BEQ endUse
	DEC shipcoY		;Move the ship Y counter up
	LDA #$00
	BEQ endUse
tryDown
	LDA $9111		;load joystick input
	EOR #$F7		;XOR against bitmask
	BNE tryLeft
	LDA shipcoY
	CMP #$15		;Won't move down if at bottom of screen
	BEQ endUse
	INC shipcoY		;Move ship down
	LDA #$00
	BEQ endUse
tryLeft
	LDA $9111		;load joystick input
	EOR #$EF		;XOR against bitmask
	BNE tryRight
	LDA shipcoX
	CMP #$00		;Don't move left if at edge of screen
	BEQ endUse
	DEC shipcoX
	LDA #$00
	BEQ endUse
tryRight
	LDA $9120		;load joystick input (VIA2)
	EOR #$7F		;XOR against bitmask
	BNE endUse
	LDA shipcoX
	CMP #$15		;Don't move right if at edge of screen
	BEQ endUse
	INC shipcoX
	LDA #$00
	BEQ endUse
endUse
	RTS

spawn
	LDX #00
	STX randobyte	;getrng not random in this instance, use this for randomness
	LDA currScoreOnes
	EOR randobyte
	STA randobyte
	LDX musicLoopOffset
	LDA sonata,x
	EOR randobyte
	STA randobyte	;End of random function
	LDA randobyte
	AND #$01F		;Make it 9 bits
	CMP #$02		;If number is equal to 2, spawn a powerup
	BEQ spawnpUP
	CMP #$04		;If number is equal to 4, spawn falling obstacle
	BEQ spawnObs
	CMP #$06		;If number is equal to 6, spawn wall
	BNE nospawn
spawnWall
	JMP nospawn
spawnObs
	LDA fallingobsFlag		;Make sure no falling object is on screen
	CMP #$01
	BEQ nospawn
	LDX #$15				;Move obstacle onto screen
	LDY #$00
	STX fallingobsX
	STY fallingobsY
	LDA #$01				;Store the flag, indicating obstacle is on screen
	STA fallingobsFlag
	JMP nospawn
spawnpUP
	LDA powerUpFlag			;Don't spawn if powerup is on screen
	CMP #$01
	BEQ nospawn
	LDX #$15
	STX powerUpX
	LDA drawDirection	;Deciding to draw in top tunnel or bottom tunnel
	CMP #$01
	BEQ powerOnb
	LDA topset,x		;Add two to roof, so powerup is not in a wall
	ADC #$02
	STA powerUpY		;Move powerup on screen
	JMP nospawn
powerOnb
	LDA topset,x
	ADC #$02			;Add two to floor, so powerup is not in wall
	STA internum
	LDA #$16
	SEC
	SBC internum
	STA powerUpY		;Move powerup onscreen
nospawn
	CLC
	RTS


;1) load col + 1 in to memory
;2) clear col
;something here
;3) store col = col + 1

updatedata
    JSR updateBullet
    JSR updatefallingobs
	DEC powerUpX
	LDA powerUpX
	AND #$7F			;Remove negative flag if it goes from 0 to 255
	CMP #$17
	BMI ponScreen
	LDA #$00
	STA powerUpFlag
	JMP skipPUps
ponScreen
	LDA #$01
	STA powerUpFlag
skipPUps
	JSR updateBullet
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
    JSR algomain
updatedone
    RTS

algomain			;Branches to correct algorithm, also updates at diff rates for diff algos
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
	CMP #$02
	BMI noUpdate
	LDA #$00
	STA upFlag
    JMP algo3
noUpdate
	INC upFlag
	RTS


algo1						;Steady pattern, up either 1 or 2 until roof, then down
    LDX #$14				;Nothing special
    LDA topset,x
    CLC
    CMP #$02
    BMI setDirectionDown
    CMP #$07
    BPL setDirectionUp
    BVC algo1Gen
setDirectionDown			;Setting direction variables
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
    LDA topset,x			;Drawing upward sloped roof
    SEC
    SBC currSubLevel
    LDX #$15
    STA topset,x
    CLC
    ADC #$06
    STA emptyset,x
    BVC algo1done
algo1GenDown				;Drawing downward sloped roof
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

algo2						;Same as algorithm1, except has randomness in two places
	LDX #$14				;(1) Moves up 1 or up 2 depending on random, (2 or 3 in second sublevel)
	LDA topset,x			;(2) Floor is either 5 or 6 subtracted from roof
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
	STY internum			;Generate upward sloping roof
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
	BEQ add5
	LDA topset,x
	CLC
	ADC #$06				;Floor is 6 away
	STA emptyset,x
	BVC algo2done
add5						;Floor is 5 away
	LDA topset,x
	CLC
	ADC #$05
	STA emptyset,x
	BVC algo2done
algo2GenDown				;Generate downward sloping roof
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
	BEQ add5d
	LDA topset,x
	CLC
	ADC #$06				;Floor is 6 down
	LDX #$15
	STA emptyset,x
	BVC algo2done
add5d
	LDA topset,x			;Floor is 5 down
	CLC
	ADC #$05
	LDX #$15
	STA emptyset,x
algo2done
	RTS

algo3						;Simplest algorithm, no middle portion
	LDX #$14				;Roof gently goes up or down
	LDY topset,x			;Second sublevel is a tighter corridor
	LDA currSubLevel
	ASL
	CLC
	ADC #$03
	STA internum
	CPY internum
	BMI setDirectionDown3
	LDA currSubLevel
	ASL
	CLC
	ADC #$04
	STA internum
	CPY internum
	BPL setDirectionUp3
	BVC algo3Gen
setDirectionDown3				;Setting direction variable
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
	LDA topset,x				;Draw upward sloping roof
	SEC
	SBC #$01
	LDX #$15
	STA topset,x
	LDA #$0D
	STA emptyset,x
	BVC algo3done
algo3GenDown					;Draw downward sloping roof
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
	LDA cheatFlag			;Skip if cheats enabled
	CMP #$01
	BEQ noHit
	JSR powerUpDetect		;Check if ship hit powerup
	JSR obsDetect			;Check if ship hit falling obstacle
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
	LDA topset,x		;Check if ship is between top and bottom
	STA internum
	CPY internum
	BMI hitTrue
	LDA emptyset,x
	STA internum
	CPY internum
	BPL hitTrue
	RTS
hitBottom
	LDA #$0C			;Check if ship is between top and bottom
	CLC					;Extra instructions are for modifying X and Y, since the tunnel is mirrored
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
noHit
	RTS

powerUpDetect				;Checks if shipX and shipY are equal to powerupX and Y
	LDA powerUpX
	CMP shipcoX
	BNE noPUp
	LDA powerUpY
	CMP shipcoY
	BNE noPUp
	JSR addPickupToScore	;Add 20 points
    JSR addPickupToAmmo		;Add 1 to ammo
	LDA #$FF
	STA powerUpX
	LDA #$00
	STA powerUpFlag
noPUp
	RTS

obsDetect					;Simply detects if shipX and Y are equal to obstacleX and Y
	LDA shipcoX
	CMP fallingobsX
	BNE noObsHit
	LDA shipcoY
	CMP fallingobsY
	BNE noObsHit
	JSR gameOver			;Ends game if true
noObsHit
	RTS



bulletdetect
    LDX bulletX         ;load x pos
    LDY bulletY         ;load y pos
    CPY #$0B
    BMI bulletHitTop    ;If Y is in top half, jump there
    CLC
    LDA bulletY
    SBC #$0A            ;Else subtract 10 from Y so it is a usable value
    TAY
    LDA #$00
    BEQ bulletHitBottom
bulletHitTop
    LDA topset,x
    STA internum
    CPY internum
    BMI bulletHitTrue
    LDA emptyset,x
    STA internum
    CPY internum
    BPL bulletHitTrue
    RTS
bulletHitBottom
    LDA #$0C
    CLC
    SBC emptyset,x
    STA internum
    CPY internum
    BMI bulletHitTrue
    LDA #$0C
    CLC
    SBC topset,x
    STA internum
    CPY internum
    BPL bulletHitTrue
    RTS
bulletHitTrue
    LDA #$FF
    STA bulletX
    STA bulletY
	LDA #$00
	STA bulletFlag
    RTS

colortop	            ;Changes color of char printed, called for each char on top of screen
	CPX shipcoX			;If it is shipX and Y, color white
	BNE bullett
	CPY shipcoY
	BEQ whitet
bullett
    CPX bulletX			;If at bulletX and Y, color white
    BNE powerUpt
    CPY bulletY
    BEQ whitet
powerUpt				;If at powerupX and Y, color yellow
    CPX powerUpX
    BNE fallingobst
    CPY powerUpY
    BEQ yellowt
fallingobst				;If at falling obstacleX and Y, color level color
    CPX fallingobsX
    BNE blackt
    CPY fallingobsY
    BEQ colort
blackt					;Checks if inside tunnel, colors black. Else, level color
	CPY #$00
	BEQ colort
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
	STA $9600,x			;Print character as black
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
	STA $9600,x			;Print character as white
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
yellowt
	TXA
	STY internum
	PHA
	JSR mul22
	PLA
	CLC
	ADC internum
	TAX
	LDA #$07
	STA $9600,x			;Print character as yellow
	RTS

colorbottom	            ;Changes color of char printed for bottom of screen
	CPX shipcoX			;Repetition of colortop, with slight modifications to
	BNE bulletb			;account for mirrored X and Y
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
	BNE powerUpb
	LDA bulletY
	CMP #$0B
	BMI powerUpb
	CLC
	SBC #$0A
	STA internum
	CPY internum
	BEQ whiteb
powerUpb
	CPX powerUpX
	BNE fallingobsb
	LDA powerUpY
	CMP #$0B
	BMI fallingobsb
	CLC
	SBC #$0A
	STA internum
	CPY internum
	BEQ yellowb
fallingobsb
	CPX fallingobsX
	BNE blackb
	LDA fallingobsY
	CMP #$0B
	BMI blackb
	CLC
	SBC #$0A
	STA internum
	CPY internum
	BEQ colorb
blackb
	CPY #$0A
	BEQ colorb
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
yellowb
	TXA
	STY internum
	PHA
	JSR mul22
	PLA
	CLC
	ADC internum
	TAX
	LDA #$07
	STA $96F2,x			;Print character as yellow
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
	JSR colortop		;Jump to the coloring for each char
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
    BNE drawPUp1
    CPY bulletY
    BEQ drawbullet      ;if yes draw bullet
drawPUp1				;Check to see if we want to draw Power up
	CPX powerUpX         ;check to see if we want to draw bullet
	BNE drawfallingobs1
	CPY powerUpY
	BEQ drawPUp	     ;if yes draw bullet
drawfallingobs1				;Check to see if we want to draw Power up
	CPX fallingobsX         ;check to see if we want to draw bullet
	BNE drawBlock
	CPY fallingobsY
	BEQ drawfallingobs	     ;if yes draw bullet
drawBlock
	PLA
	TAY
	LDA #$00			;;Block to print
	STA $1E00,y			;Print at offset
	JMP cont
drawbullet
    PLA
    TAY
    LDA #$26           ; bullet block
    STA $1E00,y
    JMP cont
drawPUp
	PLA
	TAY
	LDA #$23            ; powerUp block
	STA $1E00,y
	JMP cont
drawfallingobs
    PLA
	TAY
	LDA #$24            ; falling obs  block
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

fillbottom				;Refer to filltop, code is slightly modified for mirrored tunnel
fillcolb
	TXA
	PHA
	TYA
	PHA
	JSR colorbottom		;Jump to coloring function
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
	BNE drawPUp1b
	LDA bulletY
	CMP #$0B
	BMI drawPUp1b
	CLC
	SBC #$0A
	STA internum
	CPY internum
	BEQ drawbulletb
drawPUp1b
	CPX powerUpX
	BNE drawfallingobs1b
	LDA powerUpY
	CMP #$0B
	BMI drawfallingobs1b
	CLC
	SBC #$0A
	STA internum
	CPY internum
	BEQ drawPUpb
drawfallingobs1b
	CPX fallingobsX
	BNE drawBlockb
	LDA fallingobsY
	CMP #$0B
	BMI drawBlockb
	CLC
	SBC #$0A
	STA internum
	CPY internum
	BEQ drawfallingobsb
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
	JMP contb
drawPUpb
    PLA
    TAY
    LDA #$23			;Draw powerup
    STA $1EF2,y
    JMP contb
drawfallingobsb
    PLA
    TAY
    LDA #$24			;Draw powerup
    STA $1EF2,y
contb
	LDY depth
	INY
	CPY #$0B			;Compare Y to 11
	BPL endColb
	JMP fillcolb
endColb
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

addPickupToScore		;Used to add 20 to score when powerup is hit
    LDX #$00
pickupScoreLoop
    JSR addTenPickScore
    INX
    CPX #$01            ;score value coeffcient on 10
    BNE pickupScoreLoop
addTenPickScore
    LDA currScoreTens
    CMP #$09
    BEQ addHunToScore
    ADC #$01
    STA currScoreTens
    RTS

addPickupToAmmo			;Add one to ammo counter when powerup is hits
    LDA bulletAmmoOnes
    CMP #$09
    BEQ addToAmmoTens
    INC bulletAmmoOnes
    BVC endPickupToAmmo
addToAmmoTens			;Adds one to the tens place if ones place is 9
    LDA #$00
    STA bulletAmmoOnes
    LDA bulletAmmoTens
    CMP #$09
    BEQ endPickupToAmmo
    INC bulletAmmoTens
endPickupToAmmo
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

updateLevel				;Adds to the level
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
	LDA #$12		;R
	STA $1FE6

	CLC
	LDA currScoreTThous		;0 //currScoreHundredThousands
	ADC #$30
	STA $1FE8
	LDA currScoreThous		;0 //currScoreTenThousands
	ADC #$30
	STA $1FE9
	LDA currScoreHuns		;0 //currScoreOnes
	ADC #$30
	STA $1FEA
	LDA currScoreTens		;0 //currScoreTens
	ADC #$30
	STA $1FEB
	LDA currScoreOnes       ;0 //currScoreHuns
	ADC #$30
	STA $1FEC

	LDA #$0C		;L
	STA $1FEE
	CLC
	LDA currLevel
	ADC #$30
	STA $1FF0
	LDA #$2D		;-
	STA $1FF1
	LDA currSubLevel
	ADC #$30
	STA $1FF2

    LDA #$01		;A
	STA $1FF4
	LDA #$0D		;M
	STA $1FF5
	LDA #$0D		;M
	STA $1FF6
	CLC
	LDA bulletAmmoTens		;1
	ADC #$30
    STA $1FF8
    LDA bulletAmmoOnes		;1
	ADC #$30
    STA $1FF9

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

;Needs further debugging, causes glitches in levels
getrng
	LDY currScoreOnes
	LDA $00A2
rngloop
	ADC musicLoopOffset
	ADC $00A2
	AND #$FF			;keep as byte
	DEY
	CPY #$01
	BMI rngloop
	AND #$01
	TAY
	CLC
	RTS

;=============================================================================
;DATA
    org $1B00        ;dec  6144

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

bulletAmmoOnes
    .BYTE $01
bulletAmmoTens
    .BYTE $00

powerUpX
	.BYTE $14
powerUpY
	.BYTE $12
powerUpFlag
	.BYTE $01


fallingobsX
    .BYTE $14
fallingobsY
    .BYTE $00
fallingobsFlag
    .BYTE $01

staticobsX
	.BYTE $FF
staticobsY
	.BYTE $FF, $FF, $FF, $FF, $FF, $FF
staticobsFlag
	.BYTE $00

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

randobyte
	.BYTE $00

cheatFlag
	.BYTE $00
