;	*.*	- matches any file or directory with extension
;	*	- matches any file or directory without extension
_CHARS_BLACKLIST:
;	.asciiz ".*+,/:;<=>?\[]|"
;	matcher_see https://en.wikipedia.org/wiki/8.3_filename
; 				match input name[.[ext]] against 11 byte dir entry <name><ext>
matcher:
				ldx	#0
matcher_prepareinput:
				lda	filename_buf,x
				beq	matcher_prepare1
				sta	buffer,x
				inx	
				bne	matcher_prepareinput
matcher_prepare1:		lda	#' '			;set end of string to ' '
				sta	buffer,x
				stx	krn_tmp 		;safe end of string
				lda	#'.'
matcher_prepare2:		dex
				bmi	matcher_prepare3	;x underrun?
				cmp	buffer,x		;go from end of string to start, search for '.'
				bne	matcher_prepare2
				cmp	buffer			;starts with '.'
				beq	matcher_prepare3	;yes, do no extension match
				lda	#' '			;no, replace with the end of string at this position ' '
				sta 	buffer,x
				inx
				bra	matcher_prepare4
matcher_prepare3:
				ldx	krn_tmp			; no '.' found, skip extension match set x to end of string which is ' ' for the matcher below
matcher_prepare4:
				lda	#8+3			; end of string is byte 11 of dir filename entry
				sta	krn_tmp
				ldy	#7				; y index to offset of file extension at dirptr
				jsr	matcher_NEXT			; match the extension, x is already set above
				bcc	matcher_FAIL			;  no, exit if extension did not match				
matcher_match_name:		
				LDX #$00			;  yes, now match the filename
				LDY #$FF        	; Y is an index in the string
				lda #8				; end of string match is file name
				sta krn_tmp				
matcher_NEXT:    		
				LDA buffer,X   	; Look at next pattern character
				CMP #'*'		; Is it a star?
				BEQ matcher_STAR        ; Yes, do the complicated stuff
				INY             ; No, let's look at the string
				cpy krn_tmp		 ;end of dir entry?
				beq matcher_FOUND
				cmp #' '			 ; pattern end?
				BNE matcher_quest		 ;  no
				cmp (dirptr),y   	 ;  expect space in dir name, marks end of string within dir entry
				bne matcher_FAIL
				rts				 ; found, succes C=1 here
matcher_quest:	CMP #'?'	     ; Is the pattern caracter a ques?
				BNE matcher_REG         ; No, it's a regular character
				LDA (dirptr),Y     ; Yes, so it will match anything
				BEQ matcher_FAIL        ;  except the end of string
matcher_REG:	cmp	#'a'			; char [a-z] ?
				bcc matcher_cmp
				cmp #'z'
				bcs matcher_cmp
				and #$df			; uppercase
matcher_cmp:	CMP (dirptr),Y     ; Are both characters the same?
				BNE matcher_FAIL        ; No, so no match
				INX             ; Yes, keep checking
				CMP #0			; Are we at end of string?
				BNE matcher_NEXT        ; Not yet, loop
matcher_FOUND:  RTS             ; Success, return with C=1

matcher_STAR:   INX             ; Skip star in pattern
				CMP buffer,X   ; String of stars equals one star
				BEQ matcher_STAR        ;  so skip them also
matcher_STLOOP:  			             ; We first try to match with * = ""
				phx             ;  and grow it by 1 character every
				phy             ; Save X and Y on stack
				JSR matcher_NEXT        ; Recursive call
				ply             ; Restore X and Y
				plx
				BCS matcher_FOUND       ; We found a match, return with C=1
				INY             ; No match yet, try to grow * string
				LDA (dirptr),Y     ; Are we at the end of string?
				cmp #' '
				BNE matcher_STLOOP      ; Not yet, add a character
matcher_FAIL:    		CLC             ; Yes, no match found, return with C=0
				RTS