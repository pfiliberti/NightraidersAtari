;--------------------------------
; NIGHTRAIDERS
; WRITTEN BY : PETER FILIBERTI
; COPYRIGHT 1982
;--------------------------------
       ORG $6B0               ; mads assembler
;       .OR  $6B0              ; original
;        * = $6b0              ; ATasm
;       .TF  OBJ               ;Stores object file directly to disk
;--------------------------------
; ZERO PAGE VARIABLES
;--------------------------------
HISCORE1   = $80             ;These are the three locations where
HISCORE2   = HISCORE1+1      ;the high score is saved in BCD
HISCORE3   = HISCORE2+1      ;for later use.
OLSCORE1   = HISCORE3+1      ;These are the three locations where
OLSCORE2   = OLSCORE1+1      ;the last score achieved is placed
OLSCORE3   = OLSCORE2+1      ;for use in menu screen also BCD.
BSCOR0     = OLSCORE3+1      ;This is a binary score used as a
BSCOR1     = BSCOR0+1        ;temporary score holder by the game.
SCORE1     = BSCOR1+1        ;This is the actual game score
SCORE2     = SCORE1+1        ;stored in BCD it is also the same
SCORE3     = SCORE2+1        ;score put on game screen while playing.
;--------------------------------
TEMP1      = SCORE3+1        ;TEMP1 through TEMP8 are temporary
TEMP2      = TEMP1+1         ;locations used by main program and
TEMP3      = TEMP2+1         ;subroutines. The INTERRUPT routines
TEMP4      = TEMP3+1         ;must not touch these locatons!
TEMP5      = TEMP4+1         ;""
TEMP6      = TEMP5+1         ;""
TEMP7      = TEMP6+1         ;""
TEMP8      = TEMP7+1         ;""
CLRVAR     = TEMP8+1
;--------------------------------
LEVEL      = CLRVAR+1        ;Games level of play 0-6
SCRCNT     = LEVEL+1         ;Screen fine scroll counter
;--------------------------------
HPOS1      = SCRCNT+1        ;Horizontal position player1
HPOS2      = HPOS1+1         ;Horizontal position player2
HPOS3      = HPOS2+1         ;Horizontal position player3
HPOS4      = HPOS3+1         ;Horizontal position player4
;--------------------------------
MOVFLG     = HPOS4+1         ;Flag for screen movement
FUEL       = MOVFLG+1        ;Fuel in planes tank 0-$50
CROSSX     = FUEL+1          ;Plane horizontal axis position
MISSLEX    = CROSSX+1        ;Missle horizontal position
SHIPS      = MISSLEX+1       ;Number of ships left. start=3
;--------------------------------
IRQVAR1    = SHIPS+1         ;IRQVAR1 through IRQVAR2 are
IRQVAR2    = IRQVAR1+1       ;temporary locations to be
IRQVAR3    = IRQVAR2+2       ;used by interrupt routines only.
IRQVAR4    = IRQVAR3+3       ;Main program should not use these!
;--------------------------------
TPOINT     = IRQVAR4+1       ;Target point positioner.
HIT1       = TPOINT+1        ;HIT1-HIT4 are copies of the
HIT2       = HIT1+1          ;colision register updated every
HIT3       = HIT2+1          ;60 hz. It is used by main program
HIT4       = HIT3+1          ;interrupts logicaly or data in these.
;--------------------------------
COLLAD     = HIT4+1          ;Screen collision address (TWO BYTES)
ACTFLG     = COLLAD+2        ;Plane action flag.
;--------------------------------
; ATARI LOCATIONS
;--------------------------------
SCREEN     = $4000           ;Location in Memory of our Menu Screen Data

M0PF       = $D000           ;Missile 0 to playfield collision
M1PF       = $D001           ;Missile 1 to playfield collision
M2PF       = $D002           ;Missile 2 to playfield collision
M3PF       = $D003           ;Missile 3 to playfield collision

HPOSP0     = $D000           ; Player 0 Horizontal Position
HPOSP1     = $D001           ; Player 1 Horizontal Position
HPOSP2     = $D002           ; Player 2 Horizontal Position
HPOSP3     = $D003           ; Player 3 Horizontal Position

HPOSM0     = $D004           ; Missile 0 Horizontal Position
HPOSM1     = $D005           ; Missile 1 Horizontal Position
HPOSM2     = $D006           ; Missile 2 Horizontal Position
HPOSM3     = $D007           ; Missile 3 Horizontal Position

