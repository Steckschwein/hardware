.include "asmunit.inc" 	; unit test api

	.import b2ad2				; uut
	.import b2ad				; uut
	.import dpb2ad				; uut

.code
	
		test "b2ad"
		
		ldx #0
		ldy #0

		lda	#42
		jsr	b2ad

		assertOut "42"	; assert outpuz
		assertX 0
		assertY 0

		test "b2ad2"

		lda	#42
		jsr	b2ad2

		assertOut "042"	; assert outpuz
		assertX 0
		assertY 0

		lda	#255
		jsr	b2ad2
		assertOut "255"	; assert outpuz

		test "dpb2ad"
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

	brk

.segment "ASMUNIT"