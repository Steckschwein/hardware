.setcpu "65c02"
.include "kernel.inc"
.include "common.inc"
.include "vdp.inc"
.include "joystick.inc"
.include "kernel_jumptable.inc"
.include "appstart.inc"

.importzp ptr1,tmp1,tmp2,tmp3

.import vdp_mc_on
.import vdp_mc_blank
.import vdp_mc_set_pixel
.import	vdp_bgcolor
.import	read_joystick

appstart $1000

.define COLOR White
.define BORDER_COLOR COLOR
.define IRQ_VEC $fffe

.code
main:
        jsr krn_textui_disable
        
        sei
        jsr init_pong
        copypointer user_isr, safe_isr
        SetVector game_isr, user_isr
        cli        
        
        jsr ResetGame

		keyin
        sei
        copypointer safe_isr, user_isr
        cli
        
        vdp_sreg 0, v_reg9  ; restore screen size
        
		jsr	krn_textui_init
        jsr krn_textui_enable
        
		jmp (retvec)

safe_isr:
        .word 0
        
init_pong:
        jsr vdp_mc_blank
        jsr vdp_mc_on
        vdp_sreg v_reg1_16k|v_reg1_display_on|v_reg1_m2|v_reg1_spr_size|v_reg1_spr_mag|v_reg1_int, v_reg1 ; big sprites
        vdp_sreg v_reg8_VR, v_reg8; make sure sprites are enabled
        vdp_sreg $0, v_reg23
        vdp_sreg $0, v_reg18
        vdp_sreg v_reg25_wait|v_reg25_cmd, v_reg25
        
		ldx #63
@l1:	ldy #0
		lda #BORDER_COLOR
		jsr vdp_mc_set_pixel
		ldy #47
		lda #BORDER_COLOR
		jsr vdp_mc_set_pixel
		dex
        dex
		bpl @l1
		ldx #32
		ldy #45
@l2:	lda #BORDER_COLOR
        jsr vdp_mc_set_pixel
		dey
        dey
		bpl @l2
        
        ; patterns
        vdp_sreg <ADDRESS_GFX_MC_SPRITE_PATTERN, WRITE_ADDRESS + >ADDRESS_GFX_MC_SPRITE_PATTERN
        ldx #0
:       lda sprite_data, x
        inx
        vdp_wait_l
        sta a_vram
        cpx #32*2
        bne :-

        lda #>digits
        sta ptr1+1
        
		rts


;; DECLARE SOME VARIABLES HERE
;  .resset $0000  ;;start variables at ram location 0
  
frame_count:    .res 1,0
gamestate:  .res 1  ; .res 1 means reserve one byte of space
ballx:      .res 1  ; ball horizontal position
bally:      .res 1  ; ball vertical position
ballup:     .res 1  ; 1 = ball moving up
balldown:   .res 1  ; 1 = ball moving down
ballleft:   .res 1  ; 1 = ball moving left
ballright:  .res 1  ; 1 = ball moving right
ballspeedx: .res 1  ; ball horizontal speed per frame
ballspeedy: .res 1  ; ball vertical speed per frame
paddle1ytop:    .res 1  ; player 1 paddle top vertical position
paddle1_velo:   .res 1
paddle2ytop:    .res 1  ; player 2 paddle bottom vertical position
paddle2_velo:   .res 1
buttons1:       .res 1  ; player 1 gamepad buttons, one bit per button
buttons2:   .res 1  ; player 2 gamepad buttons, one bit per button
score1:     .res 1  ; player 1 score, 0-15
score2:     .res 1  ; player 2 score, 0-15

;; DECLARE SOME CONSTANTS HERE
STATETITLE     = $00  ; displaying title screen
STATEPLAYING   = $01  ; move paddles/ball, check for collisions
STATEGAMEOVER  = $02  ; displaying game over screen
  
RIGHTWALL      = $Fe  ; when ball reaches one of these, do something
RIGHTWALLOFFS  = PADDLE2X-(2*(3+1)) ; magnified sprite *2, 3 - 3px of '0' in paddle shape and 1px to bring ball exactly on paddle

TOPWALL        = $1
BOTTOMWALL     = $b6

