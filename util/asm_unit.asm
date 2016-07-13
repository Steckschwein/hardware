
.export _test_ok, _test_failed

_test_ok:
	lda #'.'
	jmp vdp_chrout
_test_failed:
	lda #'E'
	jmp vdp_chrout