	.include "assertion.inc" 	; test api
	
	.include "common.inc"
	.include "zeropage.inc"
	
	.import string_trim
	.import string_fat_mask		; uut

.segment "KERNEL"	; test must be placed into kernel segment, cuz we wanna use the same linker config

	SetVector test_data_01, filenameptr
	SetVector krn_ptr2, output
	jsr string_fat_mask
	assertA $01		; carry cleared
	
	
	rts

output:	
	.res 32,0

test_data_01:
	.asciiz "   "
test_data_02:
	.asciiz "  AB"
	
	.include "asmunit.asm"