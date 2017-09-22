.macro SetVector word, addr 
			lda #<word
			sta addr
			lda #>word
			sta addr+1
.endmacro

.macro inc32 val
		.local @l1
		inc val + 0
		bne @l1
		inc val + 1
		bne @l1
		inc val + 2
		bne @l1
		inc val + 3
@l1:
.endmacro

.macro m_memcpy src, dest, n
		.local @l
		ldx #n-1
@l:
		lda src,x
		sta dest,x
		dex
		bpl @l
.endmacro

.macro m_memcpy2ptr src, ptr, n
		.local @l
		ldy #n-1
@l:		lda src,y
		sta (ptr),y
		dey
		bpl @l
.endmacro

.macro m_memset dest, value, n
		.local @l
		ldx #n-1
		lda #value
@l:		sta dest,x
		dex
		bpl @l
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
