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

.importzp ptr1, ptr2, ptr3
.importzp tmp3, tmp4

.import vdp_gfx7_on
.import vdp_gfx7_blank
.import vdp_gfx7_set_pixel
.import vdp_gfx7_set_pixel_cmd

.import vdp_display_off
.import vdp_memcpy
.import vdp_mode_sprites_off
.import vdp_bgcolor


appstart $1000

.code
main:
		jsr	krn_textui_disable			;disable textui

		jsr gfxui_on

		keyin
		jsr fill_setpixel
		keyin
		lda #0
		jsr vdp_gfx7_blank
		keyin
		jsr fill_setpixel_cmd
		
		
		keyin

		jsr	gfxui_off

		jsr	krn_display_off			;restore textui
		jsr	krn_textui_init
		jsr	krn_textui_enable

		jmp (retvec)

blend_isr:
		save
		
		vdp_sreg 0, v_reg15
		vdp_wait_s
		bit a_vreg
		bpl @0
	
		lda #%01001011
		jsr vdp_bgcolor
	
		lda	#Black
		jsr vdp_bgcolor

@0:
		restore
		rti

fill_setpixel:
		ldx #0
		ldy #212
@sp:	
		vdp_wait_l 8
		txa
		jsr vdp_gfx7_set_pixel
		inx
		bne @sp
		dey
		bne @sp
		rts		

fill_setpixel_cmd:
		ldx #0
		ldy #212
@sp:	
		vdp_wait_l 8
		txa
		jsr vdp_gfx7_set_pixel_cmd
		inx
		bne @sp
		dey
		bne @sp
		rts		
		
gfxui_on:
		sei
		jsr vdp_display_off			;display off
		jsr vdp_mode_sprites_off	;sprites off

		jsr vdp_gfx7_on			    ;enable gfx7 mode

		lda 	#0
		jsr 	vdp_gfx7_blank
		
		copypointer  $fffe, irqsafe
		SetVector  blend_isr, $fffe

		cli
		rts

gfxui_off:
	sei
	copypointer  irqsafe, $fffe

	lda 	#0
	jsr 	vdp_gfx7_blank
	 
	cli
	rts

irqsafe: .res 2, 0

.data
.segment "STARTUP"