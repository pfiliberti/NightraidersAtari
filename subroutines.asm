*--------------------------------
* SUBROUTINES FOR NIGHTRAIDERS
*--------------------------------
MAPFIL     STA TEMP2
           CMP #$60
           BEQ MAPCOL2
           LDA #$8D
           STA $2C4
           LDA #$94
           STA $2C5
           LDA #$CA
           STA $2C6
           LDA #$48
           STA $2C7
           BNE MAPMOVER  
MAPCOL2    LDA #$28
           STA $2C4
           LDA #$CA
           STA $2C5
           LDA #$94
           STA $2C6
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
.1         STA $4000,X
           STA $4100,X
           STA $4200,X
           DEX
           BNE .1
           LDX #$6F
.2         STA $4300,X
           DEX
           BNE .2
           RTS
*--------------------------------
* SETUP GUAGE SCREEN
*--------------------------------
SETSCREEN  LDX #$4F 
SETS2      LDA BSCR-1,X
           STA $3E5F,X
           DEX
           BNE SETS2
           RTS
BSCR       .HS 001D0D191C0F0000
           .HS 0000000000000000
           .HS 00001D12131A1D00
           .HS 0000000000000000
           .HS 0000000000000000
           .HS 00909F8F96000000
           .HS 0000000000000000
           .HS 0000000000000000
           .HS 0000000000000000
           .HS 0000000000000000
*--------------------------------
* INITIALIZE GAME VARIABLES
*--------------------------------
INIT   LDA #$00
ILOOP  STA $0,X
       INX
       BNE ILOOP
       STA $D40E
       STA $D008
       STA $D009
       STA $D00A
       STA $D00B
       LDA #RTEND
       STA VBLK  
       STA COLLAD
       LDA /RTEND
       STA VBLK+1   
       STA COLLAD+1
       LDA #$40
       STA NMIEN
       JSR CLRMIS
       LDX #$14
ILOOP1 LDA #$00
       STA $3FBF,X  
       DEX
       BNE ILOOP1
       STA GRACTL
       STA DMACTL
       LDA #$30
       STA PMBASE
       LDX #$09
       LDA #$00
ILOOP2 STA CPLAY0-1,X
       DEX
       BNE ILOOP2
       LDX #$07
ILOOP3 STA $D200,X
       DEX
       DEX
       CPX #$FF
       BNE ILOOP3
       LDX #$05
CLRGUN STA GUNSX,X
       DEX
       BPL CLRGUN
       LDA #$40
       STA TPOINT
       LDA #$03
       STA $232
       STA $D20F
       LDA #$00
       STA $D208
       LDA #$03
       STA $D01E
       JSR INITVAR
       RTS
*--------------------------------
* MAKE PLANE
*--------------------------------
PMAKER LDX #$0C
PM1    LDA P1-1,X  
       STA $3490,X
       LDA P2-1,X
       STA $3590,X
       LDA P3-1,X
       STA $3690,X
       LDA P4-1,X
       STA $3790,X
       DEX
       BNE PM1
       LDA #$82
       STA CROSSX
       RTS
*--------------------------------
* RTEND RESTORE REGISTERS
* AFTER INTERRUPT
*--------------------------------
RTEND  PLA
       TAY
       PLA
       TAX
       PLA
NOINT  RTI
*--------------------------------
* CLEAR PLAYER MISSLE AREA
*--------------------------------
CLRMIS LDA #$00
       STA TEMP1
       LDA #$30
       STA TEMP2
       LDY #$00
CLROP  LDA #$00  
CLROP2 STA (TEMP1),Y
       INY
       BNE CLROP2
       INC TEMP2
       LDA TEMP2
       CMP #$38
       BNE CLROP
       RTS
*--------------------------------
* LONG DELAY ROUTINE
*--------------------------------
DLONG  STX TEMP2
       JSR DELAY
       LDX TEMP2
       DEX
       BNE DLONG
       RTS
*--------------------------------
* DELAY ROUTINE
*--------------------------------
DELAY  LDX #$10
DELAY1 LDY #$FF
DELAY2 DEY
       BNE DELAY2
       DEX
       BNE DELAY1
       RTS
