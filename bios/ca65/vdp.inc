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