BOTTOMWALLOFFS = $a2

LEFTWALL       = $02
LEFTWALLOFFS   = PADDLE1X+(2*(3+1))
  
PADDLE1X       = $08  ; horizontal position for paddles, doesnt move
PADDLE2X       = $F0

PADDLE_WIDTH = 4
PADDLE_HEIGHT = 20

BALL_Y_START_POS = $5c
BALL_X_START_POS = $7a

BG_1 = $01

scoreBackground=10

;;;;;;;;;;;;;;;;;;

  ;.bank 0
  ;.org $C000 
ResetGame:	
;;;Set some initial ball stats
  LDA #0
  STA balldown
  STA ballright
  LDA #1
  STA ballup
  STA ballleft
  
  LDA #BALL_Y_START_POS
  STA bally
  
  LDA #BALL_X_START_POS
  STA ballx
  
  LDA #$02
  STA ballspeedx
  STA ballspeedy

  LDA #$0
  STA score1
  STA score2

        stz paddle1_velo
        stz paddle2_velo
  
;;; Set initial paddle state
  LDA #$60
  STA paddle1ytop
  STA paddle2ytop
  	
;;:Set starting game state
  LDA #STATEPLAYING
  STA gamestate

  rts

game_isr:
;        lda #Dark_Yellow
 ;       jsr vdp_bgcolor
		lda SYS_IRR
		bpl l_exit
		
        inc frame_count
    
        ;;;all graphics updates done by here, run game engine
        JSR ReadController1  ;;get the current button data for player 1
        JSR ReadController2  ;;get the current button data for player 2

        GameEngine:  
        LDA gamestate
        CMP #STATETITLE
        BEQ EngineTitle    ;;game is displaying title screen

        LDA gamestate
        CMP #STATEGAMEOVER
        BEQ EngineGameOver  ;;game is displaying ending screen

        LDA gamestate
        CMP #STATEPLAYING
        BEQ EnginePlaying   ;;game is playing

GameEngineDone:

        JSR UpdateSprites  ;;set ball/paddle sprites from positions

        vdp_sreg <ADDRESS_GFX1_SPRITE, WRITE_ADDRESS + >ADDRESS_GFX1_SPRITE
        ldx #0
:       vdp_wait_l 10
        lda sprites, x
        sta a_vram
        inx
        cpx #3*4+1
        bne :-   

        JSR DrawScore

        lda #Medium_Green<<4|Black
        jsr vdp_bgcolor
l_exit:
        rts
;;;;;;;;
 
EngineTitle:
  ;;if start button pressed
  ;;  turn screen off
  ;;  load game screen
  ;;  set starting paddle/ball position
  ;;  go to Playing State
  ;;  turn screen on
  JMP GameEngineDone

;;;;;;;;; 
 
EngineGameOver:
  ;;if start button pressed
  ;;  turn screen off
  ;;  load title screen
  ;;  go to Title State
  ;;  turn screen on

;;;  Draw game over text
  LDX #$00
DrawGameOverLine1:
  ;LDA endingMessageLine1, x
  ;STA $2007

  CLC
  INX
  CPX #$09
  BCC DrawGameOverLine1
		
;  LDA #%00001110   ; disable sprites, enable background, no clipping on left side
 ; STA $2001

  ;; Wait for start button press
  LDA buttons1
  AND #JOY_FIRE ;%00010000
  bne Player1StartCheckDone
  JMP ResetGame

Player1StartCheckDone:
  LDA buttons2
  AND #JOY_FIRE; %00010000
  bne Player2StartCheckDone
  JMP ResetGame

Player2StartCheckDone:
  JMP GameEngineDone
 
;;;;;;;;;;;
 
EnginePlaying:

MoveBallRight:
  LDA ballright
  BEQ MoveBallRightDone   ;;if ballright=0, skip this section

  LDA ballx
  CLC
  ADC ballspeedx        ;;ballx position = ballx + ballspeedx
  STA ballx

  CMP #RIGHTWALL
  BCC MoveBallRightDone      ;;if ball x < right wall, still on screen, skip next section

  LDA score1
  CMP #$0F
  BCC @IncScore
	
  LDA #STATEGAMEOVER
  STA gamestate

