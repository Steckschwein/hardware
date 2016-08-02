.include 	"kernel.inc"

.segment "KERNEL"

.import	krn_open_rootdir, krn_open, krn_read, krn_close

.export execv

.ifdef DEBUG    ; debug stuff
	.import	primm, hexout, chrout, strout
.endif

.macro _open
		stz	execv_filename, x	;\0 terminate the current path fragment
		jsr	krn_open
		lda	errno
		beq	:+
        jmp @l_err
:
.endmacro

;		int execv(const char *path, char *const argv[]);
execv:
        stz errno
        
		ldy	#0
		;	trimm first chars
@l1:	lda (cmdptr), y
		cmp	#' '
		bne	@l2
		iny 
		bne @l1
        lda #$ff
        sta errno
        bra @l_err
@l2:	;	starts with / ? - cd root
		cmp	#'/'
		bne	@l31
		phy
		jsr krn_open_rootdir
		ply
		iny
		
@l31:   SetVector	execv_filename,	filenameptr	; filenameptr to execv filename buffer		
@l3:	;	parse path fragments and change dirs accordingly
		ldx #0
@l_parse_1:
        lda	(cmdptr), y
		beq	@l_exec
		cmp	#'/'
		beq	@l_open
		
		sta execv_filename, x
		iny
		inx
		cpx	#12	        ; 8.3 file support only
		bne	@l_parse_1
        lda #$ff
        sta errno
        bra @l_err
@l_open:
		_open
		iny	
		bne	@l3
		;TODO FIXME handle overflow - <path argument> too large
		lda	#$ff
@l_err:	
		debug8s	"exec err: ", errno
@l_end:
		rts
		
@l_exec:
        stz execv_filename, x   ;'\0' terminate
        debugstr "efn: ", execv_filename
        
		ldx #0
@l_ext_1:
		lda	execv_filename, x
        beq @l_ext_add
        cmp #' '            ; prog arguments separator
        beq @l_ext_add 
        cmp #'.'			; has extension? also override with .bin, simplifies code
		beq	@l_ext_add
		inx					
        cpx #8              ; 8.3 file support only
		bne	@l_ext_1
        lda #$ff            ; filename too large
        sta errno
        bra @l_err        
@l_ext_add:                 ; add extension
        ldy #0
@l_ext_add_1:        
        lda execv_fileext,y
		sta execv_filename,x
		iny
		inx
		cpy #5              ; size of execv_fileext
		bne @l_ext_add_1
        
        debugptr "fptr:", filenameptr
		_open				; with x as offset to fd_area        
		SetVector appstart, sd_read_blkptr
		jsr	krn_read
		;TODO FIXME check excecutable - SOS65 header ;)
		jsr	krn_close
        lda errno
        beq @l_exec_run
        jmp @l_err
@l_exec_run:
        debugptr "cmdptr:", cmdptr
		jmp	appstart
		
execv_fileext:	.byte ".bin",0
execv_filename: .res 8+1+3+1    