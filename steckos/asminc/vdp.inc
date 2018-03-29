
; TODO FIXME conflicts with ehbasic zeropage locations - use steckschwein specific zeropage.s not the cc65....runtime/zeropage.s definition
tmp1=$e0
tmp2=$e1
ptr1=$e2


a_vdp		= $0220
a_vram		= a_vdp
a_vreg		= a_vdp+1

v_reg0_m3			= 1<<1
v_reg0_m4			= 1<<2
v_reg0_m5			= 1<<3

v_reg0_extV			= 1<<0

v_reg1_16k			= 1<<7
v_reg1_display_on	= 1<<6
v_reg1_int			= 1<<5
v_reg1_m1			= 1<<4
v_reg1_m2			= 1<<3
v_reg1_spr_size		= 1<<1
v_reg1_spr_mag		= 1<<0

v_reg8_VR			= 1<<3	; 0/1 16k/64k video ram
v_reg8_SPD			= 1<<1	; 0/1 sprites enabled/disabled

v_reg25_wait 		= 1<<2
v_reg25_cmd 		= 1<<6

v_reg0 	= $80
v_reg1 	= $81
v_reg2 	= $82
v_reg3 	= $83
v_reg4 	= $84
v_reg5 	= $80 + 	5
v_reg6 	= $80	+	6
v_reg7  = $80	+	7
v_reg8  = $80	+	8

v_reg11	= $80 + 11
v_reg14	= $80 + 14
v_reg25 = $80 + 25

v_reg36 = $80 + 36
v_reg37 = $80 + 37
v_reg38 = $80 + 38
v_reg39 = $80 + 39
v_reg40 = $80 + 40
v_reg41 = $80 + 41
v_reg42 = $80 + 42
v_reg43 = $80 + 43
v_reg44 = $80 + 44
v_reg45 = $80 + 45
v_reg46 = $80 + 46


; VDP command opcodes
; high speed move
v_cmd_hmmc 	= %11110000
v_cmd_ymmm 	= %11100000
v_cmd_hmmm 	= %11010000
v_cmd_hmmv 	= %11000000

; logical move
v_cmd_lmmc 	= %10110000
v_cmd_lmcm 	= %10100000
v_cmd_lmmm 	= %10010000
v_cmd_lmmv 	= %10000000

v_cmd_line 	= %01110000
v_cmd_srch 	= %01100000
v_cmd_pset 	= %01010000
v_cmd_point = %01000000
v_cmd_stop	= %00000000

; VDP command logical operations
; SC = source color code
; DC = destination color code

v_log_imp	= %00000000 ; DC=SC
v_log_and	= %00000001	; DC AND SC
v_log_or	= %00000010 ; DC OR SC
v_log_eor	= %00000011 ; DC=/SC AND DC OR SC AND /DC
v_log_not	= %00000100 ; DC=/SC

v_log_timp	= %00001000 ; if SC=0 then DC=DC else DC=SC
v_log_tand	= %00001001 ; if SC=0 then DC=DC else DC=SC AND DC
v_log_tor	= %00001010 ; if SC=0 then DC=DC else DC=SC OR DC
v_log_teor	= %00001011 ; if SC=0 then DC=DC else DC=/SC AND DC OR SC AND /DC
v_log_tnot	= %00001100 ; if SC=0 then DC=DC else DC=/SC

SP_Y=0
SP_X=1
SP_N=2
SP_C=3

SPRITE_INVISIBLE=$bf
SPRITE_OFF=$d0

Transparent    =$00
Black          =$01	;0	0	0		"black"
Medium_Green   =$02 ;35	203	50		"23
Light_Green    =$03	;96	221	108
Dark_Blue      =$04 ;84	78	255		"544EFF"
Light_Blue     =$05 ;125 112 255	"7D70FF"
Dark_Red       =$06 ;210 84	66		"D25442"
Cyan           =$07 ;69 232	255		(Aqua Blue)
Medium_Red     =$08 ;250 89	72 		"FA5948"
Light_Red      =$09 ;255 124 108	"FF7C6C"
Dark_Yellow    =$0a ;211 198 60		"D3C63C"
Light_Yellow   =$0b ;229 210 109	"E5D26D"
Dark_Green     =$0c ;35 178	44
Magenta        =$0d ;200 90	198 	"C85AC6" (Purple)
Gray           =$0e ;204 204 204	"CCCCCC"
White          =$0f ;255 255 255	"white"

WRITE_ADDRESS			=$40
ADDRESS_GFX_SPRITE		=$1b00

ADDRESS_GFX1_SCREEN		=$0000			; name table
ADDRESS_GFX1_PATTERN	=$3800
ADDRESS_GFX1_COLOR		=$1b80
ADDRESS_GFX1_SPRITE		=ADDRESS_GFX_SPRITE
ADDRESS_GFX1_SPRITE_PATTERN=$1000;

ADDRESS_GFX2_SCREEN			=$1800			; name table
ADDRESS_GFX2_PATTERN		=$0000
ADDRESS_GFX2_COLOR			=$2000
ADDRESS_GFX2_SPRITE			=ADDRESS_GFX_SPRITE
ADDRESS_GFX2_SPRITE_PATTERN	=ADDRESS_GFX1_SPRITE_PATTERN

ADDRESS_GFX6_SCREEN			=ADDRESS_GFX1_SCREEN			; screen

ADDRESS_GFX7_SCREEN			=$10000							; 2nd 64 RAM
ADDRESS_GFX7_SPRITE			=ADDRESS_GFX_SPRITE
ADDRESS_GFX7_SPRITE_PATTERN=ADDRESS_GFX1_SPRITE_PATTERN

ADDRESS_GFX_MC_SCREEN			=ADDRESS_GFX2_SCREEN	; name table
ADDRESS_GFX_MC_PATTERN			=ADDRESS_GFX2_PATTERN	; pattern table
ADDRESS_GFX_MC_SPRITE			=ADDRESS_GFX2_SPRITE	; sprite attributes
ADDRESS_GFX_MC_SPRITE_PATTERN	=ADDRESS_GFX2_PATTERN	; sprite pattern

; vnops - 16cl -> 8Mhz -> 2Âµs, the min vdp wait
.macro	vnops
	jsr vdp_nopslide	;6cl
.endmacro

.macro m_vdp_nopslide
vdp_nopslide:

			; 8µs = 8000ns = 64 * 125ns
			; nop = 2cl
			; 8µs = 23 nop
			; jsr = 6cl
			; rts = 6cl
			; 32 - 12 = 20
			.repeat 20 ; clockspeed * 1000 / 125 / 2 - 12
			nop
			.endrepeat


			rts			;6cl
.endmacro

.macro vdp_sreg
			sta	a_vreg
			vnops
			sty	a_vreg
.endmacro

.macro	SyncBlank
	bit a_vreg	; maybe within blank, we clean flag by read to a_vreg
	nop			; TODO FIXME - investigate, accessing the a_vreg too fast results in machine crash maybe due to bus contention
	nop
	nop
	nop
@l:	bit	a_vreg	; wait until blank - irq flag set?
	bpl @l
.endmacro

.macro InBlank
@l:	bit	a_vreg
	bpl @l	   ; wait until blank - irq flag set?
.endmacro
