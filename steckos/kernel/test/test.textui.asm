	.include "asmunit.inc" 	; test api
	.include "zeropage.inc"
	
	.import textui_chrout, textui_put
	.import textui_update_crs_ptr, textui_crsxy

	.import asmunit_chrout
	.export krn_chrout=asmunit_chrout
	
.segment "KERNEL"	; test must be placed into kernel segment, cuz we wanna use the same linker config

	test "textui_crsxy"
		
		ldx #0
		ldy #0
		jsr textui_crsxy
		
		ldx #1
		ldy #3
		jsr textui_crsxy
		
		assert8 1, crs_x
		assert8 3, crs_y

		brk

.segment "ASMUNIT"
