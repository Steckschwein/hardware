.include "common.inc"
.include "kernel.inc"
.include "vdp.inc"

.export vdp_bgcolor, vdp_memcpy, vdp_mode_text, vdp_display_off

.segment "KERNEL"

.ifdef COLS80
	.ifndef V9958
		.assert 0, error, "80 COLUMNS ARE SUPPORTED ON V9958 ONLY! MAKE SURE -DV9958 IS ENABLED"
	.endif
.endif

vdp_display_off:
        SyncBlank
        vnops
		lda		#v_reg1_16k	;enable 16K ram, disable screen
		sta 	a_vreg
		vnops
		lda	  	#v_reg1
		sta   	a_vreg
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

;
;	text mode - 40x24/80x24 character mode, 2 colors
;
vdp_mode_text:

.ifdef V9958
	; enable V9958 wait state generator
	lda #1<<2
	ldy #v_reg25
	vdp_sreg
.endif

	SetVector vdp_init_bytes_text, adrl
; setup video registers upon given table
;	input:
;	adrl/adrh vector set to vdp init table for al 8 vdp registers
vdp_init_reg:
	ldy	#$00
	ldx	#v_reg0
@l1:
	lda (adrl),y
	sta a_vreg
	iny
	vnops
	stx a_vreg
	inx
	cpy	#$08
	bne @l1
	rts

vdp_init_bytes_text:
.ifdef COLS80
	.byte 	v_reg0_m4	; text mode 2
	.byte   v_reg1_16k|v_reg1_display_on|v_reg1_int|v_reg1_m1
	.byte 	(ADDRESS_GFX1_SCREEN / $1000)| 1<<1 | 1<<0	; name table - value * $1000 (v9958) --> charset
.else
	.byte	0
	.byte   v_reg1_16k|v_reg1_display_on|v_reg1_int|v_reg1_m1
	.byte 	(ADDRESS_GFX1_SCREEN / $1000) 	; name table - value * $400					--> charset
.endif
	.byte 	0	; not used
	.byte 	(ADDRESS_GFX1_PATTERN / $800) ; pattern table (charset) - value * $800  	--> offset in VRAM
	.byte	0	; not used
	.byte 	0	; not used
	.byte	Medium_Green<<4|Black

;
;   input:	a - color
;
vdp_bgcolor:
	sta   a_vreg
	lda   #v_reg7
	vnops
	sta   a_vreg
	rts

m_vdp_nopslide
