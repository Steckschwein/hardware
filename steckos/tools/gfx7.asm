.include "common.inc"
.include "vdp.inc"
.include "fcntl.inc"
.include "zeropage.inc"
.include "kernel_jumptable.inc"
.include "appstart.inc"


.importzp ptr2, ptr3
.importzp tmp3, tmp4

.import vdp_gfx7_on
.import vdp_gfx7_blank
.import vdp_display_off
.import vdp_memcpy
.import vdp_mode_sprites_off
.import vdp_bgcolor

appstart $1000

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
	; save

    ; lda	#%11100000
	; jsr vdp_bgcolor
	;
    ; lda	#Black
	; jsr vdp_bgcolor

	; restore
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

	vdp_reg 9, v_reg9_ln
	;|v_reg9_il

	jsr vdp_gfx7_on			    ;enable gfx7 mode

	lda #<.HIWORD(ADDRESS_GFX7_SCREEN<<2)
	ldy #v_reg14
	vdp_sreg
	vnops
	lda #<.LOWORD(ADDRESS_GFX7_SCREEN)
	ldy #(WRITE_ADDRESS + >.LOWORD(ADDRESS_GFX7_SCREEN))
	vdp_sreg

	SetVector	rgbdata, ptr1
	ldx #212
	ldy #0
@l0:
	vnops
	lda (ptr1),y
	sta a_vram
	iny
	bne @l0
	inc ptr1+1
	dex
	bne @l0

; 	ldx #192-171
; @lerase:
; 	vnops
; 	stz a_vram
; 	iny
; 	bne @lerase
; 	dex
; 	bne @lerase

    copypointer  $fffe, irqsafe
    SetVector  blend_isr, $fffe

	lda #%00000000	; reset vbank - TODO FIXME, kernel has to make sure that correct video adress is set for all vram operations, use V9958 flag
	ldy #v_reg14
	vdp_sreg

    cli
    rts

gfxui_off:
    sei

    copypointer  irqsafe, $fffe
    cli
    rts

m_vdp_nopslide

irqsafe: .res 2, 0

.align 256,0
rgbdata:
.incbin "felix.ppm.raw"


.segment "STARTUP"
