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

.importzp ptr1

.import vdp_gfx7_on
.import vdp_gfx7_blank
.import vdp_display_off
.import vdp_memcpy
.import vdp_mode_sprites_off
.import vdp_bgcolor
.import vdp_wait_cmd

appstart $1000

bg_color = %00000011
.code
main:
		jsr	krn_textui_disable			;disable textui
		jsr	gfxui_on

		keyin

		jsr	gfxui_off

		jsr krn_display_off			;restore textui
		jsr krn_textui_init
		jsr krn_textui_enable
		bit a_vreg ; acknowledge any vdp interrupts before re-enabling interrupts
		
		jmp (retvec)

draw_vertices:
	vdp_sreg 2, v_reg15
	ldy vertices_size	
@l:
	jsr vdp_gfx7_line
	dey
	bpl @l
	vdp_sreg 0, v_reg15
	rts

animate_vertices:
	ldx #59
@l_move:
	inc xl,x
	dex
	bpl @l_move
	rts
	
vdp_isr:
	save 
	
	vdp_sreg 0, 15	; status register index
	vdp_wait_s
   bit a_vreg
   bpl @0

	lda #%11100000
	jsr vdp_bgcolor
		
	lda #bg_color
	sta color
;	jsr draw_vertices

;	jsr animate_vertices	
	
	lda #$ff
	sta color
	jsr draw_vertices
		
;	inc yl,x
;	inc dxl,x
;	inc dyl,x
	
	lda #Black
	jsr vdp_bgcolor
@0:
	restore
	rti

vdp_gfx7_line:
	
	lda #%000111000
	jsr vdp_bgcolor
	
	vdp_sreg 36, v_reg17
	
	vdp_wait_s 4
	lda xl,y
	sta a_vregi
	vdp_wait_s 2
	lda #0
	sta a_vregi
	vdp_wait_s 4
	lda yl,y
	sta a_vregi
	vdp_wait_s 2
	lda #$01
	sta a_vregi
	vdp_wait_s 4
	lda dxl,y
	sta a_vregi
	vdp_wait_s 2
	lda #0
	sta a_vregi
	vdp_wait_s 4
	lda dyl,y
	sta a_vregi
	vdp_wait_s 2
	lda #0
	sta a_vregi

	vdp_wait_s 4		;color
	lda color
	sta a_vregi

	vdp_wait_s 4
	lda mode,y
	sta a_vregi

	vdp_wait_s 2
	lda #v_cmd_line
	sta a_vregi

	lda #%11111100
	jsr vdp_bgcolor
@wait:
;	vdp_wait_l 4
	lda a_vreg
	ror
	bcs @wait
	rts
		

gfxui_on:
	sei
	jsr vdp_display_off			;display off
	jsr vdp_mode_sprites_off	;sprites off

	jsr vdp_gfx7_on			    ;enable gfx7 mode

	lda #%00000011
	jsr vdp_gfx7_blank

	copypointer  $fffe, irqsafe
	SetVector  vdp_isr, $fffe

	cli
	rts

gfxui_off:
    sei

    copypointer  irqsafe, $fffe

    cli
    rts

color: .res 1,$ff
irqsafe: .res 2, 0
.data
.include "lines_data.inc"

vertices_end:
 .segment "STARTUP"