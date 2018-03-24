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

content = $2000
color=content+$1800

main:
		jsr	krn_textui_disable			;disable textui
		SetVector content, addr
		jsr	gfxui_on

		keyin

		jsr	gfxui_off

		jsr	krn_display_off			;restore textui
		jsr	krn_textui_init
		jsr	krn_textui_enable
		cli
		bra l2


l2:		jmp (retvec)

row=$100
blend_isr:
    bit a_vreg
    bpl @0
    save
    lda	#Black
	jsr vdp_bgcolor
	restore
@0:
		rti

gfxui_on:
    sei
	jsr	vdp_display_off			;display off
	jsr vdp_mode_sprites_off	;sprites off

    lda #%11100000
    jsr vdp_gfx7_blank

	jsr vdp_gfx7_on			    ;enable gfx7 mode
    cli
    rts

gfxui_off:
    sei
    copypointer  irqsafe, $fffe
    cli
    rts

m_vdp_nopslide

irqsafe: .res 2, 0
