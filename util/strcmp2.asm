dir_entry_size=11

; 				match input name[.[ext]] against 11 byte dir entry <name><ext>
match2:
				ldx #0
				ldy	#0
				phx					; 0 to stack, means match without extension
uppaercase:		lda	test_input,x
				cmp	#'.'
				bne	@store
				plp					; pop and ignore
				phx					; save the x offset
@store:			sta buffer,y
				iny
				inx
				cmp	#0
				bne	uppaercase		;no, next char
				plx
				beq	@patternmatch	; no extension or only extension pattern, match the hole filename
				lda	buffer			; x must be >=1 here
				cmp	#'.'			; starts with '.'
				beq	@skip_dots
				stz	buffer,x		; replace '.' with end of string
@skip_dots:		inx					; inc x, it has last index of '.'
				ldy	#7				; y index to offset of file extension at dirptr
				jsr	@NEXT			; match the extension
				bcc	@FAIL			;  no, exit if extension did not match
@patternmatch:	LDX #$00			;  yes, now match the filename
				LDY #$FF        ; Y is an index in the string
@NEXT:    		LDA buffer,X   	; Look at next pattern character
				CMP #'*'		; Is it a star?
				BEQ @STAR        ; Yes, do the complicated stuff
				INY             ; No, let's look at the string
				cpy	#8+3		 ;end of dir entry?
				beq @FOUND
				cmp	#0			 ; pattern end?
				BNE @quest		 ;  no
				lda	#' '		 ;  yes
				cmp (dirptr),y   ;  expect space in dir name
				bne	@FAIL
				rts
@quest:			CMP #'?'	     ; Is the pattern caracter a ques?
				BNE @REG         ; No, it's a regular character
				LDA (dirptr),Y     ; Yes, so it will match anything
				BEQ @FAIL        ;  except the end of string
@REG:			cmp	#'a'			; char [a-z] ?
				bcc @cmp
				cmp #'z'
				bcs @cmp
				and #$df			; uppercase
@cmp:			CMP (dirptr),Y     ; Are both characters the same?
				BNE @FAIL        ; No, so no match
				INX             ; Yes, keep checking
				CMP #0			; Are we at end of string?
				BNE @NEXT        ; Not yet, loop
@FOUND:   		RTS             ; Success, return with C=1

@STAR:    		INX             ; Skip star in pattern
				CMP buffer,X   ; String of stars equals one star
				BEQ @STAR        ;  so skip them also
@STLOOP:  			             ; We first try to match with * = ""
				phx             ;  and grow it by 1 character every
				phy             ; Save X and Y on stack
				JSR @NEXT        ; Recursive call
				ply             ; Restore X and Y
				plx
				BCS @FOUND       ; We found a match, return with C=1
				INY             ; No match yet, try to grow * string
				LDA (dirptr),Y     ; Are we at the end of string?
				cmp	#' '
				BNE @STLOOP      ; Not yet, add a character
@FAIL:    		CLC             ; Yes, no match found, return with C=0
				RTS		
buffer: .res 8+1+3,0