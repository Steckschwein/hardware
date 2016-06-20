.include "kernel.inc"
.include "vdp.inc"
.export vdp_bgcolor, vdp_memcpy, vdp_mode_text, vdp_display_off

; ROWS=23
;
;	TODO	
;		improve some functions,  avoid nop for vdp write delay 2µs by opcode reordering
;		investigate the difference between wdc and rockwell if no nop is used
;
vdp_irq_off:
		lda #v_reg1_16k|v_reg1_display_on|v_reg1_spr_size	;switch interupt off
		ldy	#v_reg1
; vdp_sreg:
		vdp_sreg
		rts

vdp_display_off:
;	jsr	.vdp_wait_blank
		lda		#v_reg1_16k	;enable 16K ram, disable screen
		sta 	a_vreg
		vnops
		lda	  	#v_reg1
		sta   	a_vreg
		rts

;	input:
;	a - low byte vram adress
;	y - high byte vram adress
;  	x - amount of bytes to fill with pattern
;	adrl - pattern
vdp_fills:
		vdp_sreg
		lda   adrl     ;3
@l1:  	vnops          ;2
		dex             ;2
		sta   a_vram    ;4
		bne	@l1           ;3
		rts
	
; fill vram with pattern
;
vdp_fill:
;	a - low byte vram adress
;	y - high byte vram adress
;	x - amount of 256byte blocks (page counter)
;	adrl - pattern
		vdp_sreg
		ldy   #$00      ;2
		lda   adrl     ;3
@l1:  	vnops          ;2
		iny             ;2
		sta   a_vram    ;
		bne   @l1         ;3
		dex
		bne   @l1
		rts

;	input:
;	adrl/adrh vector set
;	a - low byte vram adress
;	y - high byte vram adress
;  	x - amount of 256byte blocks (page counter)
vdp_memcpy:
		vdp_sreg
		ldy   #$00      ;2
@l1:	lda   (addr),y ;5
		iny             ;2
		vnops
		sta   a_vram    ;1 opcode fetch
		
		bne   @l1         ;3
		inc   adrh
		dex
		bne   @l1
		rts
	
;	input:
;	adrl/adrh vector set
;	a - low byte vram adress
;	y - high byte vram adress
;  	x - amount of bytes to copy
vdp_memcpys:
		vdp_sreg
		ldy   #$00
@l1:  	lda   (adrl),y ;5
		iny             ;2
		dex             ;2
		vnops
		sta   a_vram    ;4
		bne	@l1
		rts

vdp_mode_text_blank:
		ldx	#$04				; 4 x 256 bytes
		bra	lgfx1
vdp_mode_gfx1_blank:		; 3 x 256 bytes
		ldx	#$03
lgfx1:	lda	#' '					;fill vram screen with blank
		sta	adrl
		lda	#<ADDRESS_GFX1_SCREEN
		ldy	#WRITE_ADDRESS + >ADDRESS_GFX1_SCREEN
		bra	vdp_fill


;
; blank gfx mode 2 with 
; adrl - color to fill
;    
vdp_mode_gfx2_blank:		; 2 x 6K
	sta adrl
	lda #<ADDRESS_GFX2_COLOR
	ldy #WRITE_ADDRESS + >ADDRESS_GFX2_COLOR
	ldx	#$18
	jsr	vdp_fill
	stz adrl
	lda #<ADDRESS_GFX2_PATTERN
	ldy #WRITE_ADDRESS + >ADDRESS_GFX2_PATTERN
	ldx	#$18
	jmp	vdp_fill


vdp_mode_gfx1_sprites_off:
vdp_mode_sprites_off:
	lda	#$d0					;sprites off, at least y=$d0 will disable the sprite subsystem
	sta	adrl
	ldx	#32*4
	lda	#<ADDRESS_GFX_SPRITE
	ldy	#WRITE_ADDRESS + >ADDRESS_GFX_SPRITE
	jmp	vdp_fills


;
;	gfx mode 1 - 32x24 character mode, 16 colors with same color for 8 characters in a block
;
vdp_mode_gfx1:
	sta	adrl		;set character color
	ldx	#$20
	lda	#<ADDRESS_GFX1_COLOR
	ldy	#WRITE_ADDRESS + >ADDRESS_GFX1_COLOR	;color vram
	jsr	vdp_fills
	SetVector vdp_init_bytes_gfx1, adrl
    ;go on below
	
; setup video registers upon given table
;	input:
;	adrl/adrh vector set to vdp init table for al 8 vdp registers
vdp_init_reg:
	ldy	#$00
	ldx	#v_reg0
@l1:
	lda (adrl),y
	sta a_vreg
	iny				;iny first, burn cycle to avoid vdp nop
	vnops
	stx a_vreg
	inx
	cpy	#$08
	bne @l1
	rts

;	
;
;
;	gfx 2 - each pixel can be addressed - e.g. for image
;	
vdp_mode_gfx2:
	jsr	vdp_fill_name_table
	SetVector	vdp_init_bytes_gfx2, adrl
	bra	vdp_init_reg

;
;	gfx 3 - 4x4 color block - multicolor mode
;	
vdp_mode_gfx3:
	jsr	vdp_fill_name_table
	SetVector	vdp_init_bytes_gfx3, adrl
	bra	vdp_init_reg

