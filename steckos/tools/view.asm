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
.importzp tmp1, tmp2, tmp3, tmp4

.import vdp_gfx2_on
.import vdp_gfx2_blank
.import vdp_display_off
.import vdp_memcpy
.import vdp_mode_sprites_off
.import vdp_bgcolor

appstart $1000

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

		jsr krn_textui_disable			;disable textui
		SetVector content, addr
		jsr gfxui_on
		jsr gfxui_blend_on

		keyin

		jsr	gfxui_blend_off
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

l2:		
		jmp (retvec)

row=$100
gfxui_blend_off:
	lda #Transparent<<4|Transparent
	bra l3
gfxui_blend_on:
	lda #$ff	  ; filter mask
l3:
	sta tmp2
	SetVector  ((WRITE_ADDRESS<<8)+ADDRESS_GFX2_COLOR+0),         ptr1
	SetVector  ((WRITE_ADDRESS<<8)+ADDRESS_GFX2_COLOR+row+$f8),   ptr2; +1 row and $f8 end of line

	stz tmp0
	lda #8
	sta tmp1
	lda #$f8
	sta tmp3
	stz tmp4
	stz tmp5

@l:
	bit tmp5    ;sync with isr
	bpl @l
	
	stz tmp5

	ldx	#12
@l2:	lda ptr1
	ldy ptr1+1
	vdp_sreg
 	ldy tmp0
@c:
	lda color,y
	and tmp2
	vdp_wait_l 10
	
	sta a_vram
	iny
	cpy tmp1
	bne @c
	inc @c+2
	inc @c+2
	inc ptr1+1
	inc ptr1+1
	dex
	bne @l2

	sty tmp0    ;new offset
	sty ptr1
	tya
	clc
	adc #08
	sta tmp1

	lda #((WRITE_ADDRESS)+>ADDRESS_GFX2_COLOR)
	sta ptr1+1
	lda #>color
	sta @c+2

	ldx	#12
@l3:
	lda ptr2
	ldy ptr2+1
	vdp_sreg
	ldy tmp3
@c2:
	lda color+row,y
	and tmp2
	vdp_wait_l 10
	
	sta a_vram
	iny
	cpy tmp4
	bne @c2
	inc @c2+2
	inc @c2+2
	inc ptr2+1
	inc ptr2+1
	dex
	bne  @l3

	lda tmp3
	sta tmp4
	sec
	sbc #08
	sta tmp3
	sta ptr2

	lda #(WRITE_ADDRESS)+>(ADDRESS_GFX2_COLOR+row+$f8)
	sta ptr2+1
	lda #>(color+row)
	sta @c2+2
	lda tmp0
	beq @l4
	jmp @l
@l4:
	rts

blend_isr:
	bit a_vreg
	bpl @0
	
   save
	lda #$80
	sta tmp5
	restore

@0:   
	rti

gfxui_on:
	sei
	jsr vdp_display_off			;display off

	vdp_sreg	%00000000, v_reg14	; reset vbank - TODO FIXME, kernel has to make sure that correct video adress is set for all vram operations, use V9958 flag		
	vdp_sreg <.HIWORD(ADDRESS_GFX2_SCREEN<<2), v_reg14
	
	jsr vdp_mode_sprites_off	;sprites off

	lda #Black<<4|Black
	jsr vdp_gfx2_blank
	 
	vdp_sreg	<ADDRESS_GFX2_PATTERN, WRITE_ADDRESS + >ADDRESS_GFX2_PATTERN
	SetVector  content, vdp_ptr    ; only load the pattern data, leave colors black to blend them later
	ldx #$18	;6k bitmap - $1800
	jsr vdp_memcpy					;load the pic data

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

tmp0:	.res 1
tmp5:	.res 1

.data
content: ; 6K raw data
			.res $1800, 0
color:	; 6K raw color data

.segment "STARTUP"