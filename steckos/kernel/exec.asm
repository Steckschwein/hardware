.include	"kernel.inc"
.include 	"errno.inc"
.include 	"filedes.inc"

.segment "KERNEL"

.import fat_open, fat_read, fat_close
        
.export execv

.ifdef DEBUG ; DEBUG
    .import krn_hexout, krn_primm, krn_chrout, krn_strout, krn_print_crlf
.endif

;		int execv(const char *path, char *const argv[]);
execv:
        jsr fat_open	        ; a/x - pointer to filename
        bne @l_err_exit
		
		lda	fd_area + FD_file_attr, x
		bit #FD_ATTR_FILE		; check that whether it's a regular file
		bne	@l0
		lda	#EINVAL				; TODO FIXME error code for "Is a directory"
		bra @l_err_exit
		
@l0:	SetVector appstart, sd_read_blkptr
		jsr	fat_read
        lda errno
		bne	@l_err_exit_close
        jsr	fat_close	        ; close after read to free fd, regardless of error
        bne	@l_err_exit
@l_exec_run:
        ;TODO FIXME check excecutable - SOS65 header ;)
		jmp	appstart
@l_err_exit_close:
        pha                     ; save error
        jsr	fat_close           ; close and ignore error
        pla
@l_err_exit:
        debugA "exc:"
		rts

.ifdef DEPRECATED
.macro _open
		stz	execv_filename, x	;\0 terminate the current path fragment
        sec
		jsr	_fat_open
		beq	:+
        jmp @l_err
:
.endmacro
execv_o:
        jsr fat_clone_cd_2_td        ; clone cd 2 temp dir
        
		ldy	#0
		;	trimm first chars
@l1:	lda (cmdptr), y
		cmp	#' '
		bne	@l2
		iny 
		bne @l1
        lda #$f0    ; TODO FIXME exec errors
        sta errno
        bra @l_err
@l2:	;	starts with / ? - cd root
		cmp	#'/'
		bne	@l31
		phy
        sec
		jsr fat_open_rootdir
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
        lda #$f1
        sta errno       ; TODO FIXME exec errors
        bra @l_err
@l_open:
		_open
		iny	
		bne	@l3
		;TODO FIXME handle overflow - <path argument> too large
		lda	#$ff
@l_err:	
		debug8s	"exc:", errno
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
        lda #$f2            ; filename too large
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
		jsr	fat_read
		;TODO FIXME check excecutable - SOS65 header ;)
		jsr	fat_close
        lda errno
        beq @l_exec_run
        debug8s "exec rd:", errno
        jmp @l_err
@l_exec_run:
        debugptr "cmdptr:", cmdptr
		jmp	appstart
		
execv_fileext:	.byte ".bin",0
execv_filename: .res 8+1+3+1
.endif