SIZEP0     = $D008           ;Size of player 0
SIZEP1     = $D009           ;Size of player 1
SIZEP2     = $D00A           ;Size of player 2
SIZEP3     = $D00B           ;Size of player 3

TRIG0      = $D010           ;Read trigger button 0
TRIG1      = $D011           ;Read trigger button 1
TRIG2      = $D012           ;Read trigger button 2
TRIG3      = $D013           ;Read trigger button 3

COLPM0     = $D012           ;Color of player and missile 0
COLPM1     = $D013           ;Color of player and missile 1
COLPM2     = $D014           ;Color of player and missile 2
COLPM3     = $D015           ;Color of player and missile 3

COLPF0     = $D016           ;Color of playfield 0
COLPF1     = $D017           ;Color of playfield 1
COLPF2     = $D018           ;Color of playfield 2
COLPF3     = $D019           ;Color of playfield 3
COLBK      = $D01A           ;Playfield Background color

PRIOR      = $D01B           ;Priority select
HITCLR     = $D01E           ;Clear Player/Missile Collisions
GRAFP3     = $D010           ;Graphics for player 3
VSCROLL    = $D405           ;Vertical scroll register

; Audio registers
AUDF1      = $D200           ;Audio channel 1 frequency
AUDC1      = $D201           ;Audio channel 1 control
AUDF2      = $D202
AUDC2      = $D203
AUDF3      = $D204
AUDC3      = $D205
AUDF4      = $D206           ;Audio channel 4 frequency
AUDC4      = $D207           ;Audio channel 4 control
AUDCTL     = $D208           ;Audio control
ALLPOT     = $D208           ; (Read) Read 8 line POT port state

SKRES      = $D20A           ; (Write) Reset status (SKSTAT)
RANDOM     = $D20A           ; (Read) Random number
SKCTL      = $D20F           ;Serial Port Control
SKSTAT     = $D20F           ;(Read) Serial port status

PORTA      = $D300           ;Jack 0 & 1
PORTB      = $D301           ;Jack 2 & 3
PACTL      = $D302           ; Porta A control
PABTL      = $D303           ; Porta B control

PMBASE     = $D407           ;Player missle base address
CHBASE     = $D409           ;Character Set Base Address (high)
WSYNC      = $D40A           ;Wait for horizontal blank sync.
VCOUNT     = $D40B           ;Vertical line counter
DISPLA     = $3F00           ;Another menu screen location
VDLST      = $200            ;Display list interrupt vector
VBLK       = $224            ;Vertical blank interrupt vector
DLISTP     = $230            ;Display list pointer
SSKCTL     = $232            ;SKCTL
GPRIOR     = $26F            ;data from CTIA PRIOR (D01B)
CLB        = $2C8            ;Color register background
COLOR0     = $2C4            ;COLPF0 - Playfield 0 color
COLOR1     = $2C5            ;COLPF1 - Playfield 1 color
COLOR2     = $2C6            ;COLPF2 - Playfield 2 color
COLOR3     = $2C7            ;COLPF3 - Playfield 3 color
PCOLR0     = $2C0            ;Color player 1
PCOLR1     = $2C1            ;Color player 2
PCOLR2     = $2C2            ;Color player 3
PCOLR3     = $2C3            ;Color player 4
KEY        = $02FC           ;Read Keypress  
CONSOL     = $D01F           ;Console switch address
GRACTL     = $D01D           ;Graphic control address
CHBAS      = $2F4            ;Shadow register for hardware register - Character set base address - Font-Start
STRIG0     = $284            ;Joystick trigger
DMACTL     = $22F            ;Dma control register
NMIEN      = $D40E           ;NMI control register
;--------------------------------
; GAME COLD START
;--------------------------------
COLDSTART  LDX #HISCORE1       ;Clear all of zero page variables
           JSR INIT            
           JMP INTRO           ;Goto menu routines
WARMSTART  LDX #BSCOR0         ;Erase all of zero page variables
           JSR INIT            ;except high scores!
           JMP INTRO           ;Goto menu routines
;--------------------------------
; WORDS USED BY INTRODUCTION
;--------------------------------
       .DEF WORDS 
       .BYTE 00
       .BYTE 'BY PETER FILIBERTI    DATAMOST INC  8@?:'
       .BYTE 00
       .BYTE 'HIGH SCORE      YOUR SCORE      '
       .BYTE 00
       .BYTE 'CURRENT RANK'
       .BYTE 00
