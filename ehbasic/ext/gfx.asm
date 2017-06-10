.include "vdp.inc"

.import	vdp_display_off
.import	vdp_mc_on
.import	vdp_mc_init_screen
.import	vdp_mc_set_pixel
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
@l:		jsr krn_keyin
		beq @l
		jsr	krn_display_off			;restore textui
		jsr	krn_textui_init
		jsr	krn_textui_enable 	
		rts

GFX_MC_On:
		jsr	krn_textui_disable			;disable textui
		
		jsr vdp_display_off
		lda #Cyan<4|Dark_Yellow
		jsr vdp_mc_init_screen
		jsr	vdp_mc_on
		jmp GFX_MC_Off
		rts
	
GFX_MC_Plot:
		JSR LAB_SCGB ; scan for "," and get byte 
		CPX #255 ;
		BCS PLOT_FCER; 
		STX PLOT_XBYT ; save plot x 
		JSR LAB_SCGB ; scan for "," and get byte 
		CPX #192 ; compare with max+1 
		BCS PLOT_FCER ;
		txa
		tay
		ldx PLOT_XBYT
	;    jsr set_pixel
		RTS ; return to BASIC 
		
		; does BASIC function call error 
PLOT_FCER: 
		JMP LAB_FCER ; do function call error, then warm start 
		; now we just need the variable storage 
PLOT_XBYT:
		.byte $00 ; set default
	