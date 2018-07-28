.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/asminc/common.inc"
.include "../steckos/asminc/appstart.inc"
appstart $1000

			lda #25
			sta $20

			jsr sqrt8

			lda $20
			jsr krn_hexout

			jmp (retvec)


;-----------------------------------------------------------------
; square root from 8 bit number
; parameter in $20
; result in $20
; destructive; A,Y
;-----------------------------------------------------------------
sqrt8:		ldy #$00
			lda #$00
			sta $21
			lda $20
again:		cmp $21
			bcc nomore
			sbc $21
			iny
			inc $21
			inc $21
			bra again
nomore:		sty $20
			sta $21
			rts
