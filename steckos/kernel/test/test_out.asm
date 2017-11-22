.include "kernel_jumptable.inc"
.include "zeropage.inc"

.include "asmunit.inc"

.include "appstart.inc"
appstart $1000

		ldx #0
		ldy #0
		jsr krn_textui_crsxy
		
		assert8 "crs_x", 0, crs_x
		assert8 "crs_y", 0, crs_y
		
		assert16 "foo", 0, dirptr
			
		lda #0
		assertA 0
			
		lda #<text
		ldx #>text 
		jsr krn_strout
		
text:
	.byte "0123456789abcdefghijklmnopqrstuvwxyz", $0a, $0
