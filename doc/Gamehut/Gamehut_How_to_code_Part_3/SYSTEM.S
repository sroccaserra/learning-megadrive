;----------------------------------------------------------
;               REGISTER EQUATES
;----------------------------------------------------------
Z80REQ:         EQU     $A11100
Z80RES:         EQU     $A11200
Z80RAM:         EQU     $A00000

B4:             EQU     1<<4
B30:            EQU     1<<30

VDP_DATA:       EQU     $FFC00000
VDP_STATUS:     EQU     $FFC00004
VDP_CONTROL:    EQU     $FFC00004

VRAMW:          EQU     %01*B30+%0000*B4
CRAMW:          EQU     %11*B30+%0000*B4
VSRAMW:         EQU     %01*B30+%0001*B4
VRAMR:          EQU     %00*B30+%0000*B4
CRAMR:          EQU     %00*B30+%0010*B4
VSRAMR:         EQU     %00*B30+%0001*B4

;DMA MEMORY BLOCK DESTINATIONS
DMAVRAM:        EQU     %01*B30+%1000*B4
DMACRAM:        EQU     %11*B30+%1000*B4
DMAVSRAM:       EQU     %01*B30+%1001*B4

STACK_SIZE:     EQU     1024

                RSSET   $FFFF0000
WORKRAM:        RS.B    STACK_SIZE
ENDSTACK:       RS.B    0
SYSTEMRAM:      RS.B    0
DMANUM:         EQU     80

;JOYPAD STUFF
JSDATA1:        EQU     $00A10003
JSDATA2:        EQU     $00A10005
JSDATA3:        EQU     $00A10007
JSCTRL:         EQU     $00A10009
JSCTRL1:        EQU     $00A10009
JSCTRL2:        EQU     $00A1000b
JSCTRL3:        EQU     $00A1000d
MDSCTRL1:       EQU     $00A10013
MDSCTRL2:       EQU     $00A10019
MDSCTRL3:       EQU     $00A1001f

J_UP:           EQU     0
J_DOWN:         EQU     1
J_LEFT:         EQU     2
J_RIGHT:        EQU     3
J_BUT_B:        EQU     4
J_BUT_C:        EQU     5
J_BUT_A:        EQU     6

;SPRITE STUFF
S_1X1:          EQU     0<<8
S_1X2:          EQU     1<<8
S_1X3:          EQU     2<<8
S_1X4:          EQU     3<<8
S_2X1:          EQU     4<<8
S_2X2:          EQU     5<<8
S_2X3:          EQU     6<<8
S_2X4:          EQU     7<<8
S_3X1:          EQU     8<<8
S_3X2:          EQU     9<<8
S_3X3:          EQU     10<<8
S_3X4:          EQU     11<<8
S_4X1:          EQU     12<<8
S_4X2:          EQU     13<<8
S_4X3:          EQU     14<<8
S_4X4:          EQU     15<<8

S_PAL1:         EQU     $0000
S_PAL2:         EQU     $2000
S_PAL3:         EQU     $4000
S_PAL4:         EQU     $6000

;RING STUFF
                RSSET   0
RING_X:         RS.L    1
RING_Y:         RS.L    1
RING_MX:        RS.L    1
RING_MY:        RS.L    1
RING_GRAV:      RS.L    1
RING_LIFE:      RS.W    1
RING_SIZE:      RS.B    0

RINGS:          EQU     64      ;TOTAL NUMBER OF RINGS

;----------------------------------------------------------
;               USEFUL MACROS
;----------------------------------------------------------
WAITDMA:        MACRO
@LOOP\@         BTST    #1,VDP_STATUS+1
                BNE.S   @LOOP\@
                ENDM

WREG:           MACRO
                MOVE    #$8000!((\1)<<8)!((\2)&$FF),VDP_CONTROL
                ENDM

WREGR:          MACRO
                AND     #$00FF,\2
                OR      #VDP_R\1,\2
                MOVE    \2,VDP_CONTROL
                ENDM

WDEST:          MACRO
                MOVE.L  #\1+((\2)&$3FFF)<<16+(\2)>>14,VDP_CONTROL
                ENDM

WDESTR:         MACRO
                ROL.L   #2,\2
                ROR     #2,\2
                SWAP    \2
                AND.L   #$3FFF0003,\2
                OR.L    #\1,\2
                MOVE.L  \2,VDP_CONTROL
                ENDM

WAITVBI:        MACRO
                MOVE.W  #0,VBLANKON
@LOOP\@:        CMP.W   #0,VBLANKON
                BEQ.S   @LOOP\@
                ENDM

DMADUMP:        MACRO
                MOVE.L  #(\2)/2,D0
                MOVE.L  #\1,D1
                MOVE.L  #\3,D2
                JSR     DMADUMPS
                ENDM

DMAFPAL:        MACRO
                MOVE.L  #(((\2)/2)&$FF)<<16+(((\2)/2)&$FF00)>>8+$93009400,D0    ;LENGTH
                MOVE.L  #((((\1)/2)&$FF)<<16)+((((\1)/2)&$FF00)>>8)+$95009600,D1
                MOVE.W  #(((\1)/2)&$7F0000)>>16+$9700,D2        ;SOURCE
                MOVE.W  #((\3)&$3FFF)+$C000,D3                  ;CRAM
                MOVE.W  #((\3)&$C000)>>14+$0080,D4              ;CRAM
                JSR     RAMDMAF
                ENDM

;----------------------------------------------------------
;               SYSTEM VARIABLES
;----------------------------------------------------------
                RSSET   SYSTEMRAM       ;POINT AT SYSTEM RAM (AFTER STACK)
