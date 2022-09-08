;--------------------------------
; SUBROUTINES FOR NIGHTRAIDERS
;--------------------------------
MAPFIL     STA TEMP2
           CMP #$60
           BEQ MAPCOL2
           LDA #$8D
           STA $2C4
           LDA #$94
           STA $2C5
           LDA #$CA
           STA COLOR2
           LDA #$48
           STA $2C7
           BNE MAPMOVER  
MAPCOL2    LDA #$28
           STA $2C4
           LDA #$CA
           STA $2C5
           LDA #$94
           STA COLOR2
           LDA #$48
           STA $2C7
MAPMOVER   LDA #$40  
           STA TEMP4
           LDA #$00   
           STA TEMP1
           STA TEMP3
           TAY
MAPFIL2    LDA (TEMP1),Y
           STA (TEMP3),Y
           INC TEMP1
           INC TEMP3
           BNE MAPFIL2
           INC TEMP2
           INC TEMP4
           LDA TEMP4
           CMP #$50
           BNE MAPFIL2
           LDX #$00
           TXA
FDS161     STA $4000,X    ;Writing to SCREEN , loading map?
           STA $4100,X
           STA $4200,X
           DEX
           BNE FDS161
           LDX #$6F
FDS162     STA $4300,X
           DEX
           BNE FDS162
           RTS
;--------------------------------
; SETUP GUAGE SCREEN
;--------------------------------
SETSCREEN  LDX #$4F 
SETS2      LDA BSCR-1,X
           STA $3E5F,X
           DEX
           BNE SETS2
           RTS

BSCR       .BYTE $00,$1D,$0D,$19,$1C,$0F,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$1D,$12,$13,$1A,$1D,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$90,$9F,$8F,$96,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00
;--------------------------------
; INITIALIZE GAME VARIABLES
;--------------------------------
INIT   LDA #$00      ; Init memor to $00 Enter with X as start index
ILOOP  STA $0,X      ; Save in zeropage address offset by X
       INX           ; bump x we are clearing to top of zeropage $FF
       BNE ILOOP     ; if x not 0 loop
;--------------------------------
       STA NMIEN     ; Disable Non Maskable Interrupts
;--------------------------------
       STA SIZEP0    ; reset size of play missles
       STA SIZEP1
       STA SIZEP2
       STA SIZEP3
;--------------------------------
       LDA #RTEND&255       ; Set interupt address to
       STA VBLK             ; default RTEN to return immediately
       STA COLLAD           ; for both Collisions and 
       LDA #RTEND/255       ; vertical blank 
       STA VBLK+1   
       STA COLLAD+1
;--------------------------------
       LDA #$40      ; NMIEN_VBI
       STA NMIEN     ; activate vertical blank interrupt
;--------------------------------
       JSR CLRMIS    ; Clear player missle area ram
       LDX #$14
ILOOP1 LDA #$00
       STA $3FBF,X  
       DEX
       BNE ILOOP1
;--------------------------------
       STA GRACTL    ; Set Graphic Control?
       STA DMACTL    ; Set DMA Control?
;--------------------------------
       LDA #$30      ; Set Player Missle Memory to 
       STA PMBASE    ; Start at $3000 Make this a define in future!
--------------------------------
       LDX #$09      ; clear PCOLOR0-3 
       LDA #$00      ; plus 5 other bytes why?
ILOOP2 STA PCOLR0-1,X
       DEX
       BNE ILOOP2
--------------------------------
       LDX #$07      ; clear all 4 Audio Control Registers
ILOOP3 STA AUDF1,X   ; they are spaced 2 apart.
       DEX
       DEX           ; can we use BPL here and not do compare?
       CPX #$FF      ; -1?
       BNE ILOOP3    ; if not branch 
--------------------------------
       LDX #$05      ; zero GUNSX and y Pos
CLRGUN STA GUNSX,X
       DEX
       BPL CLRGUN    ; loop until x is -1 FF
