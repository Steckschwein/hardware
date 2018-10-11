.include "vdp.inc"

; TODO FIXME conflicts with ehbasic zeropage locations - use steckschwein specific zeropage.s not the cc65....runtime/zeropage.s definition
;.importzp ptr1
;.importzp tmp1

.import vdp_init_reg
.import vdp_nopslide
.import vdp_fill

.export vdp_gfx7_on
.export vdp_gfx7_blank
.export vdp_gfx7_set_pixel
.export vdp_gfx7_set_pixel_cmd

.code
;
;	gfx 7 - each pixel can be addressed - e.g. for image
;
vdp_gfx7_on:
			lda #v_reg9 ;	from register number down to reg0
			tax
			and #$7f		;	unmask offset
			tay
@0:		lda vdp_init_bytes_gfx7,y
			sta a_vreg
			vnops
			stx a_vreg
			dex
			dey
			bpl @0
			rts
		
vdp_init_bytes_gfx7:
			.byte v_reg0_m5|v_reg0_m4|v_reg0_m3									; reg0 mode bits
			.byte v_reg1_display_on|v_reg1_spr_size |v_reg1_int 				; TODO FIXME verify v_reg1_16k t9929 specific, therefore 0
			.byte $3f	; => 00<A16>1 1111 - entw. bank 0 (offset $0000) or 1 (offset $10000)
			.byte $0
			.byte $0
			.byte $ff
			.byte $3f
			.byte Black ; border color
			.byte v_reg8_SPD | v_reg8_VR	; SPD - sprite disabled, VR - 64k VRAM
			.byte 0;			v_reg9_ln	//TODO FIXME ntsc off => gfx_off

;
; blank gfx mode 7 with
; 	A - color to fill (RGB) 3+3+2)
;
vdp_gfx7_blank:
	phx
	
	sta colour
	
	lda #<.HIWORD(ADDRESS_GFX7_SCREEN<<2)
	ldy #v_reg14
	vdp_sreg
	vnops
	lda #<.LOWORD(ADDRESS_GFX7_SCREEN)
	ldy #(WRITE_ADDRESS + >.LOWORD(ADDRESS_GFX7_SCREEN))
	vdp_sreg
	vnops
	
	vdp_reg 17,36

	ldx #0
@loop:
	vnops
	lda data,x
	sta a_vregi
	inx
	cpx #12
	bne @loop

	vnops
	vdp_reg 15,2
@wait:
	vnops
	lda a_vreg
	ror
	bcs @wait

	lda #%00000000	; reset vbank - TODO FIXME, kernel has to make sure that correct video adress is set for all vram operations, use V9958 flag
	ldy #v_reg14
	vdp_sreg
	
	plx
	rts

data:
	.word 0 ;x
	.word 256 ;y
	.word 256 ; len x
	.word 212 ; len y
colour:
	.byte %00011100 ; colour
	.byte $00 ; destination memory, x direction, y direction, yada yada
	.byte v_cmd_hmmv ; command
	
; vdp_gfx7_blank:		; 2 x 6K
; 			ldx #212
; 			ldy #0
; @l0:
; 			vnops
; 			sta a_vram
; 			iny
; 			bne @l0
; 			dex
; 			bne @l0
; 			rts


;	X - x coordinate [0..ff]
;	Y - y coordinate [0..bf]
;	A - color GRB [0..ff] as 332
; 	VRAM ADDRESS = X + 256*Y
vdp_gfx7_set_pixel:
         pha
         stx a_vreg                 ; A7-A0 vram address low byte
         tya
         and #$3f                   ; A13-A8 vram address highbyte
         ora #WRITE_ADDRESS
         vnops                      ; TODO FIXME code reorder, avoid vnops
         sta a_vreg
         tya                        ; A16-A14 bank select via reg#14
         rol
         rol
         rol
         and #$03
         ora #<.HIWORD(ADDRESS_GFX7_SCREEN<<2)
         sta a_vreg
         vnops
         lda #v_reg14
         sta a_vreg
         vnops
         pla
         sta a_vram                 ; set color
         rts

;	set pixel to gfx7 using v9958 command engine
;
;	X - x coordinate [0..ff]
;	Y - y coordinate [0..bf]
;	A - color [0..f]
;
; 	VRAM ADDRESS = 8(INT(X DIV 8)) + 256(INT(Y DIV 8)) + (Y MOD 8)
vdp_gfx7_set_pixel_cmd:
		pha
		pha

		vdp_reg 17,36
		vnops
		stx a_vregi
		vnops

		; dummy highbyte
		lda #0
		sta a_vregi
		vnops

		sty a_vregi
		vnops

		; dummy highbyte
		lda #1
		sta a_vregi
		vnops

		vdp_reg 17,44

		pla
		;	colour
		;	GGGRRRBB
		sta a_vregi
		vnops

		lda #$0
		sta a_vregi
		vnops

		lda #v_cmd_pset
		sta a_vregi
		vnops

		vdp_reg 15,2
@wait:
		vnops
		lda a_vreg
		ror
		bcs @wait

		pla
		rts
