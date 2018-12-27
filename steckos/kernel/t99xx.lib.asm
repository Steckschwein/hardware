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

.include "common.inc"
.include "kernel.inc"
.include "vdp.inc"

.export vdp_bgcolor, vdp_memcpy, vdp_mode_text, vdp_display_off

.segment "KERNEL"

.ifdef COLS80
	.ifndef V9958
		.assert 0, error, "80 COLUMNS ARE SUPPORTED ON V9958 ONLY! MAKE SURE -DV9958 IS ENABLED"
	.endif
.endif

m_vdp_nopslide

vdp_display_off:
		vdp_sreg v_reg1, v_reg1_16k
		rts

;	input:
;	adrl/adrh vector set
;	a - low byte vram adress
;	y - high byte vram adress
;  	x - amount of 256byte blocks (page counter)
vdp_memcpy:
		vdp_sreg
		ldy #$00     ;2
@l1:	vdp_wait_l	10
        lda (addr),y ;5
		iny          ;2
		sta a_vram    ;1 opcode fetch
		bne @l1      ;3
		inc adrh
		dex
		bne @l1
		rts

;
;	text mode - 40x24/80x24 character mode, 2 colors
;
vdp_mode_text:
.ifdef V9958
	vdp_sreg <.HIWORD(ADDRESS_GFX1_SCREEN<<2), v_reg14
	; enable V9958 /WAIT pin
	vdp_sreg v_reg25_wait, v_reg25
.endif
	ldy	#0
	ldx	#v_reg0
@l1:
	lda vdp_init_bytes_text,y
	vdp_wait_s 4
	sta a_vreg
	iny
	vdp_wait_s 2
	stx a_vreg
	inx
	cpy #$08
	bne @l1
	rts

vdp_init_bytes_text:
.ifdef COLS80
	.byte v_reg0_m4	; text mode 2
	.byte v_reg1_16k|v_reg1_display_on|v_reg1_int|v_reg1_m1
	.byte (ADDRESS_GFX1_SCREEN / $1000)| 1<<1 | 1<<0	; name table - value * $1000 (v9958) --> charset
.else
	.byte	0
	.byte v_reg1_16k|v_reg1_display_on|v_reg1_int|v_reg1_m1
	.byte (ADDRESS_GFX1_SCREEN / $1000) 	; name table - value * $400					--> charset
.endif
	.byte 0	; not used
	.byte (ADDRESS_GFX1_PATTERN / $800) ; pattern table (charset) - value * $800  	--> offset in VRAM
	.byte	0	; not used
	.byte 0	; not used
	.byte	Medium_Green<<4|Black

;
;   input:	a - color
;
vdp_bgcolor:
	sta a_vreg
	lda #v_reg7
	vdp_wait_s 2
	sta a_vreg
	rts