@IncScore:
  INC score1 ;; Inc score
  
  ;; Reset ball state
  LDA #BALL_Y_START_POS
  STA bally
  
  LDA #BALL_X_START_POS
  STA ballx

  LDA #$00
  STA ballright
  LDA #$01
  STA ballleft         ;; ball now moving left
MoveBallRightDone:

MoveBallLeft:
  LDA ballleft
  BEQ MoveBallLeftDone   ;;if ballleft=0, skip this section

  LDA ballx
  SEC
  SBC ballspeedx        ;;ballx position = ballx - ballspeedx
  STA ballx

  ;; Give point to player 2, reset ball
  CMP #LEFTWALL
  BCS MoveBallLeftDone      

  LDA score2
  CMP #$0F
  BCC @IncScore
	
  LDA #STATEGAMEOVER
  STA gamestate

@IncScore:
  INC score2 ;; Inc player 2 score
  
  ;; Reset ball state
  LDA #BALL_Y_START_POS
  STA bally
  
  LDA #BALL_X_START_POS
  STA ballx

  LDA #$01
  STA ballright
  LDA #$00
  STA ballleft         ;; ball now moving left
MoveBallLeftDone:

MoveBallUp:
  LDA ballup
  BEQ MoveBallUpDone   ;;if ballup=0, skip this section

  LDA bally
  SEC
  SBC ballspeedy        ;;bally position = bally - ballspeedy
  STA bally

  LDA bally
  CMP #TOPWALL
  BCS MoveBallUpDone      ;;if ball y > top wall, still on screen, skip next section
  LDA #$01
  STA balldown
  LDA #$00
  STA ballup         ;;bounce, ball now moving down
MoveBallUpDone:

MoveBallDown:
  LDA balldown
  BEQ MoveBallDownDone   ;;if ballup=0, skip this section

  LDA bally
  CLC
  ADC ballspeedy        ;;bally position = bally + ballspeedy
  STA bally

  LDA bally
  CMP #BOTTOMWALL
  BCC MoveBallDownDone      ;;if ball y < bottom wall, still on screen, skip next section
  LDA #$00
  STA balldown
  LDA #$01
  STA ballup         ;;bounce, ball now moving down
MoveBallDownDone:

MovePaddle1Up:
  ;;if up button pressed
        LDA buttons1
        AND #JOY_UP;%00001000
        bne MovePaddle1UpDone ;; not pressed, skip

        ldx paddle1_velo
:        
        LDA paddle1ytop
        CMP #TOPWALL ;; Check if we have hit top wall
        BCC MovePaddle1Reset ;; If so, skip

        DEC paddle1ytop ;; Decrement position	
        dex
        bpl :-
        bra MovePaddle1IncVelo
MovePaddle1UpDone:

MovePaddle1Down:
  ;;if down button pressed
  ;;  if paddle bottom < bottom wall
  ;;    move paddle top and bottom down
        LDA buttons1
        AND #JOY_DOWN;%00000100
        bne MovePaddle1Reset ;; not pressed, skip

        ldx paddle1_velo
:       LDA paddle1ytop 
        CMP #BOTTOMWALLOFFS ;; Check if we have hit top wall
        BCS MovePaddle1Reset ;; If so, skip
  
        INC paddle1ytop ;; Decrement position
        dex
        bpl :-

MovePaddle1IncVelo:
        lda frame_count
        and #$1
        bne MovePaddle1Done
        inc paddle1_velo
        bra MovePaddle1Done
MovePaddle1Reset:
        stz paddle1_velo        
MovePaddle1Done:

MovePaddle2Up:
  ;;if up button pressed
        LDA buttons2
        AND #JOY_UP;%00001000
        bne MovePaddle2UpDone ;; not pressed, skip

        ldx paddle2_velo
:        
        LDA paddle2ytop
        CMP #TOPWALL ;; Check if we have hit top wall
        BCC MovePaddle2Reset ;; If so, skip

        DEC paddle2ytop ;; Decrement position	
        dex
        bpl :-
        bra MovePaddle2IncVelo
MovePaddle2UpDone:

