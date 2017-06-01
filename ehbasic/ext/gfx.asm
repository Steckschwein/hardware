.include "vdp.inc"
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

GFX_2On:
;	jsr	vdp_display_off
	;clear bitmap space
	lda	#Cyan<<4|Black
	;jsr	vdp_mode_gfx2_blank
	;enable gfx2
	;jmp	vdp_mode_gfx2
    
GFX_1On:
	;jmp	vdp_mode_gfx1

GFX_Plot:
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
	