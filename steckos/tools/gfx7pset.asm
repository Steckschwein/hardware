.include "common.inc"
.include "vdp.inc"
.include "fcntl.inc"
.include "zeropage.inc"
.include "kernel_jumptable.inc"
.include "appstart.inc"


; draw some pixels using vdp_gfx7_set_pixel, which uses the v9958 PSET command

.import vdp_gfx7_on
.import vdp_gfx7_blank
.import vdp_gfx7_set_pixel
.import vdp_display_off
.import vdp_memcpy
.import vdp_mode_sprites_off
.import vdp_bgcolor
.import hexout

appstart $1000

pt_x = 25
pt_y = 257
ht_x = 150
ht_y = 150
.code
main:

		jsr	krn_textui_disable			;disable textui
		jsr	gfxui_on

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
@0:
	rti

gfxui_on:
    sei
	jsr vdp_display_off			;display off
	jsr vdp_mode_sprites_off	;sprites off


	lda #v_reg8_SPD | v_reg8_VR
	ldy #v_reg8
	vdp_sreg
	vnops

	; lines
	; lda #v_reg9_ln
	; ldy #v_reg9
	; vdp_sreg
	; vnops

	jsr vdp_gfx7_on			    ;enable gfx7 mode

	lda #<.HIWORD(ADDRESS_GFX7_SCREEN<<2)
	ldy #v_reg14
	vdp_sreg
	vnops
	lda #<.LOWORD(ADDRESS_GFX7_SCREEN)
	ldy #(WRITE_ADDRESS + >.LOWORD(ADDRESS_GFX7_SCREEN))
	vdp_sreg


	lda #%00000011
	jsr vdp_gfx7_blank
	vnops

	lda #$ff
	ldx #0
	ldy sintable,x
@loop:
	jsr vdp_gfx7_set_pixel
	vnops
	inx
	ldy sintable,x
	cpx #00
	bne @loop


;	copypointer  $fffe, irqsafe
;	SetVector  blend_isr, $fffe

@end:
	; lda #%00000000	; reset vbank - TODO FIXME, kernel has to make sure that correct video adress is set for all vram operations, use V9958 flag
	; ldy #v_reg14
	; vdp_sreg

    cli
    rts

gfxui_off:
;    sei

;    copypointer  irqsafe, $fffe
;    cli
    rts

m_vdp_nopslide

;irqsafe: .res 2, 0

.align 256,0
rgbdata:
; .incbin "531740.raw"

sintable:
.byte 105, 110, 114, 119, 124, 128, 132, 136
.byte 140, 143, 146, 148, 151, 153, 154, 155
.byte 156, 156, 156, 155, 154, 153, 151, 148
.byte 146, 143, 140, 136, 132, 128, 124, 119
.byte 114, 110, 105, 100, 95, 90, 86, 81, 76
.byte 72, 68, 64, 60, 57, 54, 52, 49, 47, 46
.byte 45, 44, 44, 44, 45, 46, 47, 49, 51, 54
.byte 57, 60, 64, 68, 72, 76, 81, 85, 90, 95
.byte 100, 105, 110, 114, 119, 124, 128, 132
.byte 136, 140, 143, 146, 148, 151, 153, 154
.byte 155, 156, 156, 156, 155, 154, 153, 151
.byte 149, 146, 143, 140, 136, 132, 128, 124
.byte 119, 115, 110, 105, 100, 95, 90, 86, 81
.byte 76, 72, 68, 64, 60, 57, 54, 52, 49, 47
.byte 46, 45, 44, 44, 44, 45, 46, 47, 49, 51
.byte 54, 57, 60, 64, 68, 72, 76, 81, 85, 90
.byte 95, 100, 105, 110, 114, 119, 124, 128
.byte 132, 136, 140, 143, 146, 148, 151, 153
.byte 154, 155, 156, 156, 156, 155, 154, 153
.byte 151, 149, 146, 143, 140, 136, 132, 128
.byte 124, 119, 115, 110, 105, 100, 95, 90
.byte 86, 81, 76, 72, 68, 64, 60, 57
.byte 54, 52, 49, 47, 46, 45, 44, 44, 44, 45, 46, 47, 49, 51, 54, 57, 60, 64, 68, 72, 76, 81, 85, 90, 95, 100, 105, 110, 114, 119, 124, 128, 132, 136, 140, 143, 146, 148, 151, 153, 154, 155, 156, 156, 156, 155, 154, 153, 151, 149, 146, 143, 140, 136, 132, 128, 124, 119, 115, 110, 105, 100, 95, 90, 86, 81
 .segment "STARTUP"