MovePaddle2Down:
  ;;if down button pressed
  ;;  if paddle bottom < bottom wall
  ;;    move paddle top and bottom down
        LDA buttons2
        AND #JOY_DOWN;%00000100
        bne MovePaddle2Reset ;; not pressed, skip

        ldx paddle2_velo
:       LDA paddle2ytop 
        CMP #BOTTOMWALLOFFS ;; Check if we have hit top wall
        BCS MovePaddle2Reset ;; If so, skip
  
        INC paddle2ytop ;; Decrement position
        dex
        bpl :-
        
MovePaddle2IncVelo:
        lda frame_count
        and #$1
        bne MovePaddle2Done
        inc paddle2_velo
        bra MovePaddle2Done
MovePaddle2Reset:
        stz paddle2_velo        
MovePaddle2Done:

	
CheckPaddle1Collision:
  ;;if ball x < paddle1x
  ;;  if ball y > paddle y top
  ;;    if ball y < paddle y bottom
  ;;      bounce, ball now moving left
  ;; Check if on paddle x position
  LDA ballx
  CMP #LEFTWALLOFFS
  BCS CheckPaddle1CollisionDone

  cmp #LEFTWALLOFFS-PADDLE_WIDTH
  bcc CheckPaddle1CollisionDone
  
  ;; Check if ball is above paddle
  LDA bally
  CMP paddle1ytop
  BCC CheckPaddle1CollisionDone

  ;; Check if ball is below paddle
  LDA paddle1ytop
  CLC
  ADC #PADDLE_HEIGHT
  CMP bally
  BCC CheckPaddle1CollisionDone

  ;; Bounce, ball now moving right
  LDA #$01
  STA ballright
  LDA #$00
  STA ballleft         
CheckPaddle1CollisionDone:

CheckPaddle2Collision:
  ;;if ball x < paddle1x
  ;;  if ball y > paddle y top
  ;;    if ball y < paddle y bottom
  ;;      bounce, ball now moving left
  ;; Check if on paddle x position
  LDA ballx
  CMP #RIGHTWALLOFFS
  BCC CheckPaddle2CollisionDone
  
  cmp #RIGHTWALLOFFS+PADDLE_WIDTH
  bcs CheckPaddle2CollisionDone
  
  ;; Check if ball is above paddle
  LDA bally
  CMP paddle2ytop
  BCC CheckPaddle2CollisionDone

  ;; Check if ball is below paddle
  LDA paddle2ytop
  CLC
  ADC #PADDLE_HEIGHT
  CMP bally
  BCC CheckPaddle2CollisionDone

  ;; Bounce, ball now moving left
  LDA #$01
  STA ballleft
  LDA #$00
  STA ballright         
CheckPaddle2CollisionDone:
	
  JMP GameEngineDone

UpdateSprites:
    LDA bally  ;; update all ball sprite info
    sta sprites_ball+SPRITE_Y
   
    LDA ballx
    sta sprites_ball+SPRITE_X
  
    ;;update paddle 1 sprites
    lda paddle1ytop ;; load ball position and add paddle offset
    sta sprites_paddle1+SPRITE_Y

    ;;update paddle 2 sprites
    lda paddle2ytop ;; load ball position and add paddle offset
    sta sprites_paddle2+SPRITE_Y

    RTS
  
draw_digit:
        stx tmp1
        stx tmp3
        sty tmp2
        asl
        asl
        asl
        clc
        adc #<digits
        sta ptr1
        
        ldy #0
@score_l0:
        ldx #0
        lda tmp3
        sta tmp1
@score_l1:
        lda (ptr1),y
        and bitmask,x
        beq @score_l2  ; black
        lda #COLOR
@score_l2:
;        ora #Gray
        phx
        phy
        ldx tmp1
        ldy tmp2
        jsr vdp_mc_set_pixel
        ply
        plx
        inc tmp1
        inx
        cpx #6  ; pixels in char
        bne @score_l1
        inc tmp2
        iny 
        cpy #8
        bne @score_l0
        rts

DrawScore:
        LDX #scoreBackground
        lda score1
        ;; Check if score equals or exceeds 10
        cmp #10
        BCC @NoDigit1
        SBC #10
        LDX #BG_1
