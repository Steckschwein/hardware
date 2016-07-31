_test_ok:
	lda #'.'
	jmp vdp_chrout
_test_failed:
	lda #'E'
	jmp vdp_chrout