
.include "common.inc"
.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "via.inc"
.include "joystick.inc"


main:

	;via port a
	; lda #$00
	stz via1ier             ; disable VIA1 T1 interrupts
	; lda #%00000000 			; set latch
	stz via1acr
	lda #%11001100 			; set level
	sta via1pcr
	lda #%11000000 			; set PA6,7 to output (port select), PA1-6 to input (directions)
	sta via1ddra


	lda	#PORT_SEL_1			;port 1
	sta	via1porta
	
loop:
	SetVector text_j1, msgptr
	jsr krn_strout
	
	lda	via1porta
	and	#%00111111
	jsr	krn_hexout

;	lda	#PORT_SEL_2			;port 2
;	sta	via1porta
	
;	SetVector text_j2, msgptr
;	jsr krn_strout

;	lda	via1porta
;	and	#%00111111
;	jsr	krn_hexout
	
	ldx #$00
	ldy crs_y
	jsr krn_textui_crsxy
	bra loop

text_j1:
	.asciiz "j1: "
text_j2:
	.asciiz " j2: "