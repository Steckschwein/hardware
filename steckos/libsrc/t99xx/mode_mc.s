.include "vdp.inc"

.importzp ptr1
.importzp tmp0, tmp1

.import	vdp_init_reg
.import vdp_nopslide
.import vdp_fill

.export vdp_mode_mc
.export vdp_mode_mc_blank
.export vdp_set_pixel_mc

.code
;
;	gfx multi color mode - 4x4px blocks where each can have one of the 15 colors
;	
vdp_mode_mc:
			lda #<vdp_init_bytes_mc
			sta ptr1
			lda #>vdp_init_bytes_mc
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

vdp_init_bytes_mc:
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
vdp_mode_mc_blank:		; 2 x 6K
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
	
vdp_set_pixel_mc:
	and #$0f
	sta tmp0	;safe color
	
; 	0 1 2 3 4 5 6 7 8 91011
;   0 0 8 81616242432324040
	txa			
	and #$3e	; x div 2 * 8 => and, asl, asl
	asl
	asl
	sta tmp1
	
	tya
	and	#$07	; y mod 8
	ora	tmp1
	sta	a_vreg				;4 set vdp vram address low byte
	sta	tmp1				;3 safe vram address low byte
	
	; high byte vram address - div 8, result is vram address "page" $0000, $0100, ... until $05ff
	tya						;2
	lsr						;2
	lsr						;2
	lsr						;2
	sta	a_vreg				;set vdp vram address high byte
	ora #WRITE_ADDRESS		;2 adjust for write
	tay	;adrh				;2 safe vram high byte for write

    txa						;2
	bit #1					;3 test color shift required, upper nibble?
	beq l1					;2/3
	nop						;2
	lda #$f0				;2
	and a_vram				;4
	bra l2					;3
l1:	lda tmp0
	asl						;2
	asl						;2
	asl						;2
	asl
	sta tmp0
	lda a_vram
	and #$0f
l2:	
	ora tmp0				;3
	nop
	nop
	nop
	ldx tmp1				;3
	stx	a_vreg				;4 setup write adress
	nop						;2
	nop						;2
	nop						;2
	sty a_vreg
	vnops
	sta a_vram
	
	rts