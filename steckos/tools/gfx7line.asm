.include "common.inc"
.include "vdp.inc"
.include "fcntl.inc"
.include "zeropage.inc"
.include "kernel_jumptable.inc"
.include "appstart.inc"




.import vdp_gfx7_on
.import vdp_gfx7_set_pixel
.import vdp_display_off
.import vdp_memcpy
.import vdp_mode_sprites_off
.import vdp_bgcolor
.import hexout

appstart $1000


pt_x = $a0
pt_y = $a2
ht_x = $a4
ht_y = $a6

.code
main:
		sei

		jsr	krn_textui_disable			;disable textui
		jsr	gfxui_on


		lda #0
		sta pt_x
		stz pt_x+1

		lda #0
		sta pt_y
		lda #$01
		sta pt_y+1

		lda #255
		sta ht_x
		lda #0
		sta ht_x+1

		lda #212
		sta ht_y
		lda #0
		sta ht_y+1



@loop:
		vnops
		lda #%11100000
		jsr vdp_gfx7_line
		dec ht_y
		dec ht_y
		dec ht_y
		dec ht_y
		dec ht_y
		dec ht_y
		dec ht_y
		dec ht_y
		dec ht_y
		dec ht_y
		dec ht_y
		dec ht_y

		bne @loop

		keyin
		jsr	gfxui_off

		jsr	krn_display_off			;restore textui
		jsr	krn_textui_init
		jsr	krn_textui_enable
		cli

		jmp (retvec)

row=$100
blend_isr:
    bit a_vreg
    bpl @0
	save

	lda	#%11100000
	jsr vdp_bgcolor

	lda	#Black
	jsr vdp_bgcolor

	restore
@0:
	rti


gfxui_on:
	jsr vdp_display_off			;display off
	jsr vdp_mode_sprites_off	;sprites off


	lda #v_reg8_SPD | v_reg8_VR
	ldy #v_reg8
	vdp_sreg
	vnops

;	lines
	lda #v_reg9_ln
	ldy #v_reg9
	vdp_sreg
	vnops

	jsr vdp_gfx7_on			    ;enable gfx7 mode

	lda #<.HIWORD(ADDRESS_GFX7_SCREEN<<2)
	ldy #v_reg14
	vdp_sreg
	vnops
	lda #<.LOWORD(ADDRESS_GFX7_SCREEN)
	ldy #(WRITE_ADDRESS + >.LOWORD(ADDRESS_GFX7_SCREEN))
	vdp_sreg


	lda #%00000000
	jsr vdp_gfx7_blank
	vnops


	copypointer  $fffe, irqsafe
	SetVector  blend_isr, $fffe

@end:
	; lda #%00000000	; reset vbank - TODO FIXME, kernel has to make sure that correct video adress is set for all vram operations, use V9958 flag
	; ldy #v_reg14
	; vdp_sreg

    rts

gfxui_off:
    sei

    copypointer  irqsafe, $fffe
    cli
    rts

vdp_gfx7_line:
	pha
	phx
	phy

	pha

	lda pt_x
	ldy #v_reg36
	vdp_sreg
	vnops

	lda pt_x+1
	ldy #v_reg37
	vdp_sreg
	vnops

	lda pt_y
	ldy #v_reg38
	vdp_sreg
	vnops

	lda pt_y+1
	ldy #v_reg39
	vdp_sreg
	vnops

	lda ht_x
	ldy #v_reg40
	vdp_sreg
	vnops

	lda ht_x+1
	ldy #v_reg41
	vdp_sreg
	vnops

	lda ht_y
	ldy #v_reg42
	vdp_sreg
	vnops

	lda ht_y+1
	ldy #v_reg43
	vdp_sreg
	vnops

	pla
	ldy #v_reg44
	vdp_sreg
	vnops

	lda #$0
	ldy #v_reg45
	vdp_sreg
	vnops

	lda #v_cmd_line
	ldy #v_reg46
	vdp_sreg
	vnops

	lda #2
	ldy #v_reg15
	vdp_sreg
@wait:
	vnops
	lda a_vreg
	ror
	bcs @wait

	ply
	plx
	pla
	rts

vdp_gfx7_blank:
	save

	pha

	lda #0
	ldy #v_reg36
	vdp_sreg
	vnops

	lda #0
	ldy #v_reg37
	vdp_sreg
	vnops

	lda #0
	ldy #v_reg38
	vdp_sreg
	vnops

	lda #0
	ldy #v_reg39
	vdp_sreg
	vnops

	lda #255
	ldy #v_reg40
	vdp_sreg
	vnops

	lda #0
	ldy #v_reg41
	vdp_sreg
	vnops

	lda #212
	ldy #v_reg42
	vdp_sreg
	vnops

	lda #1
	ldy #v_reg43
	vdp_sreg
	vnops

	pla
	;lda #%00000011
	ldy #v_reg44
	vdp_sreg
	vnops

	lda #$0
	ldy #v_reg45
	vdp_sreg
	vnops

	lda #v_cmd_hmmv
	ldy #v_reg46
	vdp_sreg
	vnops

	lda #2
	ldy #v_reg15
	vdp_sreg
@wait:
	vnops
	lda a_vreg
	ror
	bcs @wait

	restore
	rts

m_vdp_nopslide

irqsafe: .res 2, 0


 .segment "STARTUP"