STARTVARS:      RS.B    0               ;POINTER TO START OF VARS
HOTSTART:       RS.W    1               ;HOT START FLAG
VBLANKON:       RS.W    1               ;FLAG TO SAY WHEN VERTICAL BLANK CODE IS FINISHED
VBIVECTOR:      RS.L    1               ;LOCATION OF VBLANK ROUTINE
JOYPAD0:        RS.B    1               ;JOYPAD INFORMATION
JOYPADOLD:      RS.B    1               ;JOYPAD INFORMATION FROM LAST FRAME
                RS.W    1               ;QUICK SOURCE UNUSED
QSOURCE:        RS.L    1               ;QUICK SOURCE
                RS.W    1               ;QUICK SOURCE
QSIZE:          RS.L    1               ;QUICK SIZE RAM
DMAREQ:         RS.W    DMANUM*7        ;DMA REQUEST STORE
                RS.L    1               ;OVERRUN
RAMDMA:         RS.B    200             ;RAM DMAS
PALETTES:       RS.W    16*4            ;PALETTE ON SCREEN
SPRITETEMP:     RS.W    120*4           ;TABLE FOR SPRITE DATA(80 SPRITES + 40 OVERRUN)
RINGDATA:       RS.B    RINGS*RING_SIZE ;RING SYSTEM
RANDOM:         RS.L    1               ;POINTER TO RANDOM NUMBER

USERRAM:        RS.B    0

;----------------------------------------------------------
;               CARTRIDGE HEADER INFORMATION
;----------------------------------------------------------
                ORG     $0000
                DC.L    ENDSTACK                ;STACK POINTER
                DC.L    CODESTART               ;PROGRAM COUNTER

                ORG     $0068

                DC.L    EXTINT
                DC.L    ERROR
                DC.L    HBLANK
                DC.L    ERROR
                DC.L    VBLANK

                REPT    33
                DC.L    ERROR
                ENDR

CARTRIDGEDATA:  DC.B    "SEGA GENESIS    "
                DC.B    "GAMEHUT 2018.MAR"
TITLE:          DC.B    "GAMEHUT TEST SHELL                              "
                DC.B    "GAMEHUT TEST SHELL                              "
                DC.B    "GH 00-0001 -01"        ;PRODUCT NO;VERSION
                DC.W    0                       ;CHECKSUM
                DC.B    "J               "      ;CONTROL DATA
                DC.L    $000000,$3FFFFF         ;ROM ADDRESS
                DC.L    $FF0000,$FFFFFF         ;RAM ADDRESS
                DC.B    "            "          ;EXTERNAL RAM.
                DC.B    "            "          ;MODEM DATA
                DC.B    "                                        "      ;MEMO
                DC.B    "F               "      ;RELEASE CODES
;               NORG    $0200
;----------------------------------------------------------
;       SYSTEM INIT
;----------------------------------------------------------
CODESTART:      MOVE.W  #$2700,SR
                MOVE.W  #1,HOTSTART
                TST.L   $A10008
                BNE.S   @HOTSTART
                TST.W   $A1000C
                BNE.S   @HOTSTART
                CLR.W   HOTSTART
                MOVE.B  $A10001,D0
                ANDI.B  #$F,D0
                BEQ.S   @J1
                MOVE.L  #'SEGA',$A14000
@J1:
                MOVE.L  #$C0000000,$C00004
                CLR.L   D1
                MOVE.W  #$3F,D0
@CLR1:          MOVE.W  D1,$C00000
                DBF     D0,@CLR1
                LEA.L   $FFFF0000,A0
                MOVE.W  #$3FFF,D0
@CLR2:          MOVE.L  D1,(A0)+
                DBF     D0,@CLR2

@HOTSTART:      LEA.L   ENDSTACK,SP             ;SET UP STACK POINTER
                BSR.W   INIT_Z80
                MOVE.W  #$2300,SR

                WAITDMA                         ;WAIT FOR ANY DMA'S TO FINISH
                MOVE.W  #$2700,SR               ;STOP ALL INTERUPTS

                MOVE.L  #NULL,VBIVECTOR         ;SETUP DUMMY VERTICAL BLANK ROUTINE

                JSR     INIT_VDP_REG

                JSR     CLEARCRAM
                JSR     CLEARVSRAM
                JSR     CLEARVRAM

                MOVE    #$2000,SR               ;ENABLE INTERUPTS
                WREG    1,%01100100             ;ENABLE VBLANK
                WREG    0,%00000100             ;DISABLE HBLANK

                TST.W   HOTSTART                ;WAS IT A 'HOT START'?
                BNE.S   @HOT
;HARD RESET CODE HERE IF NEEDED
                BRA.S   @SKIP

@HOT:           MOVE.W  #50-1,D0                ;STOP RESET BUG
@PAUSE:         WAITVBI
                DBRA    D0,@PAUSE

@SKIP:          JSR     JOYINIT                 ;INITIALIZE JOYPADS

                JSR     SETUPRAM                ;COPY IN PERMANENT RAM ROUTINES

                WDEST   VSRAMW,$0000            ;VSCROLL OFFSET
                MOVE.L  #0,VDP_DATA
                WDEST   VRAMW,$FC00             ;HSCROLL OFFSET
                MOVE.L  #0,VDP_DATA

                MOVE.L  #$FC00,A0               ;CLEAR HSCROLL TABLE
                MOVE.L  #896,D0
                BSR     CLEARVRAM2

                MOVE.L  #$C000,A0               ;CLEAR MAP1
                MOVE.L  #4096,D0
                BSR     CLEARVRAM2

                MOVE.L  #$E000,A0               ;CLEAR MAP2
                MOVE.L  #4096,D0
                BSR     CLEARVRAM2

                MOVE.L  #$0000,A0               ;CLEAR FIRST BLOCK IN VIDEO MEMORY
                MOVE.L  #32,D0
                BSR     CLEARVRAM2

                LEA.L   SYSPALETTE,A0
                BSR     SETPAL1
                LEA.L   SYSPALETTE,A0
                BSR     SETPAL2
                LEA.L   SYSPALETTE,A0
                BSR     SETPAL3
                LEA.L   SYSPALETTE,A0
                BSR     SETPAL4

                JSR     DUMPCOLS

                JSR     SPRITEINIT

                JSR     RINGINIT

                JSR     USERINIT

                MOVE.L  #RANDOM_NUMS,RANDOM
                MOVE.L  #MAINVBI,VBIVECTOR      ;START MAIN VERTICAL BLANK ROUTINE

                JMP     MAIN                    ;JUMP TO START OF USER CODE

