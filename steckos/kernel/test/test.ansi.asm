	.setcpu "65c02"

	.include "common.inc"
	.include "zeropage.inc"

	.import ansi_chrout	; uut

	.include "asmunit.inc" ; test api

	.import asmunit_chrout
	.export krn_chrout=asmunit_chrout
	.export textui_chrout=asmunit_chrout
	.export textui_update_crs_ptr=dummy

.segment "KERNEL"	; test must be placed into kernel segment, cuz we wanna use the same linker config

    test_name "ansi_chrout"

	stz ansi_state
	;stz ansi_index

	lda #'A'
	sta ansi_index
	jsr ansi_chrout

	assertA 'A'
	assert8 $00, ansi_state

    test_name "ansi_chrout esc"

	lda #27
	jsr ansi_chrout

	assert8 $80, ansi_state

	lda #'['
	jsr ansi_chrout

	assert8 $40, ansi_state
	assert8 $00, ansi_index

	lda #'5'
    jsr ansi_chrout

	assertA 5
	assert8 5, ansi_param1
	assert8 $41, ansi_state
	assert8 $00, ansi_index

	lda #'2'
	jsr ansi_chrout

	;assertA 2
	assert8 $00, ansi_index
	assert8 $41, ansi_state
	assert8 52, ansi_param1

	lda #';'
	jsr ansi_chrout

	assert8 $40, ansi_state
	assert8 $01, ansi_index

	lda #'2'
	jsr ansi_chrout

	assert8 $41, ansi_state
	assert8 2, ansi_param2

	lda #'3'
	jsr ansi_chrout

	assert8 $41, ansi_state
	assert8 23, ansi_param2


	brk
	dummy:
		rts

.segment "ASMUNIT"