--------------------------------
       LDA #$40
       STA TPOINT    ; Initialize TPOINT to 64
       LDA #$03      
       STA SSKCTL    ; Initialize to 3
       STA SKCTL
       LDA #$00      ; AllPOT = 0
       STA ALLPOT
       LDA #$03      ; HITCLR = 3
       STA HITCLR
       JSR INITVAR   ; INIT MORE VARIABLES
       RTS
;--------------------------------
; MAKE PLANE
; Copies Plane Images from P1-P4
; Locatons to the Player Missle Sprite
; Locations starting at Location $3490
;--------------------------------
PMAKER LDX #$0C             ; Copy 12 bytes of data for each image
PM1    LDA P1-1,X           ; Get plane image #1 data
       STA $3490,X          ; Store in sprite ram
       LDA P2-1,X           ; Get plane image #2 data
       STA $3590,X          ; Store in sprite ram
       LDA P3-1,X           ; Get plane image #3 data
       STA $3690,X          ; Store in sprite ram
       LDA P4-1,X           ; Get plane image #4 data
       STA $3790,X          ; Store in sprite ram
       DEX                  ; index -=1
       BNE PM1              ; if not 0 loop
       LDA #$82
       STA CROSSX           ; CROSSX = $82;
       RTS
;--------------------------------
; RTEND RESTORE REGISTERS
; AFTER INTERRUPT
; 6502 interupts save registers a, x and y
; on stack automatically!
;--------------------------------
RTEND  PLA
       TAY
       PLA
       TAX
       PLA
NOINT  RTI
;--------------------------------
; CLEAR PLAYER MISSLE AREA $3000-$37FF
;--------------------------------
CLRMIS LDA #$00      ; Set TEMP1 & 2 as indirect pointer
       STA TEMP1     ; to $3000 Player Missle Ram
       LDA #$30
       STA TEMP2
;--------------------------------
       LDY #$00      ; y index = 0
CLROP  LDA #$00      ; a= 0
CLROP2 STA (TEMP1),Y ; zero a locaton in ram offset by y
       INY           ; y=y+1
       BNE CLROP2    ; loop for all 256 bytes until y is 0 
;--------------------------------
       INC TEMP2     ; bump hi byte of indirect pointer
       LDA TEMP2     ; get it
       CMP #$38      ; are we at $3800?
       BNE CLROP     ; if not loop until we are done
       RTS
;--------------------------------
; LONG DELAY ROUTINE
;--------------------------------
DLONG  STX TEMP2
       JSR DELAY
       LDX TEMP2
       DEX
       BNE DLONG
       RTS
;--------------------------------
; DELAY ROUTINE
;--------------------------------
DELAY  LDX #$10
DELAY1 LDY #$FF
DELAY2 DEY
       BNE DELAY2
       DEX
       BNE DELAY1
       RTS
;--------------------------------
; PRINT ROUTINE
;--------------------------------

PRINT  STY TEMP2
       LDA #WORDS&255
       STA TEMP3
       LDA #WORDS/255
       STA TEMP4
       LDY #$00
PRINT1 LDA (TEMP3),Y
       BEQ PRINT3
PRINT2 INY
       JMP PRINT1
PRINT3 DEX
       BNE PRINT2
       INY
       TYA
       CLC
       ADC TEMP3
       STA TEMP3
       BCC PRINT4
       INC TEMP4
PRINT4 LDA #SCREEN&255
       STA TEMP5
       LDA #SCREEN/255
       STA TEMP6
       LDX TEMP1
       BEQ LOOSE
PRINT5 LDA TEMP5
       CLC
       ADC #$28
       STA TEMP5
       BCC PRINT6
       INC TEMP6  
PRINT6 DEX 
       BNE PRINT5
LOOSE  LDY #$00 
PRINT7 LDA (TEMP3),Y
       BEQ PRINT9
       CMP #$20
       BNE PRINT8
       LDA #$36
