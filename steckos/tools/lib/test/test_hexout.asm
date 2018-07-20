
.import hexout

.code
	lda	#$e7
	jsr	hexout
	
	rts
	
.segment "STARTUP"