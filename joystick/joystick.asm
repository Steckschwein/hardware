
.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/asminc/via.inc"
.include "../steckos/asminc/common.inc"
.include "../steckos/asminc/joystick.inc"
.include "../steckos/kernel/uart.inc"

.include "../steckos/asminc/appstart.inc"

.import hexout

	appstart $1000
main:


	;via port a
	; lda #$00
	stz via1ier             ; disable VIA1 T1 interrupts
	; lda #%00000000 			; set latch
	stz via1acr
	lda #%11001100 			; set level
	sta via1pcr
	lda #%10000000 			; set PA6,7 to output (port select), PA1-6 to input (directions)
	sta via1ddra

	jsr krn_primm
	.byte "x to disable joystick ports",$0a, y to enable",$0a,$00

loop:

	lda	#PORT_SEL_1			;port 1
	;lda	#00
	sta	via1porta


	lda #<text_j2
	ldx #>text_j2
	jsr krn_strout

	lda	via1porta
	and	#%00111111
	jsr	hexout

	lda	#PORT_SEL_2			;port 2
	sta	via1porta

	lda #<text_j1
	ldx #>text_j1

	jsr krn_strout

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
	lda #%00000100
	ora uart1mcr
	sta uart1mcr
	bra loop
@l:	cmp #'y'
	bne loop
	; joysticks on
	lda #%11111011
	and uart1mcr
	sta uart1mcr
	bra loop

text_j1:
	.asciiz " j1: "
text_j2:
	.asciiz "j2: "
