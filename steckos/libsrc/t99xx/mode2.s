.include "vdp.inc"

; TODO FIXME conflicts with ehbasic zeropage locaitons - use steckschwein specific zeropage.s not the cc65....runtime/zeropage.s definition
;.importzp ptr1
;.importzp tmp1

.import	vdp_init_reg
.import vdp_nopslide
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
; 	A - color to fill [0..f]
;    
vdp_gfx2_blank:		; 2 x 6K
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
	
;	set pixel to gfx2 mode screen
;
;	X - x coordinate [0..ff]
;	Y - y coordinate [0..bf]
;	A - color [0..f]
;
; 	VRAM ADDRESS = 8(INT(X DIV 8)) + 256(INT(Y DIV 8)) + (Y MOD 8)
vdp_gfx2_set_pixel:
		beq vdp_gfx2_set_pixel_e	; 0 - not set, leave blank
;		sta tmp1					; otherwise go on and set pixel
		; calculate low byte vram adress	
		txa
		and	#$f8
		sta	tmp2
		tya
		and	#$07
		ora	tmp2
		sta	a_vreg	;4 set vdp vram address low byte
		sta	tmp2	;3 safe vram low byte
		
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
;		and tmp1				;3
		ora	a_vram				;4 read current byte in vram and OR with new pixel
		tax						;2 or value to x
		nop						;2
		nop						;2
		nop						;2
		lda	tmp2				;2
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
