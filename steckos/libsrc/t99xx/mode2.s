.include "vdp.inc"

.importzp ptr1
.importzp tmp1

.import	vdp_init_reg
.import vdp_nopslide
.import vdp_fill

.export vdp_mode_gfx2
.export vdp_mode_gfx2_blank
.export vdp_fill_name_table

.code
;
;	gfx 2 - each pixel can be addressed - e.g. for image
;	
vdp_mode_gfx2:
			lda #<vdp_init_bytes_gfx2
			sta ptr1
			lda #>vdp_init_bytes_gfx2
			sta ptr1+1
			jmp	vdp_init_reg

vdp_fill_name_table:
			;set 768 different patterns --> name table
			lda	#<ADDRESS_GFX2_SCREEN
			ldy	#WRITE_ADDRESS+ >ADDRESS_GFX2_SCREEN
			vdp_sreg
			ldy	#$03
			ldx	#$00
@0:			vnops
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

;
; blank gfx mode 2 with 
; adrl - color to fill
;    
vdp_mode_gfx2_blank:		; 2 x 6K
	sta tmp1
	lda #<ADDRESS_GFX2_COLOR
	ldy #WRITE_ADDRESS + >ADDRESS_GFX2_COLOR
	ldx	#24		;6144 byte color map
	jsr	vdp_fill
	stz tmp1	;
	lda #<ADDRESS_GFX2_PATTERN
	ldy #WRITE_ADDRESS + >ADDRESS_GFX2_PATTERN
	ldx	#24		;6144 byte pattern map
	jsr	vdp_fill
	lda #<ADDRESS_GFX2_SCREEN
	ldy #WRITE_ADDRESS + >ADDRESS_GFX2_SCREEN
	ldx	#3		;768 byte screen map
	jmp	vdp_fill