	.setcpu "65c02"

	.include "common.inc"
	.include "zeropage.inc"
	
	.include "fat32.inc"
	
	.import string_fat_mask
	.import dirname_mask_matcher	; uut

	.include "asmunit.inc" ; test api
	
	.import asmunit_chrout
	.export krn_chrout=asmunit_chrout
	
.macro assertUserInput user_input, dir_entry, expect
	.local @input
	.local @entry
	bra :+
@entry: .byte dir_entry,0
@input: .byte user_input,0
:
	test .concat("[", user_input, "] [", dir_entry, "]");
	SetVector fat_dirname_mask, krn_ptr2    ; ouput
	SetVector @input, filenameptr
	jsr string_fat_mask
	
	SetVector @entry, dirptr
	jsr dirname_mask_matcher
	assertCarry expect
.endmacro

.segment "KERNEL"	; test must be placed into kernel segment, cuz we wanna use the same linker config

	assertUserInput "a.txt", "A       TXT", 1
	assertUserInput "ll.prg", "LL      PRG", 1
	assertUserInput "ls.prg", "LS      PRG", 1
	assertUserInput "Ls.Prg", "LS      PRG", 1
	assertUserInput "ls*", "LS      PRG", 0
	
	assertUserInput "l*.prg", "LL      PRG", 1
	assertUserInput "l*.prg", "LS      PRG", 1
	assertUserInput "l*.prg", "LOADER  PRG", 1
	assertUserInput "l*.prg", "LIST0001DB ", 0
	
	assertUserInput "l?.prg", "LL      PRG", 1
	assertUserInput "l?.prg", "LS      PRG", 1
	assertUserInput "l?.prg", "LOADER  PRG", 0
	assertUserInput "l?.prg", "LIST0001DB ", 0
		
	assertUserInput "l**.prg", "LL      PRG", 1
	assertUserInput "l**.prg", "LS      PRG", 1
	assertUserInput "l**.prg", "LOADER  PRG", 1
	;assertUserInput "l**.prg", "LIST0001DB ", 0  ; TODO FIXME
	
	assertUserInput "l??.prg", "LL      PRG", 1
	assertUserInput "l??.prg", "LS      PRG", 1
	assertUserInput "l??.prg", "LOADER  PRG", 0
	assertUserInput "l??.prg", "LIST0001DB ", 0
	
	assertUserInput ".", ".          ", 1
	assertUserInput ".", "..         ", 0
	
	assertUserInput "..", ".          ", 0
	assertUserInput "..", "..         ", 1
	
	assertUserInput "*.*", "A       TXT", 1
	assertUserInput "*.*", "LL      PRG", 1
	assertUserInput "*.*", "LS      PRG", 1
	assertUserInput "*.*", "LOADER  PRG", 1
	assertUserInput "*.*", "FIBONACIPRG", 1
	assertUserInput "*.*", "TESTZME TXT", 1
	assertUserInput "*.*", "PROGS      ", 1
	assertUserInput "*.*", ".          ", 1
	assertUserInput "*.*", "..         ", 1
	assertUserInput "*.*", ".SSH       ", 1
	assertUserInput "*.*", "..FOO      ", 1
	assertUserInput "*.*", "1          ", 1
	assertUserInput "*.*", "LIST0001DB ", 1
	
	assertUserInput "*.prg", "LL      PRG", 1
	assertUserInput "*.prg", "LS      PRG", 1
	assertUserInput "*.prg", "LOADER  PRG", 1
	assertUserInput "*.prg", "FIBONACIPRG", 1
	
;	assertUserInput "FI*ONA*I.P*G", "FIBONACIPRG", 1 ; TODO FIXME
	assertUserInput "FI?ONA?I.P?G", "FIBONACIPRG", 1
	
	brk

.segment "ASMUNIT"