;
;	text mode - 40x24 character mode, 16 colors with same color for 8 characters in a block
;
vdp_mode_text:
	SetVector vdp_init_bytes_text, adrl
	bra	vdp_init_reg

vdp_wait_blank:
		php
		sei
		SyncBlank
		pla
		and	#$04	;check interupt was set?
		bne	@l1
		cli
@l1:	rts


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
;	requires	gfx2_mode_bitmap_address and gfx2_mode_ptr_bitmap_color_address setup correctly with the adresses to image and color data
;
gfx2_mode_ptr_bitmap_address: 		.word ADDRESS_GFX2_PATTERN	;default data adress $1000
gfx2_mode_ptr_bitmap_color_address:	.word ADDRESS_GFX2_COLOR	;default data adress $2800
vdp_mode_gfx2_load_bitmap:
	lda	gfx2_mode_ptr_bitmap_address
	sta	adrl
	lda	gfx2_mode_ptr_bitmap_address+1
	sta	adrh
	lda	#<ADDRESS_GFX2_PATTERN
	ldy	#WRITE_ADDRESS + >ADDRESS_GFX2_PATTERN
	ldx	#$18	;6k bitmap - $1800
	jsr	vdp_memcpy					;load the pic data --> pattern table at vram $0000
	; load color
	lda	gfx2_mode_ptr_bitmap_color_address
	sta	adrl
	lda	gfx2_mode_ptr_bitmap_color_address+1
	sta	adrh
	lda	#<ADDRESS_GFX2_COLOR
	ldy	#WRITE_ADDRESS+ >ADDRESS_GFX2_COLOR
	ldx	#$18	;6k color map - $1800
	jmp	vdp_memcpy					;load the pic data --> color table at vram $2000

gfx3_mode_bitmap_address:			.word	$1800
vdp_mode_gfx3_load_bitmap:
		lda	gfx3_mode_bitmap_address
		sta	adrl
		lda	gfx3_mode_bitmap_address+1
		sta	adrh
		lda	#$00
		ldy	#WRITE_ADDRESS+$00
		ldx	#$03	;768 byte
		jsr	vdp_memcpy					;load the pic data --> pattern table at vram $0000
		rts
	
vdp_fill_name_table:
		;set 768 different patterns --> name table
		lda	#<ADDRESS_GFX2_SCREEN
		ldy	#WRITE_ADDRESS+ >ADDRESS_GFX2_SCREEN
		vdp_sreg
		ldy	#$03
		ldx	#$00
@l1:	vnops
		stx	a_vram  ;
		inx         ;2
		bne	@l1     ;3
		dey
		bne	@l1
		rts
	
vdp_init_bytes_text:
	.byte 0
	.byte v_reg1_16k|v_reg1_display_on|v_reg1_int|v_reg1_m1
	.byte 	(ADDRESS_GFX1_SCREEN / $400)	; name table - value * $400					--> characters 
	.byte 	0	; not used
	.byte 	(ADDRESS_GFX1_PATTERN / $800) ; pattern table (charset) - value * $800  	--> offset in VRAM 
	.byte	0	; not used
	.byte 	0	; not used
	.byte	Medium_Green<<4|Black

vdp_init_bytes_gfx2:
	.byte 	v_reg0_m3		; 
	.byte 	v_reg1_16k|v_reg1_display_on|v_reg1_spr_size |v_reg1_int
	.byte 	(ADDRESS_GFX2_SCREEN / $400)	; name table - value * $400
	.byte	$ff				; color table setting for gfx mode 2 --> only Bit 7 is taken into account 0 => at vram $0000, 1 => at vram $2000, Bit 6-0 AND to character number
	.byte	$03 			; pattern table - either at vram $0000 (Bit 2 = 0) or at vram $2000 (Bit 2=1), Bit 0,1 are AND to select the pattern array
	.byte	(ADDRESS_GFX2_SPRITE / $80)	; sprite attribute table - value * $80 --> offset in VRAM
	.byte	(ADDRESS_GFX2_SPRITE_PATTERN / $800)	; sprite pattern table - value * $800  --> offset in VRAM
	.byte	Black

vdp_init_bytes_gfx3:
	.byte 	0		; 
	.byte 	v_reg1_16k|v_reg1_display_on|v_reg1_m2|v_reg1_spr_size; |v_reg1_int
	.byte 	($3800 / $400)	; name table - value * $400
	.byte	$ff				; color table setting for gfx mode 2 --> only Bit 7 is taken into account 0 => at vram $0000, 1 => at vram $2000, Bit 6-0 AND to character number
	.byte	$03 			; pattern table - either at vram $0000 (Bit 2 = 0) or at vram $2000 (Bit 2=1), Bit 0,1 are AND to select the pattern array
	.byte	($3c00 / $80)	; sprite attribute table - value * $80 --> offset in VRAM
	.byte	($1800 / $800)	; sprite pattern table - value * $800  --> offset in VRAM
	.byte	Black
	
;
;   input:	a - color
;
vdp_bgcolor:
	sta   a_vreg
	lda   #v_reg7
	vnops
	sta   a_vreg
	rts