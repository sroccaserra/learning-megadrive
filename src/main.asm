;----------------------------------------------------------
;               GAMEHUT SHELL
;               BY JON BURTON - FEB 2018
;----------------------------------------------------------
                include system.asm              ;INCLUDES LOTS OF SYSTEM CODE TO MAKE ALL THIS POSSIBLE

;----------------------------------------------------------
;               VRAM MEMORY MAP IN HEXADECIMAL
;               (NOTE: CHARACTERS ARE 8 X 8 PIXEL BLOCKS)
;----------------------------------------------------------
;               $0000-$0020                     BLANK CHARACTER
;               $0020-$8000                     CHARACTERS FOR PLAYFIELDS AND SPRITES
;               $C000-$D000                     CHARACTER MAP FOR PLAYFIELD 1 (4096 BYTES)
;               $E000-$F000                     CHARACTER MAP FOR PLAYFIELD 2 (4096 BYTES)
;               $F800                           SPRITE TABLE (960 BYTES)

;----------------------------------------------------------
;               USER VARIABLES
;               - PUT ANY VARIABLES YOU NEED HERE
;----------------------------------------------------------
                RSSET   USERRAM
PLAYX:          RS.L    0
PLAY1X:         RS.W    1                       ;X POSITION OF PLAYFIELD 1
PLAY2X:         RS.W    1                       ;X POSITION OF PLAYFIELD 2
PLAYY:          RS.L    0
PLAY1Y:         RS.W    1                       ;Y POSITION OF PLAYFIELD 1
PLAY2Y:         RS.W    1                       ;Y POSITION OF PLAYFIELD 2
SONICX:         RS.W    1                       ;SONIC'S X POSITION
SONICY:         RS.W    1                       ;SONIC'S Y POSITION
SONICD:         RS.W    1                       ;SONIC'S DIRECTION
TEMPSCREEN:     RS.B    4096                    ;RAM TO BUILD TEMPORARY SCREEN MAP
ENDVARS:        RS.B    0

;----------------------------------------------------------
;               INITIALISE USER STUFF
;               - THIS IS WHERE YOU SET UP STUFF BEFORE YOU BEGIN
;----------------------------------------------------------
USERINIT:       MOVE.W  #0,PLAY1X               ;SET START PLAYFIELD 1 X POSITION TO ZERO
                MOVE.W  #0,PLAY1Y               ;SET START PLAYFIELD 1 Y POSITION TO ZERO

                DMADUMP MAPGFX,4*32,$20         ;DUMP 4 CHARACTERS (SIZE 32 BYTES EACH) TO VRAM LOCATION $20 (MAP GRAPHICS)
                DMADUMP SPRITEGFX,8*32,$1000    ;DUMP 8 CHARACTERS (SIZE 32 BYTES EACH) TO VRAM LOCATION $1000 (SPRITE GRAPHICS)

                LEA.L   TEMPSCREEN,A0           ;POINT A0 TO TEMPORARY BUFFER IN RAM TO BUILD MAP BEFORE WE COPY TO VRAM
                MOVE.W  #8-1,D3                 ;WE'LL MAKE 8 COPIES OF THIS PATTERN
@L4_IN:         LEA.L   CHARGFX,A1              ;POINT A1 TO CHARGFX, WHICH IS THE 8 CHARACTER X 4 CHARACTER PATTERN WE'LL COPY MULITPLE TIMES
                MOVE.W  #4-1,D1                 ;4 ROWS
@L3_IN:         MOVE.W  #8-1,D0                 ;COPY EACH ROW REPEATED ACROSS THE SCREEN 8 TIMES HORIZONTALLY
@L2_IN:         MOVE.W  #4-1,D2                 ;4 LONG-WORDS = 8 CHARACTERS WIDE
@L1_IN:         MOVE.L  (A1)+,(A0)+             ;COPY FROM CHARGFX TO THE TEMPSCREEN. THE + MEANS INCREMENT THE POINTERS
                DBRA    D2,@L1_IN               ;LOOP BACK TO @L1
                SUB.L   #16,A1                  ;POINT BACK TO THE START OF THE CURRENT CHARGFX ROW
                DBRA    D0,@L2_IN               ;LOOP BACK TO @L2
                ADD.L   #16,A1                  ;MOVE ONTO THE NEXT CHARGFX ROW
                DBRA    D1,@L3_IN               ;LOOP BACK TO @L3
                DBRA    D3,@L4_IN               ;LOOP BACK TO @L4

                DMADUMP TEMPSCREEN,4096,$C000   ;COPY TEMPSCREEN WHICH IS 4096 BYTES IN SIZE TO VRAM ADDRESS $C000

                LEA.L   PALETTE1,A0             ;DOWNLOAD A PALETTE FOR THE MAP TO USE
                BSR     SETPAL1                 ;OVERRIGHT FIRST PALETTE

                LEA.L   PALETTE2,A0             ;DOWNLOAD A PALETTE FOR THE SPRITES TO USE
                BSR     SETPAL2                 ;OVERRIGHT SECOND PALETTE

                JSR     DUMPCOLS                ;COPY ALL PALETTES TO CRAM (COLOUR RAM)

                MOVE.W  #$80+160-8,SONICX       ;SONIC'S X START POSITION
                MOVE.W  #$80+112-13,SONICY      ;SONIC'S Y START POSITION
                MOVE.W  #0,SONICD               ;SONIC'S START DIRECTION

                RTS