LEVNAM .BYTE 'NOVICE'
       .BYTE 00
       .BYTE 'CADET'
       .BYTE 00
       .BYTE 'ENSIGN'
       .BYTE 00
       .BYTE 'CAPTAIN'
       .BYTE 00
       .BYTE 'COMMANDER'
       .BYTE 00
       .BYTE 'NIGHTRAIDER'
       .BYTE 00
       .BYTE 'PRESS SELECT TO CHANGE STARTING RANK'
       .BYTE 00
       .BYTE 'PRESS START OR FIRE BUTTON TO PLAY'
       .BYTE 00
       .BYTE 'TODAYS TOP TEN HIGH SCORES'
       .BYTE 00
       .BYTE ' CONGRAULATIONS YOU HAVE THE HIGH SCORE '
       .BYTE 00
       .BYTE '    YOUR SCORE IS ONE OF THE TOP TEN    '
       .BYTE 00
       .BYTE '           ENTER YOUR INITIALS          '
       .BYTE 00
;--------------------------------
TBL1   .BYTE $12,$19,$17,$0B
COLORT .BYTE $8D,$94,$CA,$45,$00 
P1     .BYTE $00,$18,$24,$24,$7E,$FF,$FF,$FF     ;P1-P4 are plane shapes 
       .BYTE $FF,$FF,$81,$FF             ;I just felt like putting
P2     .BYTE $00,$00,$18,$18,$00,$00,$42,$42     ;them here!??
       .BYTE $5A,$FF,$FF,$FF
P3     .BYTE $00,$00,$00,$00,$00,$01,$03,$0F
       .BYTE $1F,$7F,$00,$00
P4     .BYTE $00,$00,$00,$00,$00,$80,$C0,$F0    
       .BYTE $F8,$FE,$00,$00
;--------------------------------
; INTRODUCTION ROUTINE
;--------------------------------
INTRO  LDA #$2C                 ;Setup character base address
       STA CHBAS
       LDA #LIST1&255            ;Setup our display list pointers
       STA DLISTP               ;to point to our display list
       LDA #LIST1/255
       STA DLISTP+1
       LDA #$00
       STA VSCROLL              ;Put a zero in horizontal scroll reg
       LDA #$3A
       STA DMACTL               ;Enable player DMA
       LDA #$03
       STA GRACTL               ;Enable player graphics
       JSR CLRMEN               ;Clear menu page
       LDA #MIRQ1&255               ;Setup the irq vectors to
       STA VDLST                ;point to our Irq routines
       LDA #MIRQ1/255
       STA VDLST+1
VSYNC  LDA VCOUNT               ;Is scan line at the top of the screen?
       CMP #$80                 ;For an NTSC machine, VCOUNT counts from $00 to $82; for PAL, it counts to $9B.
       BCC VSYNC                ;If not then loop
       LDA #$C0                 ;NMIEN_DLI($80) | NMIEN_VBI($40) - activate display list interrupt and vertical blank interrupt
       STA NMIEN                ;Enable Display list interrupts
       LDA #$00
       STA TEMP1                ;Setup menu screen messages
       STA TEMP7
       LDX #$01     
       LDY #$00     
       JSR PRINT                ;By peter filiberti etc....
       INC TEMP1
       LDX #$02
       LDY #$07     
       JSR PRINT                ;High score    Your score
       
SCORER LDX #$02                 ;Put high score and last score
       LDY #$00                 ;on screen
FDS9   LDA HISCORE1,X           ;Get a BCD byte
       LSR                      ; 
       LSR                      ;
       LSR                      ;Only want left digit
       LSR                      ;
       CLC                      ;Add 1 to convert to
       ADC #$01                 ;our weird ascii
       STA SCREEN+$59,Y          ;Put on screen
       LDA OLSCORE1,X
       LSR  
       LSR
       LSR
       LSR
       CLC
       ADC #$01
       STA SCREEN+$69,Y
       INY
       LDA HISCORE1,X           ;Get a BCD byte
       AND #$0F                 ;Only want right digit
       CLC                      ;Add 1 to convert to
       ADC #$01                 ;our weird ascii
       STA SCREEN+$59,Y              ;Put on screen
       LDA OLSCORE1,X
       AND #$0F
       CLC
       ADC #$01
       STA SCREEN+$69,Y
       INY
       DEX
       BPL FDS9
       LDA #$80
       STA TEMP7
       LDA #$98     
       STA COLOR3
       LDA #$06
       STA TEMP1
       LDX #$0A     
       LDY #$02     
       JSR PRINT
       INC TEMP1
       LDX #$0B
       LDY #$03
       JSR PRINT
       LDA #$0A
       STA TEMP1
       LDA #$00
       STA TEMP7    
       LDX #$03
       LDY #$04     
       JSR PRINT
       LDA #$00
       STA LEVEL
