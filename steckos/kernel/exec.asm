.include 	"kernel.inc"

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
		beq	@l_end
		cmp	#'/'
		beq	@l_open
		
		sta execv_file, x
		iny
		inx
		cpx	#8; 8.3 support only
		bne	@l4
		
@l_open:
		jsr krn_open
		lda errno
		bne	@l_err
		
@l_err:	
		debugHex	errno
@l_end:
		rts

execv_file: .res 9,0