*--------------------------------
* PRINT ROUTINE
*--------------------------------
PRINT  STY TEMP2
       LDA #WORDS
       STA TEMP3
       LDA /WORDS
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
PRINT4 LDA #SCREEN
       STA TEMP5
       LDA /SCREEN 
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
*--------------------------------
* DISPLAY LISTS
* Note: Display list interrupts interrupt the main processor so it can make a change
* to a color register for example or a sprite location at the specific momemnt in time
* where he crt scan line is scanning. See https://www.atariarchives.org/mapping/appendix8.php
*--------------------------------
LIST2  .HS 70F06400402424242424
       .HS 24242424242424
       .HS A4242424242404 
       .HS A045603E05204A 
       .HS 403F41  
       .DA #LIST2
       .DA /LIST2

*--------------------------------
* First Display list instructios for intro screen 
*--------------------------------
LIST1  .HS 70               ; 8 Blank Lines
       .HS 60               ; 7 Blank Lines
       .HS 09               ; Graphics Mode 4 80 pixels per line 10 bytes per line 4 scan lines
       .HS 4F               ; Graphic Mode 8 320 pixels per line 40 bytes per line 1 scan line + Horizontal Scroll
                            ; + Vertical Scroll and Enable Display List Interrupt
       .DA #NIGHTDAT        ; Low memory location of screen data
       .DA /NIGHTDAT        ; High memory location of screen data
       .HS 0F0F0F0F0F0F0F0F ; (Graphic Mode 8 320 pixels per line 40 bytes per line 1 scan line ) * 14 lines
       .HS 0F0F0F0F0F0F
       .HS 30               ; 4 blank lines
       .HS 44               ; Graphics Mode 4 80 pixels per line 10 bytes per line 4 scan lines
                            ; + Load Memory Scan from memory location 4000H
       .HS 00               ; Low Address of Memory
       .HS 40               ; High Address of Memory
       .HS D0               ; ????
       .HS 0505             ; (text mode 16 scan lines 40 pixels per line 40 bytes per line) * 2
       .HS 040404040404     ; (text mode 8 scan lines 20 pixels per line 20 bytes per line) * 6
       .HS 84               ; same text mode  + Display List Interrupt
       .HS 04               ; (text mode 8 scan lines 20 pixels per line 20 bytes per line) * 9
       .HS 0404040404040404 
       .HS 41               ; Jump and wait for vertical blank Tells ANTIC Processor where to fetch next instruction.
       .DA #LIST1           ; Low byte of display list address
       .DA /LIST1           ; Hi byte of display list address 

*--------------------------------
* DATA TABLE FOR HI-RES NIGHTRAIDER!
*--------------------------------
NIGHTDAT   .HS 0000000000000000                
           .HS 00000000000000000000000000000000
           .HS 00000000000000000000000000000000
           .HS 0000000000000000000060607E03FC18
           .HS 187FE1FF00F007E07FC1FF87FC0FF000
           .HS 00000000000000000000000000000000
           .HS 0000C0C0300E1C3030CCC30703F00300
           .HS 31C0C30C1C3870000000000000000000
           .HS 00000000000000000001C18060181860
           .HS 619986060E7006006181861818606000
           .HS 00000000000000000000000000000000
           .HS 0003C300C03000C0C0300C0C38700C00
           .HS C303003030C000000000000000000000
           .HS 00000000000000000007C60180600181
           .HS 806018386060180186060060E1C00000
           .HS 00000000000000000000000000000000
           .HS 000DCC0300C003FF00C03FE0C0C03003
           .HS 0C0F00FF81FC00000000000000000000
           .HS 00000000000000000019D806018F87FE
           .HS 01807F8181806006181E01FE01FC0000
           .HS 00000000000000000000000000000000
           .HS 0031F00C031F0C0C0300DC03FF00C00C
           .HS 30300370001C00000000000000000000
           .HS 00000000000000000061E01806061818
           .HS 06019C07FE0180186060067000180000
           .HS 00000000000000000000000000000000
           .HS 00C1C0300C0C30300C031C0C0C030030
           .HS C0C30C70303000000000000000000000
           .HS 0000000000000000018180601C186060
           .HS 18061C18180600638186187070E00000
           .HS 00000000000000000000000000000000
           .HS 030303F01FF0C0C0FC0C1C30303F03FE
           .HS 0FFC30707F8000000000000000000000
           .HS 0000000000000000060607E01FE18181
           .HS F8181860607E07F81FF860607E000000
           .HS 00000000000000000000000000000000
           .HS 00000000000000000000000000000000
           .HS 00000000000000000000000000000000
           .HS 00000000000000000000000000000000
           .HS 00000000000000000000000000000000
           .HS 0000000000000000
                                                                                                                                                                                             