
.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/asminc/via.inc"
.include "../steckos/asminc/common.inc"
.include "../steckos/asminc/joystick.inc"

.include "../steckos/asminc/appstart.inc"

.import hexout

	appstart $1000
main:
	stz via1ier             ; disable VIA1 T1 interrupts
	stz via1acr
	lda #%11001100 			; set level
	sta via1pcr
	lda #%10000000 			; set PA6,7 to output (port select), PA1-6 to input (directions)
	sta via1ddra

	jsr krn_primm
	.byte "x to disable joystick ports",$0a,"y to enable",$0a,$00

loop:


	lda	#PORT_SEL_1
	sta	via1porta

	jsr krn_primm
	.asciiz "j1: "


	lda	via1porta
	and	#%00111111
	jsr	hexout


	lda	#PORT_SEL_2		;port 1
	sta	via1porta


	jsr krn_primm
	.asciiz " j2: "

	lda	via1porta
	and	#%00111111
	jsr	hexout


	ldx #$00
	ldy crs_y
	jsr krn_textui_crsxy

	jsr krn_getkey
	bcc loop
	cmp #'x'
	bne @l
	; joysticks off
	joy_off
	bra loop
@l:	cmp #'y'
	bne @l1
	; joysticks on
	joy_on
	bra loop
@l1:
	cmp #$03
	bne loop
	jmp (retvec)
