	.import b2ad2				; uut
	.import b2ad				; uut
    .import dpb2ad
	.include "assertion.inc" 	; test api

	; required to run with steckos only
	.include "kernel_jumptable.inc"

;.segment "EXEHDR"
;	.byte   1

.code
    ldx #0
    ldy #0

	lda	#42
	jsr	b2ad

	assertOut "42"	; assert outpuz
    assertX 0
    assertY 0

	lda	#042
	jsr	b2ad2

	assertOut "042"	; assert outpuz
    assertX 0
    assertY 0

	lda	#255
	jsr	b2ad2

	assertOut "255"	; assert outpuz

	lda	#255
	ldx	#255
	jsr	dpb2ad

	assertOut "65535"	; assert outpuz



	; lda	#$e7
	; jsr	hexout
	;
	; assertOut "E7"	; assert outpuz
	; assertA $e7		; assert A is not destroyed
	;
	; lda	#$9f
	; jsr	hexout
	;
	; assertOut "9F"
	; assertA $9f

	rts

	.include "asmunit.asm"
