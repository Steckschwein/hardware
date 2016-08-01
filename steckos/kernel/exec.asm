.include 	"kernel.inc"

.segment "KERNEL"

.import	krn_open_rootdir, krn_open
.import	krn_read

; debug stuff
.ifdef DEBUG
	.import	primm, hexout
.endif

.macro _open
		stz	execv_filename, x	;\0 terminate the current path fragment
		jsr	krn_open
		lda	errno
		bne	@l_err
.endmacro

;		int execv(const char *path, char *const argv[]);
execv:
		ldy	#0
		;	trimm first chars 
@l1:	lda (cmdptr), y	
		cmp	#' '
		bne	@l2
		iny 
		bne @l1
		
@l2:	;	starts with / ? - cd root
		cmp	#'/'
		bne	@l3
		phy
		jsr krn_open_rootdir
		ply
		iny
				
		SetVector	execv_filename,	filenameptr	; filenameptr to execv filename buffer
@l3:	;	parse path fragments and change dirs accordingly
		ldx #0
@l4:	lda	(cmdptr), y
		beq	@l_exec
		cmp	#'/'
		beq	@l_open
		
		sta execv_filename, x
		iny
		inx
		cpx	#8	; 8.3 file support only
		bne	@l4	
		; fall through - we have 8 chars, try to open directory
@l_open:
		_open
		iny	
		bne	@l3
		;TODO FIXME handle overflow - <path argument> too large
		lda	#$ff
@l_err:	
		debug8	errno
@l_end:
		rts
		
@l_exec:
		txa
		tay					; x to y
		lda	#'.'			; has extension?
@l_ext_1:
		cmp	execv_filename, y
		beq	@l_ext_skip
		dey					; down till first char
		bne	@l_ext_1
@l_ext_2:
		lda execv_fileext,y
		sta execv_filename,x
		iny
		inx
		cpy #4 				; size of execv_fileext
		bne @l_ext_2
@l_ext_skip:
		_open				; with x as offset to fd_area
		SetVector appstart, sd_read_blkptr
		phx
		jsr	krn_read
		;TODO
		;check excecute
		jmp		appstart
		rts
execv_fileext:	.byte ".bin"
execv_filename: .res 8+3+1,0