PRINT8 SEC
       SBC #$36
       ORA TEMP7
       TAX
       TYA
       PHA
       LDY TEMP2
       TXA
       STA (TEMP5),Y
       INC TEMP2
       PLA
       TAY
       INY
       JMP PRINT7
PRINT9 RTS

;--------------------------------
; DISPLAY LISTS
; Note: Display list interrupts interrupt the main processor so it can make a change
; to a color register for example or a sprite location at the specific momemnt in time
; where he crt scan line is scanning. See https://www.atariarchives.org/mapping/appendix8.php
;--------------------------------

;--------------------------------
; Second Display list instructios for game
;--------------------------------
LIST2  .BYTE $70               ; 8 Blank Lines
       .BYTE $F0               ; Text Mode 0 40 pixels per line 40 bytes per line 8 scan lines + Horiz Scroll
                               ; + Vertical Scroll and Enable Display List Interrupt + Load Mem Scan
       .BYTE $64               ; Text Mode 40 pixels per line 40 bytes per line * 8 scan lines + Load Mem scan + Horiz Scroll                         
       .BYTE SCREEN&255        ; Low Address of Memory
       .BYTE SCREEN/255        ; High Address of Memory
       .BYTE $24,$24,$24,$24,$24       ; Text Mode 40 pixels per line 40 bytes per line * 8 scan lines + vertical scroll * 12
       .BYTE $24,$24,$24,$24,$24,$24,$24
       .BYTE $A4                       ; Same Text mode plus displa list interrupt + vertical scroll
       .BYTE $24,$24,$24,$24,$24       ; Text Mode 40 pixels per line 40 bytes per line * 8 scan lines + vertical scroll * 5
       .BYTE $04               ; Same text mode no scroll
       .BYTE $A0               ; Display list interrupt vertical scroll 1 blank line
       .BYTE $45               ; Text Mode 40 pixels per line 40 bytes per line 16 scan lines + Load Memory scan at 3E60 
       .BYTE $60               ; Low Byte of Memory address (3E60 is where he score line data is )
       .BYTE $3E               ; Hi Byte of Memory address
       .BYTE $05               ; Text Mode 40 pixels per line 40 bytes per line 16 scan lines
       .BYTE $20               ; 1 blank line + Vertical Scroll
       .BYTE $4A               ; Graphics mode 80 pixels per line 20 bytes per line 4 scan lines + load mem scan from 413f
       .BYTE $40               ; Low Byte of Memory address
       .BYTE $3F               ; Hi Byte of Memory address
       .BYTE $41               ; Jump and wait for vertical blank Tells ANTIC Processor where to fetch next instruction.
;       .DA #LIST2    ; .DA #expression (one byte, LSB of expression)
;       .DA /LIST2    ; .DA /expression (one byte, MSB of expression)
       .BYTE LIST2&255        ; Low byte of display list address
       .BYTE LIST2/255        ; High byte of display list address 
       ;.WORD LIST2    ; Stores words in memory at the current memory address in native format (LSB/MSB).

;--------------------------------
; First Display list instructios for intro screen 
;--------------------------------
LIST1  .BYTE $70               ; 8 Blank Lines
       .BYTE $60               ; 7 Blank Lines
       .BYTE $90               ; 1 Blank Line + Load Memory Scan + Horiz Scroll
       .BYTE $4F               ; Graphic Mode 8 320 pixels per line 40 bytes per line 1 scan line + Horiz Scroll
