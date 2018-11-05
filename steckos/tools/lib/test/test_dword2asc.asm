.include "asmunit.inc" 	; unit test api

.import dword2asc
.import char_out

.code
	
	test "dword2asc"

    ldx #<operand
    ldy #>operand

    ; binary
	lda	#'%'
    ora #%10000000

    jsr dword2asc
    assertA 32  ; 32 digits

    stx $0a
    sty $0b
    ldy #0
@l1:
    lda ($0a),y
    jsr char_out
    iny
    cpy #32
    bne @l1

    assertOut "11011110101011011011111011101111"

    ldx #<operand
    ldy #>operand

    ; octal
	lda	#'@'

    jsr dword2asc
    assertA 12  ; 11 digits + "@"

    stx $0a
    sty $0b
    ldy #0
@l2:
    lda ($0a),y
    jsr char_out
    iny
    cpy #12
    bne @l2

    assertOut "@33653337357"

    ldx #<operand
    ldy #>operand

    ; hex
	lda	#'$'

    jsr dword2asc
    assertA 9  ; 8 digits + "$"

    stx $0a
    sty $0b
    ldy #0
@l3:
    lda ($0a),y
    jsr char_out
    iny
    cpy #9
    bne @l3

    assertOut "$DEADBEEF"

    ldx #<operand
    ldy #>operand

    ; decimal
	lda	#' '

    jsr dword2asc
    assertA 10

    stx $0a
    sty $0b
    ldy #0
@l4:
    lda ($0a),y
    jsr char_out
    iny
    cpy #10
    bne @l4

    assertOut "3735928559"




	brk
operand:
    .dword $deadbeef
.segment "ASMUNIT"
