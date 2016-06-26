.include "kernel.inc"
.include "vdp.inc"

.export textui_init0, textui_update_screen, textui_chrout
.import vdp_bgcolor, vdp_memcpy, vdp_mode_text, vdp_display_off

.zeropage
tmp0=$0
tmp1=$1
; Cursor Position and buffer
crs_x	= $e6
crs_y	= $e7
crs_ptr = $e8

.segment "KERNEL"

screen=$c000
; TODO FIXME write into kernel RAM instead of DATA area
screen_status: 		.byte STATUS_TEXTUI_ENABLED
screen_write_lock: 	.byte 0
screen_frames:		.byte 0
saved_char:			.byte ' '

ROWS=24
COLS=40
CURSOR_CHAR=$db ; invert blank char - @see charset_6x8.asm

KEY_CR=$0d
KEY_LF=$0a
KEY_BACKSPACE=$08
KEY_CARIAGE_RETURN=$0a
KEY_RETURN=$0d

STATUS_BUFFER_DIRTY=1<<0
STATUS_CURSOR=1<<1
STATUS_TEXTUI_ENABLED=1<<2

textui_incy:
		jmp	inc_cursor_y
	
textui_decy:
		lda	crs_y
		bne	@l1
		rts
@l1:	dec	crs_y	; go on with textui_update_crs_ptr below
		bra	textui_update_crs_ptr
	
textui_incx:
		lda	crs_x
		cmp	#(COLS-1)
		bne @l1
		rts
@l1:	inc	crs_x
		bra	textui_update_crs_ptr
	
textui_decx:
		lda	crs_x
		bne	@l1
		rts
@l1:	dec	crs_x	; go on with textui_update_crs_ptr below
	

;   updates the 16 bit pointer crs_p upon crs_x, crs_y values
;    
textui_update_crs_ptr:
		pha

		lda saved_char     ;restore saved char
		sta (crs_ptr)
		lda #STATUS_CURSOR
		trb screen_status  ;reset cursor state
    
		stz	   tmp1
		lda    crs_y
		asl
		asl
		asl
		sta    tmp0    ; result *8
		asl
		rol    tmp1
		asl
		rol    tmp1
		clc
		adc    tmp0    ; y*32 + y*8 = y*40
		bcc    @l1
		inc    tmp1
@l1:	clc
		adc    crs_x
		sta    crs_ptr
		lda    #>screen
		adc    tmp1
		sta    crs_ptr+1

		lda (crs_ptr)
		sta saved_char     ;save char
		pla
		rts

textui_init0:
		jsr	vdp_display_off			    ;display off
		jsr	textui_blank			    ;blank screen buffer
        
		stz	crs_x
		stz	crs_y
        SetVector   screen, crs_ptr
		jsr textui_update_crs_ptr		;init cursor pointer

textui_init:
		jmp	vdp_mode_text
	
textui_blank:
		ldx	#$00
		lda	#' '
@l1:	sta	screen,x
		sta	screen+$100,x
		sta screen+$200,x
		sta	screen+$300,x
		inx
		bne	@l1
@l2:	sta	screen+$400,x	;last line for scroll up
		inx
		cpx	#COLS
		bne	@l2
    	stz crs_x
    	stz crs_y
		bra	textui_update_crs_ptr
		jmp	textui_screen_dirty
	
textui_cursor:
		lda screen_write_lock
		bne	@l2
		lda screen_frames
		and	#$0f
		bne	@l2
		lda	#STATUS_CURSOR
		tsb	screen_status
		beq	@l1
		trb	screen_status
		lda	saved_char
		jmp textui_put
@l1:	lda	#CURSOR_CHAR
		jmp textui_put
@l2:	rts

