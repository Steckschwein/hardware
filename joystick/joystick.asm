
.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/kernel/via.inc"

PORT_SEL_1		= 1<<6
PORT_SEL_2		= 1<<7
JOY_UP			= 1<<0
JOY_DOWN		= 1<<1
JOY_LEFT		= 1<<2
JOY_RIGHT		= 1<<3
JOY_FIRE		= 1<<4

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


loop:
	
	lda	#PORT_SEL_1			;port 1
	sta	via1porta
	


	jsr krn_primm
	.asciiz "j1: "

	lda	via1porta
	and	#%00111111
	jsr	krn_hexout

	lda	#PORT_SEL_2			;port 2
	sta	via1porta
	
	jsr krn_primm
	.asciiz " j2: "

	lda	via1porta
	and	#%00111111
	jsr	krn_hexout
	
	stz crs_x	
	bra loop
	
