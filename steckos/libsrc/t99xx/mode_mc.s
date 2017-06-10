.include "vdp.inc"

.importzp ptr1
.importzp tmp1, tmp2
.import	vdp_init_reg
.import vdp_nopslide
.import vdp_fill

.export vdp_mc_on
.export vdp_mc_blank
.export vdp_mc_set_pixel
.export vdp_mc_init_screen


.code
;
;	gfx multi color mode - 4x4px blocks where each can have one of the 15 colors
;	
vdp_mc_on:
			jsr	vdp_mc_init_screen
			lda #<vdp_mc_init_bytes
			sta ptr1
			lda #>vdp_mc_init_bytes
			sta ptr1+1
			jmp vdp_init_reg

vdp_mc_init_bytes:
			.byte 	0		; 
			.byte 	v_reg1_16k|v_reg1_display_on|v_reg1_m2|v_reg1_spr_size; |v_reg1_int
			.byte 	(ADDRESS_GFX_MC_SCREEN / $400)		; name table - value * $400 -> 3 * 256 pattern names (3 pages)
			.byte	$ff									; color table not used in multicolor mode
			.byte	(ADDRESS_GFX_MC_PATTERN / $800) 	; pattern table, 1536 byte - 3 * 256 
			.byte	(ADDRESS_GFX_MC_SPRITE / $80)	; sprite attribute table - value * $80 --> offset in VRAM
			.byte	(ADDRESS_GFX_MC_SPRITE_PATTERN / $800)	; sprite pattern table - value * $800  --> offset in VRAM
			.byte	Black

;			
;
;
vdp_mc_init_screen:
			lda	#<ADDRESS_GFX_MC_SCREEN
			ldy	#WRITE_ADDRESS+ >ADDRESS_GFX_MC_SCREEN
			vdp_sreg
			stz tmp2
			lda #32
			sta tmp1
@l1:		ldy #0
@l2:		ldx	tmp2
@l3:		vnops
			stx a_vram
			inx
			cpx	tmp1
			bne	@l3
			iny
			cpy #4		; 4 rows filled ?
			bne	@l2
			cpx	#32*6	; 6 pages overall
			beq @le
			stx tmp2	; next 
			clc
			txa
			adc #32
			sta tmp1
			bra @l1
@le:		rts

;
; blank multi color mode, set all pixel to black
; 	A - color to blank
;
vdp_mc_blank:
			sta	tmp1
			lda	#<ADDRESS_GFX_MC_PATTERN
			ldy	#WRITE_ADDRESS+ >ADDRESS_GFX_MC_PATTERN
			ldx #1536/256
			jmp vdp_fill

;	set pixel to mc screen
;			
;	X - x coordinate [0..3f]
;	Y - y coordinate [0..2f]
;	A - color [0..f]
;
; 	VRAM ADDRESS = 8(INT(X DIV 2)) + 256(INT(Y DIV 8)) + (Y MOD 8)
vdp_mc_set_pixel:
	and #$0f
	sta tmp2	;safe color
	
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
l1:	lda tmp2
	asl						;2
	asl						;2
	asl						;2
	asl
	sta tmp2
	lda a_vram
	and #$0f				;2
l2:	
	ora tmp2				;3
	nop						;2
	nop						;2
	nop						;2
	ldx tmp1				;3
	stx	a_vreg				;4 setup write adress
	nop						;2
	nop						;2
	nop						;2
	sty a_vreg
	vnops
	sta a_vram
	
	rts