textui_update_screen:
		;lda	#Dark_Green
		;jsr	vdp_bgcolor

		lda	screen_status
		and	#STATUS_TEXTUI_ENABLED
		beq	@l1

		inc	screen_frames
        
		jsr	textui_cursor
		
		lda	screen_status
		and	#STATUS_BUFFER_DIRTY
		beq	@l1	;exit if not dirty
		
		SetVector	screen, adrl    ; copy back buffer to video ram
		lda	#<ADDRESS_GFX1_SCREEN
		ldy	#WRITE_ADDRESS + >ADDRESS_GFX1_SCREEN
		ldx	#$04
		jsr	vdp_memcpy
		
		lda	screen_status		;clean dirty
		and	#<(~STATUS_BUFFER_DIRTY)
		sta	screen_status

@l1:
		lda	#Medium_Green<<4|Black
		jsr	vdp_bgcolor
		rts	

textui_scroll_up:
		phx
		ldx	#$00
@l1:	lda	screen+COLS,x
		sta	screen,x
		inx
		bne	@l1
@l2:	lda	screen+$100+COLS,x
		sta	screen+$100,x
		inx
		bne	@l2
@l3:	lda	screen+$200+COLS,x
		sta	screen+$200,x
		inx
		bne	@l3
@l4:	lda	screen+$300+COLS,x
		sta	screen+$300,x
		inx
		bne	@l4
		plx
		rts
	
inc_cursor_y:
		lda crs_y
		cmp	#ROWS-1		;last line
		bne	@l1

		lda saved_char     ;restore saved char
		sta (crs_ptr)
		lda #' '
		sta saved_char     ;reset .saved_char to blank, cause we scrolled up
		lda #STATUS_CURSOR
		trb screen_status  ;reset cursor state
		jsr	textui_scroll_up	; scroll and exit
		jmp textui_update_crs_ptr
@l1:	inc crs_y
	    jmp textui_update_crs_ptr

textui_enable:
		lda	screen_status
		ora	#STATUS_TEXTUI_ENABLED
		bra	lsstatus
textui_disable:
		lda	screen_status
		and	#<(~STATUS_TEXTUI_ENABLED)
lsstatus:	
		sta	screen_status
		rts

textui_put:
		sta	(crs_ptr)
		bra	textui_screen_dirty
    
textui_print:
		inc screen_write_lock	;write on
		ldy	#$00
@l1:	lda	(msgptr),y
		beq	@l2
		jsr textui_dispatch_char
		iny
		bne	@l1
@l2:	stz	screen_write_lock	;write off
		bra	textui_screen_dirty

textui_chrout:
		beq	@l1	; \0 char
		pha		; safe char
		inc screen_write_lock	;write on
		jsr textui_dispatch_char
		stz	screen_write_lock	;write off
		jsr	textui_screen_dirty
		pla								; restore char
@l1:	rts

	
; set crs x and y position absolutely - 0..32/0..23 or 0..39/0..23 40 char mode
;
textui_crsxy:
		stx crs_x
		sty crs_y
		jmp textui_update_crs_ptr
    
textui_dispatch_char:
		cmp	#KEY_CARIAGE_RETURN	;cariage return?
		bne	lfeed
textui_pos1:
		stz	crs_x
		bra	lupdate
lfeed:
		cmp	#KEY_RETURN			;line feed
		bne	@l1
 	   	jmp	inc_cursor_y
@l1:	cmp	#KEY_BACKSPACE
		bne	@l4
		lda	crs_x
		bne	@l3
		lda	crs_y			; cursor y=0, no dec
		beq	lupdate
		dec	crs_y
		lda	#(COLS-1)			; set x to end of line above
		sta	crs_x
@l2:	jsr	textui_update_crs_ptr
		lda	#' '			;blank the saved char
		sta	saved_char
    	rts
@l3:	dec	crs_x
    	bra @l2
@l4:    	   
		sta	saved_char         ; the trick, simple set saved value to plot as saved char, will be print by textui_update_crs_ptr
		lda	crs_x
		cmp	#(COLS-1)
		beq @l5
		inc	crs_x
		jmp	textui_update_crs_ptr
@l5:	stz	crs_x
		jmp	inc_cursor_y
lupdate:	
		jmp	textui_update_crs_ptr
	
textui_screen_dirty:
		lda #STATUS_BUFFER_DIRTY
		tsb screen_status       ;set dirty
		rts