;----------------------------------------------------------
;               INITIALIZE VDP
;               SETUP VIDEO FOR 40 COLUMNS AND
;               28 LINES (320x224).
;----------------------------------------------------------
INIT_VDP_REG:   WREG    15,%00000010            ;ALWAYS ASSUME WORD INC

                WREG    00,%00000100            ;INTERUPTS OFF
                WREG    01,%00000100            ;SCREEN SETUP
                WREG    02,%00110000            ;SCREEN A
                WREG    03,%00000000            ;WINDOW
                WREG    04,%00000111            ;SCREEN B
                WREG    05,%00000000            ;SPRITE ATTRIBUTE TABLE
                WREG    06,%00000000            ;
                WREG    07,%00000000            ;BACKGROUND COLOUR
                WREG    08,%00000000            ;
                WREG    09,%00000000            ;
                WREG    10,%11111111            ;HORIZ INT COUNT
                WREG    11,%00000000            ;FULL SCROLL
                WREG    12,%10000001            ;320 WIDE NO HALF BRITE
                WREG    13,%00111111            ;HORIZ SCROLL TABLE POINT
                WREG    14,%00000000            ;
                WREG    16,%00000001            ;SCROLL SIZE
                WREG    17,%00000000            ;WINDOW H POS
                WREG    18,%00000000            ;WINDOW V POS

                WREG    15,%00000010            ;ALWAYS ASSUME WORD INC

                RTS

;----------------------------------------------------------
;               CLEAR VRAM TO 0
;----------------------------------------------------------
CLEARVRAM:      WDEST   VRAMW,$0000
                MOVE.L  #$800-1,D0
                MOVEQ.L #$0,D1
                LEA.L   VDP_DATA,A0
@LOOP:          MOVE.L  D1,(A0)
                MOVE.L  D1,(A0)
                MOVE.L  D1,(A0)
                MOVE.L  D1,(A0)
                MOVE.L  D1,(A0)
                MOVE.L  D1,(A0)
                MOVE.L  D1,(A0)
                MOVE.L  D1,(A0)
                DBRA    D0,@LOOP
                RTS

;----------------------------------------------------------
;               CLEAR VRAM FROM A0
;               LENGTH D0 TO 0
;----------------------------------------------------------
CLEARVRAM2:     MOVE.L  A0,D1
                WDESTR  VRAMW,D1
                MOVEQ.L #$0,D1
                LSR.L   #2,D0
                SUB.L   #1,D0
                LEA.L   VDP_DATA,A0
@LOOP:          MOVE.L  D1,(A0)
                DBRA    D0,@LOOP
                RTS

;----------------------------------------------------------
;               CLEAR COLOUR RAM (CRAM) TO 0
;----------------------------------------------------------
CLEARCRAM:      WDEST   CRAMW,$0000
                MOVE.L  #64-1,D0
                MOVEQ.L #0,D1
                LEA.L   VDP_DATA,A0
@LOOP:          MOVE.W  D1,(A0)
                DBRA    D0,@LOOP
                RTS

;----------------------------------------------------------
;               CLEAR VIDEO RAM (VSRAM) TO 0
;----------------------------------------------------------
CLEARVSRAM:     WDEST   VSRAMW,$0000
                MOVE.L  #128/2-1,D0
                MOVEQ.L #0,D1
                LEA.L   VDP_DATA,A0
@LOOP:          MOVE.W  D1,(A0)
                DBRA    D0,@LOOP
                RTS

;----------------------------------------------------------
;               CLEAR USER RAM TO 0
;----------------------------------------------------------
CLEARRAM:       LEA.L   STARTVARS,A0
                MOVE.L  #(ENDVARS-STARTVARS)-1,D0
                MOVEQ.L #0,D1
@LOOP:          MOVE.B  D1,(A0)+
                DBRA    D0,@LOOP
                RTS

;----------------------------------------------
;               INITIALIZE THE Z80
;----------------------------------------------
INIT_Z80:       MOVE.W  #$100,D0
                LEA.L   Z80REQ,A0
                LEA.L   Z80RES,A1
                MOVE.W  D0,(A0)
                MOVE.W  D0,(A1)

@WAIT_Z80:      BTST    #0,(A0)
                BNE.S   @WAIT_Z80

                LEA.L   @INITCODE,A2
                LEA.L   Z80RAM,A3
                MOVE.W  #@CODEEND-@INITCODE-1,D1

@LOOP:          MOVE.B  (A2)+,(A3)+
                DBF     D1,@LOOP

                CLR.W   (A1)
                CLR.W   (A0)
                MOVE.W  D0,(A1)
                RTS

@INITCODE:      DC.W    $AF01,$D91F,$1127,$0021,$2600,$F977,$EDB0,$DDE1
                DC.W    $FDE1,$ED47,$ED4F,$D1E1,$F108,$D9C1,$D1E1,$F1F9
                DC.W    $F3ED,$5636,$E9E9
@CODEEND:

