.include "asmunit.inc" 	; unit test api
	
	.include "common.inc"
	.include "zeropage.inc"
	
	.include "fat32.inc"
	
	.import string_fat_mask		; uut
	.import string_fat_name		; uut
	
	.import asmunit_chrout
	.export krn_chrout=asmunit_chrout
	
.segment "KERNEL"	; test must be placed into kernel segment, cuz we wanna use the same linker config

	test "string_fat_mask"
	SetVector output, krn_ptr2	; ouput

	SetVector test_data_01, filenameptr
	jsr string_fat_mask
	assert8 $0, output	; expect zero length string
	
	SetVector test_data_02, filenameptr
	jsr string_fat_mask
	assertString "AB         ", output
	
	SetVector test_data_03, filenameptr
	jsr string_fat_mask
	assertString "LS      PRG", output
	
	SetVector test_data_04, filenameptr
	jsr string_fat_mask
	assertString "LS         ", output
	
	SetVector test_data_05, filenameptr
	jsr string_fat_mask
	assertString "LS      ???", output
	
	SetVector test_data_06, filenameptr
	jsr string_fat_mask
	assertString "????????PRG", output

	SetVector test_data_07, filenameptr
	jsr string_fat_mask
	assertString "????????   ", output

	SetVector test_data_08, filenameptr
	jsr string_fat_mask
	assertString "???????????", output
	
	SetVector test_data_09, filenameptr
	jsr string_fat_mask
	assertString "FI?ONA?IP?G", output

	SetVector test_data_10, filenameptr
	jsr string_fat_mask
;	assertString "FI?ONA?IP?G", output ; TODO FIXME

	SetVector test_data_11, filenameptr
	jsr string_fat_mask
	assertString "LS??????   ", output
	
	SetVector test_data_12, filenameptr
	jsr string_fat_mask
;	assertString "L???????   ", output ; TODO FIXME
	
	brk

output:	
	.res 11,0
test_data_01:
	.asciiz "   "
test_data_02:
	.asciiz "  AB"
test_data_03:
	.asciiz "ls.prg"
test_data_04:
	.asciiz "ls"
test_data_05:
	.asciiz "ls.*"
test_data_06:
	.asciiz "*.prg"
test_data_07:
	.asciiz "*"
test_data_08:
	.asciiz "*.*"
test_data_09:
	.asciiz "FI?ONA?I.P?G"
test_data_10:
	.asciiz "FI*ONA*I.P*G"
test_data_11:
	.asciiz "ls*"
test_data_12:
	.asciiz "l**"
	
.segment "ASMUNIT"