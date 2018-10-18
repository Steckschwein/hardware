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

.include "vdp.inc"

.export vdp_display_off
.export vdp_init_reg
.export vdp_bgcolor
.export vdp_fills, vdp_fill
.export vdp_mode_sprites_off
.export vdp_memcpys, vdp_memcpy
.export vdp_nopslide_8m
.export vdp_nopslide_2m

.code

m_vdp_nopslide

vdp_irq_off:
		vdp_sreg #v_reg1_16k|v_reg1_display_on|v_reg1_spr_size, #v_reg1	;switch interupt off
		rts

vdp_display_off:
;	jsr	.vdp_wait_blank
		lda #v_reg1_16k	;enable 16K? ram, disable screen
		sta a_vreg
		vnops
		lda #v_reg1
		sta a_vreg
		rts

vdp_mode_sprites_off:
		vdp_sreg #<ADDRESS_GFX_SPRITE, #WRITE_ADDRESS + >ADDRESS_GFX_SPRITE
		lda	#$d0					;sprites off, at least y=$d0 will disable the sprite subsystem
		ldx	#32*4					;32 sprites / 4 byte each
@0:	vnops          	;2
		dex             ;2
		sta   a_vram    ;4
		bne	@0           ;3
		rts
	
; setup video registers upon given table
;	in:
;		.A - length of init table
;		vdp_ptr - pointer set to vdp init table for al 8 vdp registers
vdp_init_reg:
			tay			; y offset into init table
			ora #$80		; bit 7 = 1 => register write
			tax
@l:		lda (vdp_ptr),y
			sta a_vreg
			vdp_wait_s
			stx a_vreg
			dex
			dey
			bpl @l
			rts
			
		ldy #$00
		ldx #v_reg0
@0:	lda (vdp_ptr),y
		sta a_vreg
		iny
		vnops
		stx a_vreg
		inx
		cpy	#$08
		bne @0
		rts

vdp_wait_blank:
			php
			sei
			SyncBlank
			pla
			and	#$04	;check interupt was set?
			bne	@0
			cli
@0:			rts

;
;   input:	a - color
;
vdp_bgcolor:
	sta   a_vreg
	lda   #v_reg7
	vdp_wait_s
	sta   a_vreg
	rts

vdp_fill:
;	input:
;		.A - byte to fill
;		.X - amount of 256byte blocks (page counter)
			ldy   #0      ;2
@0:		vnops          ;2
			iny             ;2
			sta   a_vram 
			bne   @0         ;3
			dex
			bne   @0
			rts
	
vdp_fills:
;	in:
;		.X - amount of bytes
;
@0:	vnops          	;2
		dex             ;2
		sta a_vram    ;4
		bne	@0           ;3
		rts
			
;	input:
;  	.X - amount of 256byte blocks (page counter)
;		vdp_ptr to source data
vdp_memcpy:
		ldy #0      ;2
@l1:	vdp_wait_l  ; TODO FIXME try vdp_wait_s here
		lda (vdp_ptr),y ;5
		iny             ;2
		sta a_vram    ;1 opcode fetch
		bne @l1         ;3
		inc vdp_ptr+1
		dex
		bne @l1
		rts
		
;	input:
;  	.X - amount of bytes to copy
vdp_memcpys:
		ldy   #0
@0:	vnops
		lda   (vdp_ptr),y ;5
		sta a_vram    ;4
		iny             ;2
		dex             ;2
		bne	@0
		rts