;       .DA #NIGHTDAT
;       .DA /NIGHTDAT
        .WORD NIGHTDAT    ; Stores words in memory at the current memory address in native format (LSB/MSB).
       .BYTE $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F ; (Graphic Mode 8 320 pixels per line 40 bytes per line 1 scan line ) * 14 lines
       .BYTE $0F,$0F,$0F,$0F,$0F,$0F
       .BYTE $30               ; 4 blank lines
       .BYTE $44               ; Graphics Mode 4 80 pixels per line 10 bytes per line 4 scan lines
                               ; + Load Memory Scan from memory location 4000H = SCREEN
       .BYTE SCREEN&255        ; Low Address of Memory
       .BYTE SCREEN/255        ; High Address of Memory
       .BYTE $D0               ; ????
       .BYTE $05,$05           ; (text mode 16 scan lines 40 pixels per line 40 bytes per line) * 2
       .BYTE $04,$04,$04,$04,$04,$04     ; (text mode 8 scan lines 20 pixels per line 20 bytes per line) * 6
       .BYTE $84               ; same text mode  + Display List Interrupt
       .BYTE $04               ; (text mode 8 scan lines 20 pixels per line 20 bytes per line) * 9
       .BYTE $04,$04,$04,$04,$04,$04,$04,$04 
       .BYTE $41               ; Jump and wait for vertical blank Tells ANTIC Processor where to fetch next instruction.
;       .DA #LIST1   ; .DA #expression (one byte, LSB of expression) 
;       .DA /LIST1   ; .DA /expression (one byte, MSB of expression)
       .BYTE LIST1&255
       .BYTE LIST1/255
       ;.WORD LIST1   ; Stores words in memory at the current memory address in native format (LSB/MSB).

;--------------------------------
; DATA TABLE FOR HI-RES NIGHTRAIDER!
;--------------------------------
NIGHTDAT   .BYTE $00,$00,$00,$00,$00,$00,$00,$00                
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$60,$60,$7E,$03,$FC,$18
           .BYTE $18,$7F,$E1,$FF,$00,$F0,$07,$E0,$7F,$C1,$FF,$87,$FC,$0F,$F0,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$C0,$C0,$30,$0E,$1C,$30,$30,$CC,$C3,$07,$03,$F0,$03,$00
           .BYTE $31,$C0,$C3,$0C,$1C,$38,$70,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$C1,$80,$60,$18,$18,$60
           .BYTE $61,$99,$86,$06,$0E,$70,$06,$00,$61,$81,$86,$18,$18,$60,$60,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$03,$C3,$00,$C0,$30,$00,$C0,$C0,$30,$0C,$0C,$38,$70,$0C,$00
           .BYTE $C3,$03,$00,$30,$30,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$C6,$01,$80,$60,$01,$81
           .BYTE $80,$60,$18,$38,$60,$60,$18,$01,$86,$06,$00,$60,$E1,$C0,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$0D,$CC,$03,$00,$C0,$03,$FF,$00,$C0,$3F,$E0,$C0,$C0,$30,$03
           .BYTE $0C,$0F,$00,$FF,$81,$FC,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$19,$D8,$06,$01,$8F,$87,$FE
           .BYTE $01,$80,$7F,$81,$81,$80,$60,$06,$18,$1E,$01,$FE,$01,$FC,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$31,$F0,$0C,$03,$1F,$0C,$0C,$03,$00,$DC,$03,$FF,$00,$C0,$0C
           .BYTE $30,$30,$03,$70,$00,$1C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$61,$E0,$18,$06,$06,$18,$18
           .BYTE $06,$01,$9C,$07,$FE,$01,$80,$18,$60,$60,$06,$70,$00,$18,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$C1,$C0,$30,$0C,$0C,$30,$30,$0C,$03,$1C,$0C,$0C,$03,$00,$30
           .BYTE $C0,$C3,$0C,$70,$30,$30,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$01,$81,$80,$60,$1C,$18,$60,$60
           .BYTE $18,$06,$1C,$18,$18,$06,$00,$63,$81,$86,$18,$70,$70,$E0,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $03,$03,$03,$F0,$1F,$F0,$C0,$C0,$FC,$0C,$1C,$30,$30,$3F,$03,$FE
           .BYTE $0F,$FC,$30,$70,$7F,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$06,$06,$07,$E0,$1F,$E1,$81,$81
           .BYTE $F8,$18,$18,$60,$60,$7E,$07,$F8,$1F,$F8,$60,$60,$7E,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
           .BYTE $00,$00,$00,$00,$00,$00,$00,$00
