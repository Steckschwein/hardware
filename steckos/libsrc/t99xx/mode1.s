.include "vdp.inc"

.importzp ptr1

.import	vdp_init_reg
.import vdp_nopslide
.import vdp_fills, vdp_fill

.code
.scope

vdp_mode_gfx1_blank:		; 3 x 256 bytes
	ldx	#$03
	lda	#' '					;fill vram screen with blank
	pha
	lda	#<ADDRESS_GFX1_SCREEN
	ldy	#WRITE_ADDRESS + >ADDRESS_GFX1_SCREEN
	jmp	vdp_fill

vdp_init_bytes_gfx1:
	.byte 	0
	.byte	v_reg1_16k|v_reg1_display_on|v_reg1_spr_size|v_reg1_int
	.byte 	(ADDRESS_GFX1_SCREEN / $400)	; name table - value * $400					--> characters 
	.byte 	(ADDRESS_GFX1_COLOR /  $40)	; color table - value * $40 (gfx1), 7f/ff (gfx2)
	.byte 	(ADDRESS_GFX1_PATTERN / $800) ; pattern table (charset) - value * $800  	--> offset in VRAM 
	.byte	(ADDRESS_GFX1_SPRITE / $80)	; sprite attribute table - value * $80 		--> offset in VRAM
	.byte 	(ADDRESS_GFX1_SPRITE_PATTERN / $800)  ; sprite pattern table - value * $800  		--> offset in VRAM
	.byte	Black

;
;	gfx mode 1 - 32x24 character mode, 16 colors with same color for 8 characters in a block
;
vdp_mode_gfx1:
	pha			;color value to stack
	ldx	#$20
	lda	#<ADDRESS_GFX1_COLOR
	ldy	#WRITE_ADDRESS + >ADDRESS_GFX1_COLOR	;color vram
	jsr	vdp_fills
	lda	#<vdp_init_bytes_gfx1
	sta ptr1
	lda	#>vdp_init_bytes_gfx1
	sta ptr1+1
	jmp	vdp_init_reg

.endscope