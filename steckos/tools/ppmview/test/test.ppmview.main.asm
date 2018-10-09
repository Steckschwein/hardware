	.include "asmunit.inc" 	; test api
	
	.include "common.inc"
	.include "errno.inc"
	.include "zeropage.inc"
	
	.import parse_header
	
;.import asmunit_chrout
;krn_chrout=asmunit_chrout
;.export krn_chrout

.export ppmdata
.export ppm_width
.export ppm_height

.code
	test_name "parse_header not ppm"
	
	jsr parse_header
	assertZero 0		;error
	assertA $ff
	
	test_name "parse_header ppm"
	m_memcpy ppm_header, ppmdata, 16
	jsr parse_header
	assertZero 1		;
	assertA 0
	assert8 <256, ppm_width
	assert8 171, ppm_height
	
	brk

.export vdp_bgcolor=mock
.export hexout=mock
.export vdp_display_off=mock
.export vdp_gfx7_on=mock
	
mock:
	rts

ppm_header:
	.byte "P6",$0a,"256 171",$0a,"255"

ppmdata: .res 32,0
ppm_width: .res 1, 0
ppm_height: .res 1, 0 
.segment "ASMUNIT"