;----------------------------------------------------------
;               INIT JOY
;----------------------------------------------------------
JOYINIT:        MOVE.B  #$00,MDSCTRL1
                MOVE.B  #$00,MDSCTRL2
                MOVE.B  #$00,MDSCTRL3
                MOVE.B  #$40,JSCTRL
                MOVE.B  #$40,JSCTRL1
                MOVE.B  #$40,JSCTRL2
                MOVE.B  #$40,JSCTRL3
                MOVE.B  #$40,JSDATA1
                MOVE.B  #$40,JSDATA2
                MOVE.B  #$40,JSDATA3
                RTS

;----------------------------------------------------------
;               READ JOYSTICK
;----------------------------------------------------------
JOYGET6:        movem.l d1/d2/d3/d4/d5/a0,-(sp)
                moveq   #0,d0
                cmp.w   #$0002,d1
                bhi     @JOYGET6_ERR
                add.w   d1,d1
                move.l  #$00a10003,a0           ; joystick data port address
                move.b  #$40,6(a0,d1.w)         ; set TH = output
                nop
                nop
                move.b  #$40,(a0,d1.w)          ; select [ ? 1 TRG-C TRG-B R L D U ]
                moveq   #0,d2
                nop
                nop
                nop
                move.b  $00(a0,d1.w),d2         ; d2 = xxxx|xxxx|? 1 TRG-C TRG-B R L D U
                cmp.b   #$70,d2                 ; checking for mouse or other handshaking device
                beq     @JOYGET6_ERR
                move.b  #$00,(a0,d1.w)          ; select [ ? 0 START TRG-A 0 0 D U ]
                lsl.w   #8,d2                   ; d2 = ? 1 TRG-C TRG-B R L D U|0 0 0 0 0 0 0 0
                move.b  $00(a0,d1.w),d2         ; d2 = ? 1 TRG-C TRG-B R L D U|? 0 St TRG-A 0 0 D U
                cmp.b   #$3f,d2                 ; checking for nothing connected
                beq     @JOYGET6_ERR
                move.b  #$40,(a0,d1.w)          ; select [ ? 1 TRG-C TRG-B R L D U ]
                moveq   #0,d3
                nop
                nop
                nop
                move.b  $00(a0,d1.w),d3         ; d3 = xxxx|xxxx|? 1 TRG-C TRG-B R L D U
                move.b  #$00,(a0,d1.w)          ; select [ ? 0 START TRG-A 0 0 D U ]
                lsl.w   #8,d3
                move.b  $00(a0,d1.w),d3         ; d3 = ? 1 TRG-C TRG-B R L D U|? 0 St TRG-A 0 0 D U
                move.b  #$40,(a0,d1.w)          ; select [ ? 1 TRG-C TRG-B R L D U ]
                moveq   #0,d4
                nop
                nop
                nop
                move.b  $00(a0,d1.w),d4         ; d4 = xxxx|xxxx|? 1 TRG-C TRG-B R L D U
                move.b  #$00,(a0,d1.w)          ; select [ ? 0 START TRG-A 0 0 0 0 ]
                lsl.w   #8,d4
                move.b  $00(a0,d1.w),d4         ; d4 = ? 1 TRG-C TRG-B R L D U|? 0 St TRG-A 0 0 0 0
                move.b  #$40,(a0,d1.w)          ; select [ ? 1 0 0 MD TX TY TZ ]
                moveq   #0,d5
                nop
                nop
                nop
                move.b  $00(a0,d1.w),d5         ; d5 = 0000|0000|? 1 0 0 MD TX TY TZ
                move.b  #$00,(a0,d1.w)          ; select [ ? 0 0 0 1 1 1 1 ]
                lsl.w   #8,d5
                move.b  $00(a0,d1.w),d5         ; d5 = ? 1 0 0 MD TX TY TZ| ? 0 0 0 1 1 1 1
                move.b  #$40,(a0,d1.w)

                cmp.w   d2,d3
                bne     @JOYGET6_ERR            ; nothing connected or unknown device
                cmp.w   d3,d4
                beq     @JOYGET3_PAD            ; regular 3 button controller
                and.w   #$000f,d4
                bne     @JOYGET6_ERR
                move.b  d2,d0
                lsl.w   #4,d0                   ; d0.w = 0000|? 0 St TA 0 0 D U 0 0 0 0
                lsr.w   #8,d2                   ; d2.w = 0000|0000|? 1 TC TB R L D U
                move.b  d2,d0                   ; d0.w = 0000|? 0 St TA ? 1 TC TB R L D U
                lsl.b   #2,d0                   ; d0.w = 0000|? 0 St TA TC TB R L D U 0 0
                lsr.w   #2,d0                   ; d0.w = 0000|0 0 ? 0|St TA TC TB R L D U
                and.l   #$000000ff,d0
                lsl.b   #4,d5                   ; d5.w = ? 1 0 0 MD TX TY TZ|1 1 1 1 0 0 0 0
                lsl.w   #4,d5                   ; d5.w = MD TX TY TZ 1 1 1 1 0 0 0 0 0 0 0 0
                or.w    d5,d0                   ; d0.w = MD TX TY TZ 1 1 1 1 St TA TC TB R L D U
                or.l    #$80000000,d0           ; d0.l = 1xxx|xxxx|xxxx|xxxx|MD,TX,TY,TZ,St,TA,TC,TB,R,L,D,U
                bra     @JOYGET6_ERR
@JOYGET3_PAD:
                move.b  d2,d0
                lsl.w   #4,d0                   ; d0.w = 0000|? 0 St TA 0 0 D U 0 0 0 0
                lsr.w   #8,d2                   ; d2.w = 0000|0000|? 1 TC TB R L D U
                move.b  d2,d0                   ; d0.w = 0000|? 0 St TA ? 1 TC TB R L D U
                lsl.b   #2,d0                   ; d0.w = 0000|? 0 St TA TC TB R L D U 0 0
                lsr.w   #2,d0                   ; d0.w = 0000|0 0 ? 0|St TA TC TB R L D U
                and.l   #$000000ff,d0           ; d0.l = 0xxx|xxxx|xxxx|xxxx|xxxx|xxxx|St,TA,TC,TB,R,L,D,U
