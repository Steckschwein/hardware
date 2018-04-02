.include "common.inc"
.include "vdp.inc"
.include "fcntl.inc"
.include "zeropage.inc"
.include "kernel_jumptable.inc"
.include "appstart.inc"




.import vdp_gfx7_on
.import vdp_gfx7_blank
.import vdp_gfx7_set_pixel
.import vdp_display_off
.import vdp_memcpy
.import vdp_mode_sprites_off
.import vdp_bgcolor
.import hexout

appstart $1000


pt_x = $10
pt_y = $12
ht_x = $14
ht_y = $16

.code
main:
		lda #0
		sta pt_x
		stz pt_x+1

		; lda #100
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

		ldx #21

		jsr	krn_textui_disable			;disable textui
		jsr	gfxui_on

		lda #$41
		sta $0230



		keyin

		jsr	gfxui_off

		jsr	krn_display_off			;restore textui
		jsr	krn_textui_init
		jsr	krn_textui_enable
		bit a_vreg ; acknowledge any vdp interrupts before re-enabling interrupts

		cli

		jmp (retvec)

blend_isr:
	php
    bit a_vreg
    bpl @0
	save

	lda	#%11100000
	jsr vdp_bgcolor

	lda	#Black
	jsr vdp_bgcolor

	restore
@0:
	plp
	rti


gfxui_on:
	sei
	jsr vdp_display_off			;display off
	jsr vdp_mode_sprites_off	;sprites off

	vdp_reg 8, v_reg8_SPD | v_reg8_VR
	vnops

;	lines
	vdp_reg 9, v_reg9_ln

	jsr vdp_gfx7_on			    ;enable gfx7 mode

	vdp_reg 14, <.HIWORD(ADDRESS_GFX7_SCREEN<<2)
	vnops

	vdp_reg (WRITE_ADDRESS + >.LOWORD(ADDRESS_GFX7_SCREEN)), <.LOWORD(ADDRESS_GFX7_SCREEN)
	vnops

	; lda #%00000011
	; jsr vdp_gfx7_blank

; @loop:
; 	vnops
	lda #$ff
	jsr vdp_gfx7_line

;
; 	dec ht_y
; 	dec ht_y
; 	dec ht_y
; 	dec ht_y
; 	dec ht_y
; 	dec ht_y
; 	dec ht_y
; 	dec ht_y
; 	dec ht_y
; 	dec ht_y
; 	dec ht_y
; 	dec ht_y
;
; 	dex
; 	bne @loop


	copypointer  $fffe, irqsafe
	SetVector  blend_isr, $fffe

	; reset vbank - TODO FIXME, kernel has to make sure that correct video adress is set for all vram operations, use V9958 flag
	vdp_reg 14, %00000000

	bit a_vreg ; acknowledge any vdp interrupts before re-enabling interrupts
	cli
	lda #$81
	sta $0230


    rts

gfxui_off:
    sei

    copypointer  irqsafe, $fffe

	bit a_vreg ; acknowledge any vdp interrupts before re-enabling interrupts
    cli
    rts

vdp_gfx7_line:
	phx
	pha

	vdp_reg 17,36

	ldx #0
@loop:
	vnops
	lda pt_x,x
	sta a_vregi
	inx
	cpx #8
	bne @loop

	vnops
	pla
	sta a_vregi

	vnops
	lda #0
	sta a_vregi

	vnops
	lda #v_cmd_line
	sta a_vregi

	vnops

@wait:
	vdp_reg 15,2
	vnops
	lda a_vreg
	ror
	bcs @wait

	plx
	rts




m_vdp_nopslide

irqsafe: .res 2, 0


 .segment "STARTUP"
