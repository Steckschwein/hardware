	.include "assertion.inc" 	; test api
	
	.include "common.inc"
	.include "zeropage.inc"
	
	.include "fat32.inc"
	
	.import string_fat_mask
	.import dirname_mask_matcher	; uut
	
.segment "KERNEL"	; test must be placed into kernel segment, cuz we wanna use the same linker config

	SetVector fat_dirname_mask, krn_ptr2	; ouput
	
	SetVector input_1, filenameptr
	jsr string_fat_mask
	
	SetVector dir_1, dirptr
	jsr dirname_mask_matcher
	assertCarry 0
	assertZero 1
		
	SetVector dir_2, dirptr
	jsr dirname_mask_matcher
	assertCarry 0
	assertZero 1
	
	SetVector dir_3, dirptr
	jsr dirname_mask_matcher
	assertZero 1
;	assertCarry 1
	
	brk

test_dirs=13
expected_result: .res 32;   pointer of input + size of results (input_X + test_dirs)

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

input_1:	;.byte 0,0,1,0,0,0,0,0,0,0,0,0,0 ;expected result - 0 - no match, 1 - match - eg. 0,0,1 mean matches "LS        PRG" from dir_3
			.byte "ls.prg",0        	;user input
input_2: 	.byte 0,1,1,1,0,0,0,0,0,0,0,0,0
			.byte "l*.prg",0
input_3: 	.byte 0,1,1,0,0,0,0,0,0,0,0,0,0
			.byte "l?.prg",0
input_4: 	.byte 0,1,1,1,0,0,0,0,0,0,0,0,0
			.byte "l**.prg",0
input_5: 	.byte 0,1,1,0,0,0,0,0,0,0,0,0,0
			.byte "l??.prg",0
input_6: 	.byte 0,1,1,1,0,0,0,0,0,0,0,0,0
			.byte "l?????.PRG",0
input_7: 	.byte 0,0,1,0,0,0,0,0,0,0,0,0,0
			.byte "Ls.PrG",0
input_8: 	.byte 0,0,0,0,0,0,0,1,0,0,0,0,0
			.byte ".",0
input_9: 	.byte 0,0,0,0,0,0,0,0,1,0,0,0,0
			.byte "..",0
input_10: 	.byte 1,1,1,1,1,1,1,1,1,1,1,1,1
			.byte "*.*",0
input_11: 	.byte 0,0,0,0,0,1,0,0,0,0,0,0,0
			.byte "testzme.txt",0
input_12: 	.byte 0,0,0,0,0,0,1,0,0,0,0,0,0
			.byte "progs",0
input_13: 	.byte 0,0,0,0,0,0,0,0,0,1,0,0,0
			.byte ".ssh",0
input_14: 	.byte 0,0,0,0,0,0,0,0,0,0,1,0,0
			.byte "..foo",0
input_15: 	.byte 0,1,1,1,0,0,0,0,0,0,0,0,1
			.byte "l*.*",0
input_16: 	.byte 1,0,0,0,0,0,0,0,0,0,0,0,0
			.byte "a.*",0
input_17: 	.byte 0,1,1,1,0,0,0,0,0,0,0,0,0
			.byte "l*.p*",0
input_18: 	.byte 0,0,1,0,0,0,0,0,0,0,0,0,0
			.byte "ls",0
input_19: 	.byte 0,0,0,0,0,0,0,0,0,0,0,1,0
			.byte "1",0
input_20: 	.byte 0,1,1,1,1,0,0,0,0,0,0,0,0
			.byte "*.prg",0
input_21: 	.byte 0,0,0,0,1,0,0,0,0,0,0,0,0
			.byte "FIBONACI.PRG",0
input_22: 	.byte 0,0,0,0,1,0,0,0,0,0,0,0,0
			.byte "FI*ONA*I.P*G",0
input_23: 	.byte 0,1,1,1,0,0,0,0,0,0,0,0,1
			.byte "l*",0
input_24: 	.byte 0,0,1,0,0,0,0,0,0,0,0,0,0
			.byte "ls*",0
			
test_dir_tab:
	.word dir_1
	.word dir_2
	.word dir_3
	.word dir_4
	.word dir_5
	.word dir_6
	.word dir_7
	.word dir_8
	.word dir_9
   .word dir_10
   .word dir_11
   .word dir_12
	.word dir_13
test_dir_tab_e:

Println:
    lda #$0a
    jmp _test_out

.macro SetTestInput input
   lda #<(input+test_dirs)
	sta testinput+1
	sta filenameptr
	
    lda #<input
    sta a5+1
    ;high bytes
    lda #>(input+test_dirs)
	sta testinput+2
	sta filenameptr+1
	
    lda #>input
    sta a5+2
	;sta a50+2
.endmacro

test_suite:
    SetTestInput input_1
    jsr test
	 rts
    SetTestInput input_1
    jsr test
    SetTestInput input_2
    jsr test
    SetTestInput input_3
    jsr test
	 SetTestInput input_4
	 jsr test
    SetTestInput input_5
    jsr test
    SetTestInput input_6
    jsr test
    SetTestInput input_7
    jsr test
    SetTestInput input_8
    jsr test
    SetTestInput input_9
    jsr test
    SetTestInput input_10
    jsr test
    SetTestInput input_11
    jsr test
    SetTestInput input_12
    jsr test
    SetTestInput input_13
    jsr test
    SetTestInput input_14
    jsr test
    SetTestInput input_15
    jsr test
    SetTestInput input_16
    jsr test
    SetTestInput input_17
    jsr test
    SetTestInput input_18
    jsr test
    SetTestInput input_19
    jsr test
    SetTestInput input_20
    jsr test
    SetTestInput input_21
    jsr test
    SetTestInput input_22
    jsr test
    SetTestInput input_23
    jsr test
    SetTestInput input_24
    jsr test
    
	jmp (retvec)
    
test:
			jsr Println
			ldx #0
			ldy #0
l1:
			lda test_dir_tab,x
			sta dirptr
			lda test_dir_tab+1,x
			sta dirptr+1
    
			phx
			phy
			jsr dirname_mask_matcher
			ply
			plx
			lda	#0
			rol			;result in carry to bit 0	
			jsr _hexout
a5:		cmp	expected_result, y
			bra _next
_failed:
			assertOut "FAIL"
_next:
			iny
			inx
			inx
			cpx	#(test_dir_tab_e-test_dir_tab)
			bne	l1
			lda #' '
			jsr _test_out
			ldy	#0
testinput:	
			lda	expected_result, y
			beq	@oe
			jsr _test_out
			iny
			bne testinput
@oe:		rts

	.include "asmunit.asm"
