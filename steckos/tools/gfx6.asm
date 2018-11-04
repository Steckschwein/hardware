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
.include "vdp.inc"
.include "fcntl.inc"
.include "zeropage.inc"
.include "kernel_jumptable.inc"
.include "appstart.inc"


.importzp ptr2, ptr3
.importzp tmp3, tmp4

.import vdp_gfx6_on
.import vdp_gfx6_blank
.import vdp_display_off
.import vdp_memcpy
.import vdp_mode_sprites_off
.import vdp_bgcolor

appstart $1000

main:
		jsr	krn_textui_disable			;disable textui

		jsr	gfxui_on

		keyin
		jsr	gfxui_off

		jsr	krn_display_off			;restore textui
		jsr	krn_textui_init
		jsr	krn_textui_enable
		cli

		jmp (retvec)

row=$100
blend_isr:
    bit a_vreg
    bpl @0
    save
    lda	#Black
	jsr vdp_bgcolor
	restore
@0:
		rti

gfxui_on:
   sei
	jsr vdp_display_off			;display off
	jsr vdp_mode_sprites_off	;sprites off

	lda #%00000011
	ldy #v_reg11
	vdp_sreg

	lda #%00000000
	ldy #v_reg14
	vdp_sreg
	vnops
	lda #<ADDRESS_GFX6_SCREEN
	ldy #(WRITE_ADDRESS + >ADDRESS_GFX6_SCREEN)
	vdp_sreg

    lda #%00011100
;    lda #%00000011
;   lda #%11100000
    lda #%11100011
;    jsr vdp_gfx6_blank

	ldy #192
	ldx #0
@l0:
	stx a_vram
	vnops
	dex
	bne @l0
	dey
	bne @l0

    copypointer  $fffe, irqsafe
    SetVector  blend_isr, $fffe

	 jsr vdp_gfx6_on			    ;enable gfx6 mode
    cli
    rts

gfxui_off:
    sei
    copypointer  irqsafe, $fffe
    cli
    rts

m_vdp_nopslide

irqsafe: .res 2, 0
