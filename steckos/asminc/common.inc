.macro SetVector word, addr 
			lda #<word
			sta addr
			lda #>word
			sta addr+1
.endmacro

.macro copypointer fromptr, toptr 
	.repeat 2, i
		lda fromptr+i
		sta toptr	+i	
	.endrepeat
.endmacro

.macro save
	pha
	phy
	phx
.endmacro

.macro restore
	plx
	ply
	pla
.endmacro

.macro keyin
	.local @l
@l:     jsr krn_getkey
        bcc @l
.endmacro

KEY_ESCAPE = 27