@JOYGET6_ERR:
                movem.l (sp)+,d1/d2/d3/d4/d5/a0
                rts

;----------------------------------------------------------
;               NEW READ JOY
;----------------------------------------------------------
READJOY:        MOVE.W  #$100,Z80REQ
@L1:            BTST    #0,Z80REQ
                BNE.S   @L1

                MOVE.B  JOYPAD0,JOYPADOLD       ;STORE OLD PAD INFO FOR DEBOUNCE IF NEEDED

                MOVE.W  #0,D1
                BSR     JOYGET6

                MOVE.W  #0,Z80REQ

                TST.B   D0                      ;DID JOYPAD READ FAIL?
                BNE.S   @PASS
                MOVE.B  #$FF,D0
@PASS:          MOVE.B  D0,JOYPAD0
                RTS

;----------------------------------------------------------
;               INTERUPT ROUTINES
;----------------------------------------------------------

;----------------------------------------------------------
;               VERTICAL BLANK HANDLER
;----------------------------------------------------------
VBLANK:         MOVE.L  VBIVECTOR,-(A7)
                RTS

NULL:           MOVE.W  #1,VBLANKON
                RTE

MAINVBI:        MOVEM.L A0-A6/D2-D7,-(SP)       ;PUSH REGISTERS

                JSR     USERVBI
                JSR     READJOY

                MOVEM.L (SP)+,A0-A6/D2-D7       ;RESTORE REGISTERS
                MOVE.W  #1,VBLANKON             ;TELL MAIN LOOP THAT VBI CODE HAS FINISHED
                RTE
;----------------------------------------------------------
;               HORIZONTAL BLANK INTERUPT
;----------------------------------------------------------
HBLANK:         RTE

;----------------------------------------------------------
;               EXTERNAL INTERUPT
;----------------------------------------------------------
EXTINT:         RTE

;------------------------------
;       ERROR HANDLING CODE
;------------------------------
ERROR:          MOVE.W  #$2700,SR               ;TURN OFF INTERUPTS
@INF:           BRA.S   @INF                    ;INFINITE LOOP

;----------------------------------------------------------
;               DUMP DATA VIA DMA
;               D0=SIZE IN WORDS
;               D1=SOURCE ADDRESS
;               D2=DESTINATION ADDRESS
;               A0,A1,D3,D4,D5,D6 TRASHED
;----------------------------------------------------------
DMADUMPS:       LEA.L   VDP_CONTROL,A1

                AND.L   #$FFFFFF,D1             ;MAKE SURE IN ROM/RAM

                MOVE.W  D0,D3
                ADD.W   D3,D3
                MOVE.W  D1,D4
                ADD.W   D3,D4
                BEQ.S   @PASS
                BCS     @TWO

@PASS:
                MOVE.W  #$100,Z80REQ
@L1:            BTST    #0,Z80REQ
                BNE.S   @L1
                WREG    01,%01110100            ;DMA ENABLE

                JSR     RAMDMA

                WAITDMA

                WREG    01,%01100100            ;DMA DISABLE
                MOVE.W  #0,Z80REQ

                RTS

@TWO:           SUB.W   D4,D3
                LSR.W   #1,D3
                MOVE.W  D3,D0
                MOVE.L  D1,D5
                MOVE.L  D2,D6

                MOVE.W  #$100,Z80REQ
@L2:            BTST    #0,Z80REQ
                BNE.S   @L2
                WREG    01,%01110100            ;DMA ENABLE

                JSR     RAMDMA

                MOVE.L  D5,D1
                MOVE.L  D6,D2
                ADD.W   D3,D2
                ADD.W   D3,D2
                ADD.L   #$10000,D1
                CLR.W   D1
                MOVE.W  D4,D0
                LSR.W   #1,D0

                JSR     RAMDMA

                WAITDMA

                WREG    01,%01100100            ;DMA DISABLE
                MOVE.W  #0,Z80REQ

                RTS

;----------------------------------------------------------
;               RAM DMA ROUTINES
;               A1=VDP_CONTROL
;               D0=SIZE
;               D1=SOURCE
;               D2=DEST
;               A0,D1,D2 TRASHED
;----------------------------------------------------------
RAMDMAC:        LEA.L   QSOURCE+10,A0
                LSR.L   #1,D1
                LSL.L   #2,D2
                LSR.W   #2,D2
                SWAP    D2
                AND.W   #$3,D2
                OR.L    #$40000080,D2

                MOVEP.W D0,-3(A0)
                MOVEP.L D1,-11(A0)

                MOVE.W  -(A0),(A1)
                MOVE.W  -(A0),(A1)
                MOVE.W  -(A0),(A1)
                MOVE.W  -(A0),(A1)
                MOVE.W  -(A0),(A1)
                SWAP    D2
                MOVE.W  D2,(A1)
                SWAP    D2
                MOVE.W  D2,(A1)
                RTS

RAMDMAFC:       MOVE.L  D0,(A1)
                MOVE.L  D1,(A1)
                MOVE.W  D2,(A1)
                MOVE.W  D3,(A1)
                MOVE.W  D4,(A1)
                RTS

RAMVERTC:       LEA.L   DMAREQ,A0
                MOVE.W  #$8000,D1

                MOVE.W  #$8174,(A2)             ;DMA ENABLE

@BACK:          MOVE.W  (A0)+,D0
                BGE.S   @CHECK
