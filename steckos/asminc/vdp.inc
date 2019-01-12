; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

vdp_ptr=$e0
vdp_tmp=$e2

a_vdp		= $0220
a_vram		= a_vdp
a_vreg		= a_vdp+1
a_vregpal	= a_vdp+2
a_vregi		= a_vdp+3

s_reg0_F    = 1<<7	; Frame Flag, interrupt flag
s_reg0_5S   = 1<<6
s_reg0_C    = 1<<5

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

v_reg9_ln 			= 1<<7  ; lines - 0 - 192 lines, 1 - 212 lines
v_reg9_il			= 1<<3	; interlace
v_reg9_nt			= 1<<1	; ntsc/pal

v_reg17_aii			= 1<<7	; auto increment

v_reg25_sp2 		= 1<<0
v_reg25_msk 		= 1<<1
v_reg25_wait 		= 1<<2
v_reg25_cmd 		= 1<<6


v_reg45_mxc = 1<<6
v_reg45_mxd = 1<<5
v_reg45_mxs = 1<<4
v_reg45_diy = 1<<3
v_reg45_dix = 1<<2
v_reg45_maj = 1<<0

v_reg0 	= $80
v_reg1 	= $81
v_reg2 	= $82
v_reg3 	= $83
v_reg4 	= $84
v_reg5 	= $80 + 	5
v_reg6 	= $80	+	6
v_reg7  = $80	+	7
; start of V9938/V9958 register set
v_reg8  = $80	+	8
v_reg9  = $80	+	9
v_reg11	= $80 + 11
v_reg14	= $80 + 14
v_reg15	= $80 + 15

v_reg17	= $80 + 17
v_reg18	= $80 + 18	; display adjust
v_reg23	= $80 + 23	; vertical offset

; V9958 specific
v_reg25 = $80 + 25
v_reg26 = $80 + 26  ; horizonatl scroll register, bit 5-0, scroll 8 dot units (character)
v_reg27 = $80 + 27  ; horizonatl scroll register bit 2-0, scroll dot units

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

SPRITE_Y=0
SPRITE_X=1
SPRITE_N=2
SPRITE_C=3

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

ADDRESS_GFX2_SCREEN		    =$1800			; name table
ADDRESS_GFX2_PATTERN		=$0000
ADDRESS_GFX2_COLOR			=$2000
ADDRESS_GFX2_SPRITE			=ADDRESS_GFX_SPRITE
ADDRESS_GFX2_SPRITE_PATTERN	=ADDRESS_GFX1_SPRITE_PATTERN

ADDRESS_GFX6_SCREEN			=ADDRESS_GFX1_SCREEN			; screen

ADDRESS_GFX7_SCREEN			=$10000							; 2nd 64 RAM
ADDRESS_GFX7_SPRITE			=ADDRESS_GFX_SPRITE
ADDRESS_GFX7_SPRITE_PATTERN =ADDRESS_GFX1_SPRITE_PATTERN

ADDRESS_GFX_MC_SCREEN			=ADDRESS_GFX2_SCREEN	; name table
ADDRESS_GFX_MC_PATTERN			=ADDRESS_GFX2_PATTERN	; pattern table
ADDRESS_GFX_MC_SPRITE			=ADDRESS_GFX2_SPRITE	; sprite attributes
ADDRESS_GFX_MC_SPRITE_PATTERN	=ADDRESS_GFX1_SPRITE_PATTERN	; sprite pattern

.define CLOCK_SPEED_MHZ 8

; long delay with 6+2 2µs wait
MAX_NOPS_8M = (6 * 1000 / (1000 / CLOCK_SPEED_MHZ)) / 2 ; eg. 8Mhz, means 125ns per cycle. so wait 6µs = 6000ns => 6000ns / 125ns = 48cl / 2 => 24 NOP
; short delay with 2µs wait
MAX_NOPS_2M = (2 * 1000 / (1000 / CLOCK_SPEED_MHZ) - 12) / 2 ; - 12 => jsr/rts = 2*6cl = 12cl must be subtract

.macro m_vdp_nopslide
; NOTE!!!
; - TMS9929 and V9938/V9958 wait 2µs between 2 byte writes and 8µs for the 3rd and n'th byte write and wait 8µs before 3rd byte and all n'th byte writes
vdp_nopslide_8m:
			; long delay with 6+2 2µs wait
			.repeat MAX_NOPS_8M
			nop
			.endrepeat
vdp_nopslide_2m:	
			.repeat MAX_NOPS_2M
			nop
			.endrepeat
			rts
.endmacro

.macro vnops
		vdp_wait_l
.endmacro

.macro vdp_wait_s _wasted_cycles
		.local _wasted_cycles
		.ifndef vdp_nopslide_2m
			.import vdp_nopslide_2m
		.endif
		.if(.paramcount > 0)
			.assert _wasted_cycles >= 0 && (_wasted_cycles / 2) <= MAX_NOPS_2M, error, .concat("parameter <wasted cycles> must be 0<= ", .string(_wasted_cycles/2), " <= ", .string(MAX_NOPS_2M))
			jsr vdp_nopslide_2m + (_wasted_cycles / 2) ; add number of wasted clycle, we calculate the jsr offset to remaining nops
		.else
			jsr vdp_nopslide_2m
		.endif
.endmacro

.macro vdp_wait_l _wasted_cycles	; amount of cycles already wasted in rang [-n..0]
		.local _wasted_cycles
		.ifndef vdp_nopslide_8m
			.import vdp_nopslide_8m
		.endif
		.if(.paramcount > 0)
			.assert _wasted_cycles >= 0 && (_wasted_cycles / 2) <= MAX_NOPS_8M, error, .concat("parameter <wasted cycles> must be 0<= ", .string(_wasted_cycles/2), " <= ")
			jsr vdp_nopslide_8m + (_wasted_cycles / 2) ; add number of wasted clycle, we calculate the jsr offset to remaining nops
		.else
			jsr vdp_nopslide_8m
		.endif
.endmacro

.macro vdp_sreg _1st, _2nd
		.local _1st
		.local _2nd
		.if(.paramcount <> 2)	;no macro args, use the A/Y parameter call
			vdp_wait_s
			sta a_vreg
			vdp_wait_s
			sty a_vreg
		.else							; otherwise use the new api call, with fewer nops for register writes
			vdp_wait_s 2
			lda #_1st
			sta a_vreg
			vdp_wait_s 2
			lda #_2nd
			sta a_vreg
			.endif
.endmacro

.macro vdp_reg reg, val
			vdp_wait_s 2
			lda #val
			sta a_vreg
			vdp_wait_s 2
			lda #$80 + reg
			sta a_vreg
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
