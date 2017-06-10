.include "vdp.inc"

.import	vdp_display_off
.import	vdp_mc_on
.import	vdp_mc_blank
.import	vdp_mc_init_screen
.import	vdp_mc_set_pixel

.import vdp_mode_gfx2

.export GFX_MC_On
.export GFX_MC_Off
.export GFX_MC_Plot

;
;	within basic define extensions as follows
;
;	PLOT = $xxxx 			- assign the adress of GFX_Plot from label file
;	CALL PLOT,X,Y,COLOR		- invoke GFX_Plot with CALL api
;
GFX_BgColor:
    JSR LAB_SCGB ; scan for "," and get byte 
    stx a_vreg
    lda #$87
    sta a_vreg
    RTS ; return to BASIC

GFX_MC_Off:
		sei
		jsr	krn_display_off			;restore textui
		jsr	krn_textui_init
		jsr	krn_textui_enable
		cli
		rts

GFX_MC_On:
		sei
		jsr	krn_textui_disable			;disable textui
		jsr krn_display_off
		lda #0 ; black/black
		jsr vdp_mc_blank
		jsr	vdp_mc_on
		cli
		rts
	
GFX_MC_Plot:
		SyncBlank
		JSR LAB_SCGB 	; scan for "," and get byte 
		stx PLOT_XBYT ; save plot x 
		JSR LAB_SCGB ; scan for "," and get byte 
		stx PLOT_YBYT
		JSR LAB_SCGB ; scan for "," and get byte 
		txa
		and #$0f
;		jsr krn_hexout
		ldx PLOT_XBYT
;		txa
;		jsr krn_hexout
		ldy PLOT_YBYT
;		tya
;		jsr krn_hexout
;		rts
		jmp vdp_mc_set_pixel
;		RTS ; return to BASIC 
		
		; does BASIC function call error 
PLOT_FCER: 
		JMP LAB_FCER ; do function call error, then warm start 
		; now we just need the variable storage 
PLOT_XBYT:
		.byte $00 ; set default
PLOT_YBYT:
		.byte $00 ; set default