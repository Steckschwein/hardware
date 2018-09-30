	.setcpu "65c02"

	.include "common.inc"
	.include "zeropage.inc"
	
	.include "fat32.inc"
	
	.import string_fat_mask
	.import dirname_mask_matcher	; uut

	.include "asmunit.inc" ; test api
	
.macro assertUserInput user_input, dir_entry, expect
	.local @input
	bra :+
@input: .byte user_input,0
:
	SetVector fat_dirname_mask, krn_ptr2    ; ouput
	SetVector @input, filenameptr
	jsr string_fat_mask
	
	SetVector dir_entry, dirptr
	jsr dirname_mask_matcher
	assertCarry expect
.endmacro

.segment "KERNEL"	; test must be placed into kernel segment, cuz we wanna use the same linker config

	assertUserInput "a.txt", dir_1, 1
	assertUserInput "ll.prg", dir_2, 1
	assertUserInput "ls.prg", dir_3, 1
	assertUserInput "Ls.Prg", dir_3, 1
	assertUserInput "ls*", dir_3, 0
	
	assertUserInput "l*.prg", dir_2, 1
	assertUserInput "l*.prg", dir_3, 1
	assertUserInput "l*.prg", dir_4, 1
	assertUserInput "l*.prg", dir_13, 0
	
	assertUserInput "l?.prg", dir_2, 1
	assertUserInput "l?.prg", dir_3, 1
	assertUserInput "l?.prg", dir_4, 0
	assertUserInput "l?.prg", dir_13, 0
		
	assertUserInput "l**.prg", dir_2, 1
	assertUserInput "l**.prg", dir_3, 1
	assertUserInput "l**.prg", dir_4, 1
	;assertUserInput "l**.prg", dir_13, 0  ; TODO FIXME
	
	assertUserInput "l??.prg", dir_2, 1
	assertUserInput "l??.prg", dir_3, 1
	assertUserInput "l??.prg", dir_4, 0
	assertUserInput "l??.prg", dir_13, 0
	
	assertUserInput ".", dir_8, 1
	assertUserInput ".", dir_9, 0
	
	assertUserInput "..", dir_8, 0
	assertUserInput "..", dir_9, 1
	
	assertUserInput "*.*", dir_1, 1
	assertUserInput "*.*", dir_2, 1
	assertUserInput "*.*", dir_3, 1
	assertUserInput "*.*", dir_4, 1
	assertUserInput "*.*", dir_5, 1
	assertUserInput "*.*", dir_6, 1
	assertUserInput "*.*", dir_7, 1
	assertUserInput "*.*", dir_8, 1
	assertUserInput "*.*", dir_9, 1
	assertUserInput "*.*", dir_10, 1
	assertUserInput "*.*", dir_11, 1
	assertUserInput "*.*", dir_12, 1
	assertUserInput "*.*", dir_13, 1
	
	assertUserInput "*.prg", dir_2, 1
	assertUserInput "*.prg", dir_3, 1
	assertUserInput "*.prg", dir_4, 1
	assertUserInput "*.prg", dir_5, 1
	
;	assertUserInput "FI*ONA*I.P*G", dir_5, 1 ; TODO FIXME
	assertUserInput "FI?ONA?I.P?G", dir_5, 1
	
	brk
	
dir_1:	     .byte "A       TXT"
dir_2:	     .byte "LL      PRG"	;2
dir_3:	     .byte "LS      PRG"	;4
dir_4:	     .byte "LOADER  PRG"	;6
dir_5:	     .byte "FIBONACIPRG"	;8
dir_6:	     .byte "TESTZME TXT"	;10
dir_7:	     .byte "PROGS      "	;12
dir_8:	     .byte ".          "	;14
dir_9:	     .byte "..         "	;16
dir_10:	     .byte ".SSH       "	;18
dir_11:	     .byte "..FOO      "	;20
dir_12:	     .byte "1          "	;22
dir_13:	     .byte "LIST0001DB "	;24

input_1:	;	.byte 0,0,1,0,0,0,0,0,0,0,0,0,0 ;expected result - 0 - no match, 1 - match - eg. 0,0,1 mean matches "LS        PRG" from dir_3
			.byte "ls.prg",0        	;user input
input_2: ;	.byte 0,1,1,1,0,0,0,0,0,0,0,0,0
			.byte "l*.prg",0
input_3: ;	.byte 0,1,1,0,0,0,0,0,0,0,0,0,0
			.byte "l?.prg",0
input_4: ;	.byte 0,1,1,1,0,0,0,0,0,0,0,0,0
			.byte "l**.prg",0
input_5: ;	.byte 0,1,1,0,0,0,0,0,0,0,0,0,0
			.byte "l??.prg",0
input_6: ;	.byte 0,1,1,1,0,0,0,0,0,0,0,0,0
			.byte "l?????.PRG",0
input_7: ;	.byte 0,0,1,0,0,0,0,0,0,0,0,0,0
			.byte "Ls.PrG",0
input_8: ;	.byte 0,0,0,0,0,0,0,1,0,0,0,0,0
			.byte ".",0
input_9: ;	.byte 0,0,0,0,0,0,0,0,1,0,0,0,0
			.byte "..",0
input_10: ;	.byte 1,1,1,1,1,1,1,1,1,1,1,1,1
			.byte "*.*",0
input_11: 	;.byte 0,0,0,0,0,1,0,0,0,0,0,0,0
			.byte "testzme.txt",0
input_12: 	;.byte 0,0,0,0,0,0,1,0,0,0,0,0,0
			.byte "progs",0
input_13: 	;.byte 0,0,0,0,0,0,0,0,0,1,0,0,0
			.byte ".ssh",0
input_14: 	;.byte 0,0,0,0,0,0,0,0,0,0,1,0,0
			.byte "..foo",0
input_15: 	;.byte 0,1,1,1,0,0,0,0,0,0,0,0,1
			.byte "l*.*",0
input_16: 	;.byte 1,0,0,0,0,0,0,0,0,0,0,0,0
			.byte "a.*",0
input_17: 	;.byte 0,1,1,1,0,0,0,0,0,0,0,0,0
			.byte "l*.p*",0
input_18: 	;.byte 0,0,1,0,0,0,0,0,0,0,0,0,0
			.byte "ls",0
input_19: ;	.byte 0,0,0,0,0,0,0,0,0,0,0,1,0
			.byte "1",0
input_20: 	;.byte 0,1,1,1,1,0,0,0,0,0,0,0,0
			.byte "*.prg",0
input_21: ;	.byte 0,0,0,0,1,0,0,0,0,0,0,0,0
			.byte "FIBONACI.PRG",0
input_22: ; .byte 0,0,0,0,1,0,0,0,0,0,0,0,0
			.byte "FI*ONA*I.P*G",0
input_23: ;	.byte 0,1,1,1,0,0,0,0,0,0,0,0,1
			.byte "l*",0
input_24: ;	.byte 0,0,1,0,0,0,0,0,0,0,0,0,0
			.byte "ls*",0			

.segment "ASMUNIT"