SELECT LDX #$14
       LDA #$00
FDS10  STA SCREEN+$1A4,X
       DEX
       BNE FDS10
       LDA #$0A
       STA TEMP1
       LDA #$80
       STA TEMP7
       LDA LEVEL 
       CLC
       ADC #$04
       TAX
       LDY #$17
       JSR PRINT
       JSR BEEPS
       LDA #$00
       STA TEMP6
       STA TEMP7
       STA TEMP8
CKEY   LDA CONSOL
       ROR
       BCS PF1
       JMP GAME
PF1    ROR
       BCS PF2
PF3    LDA CONSOL
       AND #$02
       BEQ PF3
       INC LEVEL
       LDA LEVEL
       CMP #$06
       BNE PF4
       LDA #$00
       STA LEVEL
PF4    JMP SELECT
PF2    LDA TRIG0
       BNE CKEY
       JMP GAME
;--------------------------------
CLRMEN LDA #$40                 ;Erase our menu screen
       STA TEMP2                ;$4000-$5000
       LDY #$00
       STY TEMP1
FDS12  TYA
FDS11  STA (TEMP1),Y
       INY
       BNE FDS11
       INC TEMP2
       LDA TEMP2
       CMP #$50
       BNE FDS12
       RTS
;--------------------------------
; MIRQ1 IRQ FOR MENU!
;--------------------------------
MIRQ1  PHA
       TXA
       PHA
       LDA VCOUNT
       CMP #$30         ;For an NTSC machine, VCOUNT counts from $00 to $82; for PAL, it counts to $9B.
       BCS MIRQ2
       LDA COLOR2
       LDX #$11     
FDS13  STA WSYNC        ;Wait for Sync 0 A write to WSYNC causes the CPU to halt execution until the start of horizontal blank.
       STA COLPF2
       CLC
       ADC #$02     
       DEX
       BNE FDS13 
       INC CCNT
       LDA CCNT
       CMP #$08     
       BNE FDS14
       LDA #$00
       STA CCNT
       INC COLOR2
FDS14  LDA #$28     
       STA COLPF2
       PLA
       TAX
       PLA
       RTI    
CCNT   .BYTE 00
;--------------------------------
MIRQ2  TYA
       PHA
       LDA #$C8     
       STA COLPF2
       LDA #$0F
       STA COLPF3   
       PLA
       TAY
       PLA
       TAX
       PLA
       RTI
;--------------------------------
GAME   LDA #$00
       STA NMIEN   
       STA DMACTL 
       LDX #$05
COLFIL LDA COLORT-1,X
       STA COLOR0-1,X
       DEX
       BNE COLFIL
       LDA #IRQ1&255
       STA VDLST
       LDA #IRQ1/255
       STA VDLST+1
       LDA #VBLANK&255
       STA VBLK
       LDA #VBLANK/255
       STA VBLK+1
       LDA #LIST2&255
       STA DLISTP
       LDA #LIST2/255
       STA DLISTP+1
       LDA #$58
       STA LIST2+3
       LDA #$4C
       STA LIST2+4
       LDA #$07
       STA SCRCNT
       STA VSCROLL
       JSR CLRMIS
       JSR SETSCREEN
       LDA #$0F
       STA $D404
       JSR PMAKER
       LDA #$70
       STA CHBAS
       LDA #$50
       JSR MAPFIL
       LDA #$31
       STA GPRIOR
CS     STA WSYNC
       LDA VCOUNT
       CMP #$78          ;For an NTSC machine, VCOUNT counts from $00 to $82; for PAL, it counts to $9B.
       BNE CS
       STA WSYNC
       LDA #$C0          ;NMIEN_DLI($80) | NMIEN_VBI($40) - activate display list interrupt and vertical blank interrupt
       STA NMIEN
       LDA #$3E  
       STA DMACTL 
       LDA #$00
       STA BSCOR0
       STA BSCOR1
       STA SCORE1
       STA SCORE2
       STA SCORE3
       LDA #$50
       STA FUEL
       LDA #$04
       STA SHIPS

       ICL "night2.asm"
       ICL "night3.asm"
       ICL "interrupts.asm"
       ICL "subroutines.asm"
       ICL "shapes.asm"
       ICL "variables.asm"

       ; Load in character sets and maps where game expects to be
       ORG $2C00  
       INS "charset2.bin"
       ORG $5000
       INS "maps.bin"
