
.SEGMENT "ROM"


do_reset:
	lda #$80
	sta $0230
loop:	jmp loop
.CODE

.SEGMENT "VECTORS"

;----------------------------------------------------------------------------------------------
; Interrupt vectors
;----------------------------------------------------------------------------------------------
; $FFFA/$FFFB NMI Vector
.ORG $fffa

.word $ffff
; $FFFC/$FFFD reset vector
;*= $fffc
.word do_reset
; $FFFE/$FFFF IRQ vector
;*= $fffe
.word $ffff
.code