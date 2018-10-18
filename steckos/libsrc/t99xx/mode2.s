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

.import vdp_init_reg
.import vdp_fill

.export vdp_gfx2_on
.export vdp_gfx2_blank
.export vdp_gfx2_set_pixel

.code
;
;	gfx 2 - each pixel can be addressed - e.g. for image
;	
vdp_gfx2_on:
			jsr vdp_fill_name_table
			
			lda #<vdp_init_bytes_gfx2
			sta vdp_ptr
			lda #>vdp_init_bytes_gfx2
			sta vdp_ptr+1
			lda #(vdp_init_bytes_gfx2_end-vdp_init_bytes_gfx2)
			jmp vdp_init_reg
			

			jsr vdp_fill_name_table
			lda #<vdp_init_bytes_gfx2
			sta vdp_ptr
			lda #>vdp_init_bytes_gfx2
			sta vdp_tmp+1
			jmp vdp_init_reg

vdp_fill_name_table:
			;set 768 different patterns --> name table			
			vdp_sreg #<ADDRESS_GFX2_SCREEN, #WRITE_ADDRESS+ >ADDRESS_GFX2_SCREEN
			ldy #$03
			ldx #$00
@0:		vdp_wait_l			
			stx	a_vram  ;
			inx         ;2
			bne	@0       ;3
			dey
			bne	@0
			rts

vdp_init_bytes_gfx2:
			.byte 	v_reg0_m3		; 
			.byte 	v_reg1_16k|v_reg1_display_on|v_reg1_spr_size |v_reg1_int
			.byte 	(ADDRESS_GFX2_SCREEN / $400)	; name table - value * $400
			.byte	$ff				; color table setting for gfx mode 2 --> only Bit 7 is taken into account 0 => at vram $0000, 1 => at vram $2000, Bit 6-0 AND to character number
			.byte	$03 			; pattern table - either at vram $0000 (Bit 2 = 0) or at vram $2000 (Bit 2=1), Bit 0,1 are AND to select the pattern array
			.byte	(ADDRESS_GFX2_SPRITE / $80)	; sprite attribute table - value * $80 --> offset in VRAM
			.byte	(ADDRESS_GFX2_SPRITE_PATTERN / $800)	; sprite pattern table - value * $800  --> offset in VRAM
			.byte	Black
vdp_init_bytes_gfx2_end:
;
; blank gfx mode 2 with 
; 	.A - color to fill [0..f]
;    
vdp_gfx2_blank:		; 2 x 6K
	tax
	vdp_sreg #<ADDRESS_GFX2_COLOR, #WRITE_ADDRESS + >ADDRESS_GFX2_COLOR
	txa
	ldx #24		;6144 byte color map
	jsr vdp_fill
	
	vdp_sreg #<ADDRESS_GFX2_PATTERN, #WRITE_ADDRESS + >ADDRESS_GFX2_PATTERN
	ldx #24		;6144 byte pattern map
	lda #0
	jsr vdp_fill
	
	vdp_sreg #<ADDRESS_GFX2_SCREEN, #WRITE_ADDRESS + >ADDRESS_GFX2_SCREEN
	ldx #3		;768 byte screen map
	lda #0
	jmp vdp_fill
	
;	set pixel to gfx2 mode screen
;
;	X - x coordinate [0..ff]
;	Y - y coordinate [0..bf]
;	A - color [0..f]
;
; 	VRAM ADDRESS = 8(INT(X DIV 8)) + 256(INT(Y DIV 8)) + (Y MOD 8)
vdp_gfx2_set_pixel:
		beq vdp_gfx2_set_pixel_e	; 0 - not set, leave blank
		; calculate low byte vram adress	
		txa						;2
		and	#$f8
		sta	vdp_tmp
		tya
		and	#$07
		ora	vdp_tmp
		sta	a_vreg	;4 set vdp vram address low byte
		sta	vdp_tmp	;3 safe vram low byte
		
		; high byte vram address - div 8, result is vram address "page" $0000, $0100, ...
		tya						;2
		lsr						;2
		lsr						;2
		lsr						;2
		sta	a_vreg				;set vdp vram address high byte
		ora #WRITE_ADDRESS		;2 adjust for write
		tay						;2 safe vram high byte for write in y
	
		txa						;2 set the appropriate bit 
		and	#$07				;2
		tax						;2
		lda	bitmask,x			;4
		ora	a_vram				;4 read current byte in vram and OR with new pixel
		tax						;2 or value to x
		nop						;2
		nop						;2
		nop						;2
		lda	vdp_tmp			;2
		sta a_vreg
		tya						;2
		nop						;2
		nop						;2
		sta	a_vreg
		vnops
		stx a_vram	;set vdp vram address high byte
vdp_gfx2_set_pixel_e:
		rts
bitmask:
	.byte $80,$40,$20,$10,$08,$04,$02,$01