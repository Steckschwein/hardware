.setcpu "65c02"
.org    $1000
    nop
	jmp	test_suite

.include "../bios/bios_call.inc"
.include "strcmp.asm"
.include "asm_unit.asm"

test_dirs=9
test_input=*;   input_X + test_dirs; address of input + size of results

.macro Println
    lda #13
    jsr vdp_chrout
    lda #10
    jsr vdp_chrout    
.endmacro

.macro SetTestInput input
    lda #<input+test_dirs
    sta a0+1
    sta a1+1
    sta a2+1
    sta a3+1
    sta a4+1
    lda #<input
    sta a5+1
    lda #>input+test_dirs
    sta a0+2
    sta a1+2
    sta a2+2
    sta a3+2
    sta a4+2
    lda #>input
    sta a5+2
.endmacro

test_suite:    
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
    rts    
    
test:
    Println
	ldx #0
	ldy #0
l1:
	lda test_dir_tab,x
	sta dirptr
	lda test_dir_tab+1,x
	sta dirptr+1
    
	phx
	phy
	jsr match	; check <name>.<ext> against 11 byte dir entry <name> <ext>
	ply
	plx		
	lda	#0
	rol			;result in carry to bit 0	
a5:	cmp	test_input, y
	bne	_failed
	jsr	_test_ok
    bra _ok
_failed:
	;failed with 'y'
	jsr	_test_failed
_ok:
	iny
	inx
	inx
	cpx	#test_dir_tab_e-test_dir_tab
	bne	l1	
	rts
		
dir_1:	     .byte "FILE00  TXT"
dir_2:	     .byte "LL      BIN"	;2
dir_3:	     .byte "LS      BIN"	;4
dir_4:	     .byte "LOADER  BIN"	;6
dir_5:	     .byte "FILE04  TXT"	;8
dir_6:	     .byte "TEST    TXT"	;10
dir_7:	     .byte "PROGS      "	;12
dir_8:	     .byte ".          "	;14
dir_9:	     .byte "..         "	;16

input_1: 	.byte 0,0,1,0,0,0,0,0,0 ;expected result - 0 - no match, 1 - match - eg. 0,0,1 mean matches "LS        BIN" from dir_3
			.byte "ls.bin",0        ;user input
input_2: 	.byte 0,1,1,1,0,0,0,0,0
			.byte "l*.bin",0
input_3: 	.byte 0,1,1,0,0,0,0,0,0
			.byte "l?.bin",0
input_4: 	.byte 0,1,1,1,0,0,0,0,0
			.byte "l**.bin",0
input_5: 	.byte 0,0,0,0,0,0,0,0,0
			.byte "l??.bin",0
input_6: 	.byte 0,0,0,1,0,0,0,0,0
			.byte "l?????.bin",0
input_7: 	.byte 0,0,1,0,0,0,0,0,0
			.byte "Ls.bin",0
input_8: 	.byte 0,0,0,0,0,0,0,1,0
			.byte ".",0
input_9: 	.byte 0,0,0,0,0,0,0,0,1
			.byte "..",0
input_10: 	.byte 0,0,0,0,0,0,0,0,0
			.byte "test.txtfoobar",0
input_11: 	.byte 0,0,0,0,0,1,0,0,0
			.byte "test.txt",0
input_12: 	.byte 0,0,0,0,0,0,1,0,0
			.byte "progs",0

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
test_dir_tab_e: