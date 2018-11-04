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
.importzp tmp1, tmp3, tmp4

.import vdp_gfx2_on
.import vdp_gfx2_blank
.import vdp_display_off
.import vdp_memcpy
.import vdp_mode_sprites_off
.import vdp_bgcolor


appstart $1000

content = $2000
color=content+$1800

main:
		lda paramptr
		ldx paramptr+1
		ldy #O_RDONLY
		jsr krn_open
		bne @err

		stx tmp1						; save fd
		SetVector content, read_blkptr
		jsr krn_read
		ldx tmp1
		jsr krn_close
		bne @err

		jsr	krn_textui_disable			;disable textui
		SetVector content, addr
		jsr	gfxui_on

		keyin

		jsr	gfxui_off

		jsr	krn_display_off			;restore textui
		jsr	krn_textui_init
		jsr	krn_textui_enable
		cli
		bra l2

@err:
		jsr krn_primm
		.asciiz "load error file "
		lda #<paramptr
		ldx #>paramptr
		jsr krn_strout

l2:		jmp (retvec)

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

   lda #Black<<4|Black
   jsr vdp_gfx2_blank

   SetVector  content, ptr1
	lda	#<ADDRESS_GFX2_PATTERN
	ldy	#WRITE_ADDRESS + >ADDRESS_GFX2_PATTERN
	vdp_sreg
	ldx	#$18	;6k bitmap - $1800
	jsr	vdp_memcpy					;load the pic data

   SetVector  color, ptr1
	lda	#<ADDRESS_GFX2_COLOR
	ldy	#WRITE_ADDRESS + >ADDRESS_GFX2_COLOR
	ldx	#$18	;6k bitmap - $1800
	jsr	vdp_memcpy					;load the pic data

   copypointer  $fffe, irqsafe
	SetVector  blend_isr, $fffe

	jsr vdp_gfx2_on			    ;enable gfx2 mode

	cli
   rts

gfxui_off:
    sei
    copypointer  irqsafe, $fffe
    cli
    rts

irqsafe: .res 2, 0