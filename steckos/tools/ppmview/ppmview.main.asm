; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschein.de
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

;
; use imagemagick $convert <image> -geometry 256 -colort 256 <image.ppm>
;
.setcpu "65c02"
.include "common.inc"
.include "vdp.inc"
.include "fcntl.inc"
.include "zeropage.inc"
.include "kernel_jumptable.inc"

.importzp ptr2, ptr3
;.importzp tmp, tmp4

.import hexout
.import vdp_gfx7_on
.import vdp_gfx7_blank
.import vdp_display_off
.import vdp_memcpy
.import vdp_mode_sprites_off
.import vdp_bgcolor

.import ppmdata
.import ppm_width
.import ppm_height

.export ppmview_main

; for TEST purpose
.export parse_header

.define MAX_WIDTH 256
.define MAX_HEIGHT 192

.code
ppmview_main:
		lda paramptr
		ldx paramptr+1
		ldy #O_RDONLY
		jsr krn_open
		bne @err

		stx fd

		SetVector ppmdata, read_blkptr
		ldy #01 ; 1 block first
		jsr krn_fread
		bne @err

		jsr parse_header
		bne @exit

		bra @exit

		jsr	krn_textui_disable			;disable textui
		jsr	gfxui_on
		keyin
		jsr	gfxui_off

		jsr	krn_display_off			;restore textui
		jsr	krn_textui_init
		jsr	krn_textui_enable
		bra @exit

@err:
		jsr krn_primm
		.asciiz " file error, code: "
		jsr hexout
@exit:
		ldx fd
		cmp #$ff
		beq @l_exit
		jsr krn_close
@l_exit:
		jmp (retvec)

PPM_P6:	.byte "P6"

parse_header:
		ldy #0
		jsr parse_string

		lda #'P'
		cmp buffer
		bne @l_not_ppm
		lda #'6'
		cmp buffer+1
		bne @l_not_ppm
		
		jsr parse_int	;width
		cmp #<MAX_WIDTH
		bne @l_not_ppm
		sta ppm_width
		jsr parse_int	;height
		cmp #MAX_HEIGHT
		bcs @l_not_ppm
		sta ppm_height
		jsr parse_int	;depth
		lda #0
		rts
@l_not_ppm:
;		jsr krn_primm
;		.asciiz " Not valid ppm file!"
		lda #$ff
		rts

parse_int:
		jsr parse_string
		stz tmp
		ldx #0
:
		lda buffer, x
		beq :+		
		pha		;n*10 => n*2 + n*8
		lda tmp
		asl
		sta tmp
		asl
		asl
		adc tmp
		sta tmp
		pla
		sec
		sbc #'0'
		clc
		adc tmp
		sta tmp
		inx
		bne :-	
:		lda tmp
		rts

parse_string:
		ldx #0
@l0:	lda ppmdata, y
		cmp #$20+1		; <= $20 - control characters are treat as whitespace
		bcc @le
		sta buffer, x
		inx
		iny
		bne @l0
@le:	iny
		stz buffer, x
		rts

blend_isr:
		bit a_vreg
		bpl @0
		save

		lda	#%11100000
		jsr vdp_bgcolor

		lda	#Black
		jsr vdp_bgcolor

		restore
@0:
		rti

gfxui_on:
    sei
	jsr vdp_display_off			;display off

	lda #v_reg8_SPD | v_reg8_VR	;
	ldy #v_reg8
	vdp_sreg
	vnops

	jsr vdp_gfx7_on			    ;enable gfx7 mode

	lda #<.HIWORD(ADDRESS_GFX7_SCREEN<<3)
	ldy #v_reg14
	vdp_sreg
	vnops
	lda #<.LOWORD(ADDRESS_GFX7_SCREEN)
	ldy #(WRITE_ADDRESS + >.LOWORD(ADDRESS_GFX7_SCREEN))
	vdp_sreg

    copypointer  $fffe, irqsafe
    SetVector  blend_isr, $fffe

	lda #%00000000	; reset vbank - TODO FIXME, kernel has to make sure that correct video adress is set for all vram operations, use V9958 flag
	ldy #v_reg14
	vdp_sreg

    cli
    rts

gfxui_off:
    sei

    copypointer  irqsafe, $fffe
    cli
    rts

m_vdp_nopslide

irqsafe: .res 2, 0
; TODO FIXME clarify BSS segment voodo
fd:		.res 1, $ff
buffer:	.res 8, 0
tmp: .res 0