;------------------------------
;       MAIN GAME LOOP
;------------------------------
MAIN:           WAITVBI                                 ;WAITS FOR THE START OF THE NEXT FRAME
                ADD.W   #1,PLAY1X                       ;SCROLL PLAYFIELD 1 RIGHT BY ONE PIXEL
                ADD.W   #1,PLAY1Y                       ;SCROLL PLAYFIELD 1 UP BY ONE PIXEL
;ADD SPRITES
                LEA.L   SPRITETEMP,A1                   ;POINT TO TEMPORARY MEMORY TO BUILD SPRITE LIST

                MOVE.W  SONICY,(A1)+                    ;Y POSITION ($80 IS TOP OF SCREEN)
                MOVE.W  #S_2X4+1,(A1)+                  ;SIZE 2X4 CHARACTERS, NEXT SPRITE
                MOVE.W  #S_PAL2+$1000/32,D0             ;PALETTE NUMBER+GRAPHIC VRAM LOCATION/32
                ADD.W   SONICD,D0
                MOVE.W  D0,(A1)+                        ;ADD SONIC'S DIRECTION
                MOVE.W  SONICX,(A1)+                    ;X POSITION ($80 IS LEFT OF SCREEN

                MOVE.L  #$10000,(A1)+                   ;TERMINATE SPRITE LIST
                MOVE.L  #1,(A1)+                        ;       "  "

;MOVE SONIC
                BTST    #J_RIGHT,JOYPAD0
                BNE.S   @MOVE1
                ADD.W   #1,SONICX
                MOVE.W  #0,SONICD
@MOVE1:
                BTST    #J_LEFT,JOYPAD0
                BNE.S   @MOVE2
                SUB.W   #1,SONICX
                MOVE.W  #$800,SONICD
@MOVE2:
                BTST    #J_DOWN,JOYPAD0
                BNE.S   @MOVE3
                ADD.W   #1,SONICY
@MOVE3:
                BTST    #J_UP,JOYPAD0
                BNE.S   @MOVE4
                SUB.W   #1,SONICY
@MOVE4:

                BRA     MAIN                            ;LOOP BACK TO WAIT FOR NEXT FRAME

;----------------------------------------------------------
;               USER VBI ROUTINES
;               - PUT TIME CRITICAL CODE THAT MUST CALLED DURING THE VERTICAL BLANK HERE
;----------------------------------------------------------
USERVBI:        LEA.L   VDP_DATA,A1
                LEA.L   VDP_CONTROL,A2
;SET HORIZONTAL OFFSETS
                MOVE.L  #$7C000003,(A2)
                MOVE.L  PLAYX,(A1)              ;THIS TELLS THE VDP (VISUAL DISPLAY PROCESSOR) WHAT X POSITION THE PLAYFIELDS SHOULD BE AT

;SET VERTICAL OFFSETS
                MOVE.L  #$40000010,(A2)         ;THIS TELLS THE VDP WHAT Y POSITION THE PLAYFIELDS SHOULD BE AT
                MOVE.L  PLAYY,(A1)

;COPY SPRITE TABLE TO VRAM
                JSR     SPRITEDUMP
;READ JOYPAD
                BSR     READJOY                 ;READ THE JOYPAD

                RTS

;----------------------------------------------------------
;               PUT DATA BELOW HERE
;----------------------------------------------------------
;               CHARACTER CODES TO BUILD OUR PATTERN
CHARGFX:        incbin "bin/char_gfx.bin"
;               MAP GRAPHICS
MAPGFX:         incbin "bin/map_gfx.dat"
;               SPRITE GRAPHICS
SPRITEGFX:      incbin "bin/sprite_gfx.dat"
;               USER PALETTES
PALETTE1:       incbin "bin/map_gfx.pal"
PALETTE2:       incbin "bin/sprite_gfx.pal"
