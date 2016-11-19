; 				match input name[.[ext]] against 11 byte dir entry <name><ext>
match2:
				stz krn_tmp			; 0 means without extension
				ldx #0
prepareinput:	lda	filename_buf,x
				beq	@prepare_end
				cmp	#'.'
				bne	@store
				stx krn_tmp			; save the offset of the '.'
@store:			sta buffer,x
				inx
				bne	prepareinput	;no, next char
@prepare_end:	sta buffer,x		;\0 term buffer
				
				lda krn_tmp			; '.' found in input and position >0 ?
				bne	@match_ext		; no, match the filename with extension
				bra @match_ext_1	; yes, match the filename and extension must be "", x already points to \0 from loop above
@match_ext:		tax
				lda	buffer			; input starts with '.' ?
				cmp	#'.'			
				beq	@match_ext_0	; yes, skip the '.'
				stz	buffer,x		; no, replace '.' with end of string
@match_ext_0:	inx					; inc x to next char after the '.'
@match_ext_1:	ldy	#7				; y index to offset of file extension at dirptr
				jsr	@NEXT			; match the extension
				bcc	@FAIL			;  no, exit if extension did not match				
@match_name:	LDX #$00			;  yes, now match the filename
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
				cmp (dirptr),y   ;  expect space in dir name, marks end of string
				bne	@FAIL
				rts				 ; found, succes C=1 here
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