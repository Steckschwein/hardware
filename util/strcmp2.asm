dir_entry_size=11

; 				match input name[.[ext]] against 11 byte dir entry <name><ext>
match2:
				ldx #0
				ldy	#0
				phx					; 0 to stack, means match without extension
uppaercase:		lda	test_input,x
				beq	@preparematch
				cmp	#'.'
				bne	@toupper
				cpx	#2
				bcc	@toupper		; further '.' in pattern?
				pla					; we have to match filename and extension
				phx					; save the x offset
				lda	#0				; replace with end of string
				bra	@store			
@toupper:		cmp	#'a'			; char [a-z] ?
				bcc @store
				cmp #'z'
				bcs @store
				and #$df			; uppercase
@store:			sta buffer,y
				iny
				inx
				bne	uppaercase		;no, next char
				pla					;input overflow, pop extension flag
				bra	@FAIL
				
@preparematch:	sta	buffer,y
				plx					
				beq	@patternmatch	; no extension pattern, match the hole filename
				inx					; inc x, it was last index of '.'
				ldy	#7				; y index to offset of file extension at dirptr
				jsr	@NEXT			; match the extension
				bcs	@patternmatch	; extension match, now the filename
				bra @FAIL
@patternmatch:	LDX #$00
				LDY #$FF        ; Y is an index in the string
@NEXT:    		LDA buffer,X   	; Look at next pattern character
				CMP #'*'	    ; Is it a star?
				BEQ @STAR        ; Yes, do the complicated stuff
				INY             ; No, let's look at the string
				CMP #'?'	     ; Is the pattern caracter a ques?
				BNE @REG         ; No, it's a regular character
				LDA (dirptr),Y     ; Yes, so it will match anything
				BEQ @FAIL        ;  except the end of string
@REG:     		cmp	#0			;end of pattern
				beq @FOUND
				pha
				;jsr vdp_chrout
				lda (dirptr),Y
				;jsr vdp_chrout
				pla
				CMP (dirptr),Y     ; Are both characters the same?
				BNE @FAIL        ; No, so no match
				INX             ; Yes, keep checking
				CMP #0          ; Are we at end of string?
				BNE @NEXT        ; Not yet, loop
@FOUND:   		RTS             ; Success, return with C=1

@STAR:    		INX             ; Skip star in pattern
				CMP buffer,X   ; String of stars equals one star
				BEQ @STAR        ;  so skip them also
@STLOOP:  		;TXA             ; We first try to match with * = ""
				PHx             ;  and grow it by 1 character every
				;TYA             ;  time we loop
				PHy             ; Save X and Y on stack
				JSR @NEXT        ; Recursive call
				PLy             ; Restore X and Y
				;TAY
				PLx
				;TAX
				BCS @FOUND       ; We found a match, return with C=1
				INY             ; No match yet, try to grow * string
				LDA (dirptr),Y     ; Are we at the end of string?
				BNE @STLOOP      ; Not yet, add a character
@FAIL:    		CLC             ; Yes, no match found, return with C=0
				RTS
		
buffer: .res 8+1+3,0