
; start memcheck here
start_check = $0300
ram_end 			= $0288
ram_end_l   		= ram_end
ram_end_h   		= ram_end+1

; Pointers
addr 		= $e0
adrl     	= addr
adrh     	= addr+1
ptr1		= $e2
ptr1l		= ptr1
ptr1h		= ptr1+1
ptr2		= $e4
ptr2l		= ptr2
ptr2h		= ptr2+1

; UART address and registers
uart1		= $0200
uart1rxtx	= uart1+0
uart1ier	= uart1+0
uart1dll	= uart1+0
uart1dlh	= uart1+1
uart1iir	= uart1+2
uart1fcr	= uart1+2
uart1lcr	= uart1+3
uart1mcr	= uart1+4
uart1lsr	= uart1+5
uart1msr	= uart1+6
uart1scr	= uart1+7

; VIA address and registers
via1        = $0210
via1porta   = via1+1
via1portb   = via1
via1ddrb    = via1+2
via1ddra    = via1+3
via1t1cl    = via1+4
via1t1ch    = via1+5
via1t2cl    = via1+8
via1t2ch    = via1+9
via1sr      = via1 + $0a
via1acr     = via1 + $0b
via1pcr     = via1 + $0c
via1ifr     = via1 + $0d
via1ier     = via1 + $0e

;----------------------------------------------------------------------------------------------
; SD Card commands
;----------------------------------------------------------------------------------------------
cmd0 	= $40       ; GO_IDLE_STATE
cmd1 	= $40 + 1 	; SEND_OP_COND
cmd8 	= $40 + 8   ; SEND_IF_COND
cmd12	= $40 + 12  ; STOP_TRANSMISSION
cmd16	= $40 + 16 	; SET_BLOCKLEN
cmd17	= $40 + 17	; READ_SINGLE_BLOCK
cmd18	= $40 + 18	; READ_MULTIPLE_BLOCK
cmd24	= $40 + 24	; WRITE_BLOCK
cmd55	= $40 + 55	; APP_CMD
cmd58	= $40 + 58	; READ_OCR
acmd41	= $40 + 41

sd_data_token = $fe
sd_card_status 		= $0298  
; SD CArd command parameter/result buffer
sd_cmd_param 		= $02a0
sd_cmd_chksum		= sd_cmd_param+4
sd_cmd_result 		= $02a5

errno	 				= $0300


a_vdp		= $0220
a_vram		= a_vdp
a_vreg		= a_vdp+1

v_reg0_m3			= 1<<1
v_reg0_extV			= 1<<0

v_reg1_16k			= 1<<7
v_reg1_display_on	= 1<<6
v_reg1_int			= 1<<5
v_reg1_m1			= 1<<4
v_reg1_m2			= 1<<3
v_reg1_spr_size		= 1<<1
v_reg1_spr_mag		= 1<<0

v_reg0 	= $80
v_reg1 	= $81
v_reg2 	= $82
v_reg3 	= $83
v_reg4 	= $84
v_reg5 	= $85
v_reg6 	= $86
v_reg7  = $87

Transparent    =$00
Black          =$01
Medium_Green   =$02
Light_Green    =$03
Dark_Blue      =$04
Light_Blue     =$05;  5 Light Blue 
Dark_Red       =$06
Cyan           =$07 ;(Aqua Blue)
Medium_Red     =$08
Light_Red      =$09
Dark_Yellow    =$0a		;1010
Light_Yellow   =$0b		;1011
Dark_Green     =$0c		;1100
Magenta        =$0d ; (Purple)
Gray           =$0e
White          =$0f

WRITE_ADDRESS			=$40
ADDRESS_GFX_SPRITE		=$1b00

ADDRESS_GFX1_SCREEN		=$0800
ADDRESS_GFX1_PATTERN	=$3800
ADDRESS_GFX1_COLOR		=$1b80
ADDRESS_GFX1_SPRITE		=ADDRESS_GFX_SPRITE
ADDRESS_GFX1_SPRITE_PATTERN=$1000;ADDRESS_GFX1_PATTERN

ROWS=23
COLS=32

; Cursor Position and buffer
crs_x	= $e6
crs_y	= $e7

KEY_CR=$0d
KEY_LF=$0a
KEY_BACKSPACE=$08