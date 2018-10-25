	.include "asmunit.inc" 	; test api
	
	.include "common.inc"
	.include "errno.inc"
	.include "zeropage.inc"

	.importzp ptr2

	.import parse_header	
	.import byte_to_grb
	
	.import asmunit_chrout
	.export char_out=asmunit_chrout	; TODO FIXME causes a linker warning


; from ppmview	
.export ppmdata
.export ppm_width
.export ppm_height

.macro test label
	test_name label
	stz ppm_width
	stz ppm_height
.endmacro

.code

;-------------	
	test "parse_header valid"
	m_memcpy test_ppm_header_valid, ppmdata, 16
	jsr parse_header
	assertZero 1		;
	assertA 0
	assert8 <256, ppm_width
	assert8 212, ppm_height

;-------------	
	test "parse_header not ppm"	
	m_memcpy test_ppm_header_notppm, ppmdata, 16
	jsr parse_header
	assertZero 0		;error
	assertA $ff
	
;-------------	
	test "parse_header wrong height"
	m_memcpy test_ppm_header_wrong_height, ppmdata, 16
	jsr parse_header
	assertZero 0		;error
	assertA $ff

;-------------	
	test "parse_header wrong depth"
	m_memcpy test_ppm_header_wrong_depth, ppmdata, 16
	jsr parse_header	
	assertZero 0		;error
	assertA $ff
	
;-------------	
	test "parse_header with comment"
	m_memcpy test_ppm_header_comment, ppmdata, 127
	jsr parse_header
	assertZero 1		;
	assertA 0
	assert8 <256, ppm_width
	assert8 192, ppm_height	
	
	test "byte_to_grb"
 	SetVector ppmdata, read_blkptr
	m_memcpy test_ppm_data, ppmdata, 32
	
	ldy #0
	jsr byte_to_grb
	assertA 0

	jsr byte_to_grb
	assertA $ff
	
	jsr byte_to_grb
	assertA $ff
	
	jsr byte_to_grb
	assertA $49

	jsr byte_to_grb
	assertA $51
	
	jsr byte_to_grb
	assertA $ba

	brk

.export krn_primm=mock
.export vdp_bgcolor=mock
.export hexout=mock
.export vdp_display_off=mock
.export vdp_gfx7_on=mock
.export krn_open=mock, krn_fread=mock, krn_close=mock
.export krn_textui_enable=mock
.export krn_textui_disable=mock
.export krn_textui_init=mock
.export krn_display_off=mock
.export krn_getkey=mock

mock:
	rts

test_ppm_header_valid:
	.byte "P6",$0a,"256 212",$0a,"255",$0a
test_ppm_header_notppm:
	.byte "P3",$0a,"256 171",$0a,"255",$0a
test_ppm_header_wrong_height:
	.byte "P6",$0a,"256 213",$0a,"255",$0a
test_ppm_header_wrong_depth:
	.byte "P6",$0a,"256 212",$0a,"65535",$0a
test_ppm_header_comment:
	.byte "P6",$0a,"#Compressed with JPEG Optimizer 4.00, www.xat.com",$0a,"#comment 2",$0a,"256 192",$0a,"255",$0a

test_ppm_data:	; ppm RGB => GRB 3,3,2
	.byte $0, $0, $0		;0
	.byte $ff, $ff, $ff	;$ff
	.byte $e0, $e0, $c0	;$ff
	.byte $40, $40, $40	;$49
	.byte $80, $40, $40	;$51
	.byte $d6, $b5, $81	;$ba

	
ppm_width: .res 1, 0
ppm_height: .res 1, 0 
ppmdata: .res 32,0
.segment "ASMUNIT"