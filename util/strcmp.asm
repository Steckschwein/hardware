dir_entry_size=11
krn_tmp=$a0

match2:
				lda	test_input		;empty input?
				beq	m_not_found
				
				ldx #0
				ldy	#0
@0:				lda	test_input,x	; skip leading dots
				beq	<compare>
				cmp	#'.'
				bne	@uppercase_0
				sta buffer,y
				inx
				iny
				cpx	#2
				bne	@0				;go on, there may other chars still left
@uppercase:		lda	test_input,x
				beq	<compare>
@uppercase_0:	cmp	#'.'
				beq	@fill_name_space
				cmp	#'*'
				beq	@fill_name_wildcard
				cmp	#'a'			; regular char, match uppercase
				bcc @uppercase_1
				cmp #'z'
				bcs @uppercase_1
				and #$df			; uppercase
@uppercase_1:	sta buffer,y
				inx
				iny
				cpx	#8+3+1
				bne	@0
				bra	m_not_found		; 8.3 overflow
				
@fill_name_wildcard:
				lda #'?'
				bra	@fill_name
@fill_name_space:
				lda	#' '
@fill_name:		sta	buffer,y
				iny
				cpy	#8
				bne	@fill_name
				inx	; skip the 		; l*l.bin
				
				
@cdpd_or_ext:	
				cpx	#0				; file starts with '.'
				beq	@cdpd_0			; handle cd or pd
				bra	@ext_0			; handle ext - skip the dot, not used during compare

@cdpd:			lda	test_input,x
				beq	<compare>
@cdpd_0:	
				sta	buffer,y
				iny
				inx
				cpx	#8+3+1
				bne	@cdpd
				bra m_not_found
				
@ext:			lda	test_input,x
				beq	<compare>
				sta	buffer,y
				iny
@ext_0:			inx
				cpx	#8+3+1
				bne	@ext
				bra m_not_found				


match:
	ldx #0
	ldy #0

	; 0..1 in input may be "." or "..", so compare dir entry with .
match_skip_dots:
	lda	#'.'
a0:	cmp	test_input,x
	bne	match_0

	cmp (dirptr),y
	bne m_not_found
	inx					; 2nd "." ?
	iny
a1:	lda	test_input,x
	bne	match_skip_dots_1 ; end of input ?
	lda	#' '
	cmp (dirptr),y
	bne m_not_found
match_skip_dots_1:
	cpy #02
	bne match_skip_dots
	bra	match_ext_0
	
match_0:
a2:	lda test_input,x
	beq m_not_found		;end of input, not found
match_0_d:
	cmp #'*'
	beq m_n
	cmp #'?'
	beq m_1			; ? found - skip compare, matches anything - note: multiple ? will end up in consuming the input string char by char until ' '
	cmp #'.'		; . found
	bne m_r

	inx
match_ext_0:
	lda #' '		; seek to dir entry extension offset	
match_ext:
	cmp (dirptr),y
	bne match_0
match_ext_1:
	iny
	cpy #dir_entry_size
	beq	m_found		; end of dir?
	bra	match_ext
	
m_r:
    cmp	#'a'		; regular char, match uppercase
	bcc m_r_match
	cmp #'z'
	bcs m_r_match
	and #$df		; uppercase
m_r_match:
	cmp (dirptr),y	; regular char, compare
	bne m_not_found
m_1:
	inx
	iny
	cpy #dir_entry_size
	bne match_0
	
a3:
    lda test_input,x	;input chars left?
	beq m_found
	bra m_not_found
	
m_n:
	inx
a4:
	cmp test_input,x	; skip read multiple '*'
	beq m_n
	
	lda #' '
m_n1:
	cmp (dirptr),y		; until ' '
	beq match_ext_1		; then go on with skip until extension above
m_n2:
	iny		
	cpy #dir_entry_size
	bne m_n1	; end of dir entry? found...
m_found:
	sec
 	rts
m_not_found:
	clc
 	rts
buffer: .res 8+3, 0