@NoDigit1:
        pha
        txa
        ldx #18
        ldy #2
        jsr draw_digit
        pla
        ;; Store first digit
        ldx #24
        ldy #2
        jsr draw_digit

  
        ;; Draw player 2 score  
        LDX #scoreBackground
        lda score2
        ;; Check if score equals or exceeds 10
        cmp #10
        BCC @NoDigit2
        SBC #10
        LDX #BG_1
@NoDigit2:
        pha
        txa
        ldx #35
        ldy #2
        jsr draw_digit
        pla
        ldx #41
        ldy #2
        jsr draw_digit
 
        RTS
 
ReadController1:
    lda #JOY_PORT1
    jsr read_joystick
    sta buttons1
    rts
  
ReadController2:
    lda #JOY_PORT2
    jsr read_joystick
    sta buttons2
    rts
          
;;;;;;;;;;;;;;  
sprites:
     ;vert horiz tile attr 
sprites_paddle1:
  .byte $a0, $0a, $0, COLOR   ;sprite 0 - paddle
sprites_paddle2:
  .byte $a0, $ea, $0, COLOR   ;sprite 1 - paddle
sprites_ball:
  .byte $40, $a0, $4, COLOR   ;sprite 2 - ball
  .byte $d0; end of sprites

sprite_data:
  .byte %00000000
  .byte %00000000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte 0,0,0,0,0,0,0,0
  .byte 0,0,0,0,0,0,0,0
  
  .byte 0,$18,$18,0,0,0,0,0
  .byte 0,0,0,0,0,0,0,0
  .byte 0,0,0,0,0,0,0,0,0
  .byte 0,0,0,0,0,0,0,0,0

;;;;;;;;;;;;;;
bitmask:
    .byte $80,$40,$20,$10,$08,$04

.macro pixel8 val
    .repeat 1, i
        .if (.strat(val, i) = '#')
         .byte 1<<i
        .endif
    .endrepeat
.endmacro

.data
digits:
;pixel8 "####...."
;.byte $f8, $88, $88, $88, $88, $88, $88, $f8;
.byte $f0, $90, $90, $90, $90, $90, $90, $f0;
;####....
;#..#....
;#..#....
;#..#....
;#..#....
;#..#....
;#..#....
;####....
.byte $20, $20, $20, $20, $20, $20, $20, $20;
;..#.....
;..#.....
;..#.....
;..#.....
;..#.....
;..#.....
;..#.....
;..#.....
.byte $f0, $10, $10, $f0, $80, $80, $80, $f0;
;####....
;...#....
;...#....
;####....
;#.......
;#.......
;#.......
;####....
.byte $f0, $10, $10, $f0, $10, $10, $10, $f0;
;####....
;...#....
;...#....
;####....
;...#....
;...#....
;...#....
;####....
.byte $90, $90, $90, $f0, $10, $10, $10, $10;
;#..#....
;#..#....
;#..#....
;####....
;...#....
;...#....
;...#....
;...#....
.byte $f0, $80, $80, $f0, $10, $10, $10, $f0;
;####....
;#.......
;#.......
;####....
;...#....
;...#....
;...#....
;####....
.byte $f0, $80, $80, $f0, $90, $90, $90, $f0;
;####....
;#.......
;#.......
;####....
;#..#....
;#..#....
;#..#....
;####....
.byte $f0, $10, $10, $10, $10, $10, $10, $10;
;####....
;...#....
;...#....
;...#....
;...#....
;...#....
;...#....
;...#....
.byte $f0, $90, $90, $f0, $90, $90, $90, $f0;
;####....
;#..#....
;#..#....
;####....
;#..#....
;#..#....
;#..#....
;####....
.byte $f0, $90, $90, $f0, $10, $10, $10, $f0;
;####....
;#..#....
;#..#....
;####....
;...#....
;...#....
;...#....
;####....
.byte 0,0,0,0,0,0,0,0
;........
;........
;........
;........
;........
;........
;........
;G A M E O V E R
.byte 0,0,0,0,0,0,0,0 
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0

.segment "STARTUP"