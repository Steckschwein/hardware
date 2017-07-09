
; 	match input name[.[ext]] (8.3 filename) against 11 byte dir entry <name><ext>
;	note:
;		*.*	- matches any file or directory with extension
;		*	- matches any file or directory without extension
;	in:
;		filename_buf the pattern to match the dir name via dirptr
filename_matcher:
				ldx #0
matcher_test1:	lda filename_buf,x
				cmp #'a'					; char [a-z] ?
				bcc matcher_prepare0		; no, we have to go the long way
				cmp #'z'+1
				bcs matcher_prepare0
				and #$df					; uppercase
				cmp (dirptr)				; match first byte?
				bne matcher_FAIL
				
matcher_prepare0:
				sta buffer,x
				inx
				cpx #8+1+3 +1				;buffer overflow?
				beq matcher_FAIL
matcher_prepareinput:
				lda filename_buf,x
				bne matcher_prepare0
matcher_prepare1:
				lda #' '					;set end of string to ' ', which means end of string in dir entry
				sta buffer,x
				lda #'.'
matcher_prepare2:
				dex							;walk back from end of string
				bmi matcher_match_name		;x underrun? means no '.' found, skip extension match, go to filename match
				cmp buffer,x				;is it a '.' ?
				bne matcher_prepare2		;no, go on
				cmp buffer					;yes, test whether input starts with '.'
				beq matcher_match_name		;yes, do no extension match, go to filename match
				lda #' '					;no,
				sta buffer,x				;replace the '.' with the end of string (' ')
				inx							;set x to the first char of the extension
				lda #8+3					;end of dir entry to index 11, end of the extension of the 8.3 dir entry
				sta krn_tmp
				ldy #7						;y set to offset of file extension-1 at dirptr
				jsr matcher_NEXT			;match the extension, x is already set above
				bcc matcher_EXIT			;no, exit if extension did not match, C=0 already
matcher_match_name:
				LDX #$00					;yes, now match the filename
				LDY #$FF        			;y is an index in the string
				lda #8						;end of dir entry to index 8, which is the name of the 8.3 dir entry
				sta krn_tmp				
matcher_NEXT:    		
				LDA buffer,X   				;Look at next pattern character
				CMP #'*'					;Is it a star?
				BEQ matcher_STAR        	;Yes, do the complicated stuff
				INY             			;No, let's look at the string
				cpy krn_tmp		 			;end of dir entry?
				beq matcher_FOUND
				cmp #' '			 		;pattern end?
				BNE matcher_quest		 	;no
				cmp (dirptr),y   	 		;yes, expect space in dir name, marks end of string within dir entry
				bcs matcher_FOUND			;yes, matched, succes C=1 here
				rts				 			;no, exit with no match
matcher_quest:	
				CMP #'?'	     			; Is the pattern caracter a ques?
				BNE matcher_REG         	; No, it's a regular character
				LDA (dirptr),Y     			; Yes, so it will match anything
				BEQ matcher_FAIL        	;  except the end of string
matcher_REG:	
				cmp #'a'					; char [a-z] ?
				bcc matcher_cmp				; no, we have to go the long way
				cmp #'z'+1
				bcs matcher_cmp
				and #$df					; uppercase
matcher_cmp:	cmp (dirptr),y				; match byte?
				BNE matcher_FAIL        	; No, so no match
				INX             			; Yes, keep checking
				CMP #0						; Are we at end of string?
				BNE matcher_NEXT        	; Not yet, loop
matcher_FOUND:  RTS             			; Success, return with C=1

matcher_STAR:   INX             			; Skip star in pattern
				CMP buffer,X   				; String of stars equals one star
				BEQ matcher_STAR       		;  so skip them also
matcher_STLOOP:  			             	; We first try to match with * = ""
				phx             			;  and grow it by 1 character every
				phy             			; Save X and Y on stack
				JSR matcher_NEXT        	; Recursive call
				ply             			; Restore X and Y
				plx
				BCS matcher_FOUND       	; We found a match, return with C=1
				INY             			; No match yet, try to grow * string
				LDA (dirptr),Y     			; Are we at the end of string?
				BNE matcher_STLOOP      	; Not yet, add a character
matcher_FAIL:   CLC            				; Yes, no match found, return with C=0
matcher_EXIT:	RTS