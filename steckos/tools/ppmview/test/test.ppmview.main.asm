	.include "asmunit.inc" 	; test api
	
	.include "common.inc"
	.include "errno.inc"
	.include "zeropage.inc"

	.importzp ptr2

	.import parse_header	
	.import byte_to_grb
	
	.import asmunit_chrout
	.export char_out=asmunit_chrout	; TODO FIXME causes a linker warning

.export ppmdata
.export ppm_width
.export ppm_height

.macro test label
	test_name label
	stz ppm_width
	stz ppm_height
.endmacro

.code

	test "parse_header not ppm"	
	jsr parse_header
	assertZero 0		;error
	assertA $ff
	
	test "parse_header height"
	m_memcpy test_ppm_header_height, ppmdata, 16
	jsr parse_header
	assertZero 0		;error
	assertA $ff

	test "parse_header valid"
	m_memcpy test_ppm_header, ppmdata, 16
	jsr parse_header
	assertZero 1		;
	assertA 0
	assert8 <256, ppm_width
	assert8 171, ppm_height
	
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

test_ppm_header:
	.byte "P6",$0a,"256 171",$0a,"255",$0a
test_ppm_header_height:
	.byte "P6",$0a,"256 193",$0a,"255",$0a

test_ppm_data:	; ppm RGB => GRB 3,3,2
	.byte $0, $0, $0		;0
	.byte $ff, $ff, $ff	;$ff
	.byte $e0, $e0, $c0	;$ff
	.byte $40, $40, $40	;$49
	.byte $80, $40, $40	;$51

	
ppm_width: .res 1, 0
ppm_height: .res 1, 0 
ppmdata: .res 32,0
.segment "ASMUNIT"