;
;	color - adjust colors
;
.include "common.inc"
.include "vdp.inc"
.include "zeropage.inc"
.include "../kernel/kernel_jumptable.inc"

.include "appstart.inc"
appstart $1000

.import vdp_gfx1_blank
.import vdp_gfx1_on

.import vdp_mc_blank
.import vdp_mc_on
.import vdp_mc_set_pixel


_x=$0
_y=$1

	sei
	jsr	krn_textui_disable			;disable textui
	jsr krn_display_off
	lda #Cyan<<4|Black
	lda	#Black
	jsr vdp_mc_blank
	jsr	vdp_mc_on
	cli

	stz _x
	stz _y
@loop:
	ldy _y
	ldx _x
	lda _y
	and #$0f
	SyncBlank
	jsr vdp_mc_set_pixel
	inc _x
	lda _x
	cmp #64
	bne @loop
	stz _x
	inc _y
	lda _y
	cmp #48
	bne @loop

	keyin
									;restore textui
	sei
	jsr	krn_display_off
	jsr	krn_textui_init
	cli
	jsr	krn_textui_enable

	jmp (retvec)
