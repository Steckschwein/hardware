.include	"zeropage.inc"
.include	"fat32.inc"
.include	"errno.inc"
.segment "KERNEL"
.export string_fat_name
.export string_fat_mask

	; trim string, remove leading and trailing white space
	; in:
	;	filenameptr with input string to trim
	; out:
	;	the trimmed string at filenameptr
	;	Z=0 and A=length of string, Z=1 if string was trimmed to empty string (A=0)
	;	C=1 on string overflow, means input >255 byte
string_trim:
		stz	krn_tmp
		stz krn_tmp2
l_1:
		ldy	krn_tmp
		inc	krn_tmp
		lda	(filenameptr),	y
		beq	l_2
		cmp	#' '+1			
		bcc	l_1					; 0..32 skip control chars and ' '
l_2:	ldy	krn_tmp2
		sta	(filenameptr), y
		cmp	#0					; was end of string?
		beq	l_st_ex
		inc	krn_tmp2
		bne	l_1
		sec
		rts
l_st_ex:
		clc				;
		tya				; length to A
		rts	

	; build 11 byte fat file name (8.3) as used within dir entries 
	; in:
	;	krn_ptr1 pointer to result of fat file name mask
	;	filenameptr pointer to input string to convert to fat file name mask
	; out:
	;	fat_dir_entry_tmp with the mask build upon input string
	;	
	;	
string_fat_mask:
	jsr string_trim					; trim input
	bcs __tfm_exit					; overflow
	beq __tfm_exit					; empty input	

	stz krn_tmp
	stz krn_tmp2
__tfn_mask_input:
	ldy krn_tmp
	lda (filenameptr), y
	beq __tfn_mask_fill_blank
	inc krn_tmp
__tfn_mask_qm:
	cmp #'?'
	bne __tfn_mask_star
	sec								; save only 1 char in fill
	bra __tfn_mask_fill_l1
__tfn_mask_star:
	cmp #'*'
	bne __tfn_mask_dot
	lda #'?'
	bra __tfn_mask_fill
__tfn_mask_dot:
	cmp #'.'
	bne __tfn_mask_char
__tfn_mask_fill_blank:
	lda #' '
__tfn_mask_fill:
	clc
__tfn_mask_fill_l1:
	ldy krn_tmp2
	sta (krn_ptr1), y
	iny
	sty krn_tmp2
	bcs __tfn_mask_input			; C=1, then go on next char
	cpy #8
	beq __tfn_mask_extension		; go on with extension
	cpy #8+3
	bne __tfn_mask_fill_l1
__tfm_exit:	
	rts
__tfn_mask_char:
	cmp #'a'			; char [a-z] ?
	bcc __tfn_mask_char_l1
	cmp #'z'+1
	bcs __tfn_mask_char_l1
	and #$df			; uppercase
__tfn_mask_char_l1:	
	ldy krn_tmp2
	sta (krn_ptr1), y
	iny 
	sty krn_tmp2
	cpy #8+3
	bne __tfn_mask_input
	rts
__tfn_mask_extension:
	ldy krn_tmp
	lda (filenameptr),y
	beq __tfn_mask_fill_blank
	inc krn_tmp
	cmp #'.'
	bne __tfn_mask_qm
	bra __tfn_mask_input

	
	; build 11 byte fat file name (8.3) as used within dir entries 
	; in:
	;	filenameptr with input string to convert to fat file name mask
	;	krn_ptr1 with pointer where the fat file name mask should be stored
	; out:
	;	Z=1 on success and fat_dir_entry_tmp with the mask build upon input string
	;   Z=0 on error, the input string contains invalid chars not allowed within a dos 8.3. file name
string_fat_name:
	ldy #0
__sfn_ic:
	lda (filenameptr), y
	beq __sfn_mask
	jsr string_illegalchar
	bne __sfn_exit
	iny
	bne __sfn_ic
__sfn_mask:
	jsr string_fat_mask				;
	lda #0
__sfn_exit:	
	rts
	
	; in:
	;	A - char to check whether it is legal to build a fat file name or extension
	; out:
	;	Z=1 on success, Z=0 otherwise which input char is invalid
string_illegalchar:
	ldx #15					; size of blacklist
__illegalchar_l1:
	cmp __illegalchars, x
	beq __illegalchar_ex
	dex
	bpl __illegalchar_l1
	lda #0
	rts
__illegalchar_ex:	
	lda #EINVAL
	rts
__illegalchars:
	.byte "?*+,/:;<=>\[]|",'"',127