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




.import vdp_gfx7_on
.import vdp_gfx7_blank
.import vdp_gfx7_set_pixel
.import vdp_display_off
.import vdp_memcpy
.import vdp_mode_sprites_off
.import vdp_bgcolor

appstart $1000


pt_x = $10
pt_y = $12
ht_x = $14
ht_y = $16

.code
main:
		lda #0
		sta pt_x
		stz pt_x+1

		; lda #100
		sta pt_y
		lda #$01
		sta pt_y+1

		lda #255
		sta ht_x
		lda #0
		sta ht_x+1

		lda #212
		sta ht_y
		lda #0
		sta ht_y+1

		ldx #21

		jsr	krn_textui_disable			;disable textui
		jsr	gfxui_on

		keyin

		jsr	gfxui_off

		jsr	krn_display_off			;restore textui
		jsr	krn_textui_init
		jsr	krn_textui_enable
		bit a_vreg ; acknowledge any vdp interrupts before re-enabling interrupts

		cli

		jmp (retvec)

blend_isr:
	pha	
	vdp_reg 15,0
	vnops
    bit a_vreg
    bpl @0

	lda	#%11100000
	jsr vdp_bgcolor

	lda	#Black
	jsr vdp_bgcolor


@0:
	pla
	rti


gfxui_on:
	sei
	jsr vdp_display_off			;display off
	jsr vdp_mode_sprites_off	;sprites off

	jsr vdp_gfx7_on			    ;enable gfx7 mode

	lda #%00000011
	jsr vdp_gfx7_blank

@loop:
	lda #$ff
	jsr vdp_gfx7_line


	dec ht_y
	dec ht_y
	dec ht_y
	dec ht_y
	dec ht_y
	dec ht_y
	dec ht_y
	dec ht_y
	dec ht_y
	dec ht_y
	dec ht_y
	dec ht_y

	dex
	bne @loop
	copypointer  $fffe, irqsafe
	SetVector  blend_isr, $fffe

	cli
	rts

gfxui_off:
    sei

    copypointer  irqsafe, $fffe

    cli
    rts

vdp_gfx7_line:
	phx
	pha

	vdp_reg 17,36

	ldx #0
@loop:
	vnops
	lda pt_x,x
	sta a_vregi
	inx
	cpx #8
	bne @loop

	vnops
	pla
	sta a_vregi

	vnops
	lda #0
	sta a_vregi

	vnops
	lda #v_cmd_line
	sta a_vregi

	vnops

	vdp_reg 15,2
@wait:
	vnops
	lda a_vreg
	ror
	bcs @wait

	plx
	rts

irqsafe: .res 2, 0
 .segment "STARTUP"
