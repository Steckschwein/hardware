;
;	color - adjust colors
;
.org $1000
.include "appstart.inc"

.include "common.inc"
.include "vdp.inc"
.include "zeropage.inc"
.include "../kernel/kernel_jumptable.inc"

.import vdp_gfx1_blank
.import vdp_gfx1_on

.import vdp_mc_blank
.import vdp_mc_on
.import vdp_mc_set_pixel

	sei
	jsr	krn_textui_disable			;disable textui
	jsr krn_display_off
	lda #Cyan<<4|Black
;	jsr vdp_gfx1_blank
;	jsr	vdp_gfx1_on
	lda	#Black
	jsr vdp_mc_blank
	jsr	vdp_mc_on
	
	SyncBlank
	ldx #30
	ldy #30
	lda #White
	jsr vdp_mc_set_pixel

	cli
	
	keyin
	
									;restore textui
	sei
	jsr	krn_display_off			
	jsr	krn_textui_init
	cli
	jsr	krn_textui_enable

	jmp (retvec)