@L1:            MOVE.W  D0,(A2)                 ;FIRST PASS
                MOVE.L  (A0)+,(A2)              ;SIZE/SOURCE
                MOVE.L  (A0)+,(A2)              ;SOURCE/SOURCE
                MOVE.W  (A0)+,(A2)              ;DEST
                MOVE.W  (A0)+,(A2)              ;DEST/MODE

                MOVE.W  (A0)+,D0                ;SIZE
                BLT.S   @L1

@CHECK:         BEQ.S   @DONE                   ;END
                OR.W    D1,D0
                MOVE.W  D0,(A2)
                BRA.S   @BACK

@DONE:          MOVE.L  #0,DMAREQ

                MOVE.W  #$8164,(A2)             ;DMA DISABLE

                RTS

RAMDMAEND:

;----------------------------------------------------------
;               COPY RAM ROUTINES TO RAM
;----------------------------------------------------------
SETUPRAM:       MOVE.L  #$94009300,QSIZE
                MOVE.L  #$97009600,QSOURCE
                MOVE.W  #$9500,QSOURCE+4

                LEA.L   RAMDMAC,A0
                LEA.L   RAMDMA,A1

                MOVE.W  #RAMDMAEND-RAMDMAC-1,D0
@L1:            MOVE.B  (A0)+,(A1)+
                DBRA    D0,@L1
                RTS

RAMDMAF:        EQU     RAMDMA+(RAMDMAFC-RAMDMAC)
RAMVERT:        EQU     RAMDMA+(RAMVERTC-RAMDMAC)

;----------------------------------------------------------
;               PALETTE SETUPS
;----------------------------------------------------------
SETPAL1:        MOVE.W  #16-1,D0
                LEA.L   PALETTES,A1
@LOOP1:         MOVE.W  (A0)+,(A1)+
                DBRA    D0,@LOOP1
                RTS

SETPAL2:        MOVE.W  #16-1,D0
                LEA.L   PALETTES+32,A1
@LOOP1:         MOVE.W  (A0)+,(A1)+
                DBRA    D0,@LOOP1
                RTS

SETPAL3:        MOVE.W  #16-1,D0
                LEA.L   PALETTES+64,A1
@LOOP1:         MOVE.W  (A0)+,(A1)+
                DBRA    D0,@LOOP1
                RTS

SETPAL4:        MOVE.W  #16-1,D0
                LEA.L   PALETTES+96,A1
@LOOP1:         MOVE.W  (A0)+,(A1)+
                DBRA    D0,@LOOP1
                RTS

;----------------------------------------------------------
;               COPY PALETTE TO MEMORY
;----------------------------------------------------------
DUMPCOLS:       MOVEM.L D0-D4,-(SP)

                MOVE.W  #$100,Z80REQ
@L1:            BTST    #0,Z80REQ
                BNE.S   @L1
                WREG    01,%01110100            ;DMA ENABLE
                LEA.L   VDP_CONTROL,A1
                DMAFPAL PALETTES,128,$0000
                WREG    01,%01100100            ;DMA DISABLE
                MOVE.W  #0,Z80REQ

                MOVEM.L (SP)+,D0-D4

                RTS

;----------------------------------------------------------
;               SPRITE CODE
;----------------------------------------------------------
SPRITEINIT:     WREG    5,$7C   ;SPRITE ATTRIBUTE TABLE

                LEA.L   VDP_DATA,A1
                WDEST   VRAMW,$F800

                MOVE.W  #1,(A1)
                MOVE.W  #0,(A1)
                MOVE.W  #0,(A1)
                MOVE.W  #1,(A1)

                LEA.L   SPRITETEMP,A1
                MOVE.W  #1,(A1)+
                MOVE.W  #0,(A1)+
                MOVE.W  #0,(A1)+
                MOVE.W  #1,(A1)+

                JSR     SPRITEDUMP

                RTS

SPRITEDUMP:     DMADUMP SPRITETEMP,640,$F800
                RTS

;----------------------------------------------------------
;               RING CODE
;----------------------------------------------------------

;-------------------------
;       INITIALISE RINGS
;-------------------------
RINGINIT:       LEA.L   RINGDATA,A0
                MOVE.W  #RINGS-1,D0                     ;NUMBER OF RINGS TO PROCESS
                MOVE.W  #0,D1
@L1:            MOVE.W  D1,RING_LIFE(A0)                ;SET LIFE SPAN TO 0
                ADD.L   #RING_SIZE,A0
                DBRA    D0,@L1
                RTS

;-------------------------
;       PROCESS RINGS
;-------------------------
PROCRING:       LEA.L   RINGDATA,A0
                MOVE.W  #RINGS-1,D0
                AND.W   #$FF,D7                         ;CLEAR AWAY ANY PREVIOUS SIZE INFO FROM SPRITE COUNT
                ADD.W   #S_2X2,D7                       ;ALL THESE RINGS WILL BE 2X2 IN SIZE
                MOVE.W  #S_PAL2+$1100/32,D6             ;ALL RINGS WILL USE THIS PALETTE AND VRAM LOCATION

@L1:            TST.W   RING_LIFE(A0)
                BEQ.S   @SKIP
;ADD SPRITE TO TABLE
                MOVE.W  RING_Y(A0),(A1)+                ;Y POSITION
                MOVE.W  D7,(A1)+                        ;SIZE 2X2 CHARACTERS AND SPRITE NUM
                MOVE.W  D6,(A1)+                        ;PALETTE NUMBER+GRAPHIC VRAM LOCATION/32
                MOVE.W  RING_X(A0),(A1)+                ;X POSITION ($80 IS LEFT OF SCREEN)
                ADD.W   #1,D7                           ;INCREMENT SPRITE COUNT
