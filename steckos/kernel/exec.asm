.include 	"kernel.inc"

.segment "KERNEL"

.import	krn_open_rootdir, krn_open

; debug stuff
.ifdef DEBUG
	.import	primm, hexout
.endif

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
				
		SetVector	execv_file,	filenameptr	; filenameptr to execv filename buffer
@l3:	;	parse path fragments and cd	
		ldx #0
@l4:	lda	(cmdptr), y
		beq	@l_exec
		cmp	#'/'
		beq	@l_open
		
		sta execv_file, x
		iny
		inx
		cpx	#8	; 8.3 file support only
		bne	@l4	
		; fall through 8 chars directory name, try to open 
@l_open:
		stz	execv_file, x	;\0 terminate the current path fragment
		jsr krn_open
		lda errno
		bne	@l_err
		iny	
		bne	@l3
		rts
@l_err:	
		debugHex	errno
@l_end:
		rts
@l_exec:
		stz	execv_file, x	;\0 terminate the current path fragment
		;jsr	fat_read

execv_file: .res 9,0