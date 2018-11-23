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
		vdp_sreg v_reg1_16k|v_reg1_display_on|v_reg1_spr_size, v_reg1	;switch interupt off
		rts

vdp_display_off:
		lda #v_reg1_16k	;enable 16K? ram, disable screen
		sta a_vreg
		vdp_wait_s 2
		lda #v_reg1
		sta a_vreg
		rts

vdp_mode_sprites_off:
		vdp_sreg <ADDRESS_GFX_SPRITE, WRITE_ADDRESS + >ADDRESS_GFX_SPRITE
		lda	#$d0					;sprites off, at least y=$d0 will disable the sprite subsystem
		ldx	#32*4					;32 sprites / 4 byte each
@0:	vdp_wait_l 6
		dex             ;2
		sta   a_vram    ;4
		bne	@0        ;3
		rts
	
; setup video registers upon given table
;	in:
;		.A - length of init table
;		vdp_ptr - pointer set to vdp init table for al 8 vdp registers
vdp_init_reg:
			tay			; y offset into init table
			ora #$80		; bit 7 = 1 => register write
			tax
@l:		vdp_wait_s 4
			lda (vdp_ptr),y ; 5c
			sta a_vreg
			vdp_wait_s
			stx a_vreg
			dex				;2c
			dey				;2c
			bpl @l 			;3c
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
	vdp_wait_s 2
	sta   a_vreg
	rts

vdp_fill:
;	input:
;		.A - byte to fill
;		.X - amount of 256byte blocks (page counter)
        ldy   #0    
@0:     vdp_wait_l 6
        iny             ;2
        sta a_vram 	 ;
        bne @0        ;3
        dex
        bne @0
        rts
	
vdp_fills:
;	in:
;		.X - amount of bytes
;
@0:	vdp_wait_l 6  	;3 + 2 + 1 opcode fetch
		dex            ;2
		sta a_vram     ;4
		bne	@0       ;3
		rts
			
;	input:
;  	.X - amount of 256byte blocks (page counter)
;		vdp_ptr to source data
vdp_memcpy:
		ldy #0      	 
@l1:	vdp_wait_l 11 	 ;3 + 5 + 2 + 1 opcode fetch
		lda (vdp_ptr),y ;5
		iny             ;2
		sta a_vram    	 ;1
		bne @l1         ;3
		inc vdp_ptr+1
		dex
		bne @l1
		rts
		
;	input:
;  	.X - amount of bytes to copy
vdp_memcpys:
		ldy   #0
@0:	vdp_wait_l 13	 ;2 + 2 + 3 + 5 + 1 opcode fetch
		lda (vdp_ptr),y ;5
		sta a_vram    	 ;1+3
		iny             ;2
		dex             ;2
		bne	@0			 ;3
		rts
