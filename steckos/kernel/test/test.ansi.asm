	.setcpu "65c02"

	.include "common.inc"
	.include "zeropage.inc"

	.include "fat32.inc"

	.import ansi_chrout	; uut

	.include "asmunit.inc" ; test api

	.import asmunit_chrout
	.export krn_chrout=asmunit_chrout


.segment "KERNEL"	; test must be placed into kernel segment, cuz we wanna use the same linker config

	stz ansi_state
	;stz ansi_index

	lda #'A'
	sta ansi_index
	jsr ansi_chrout

	assertA 'A'
	assert8 $00, ansi_state

	lda #27
	jsr ansi_chrout

	assert8 $80, ansi_state

	lda #'['
	jsr ansi_chrout

	assert8 $40, ansi_state
	assert8 $00, ansi_index

	lda #'5'
	jsr ansi_chrout

	assert8 $40, ansi_state
	assert8 $01, ansi_index

	lda #';'
	jsr ansi_chrout

	assert8 $40, ansi_state
	assert8 $02, ansi_index


	lda #'A'
	jsr ansi_chrout

	assert8 $00, ansi_state
	assert8 $02, ansi_index


	brk

.segment "ASMUNIT"