;PROCESS PHYSICS
                MOVE.L  RING_MX(A0),D1
                ADD.L   D1,RING_X(A0)
                MOVE.L  RING_MY(A0),D1
                ADD.L   D1,RING_Y(A0)
                MOVE.L  RING_GRAV(A0),D1
                ADD.L   D1,RING_MY(A0)
                SUB.W   #1,RING_LIFE(A0)

@SKIP:          ADD.L   #RING_SIZE,A0
                DBRA    D0,@L1
                RTS

;-------------------------
;       ADD A RING
;-------------------------
ADDRING:        LEA.L   RINGDATA,A0
                MOVE.W  #RINGS-1,D0
                MOVE.W  #10000,D2                       ;STORE SHORTEST REMAINING RING LIFE HERE
                MOVE.L  A0,A1                           ;SHORTEST LIFE RING POSITION

@L1:            MOVE.W  RING_LIFE(A0),D1
                BEQ.S   @ADD                            ;RING WITH ZERO LIFE, SO FREE SLOT FOUND
                CMP.W   D1,D2                           ;SHORTER LIFE THAN CURRENT SHORTEST?
                BLE.S   @SKIP
                MOVE.W  D1,D2                           ;NEW SHORTEST
                MOVE.L  A0,A1                           ;NEW SHORTEST POSITION
@SKIP:          ADD.L   #RING_SIZE,A0
                DBRA    D0,@L1

                MOVE.L  A1,A0                           ;REPLACE RING WITH SHORTEST LIFE LEFT IF ZERO NOT FOUND

@ADD:           SWAP.W  D3
                CLR.W   D3
                SWAP.W  D4
                CLR.W   D4
                MOVE.L  D3,RING_X(A0)
                MOVE.L  D4,RING_Y(A0)
                MOVE.L  D5,RING_MX(A0)
                MOVE.L  D6,RING_MY(A0)
                MOVE.L  D7,RING_GRAV(A0)
                MOVE.W  #120,RING_LIFE(A0)
                RTS

;----------------------------------------------------------
;               GET A RANDOM NUMBER FROM 0-255
;----------------------------------------------------------
GETRANDOM:      MOVE.L  RANDOM,A0
                MOVEQ.L #0,D0
                MOVE.B  (A0)+,D0
                ADD.L   #1,A0
                CMP.L   #RANDOM_END,A0
                BLT.S   @P1
                MOVE.L  #RANDOM_NUMS,A0
@P1:            MOVE.L  A0,RANDOM
                RTS

;----------------------------------------------------------
;               SYSTEM PALETTE
;----------------------------------------------------------
SYSPALETTE:     DC.W    $0000,$0000,$0040,$0060
                DC.W    $0080,$00a0,$00c0,$0004
                DC.W    $0026,$0248,$026a,$048c
                DC.W    $06ae,$0622,$0842,$0a64

