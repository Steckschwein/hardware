.export sqrt8

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
@again:		cmp $21
			bcc @nomore
			sbc $21
			iny
			inc $21
			inc $21
			bra @again
@nomore:	sty $20
			sta $21
			rts
