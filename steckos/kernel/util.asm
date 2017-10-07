; enable debug for this module
.ifdef DEBUG_UTIL
	debug_enabled=1
.endif
.include	"kernel.inc"
.include	"fat32.inc"
.include	"errno.inc"
.segment "KERNEL"
.export string_fat_name, fat_name_string, put_char
.export string_fat_mask
.export dirname_mask_matcher

		; in:
		;	dirptr pointer to dir entry
dirname_mask_matcher:
		ldy #10 ;.sizeof(F32DirEntry::Name) + .sizeof(F32DirEntry::Ext) - 1
__dmm:	lda fat_dirname_mask, y
		cmp #'?'
		beq __dmm_next
		cmp (dirptr), y
		bne __dmm_neq
__dmm_next:
		dey
		bpl __dmm
		sec
		rts
__dmm_neq:
		clc
		rts
		
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
		bcc	l_1					; skip all chars within 0..32
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
	;	filenameptr pointer to input string to convert to fat file name mask
	;	krn_ptr2 pointer to result of fat file name mask
	; out:
	;	fat_dir_entry_tmp with the mask build upon input string
	;	C=1 if input was too large (>255 byte), C=0 otherwise
	;	Z=1 if input was empty string, Z=0 otherwise
string_fat_mask:
	jsr string_trim					; trim input
	bcs __tfm_exit					; C=1, overflow
	beq __tfm_exit					; Z=1, empty input	

	stz krn_tmp
	ldy #0
__tfn_mask_input:
	sty krn_tmp2
	ldy krn_tmp
	lda (filenameptr), y
	beq __tfn_mask_fill_blank
	inc krn_tmp
	cmp #'.'
	bne __tfn_mask_qm
	ldy krn_tmp2
	beq __tfn_mask_char_l2			; first position, we capture the "."
	cpy #8							; reached from here from first fill (the name) ?
	beq __tfn_mask_input
	cpy #1							; 2nd position?
	bne __tfn_mask_fill_blank		; no, fill section
	cmp	(krn_ptr2)					; otherwise check whether we already captured a "." as first char
	beq __tfn_mask_char_l2
__tfn_mask_fill_blank:
	lda #' '
	bra __tfn_mask_fill
__tfn_mask_qm:
	cmp #'?'
	bne __tfn_mask_star
	sec								; save only 1 char in fill
	bra __tfn_mask_fill_l1
__tfn_mask_star:
	cmp #'*'
	bne __tfn_mask_char
	lda #'?'	
__tfn_mask_fill:
	clc
__tfn_mask_fill_l1:
	ldy krn_tmp2
__tfn_mask_fill_l2:	
	sta (krn_ptr2), y
	iny
	bcs __tfn_mask_input			; C=1, then go on next char
	cpy #8
	beq __tfn_mask_input		; go on with extension
	cpy #8+3
	bne __tfn_mask_fill_l2
__tfm_exit:	
	rts
__tfn_mask_char:
	cmp #$60 ; Is lowercase?
	bcc __tfn_mask_char_l1
	and	#$DF
__tfn_mask_char_l1:
	ldy krn_tmp2
__tfn_mask_char_l2:
	sta (krn_ptr2), y
	iny 
	cpy #8+3
	bne __tfn_mask_input
	rts

	; fat name to string by reference
	; in:
	;	krn_ptr2	- pointer to result string
	;	krn_tmp2	- offset from krn_ptr2 (result string)
	; out:
	;	
fat_name_string:
	ldy #0
@l0:
	cpy #11
	beq @l_exit
	sty krn_tmp
	lda	(dirptr), y
	cmp #' '
	beq @l_skip
	jsr put_char
@l_skip:
	ldy krn_tmp
	iny
	cpy #8
	bne @l0
	lda #'.'
	phy 
	jsr put_char
	ply
	bra @l0
@l_exit:
	rts

put_char:
	ldy krn_tmp2
	sta (krn_ptr2), y
	inc krn_tmp2
	debug8 "t2", krn_tmp2
	debug16 "p2", krn_ptr2
	rts
	
	; build 11 byte fat file name (8.3) as used within dir entries 
	; in:
	;	filenameptr with input string to convert to fat file name mask
	;	krn_ptr2 with pointer where the fat file name mask should be stored
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