;----------------------------------------------------------
;               RANDOM NUMBER TABLE (1024 ENTRIES)
;----------------------------------------------------------
RANDOM_NUMS:    DC.B    197, 154, 220, 63, 252, 161, 139, 18, 96, 144, 37, 90, 62, 70, 250, 87
                DC.B    52, 190, 176, 161, 14, 238, 157, 46, 45, 130, 207, 152, 113, 65, 34, 51
                DC.B    79, 182, 52, 205, 36, 144, 222, 136, 249, 167, 207, 151, 107, 231, 202, 138
                DC.B    72, 54, 179, 208, 14, 103, 38, 177, 71, 202, 106, 60, 92, 200, 74, 26
                DC.B    18, 75, 53, 200, 234, 48, 11, 51, 113, 83, 106, 159, 41, 74, 49, 16
                DC.B    138, 188, 210, 107, 169, 3, 156, 78, 94, 208, 74, 123, 205, 203, 227, 91
                DC.B    214, 99, 194, 6, 154, 182, 218, 7, 167, 27, 4, 188, 104, 171, 148, 228
                DC.B    139, 185, 228, 215, 216, 178, 35, 245, 9, 142, 80, 226, 246, 186, 241, 244
                DC.B    52, 170, 59, 181, 72, 112, 255, 177, 27, 222, 45, 31, 11, 223, 46, 173
                DC.B    203, 50, 34, 65, 163, 146, 182, 97, 5, 206, 22, 27, 232, 147, 60, 138
                DC.B    55, 171, 95, 178, 235, 160, 32, 216, 255, 226, 145, 79, 175, 192, 20, 186
                DC.B    38, 69, 98, 148, 152, 175, 178, 17, 24, 231, 240, 159, 203, 108, 71, 119
                DC.B    183, 214, 223, 62, 252, 135, 192, 240, 22, 15, 163, 51, 61, 194, 220, 32
                DC.B    148, 37, 212, 238, 57, 162, 220, 158, 51, 115, 126, 36, 227, 11, 180, 19
                DC.B    238, 144, 5, 60, 236, 189, 41, 13, 88, 222, 121, 12, 204, 93, 179, 208
                DC.B    25, 224, 201, 128, 97, 235, 111, 250, 2, 29, 140, 188, 24, 49, 80, 3
                DC.B    154, 209, 24, 53, 208, 47, 186, 26, 29, 110, 75, 165, 3, 217, 77, 115
                DC.B    51, 158, 16, 124, 122, 174, 96, 129, 154, 41, 173, 68, 92, 75, 243, 176
                DC.B    231, 183, 195, 221, 126, 19, 147, 21, 29, 22, 186, 151, 233, 191, 218, 240
                DC.B    94, 44, 73, 227, 74, 40, 20, 158, 224, 136, 143, 21, 90, 210, 127, 105
                DC.B    10, 56, 158, 41, 107, 95, 173, 171, 119, 161, 75, 180, 83, 229, 23, 37
                DC.B    148, 110, 237, 58, 223, 102, 120, 116, 2, 57, 143, 231, 251, 171, 10, 25
                DC.B    53, 250, 226, 38, 243, 70, 128, 195, 182, 80, 153, 168, 45, 43, 54, 144
                DC.B    214, 152, 99, 165, 128, 16, 78, 220, 18, 34, 221, 236, 70, 65, 30, 176
                DC.B    101, 156, 134, 38, 57, 171, 216, 120, 202, 58, 76, 192, 20, 180, 182, 99
                DC.B    27, 213, 140, 114, 150, 50, 60, 220, 53, 83, 108, 249, 12, 26, 250, 178
                DC.B    14, 247, 230, 92, 39, 50, 63, 103, 35, 99, 134, 186, 205, 17, 152, 197
                DC.B    60, 141, 92, 254, 23, 206, 69, 12, 102, 222, 125, 138, 238, 115, 93, 29
                DC.B    179, 215, 23, 22, 223, 27, 169, 172, 153, 9, 46, 75, 152, 26, 52, 85
                DC.B    58, 149, 180, 168, 207, 78, 49, 31, 244, 133, 83, 209, 94, 82, 170, 145
                DC.B    175, 171, 255, 148, 104, 251, 145, 93, 1, 193, 4, 125, 82, 168, 119, 179
                DC.B    157, 151, 47, 183, 193, 101, 229, 19, 8, 25, 75, 228, 179, 20, 97, 123
                DC.B    191, 70, 127, 211, 5, 196, 145, 19, 226, 48, 238, 214, 3, 88, 27, 61
                DC.B    225, 166, 68, 71, 101, 14, 82, 237, 144, 107, 79, 191, 231, 226, 70, 112
                DC.B    180, 21, 179, 255, 126, 166, 127, 134, 153, 128, 90, 254, 106, 58, 149, 161
                DC.B    178, 15, 131, 45, 87, 2, 79, 76, 64, 193, 109, 62, 213, 165, 31, 98
                DC.B    113, 103, 154, 179, 89, 50, 201, 218, 190, 98, 7, 19, 160, 73, 255, 169
                DC.B    199, 9, 106, 63, 197, 50, 51, 172, 167, 158, 93, 185, 110, 118, 2, 140
                DC.B    5, 206, 28, 15, 169, 46, 151, 231, 43, 156, 121, 72, 255, 103, 114, 253
                DC.B    130, 180, 98, 185, 50, 19, 231, 64, 24, 80, 190, 78, 54, 126, 186, 29
                DC.B    40, 146, 1, 6, 12, 142, 77, 215, 205, 70, 85, 160, 247, 80, 45, 144
                DC.B    39, 230, 198, 173, 233, 187, 185, 183, 104, 229, 105, 166, 206, 211, 149, 113
                DC.B    194, 191, 50, 81, 89, 198, 213, 187, 56, 247, 17, 6, 39, 132, 166, 193
                DC.B    96, 173, 136, 104, 212, 23, 48, 25, 185, 164, 122, 99, 252, 39, 251, 88
                DC.B    11, 161, 48, 7, 179, 206, 244, 169, 82, 35, 178, 76, 18, 202, 130, 53
                DC.B    73, 211, 149, 232, 133, 97, 186, 26, 86, 152, 34, 90, 174, 79, 116, 244
                DC.B    47, 231, 220, 122, 51, 182, 206, 249, 255, 112, 181, 234, 173, 218, 52, 99
                DC.B    104, 179, 87, 34, 127, 200, 25, 77, 57, 149, 95, 214, 111, 255, 174, 163
                DC.B    170, 114, 18, 55, 230, 204, 7, 32, 202, 183, 81, 174, 141, 134, 196, 168
                DC.B    160, 234, 225, 217, 101, 79, 100, 230, 61, 218, 49, 221, 150, 198, 213, 33
                DC.B    163, 154, 149, 222, 232, 136, 107, 165, 116, 156, 10, 141, 255, 170, 208, 120
                DC.B    183, 243, 45, 174, 57, 242, 61, 248, 152, 246, 97, 224, 110, 106, 168, 187
                DC.B    16, 82, 226, 34, 101, 45, 124, 171, 17, 182, 229, 63, 52, 190, 117, 58
                DC.B    103, 234, 181, 150, 92, 48, 32, 217, 241, 102, 134, 220, 58, 253, 37, 194
                DC.B    29, 125, 214, 123, 90, 103, 45, 247, 114, 94, 8, 253, 128, 73, 12, 191
                DC.B    89, 242, 54, 170, 119, 39, 83, 108, 234, 152, 31, 147, 145, 158, 163, 74
                DC.B    180, 86, 27, 96, 251, 190, 238, 183, 47, 61, 131, 150, 65, 146, 228, 237
                DC.B    12, 69, 139, 14, 163, 131, 24, 66, 224, 142, 47, 180, 210, 103, 229, 228
                DC.B    49, 195, 135, 66, 60, 166, 16, 17, 253, 170, 50, 15, 185, 11, 67, 235
                DC.B    205, 230, 76, 26, 70, 36, 102, 159, 196, 242, 66, 4, 96, 246, 77, 47
                DC.B    14, 220, 229, 242, 72, 110, 239, 96, 32, 195, 99, 153, 49, 168, 230, 37
                DC.B    33, 191, 146, 62, 87, 180, 17, 137, 24, 236, 245, 109, 155, 241, 2, 250
                DC.B    190, 217, 189, 115, 121, 86, 78, 232, 204, 210, 247, 68, 165, 39, 93, 177
                DC.B    96, 26, 133, 49, 79, 53, 155, 180, 110, 253, 172, 85, 233, 162, 18, 210
RANDOM_END:
