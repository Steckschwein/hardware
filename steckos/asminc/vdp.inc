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

ADDRESS_GFX1_SCREEN		=$0800
ADDRESS_GFX1_PATTERN	=$3800
ADDRESS_GFX1_COLOR		=$1b80
ADDRESS_GFX1_SPRITE		=ADDRESS_GFX_SPRITE
ADDRESS_GFX1_SPRITE_PATTERN=$1000;

ADDRESS_GFX2_SCREEN		=$1800
ADDRESS_GFX2_PATTERN	=$0000
ADDRESS_GFX2_COLOR		=$2000
ADDRESS_GFX2_SPRITE		=ADDRESS_GFX_SPRITE
ADDRESS_GFX2_SPRITE_PATTERN=ADDRESS_GFX2_PATTERN

; vnops - 16cl -> 8Mhz -> 2Âµs, the min vdp wait
.macro	vnops
	jsr vdp_nopslide	;6cl	
.endmacro

.macro m_vdp_nopslide
vdp_nopslide:
		nop			;2cl
		nop			;2cl
		rts			;6cl
.endmacro

.macro vdp_sreg
			sta	a_vreg
			vnops
			sty	a_vreg	
.endmacro

.macro	SyncBlank
	lda a_vreg
@l:	bit	a_vreg
	bpl @l	   ; wait until blank - irq flag set?
.endmacro