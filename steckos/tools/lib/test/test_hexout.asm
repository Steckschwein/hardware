
; uut
.import hexout

.include "assertion.inc"

;.export char_out=$f001

.code
	lda	#$e7
	jsr	hexout
	
	assert16out "exp", "e7"
	
	rts

.include "asmunit.asm"