.include "vdp.inc"

; TODO FIXME conflicts with ehbasic zeropage locaitons - use steckschwein specific zeropage.s not the cc65....runtime/zeropage.s definition
;.importzp ptr1
;.importzp tmp1

.import vdp_init_reg
.import vdp_nopslide
.import vdp_fill

.export vdp_gfx6_on
.export vdp_gfx6_blank
.export vdp_gfx6_set_pixel

.code
;
;	gfx 6 - 
;
vdp_gfx6_on:
			lda #<vdp_init_bytes_gfx6
			sta ptr1
			lda #>vdp_init_bytes_gfx6
			sta ptr1+1
			jmp vdp_init_reg

vdp_init_bytes_gfx6:
			.byte v_reg0_m5|v_reg0_m3												; reg0 mode bits
			.byte v_reg1_display_on|v_reg1_spr_size |v_reg1_int 			; TODO FIXME verify v_reg1_16k t9929 specific, therefore 0
			.byte $1f	; => 00<A16>1 1111 - entw. bank 0 oder 1 (64k)
			.byte	$0
			.byte	$0
			.byte	$ff
			.byte	$3f
			.byte	$ff
			

;
; blank gfx mode 2 with
; 	A - color to fill (RGB) 3+3+2)
;
vdp_gfx6_blank:		; 2 x 6K
;.ifdef V9958
	sta tmp1
	lda #%00000000
	ldy #v_reg14
	vdp_sreg
	
	lda #<ADDRESS_GFX7_SCREEN
	ldy #WRITE_ADDRESS + >ADDRESS_GFX7_SCREEN
	ldx #32
	jmp vdp_fill

;	set pixel to gfx2 mode screen
;
;	X - x coordinate [0..ff]
;	Y - y coordinate [0..bf]
;	A - color [0..f]
;
; 	VRAM ADDRESS = 8(INT(X DIV 8)) + 256(INT(Y DIV 8)) + (Y MOD 8)
vdp_gfx6_set_pixel:
		beq vdp_gfx6_set_pixel_e	; 0 - not set, leave blank
;		sta tmp1					; otherwise go on and set pixel
		; calculate low byte vram adress
		txa						;2
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
vdp_gfx6_set_pixel_e:
		rts
bitmask:
	.byte $80,$40,$20,$10,$08,$04,$02,$01