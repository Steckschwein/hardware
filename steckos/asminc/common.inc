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

; Decrement the 32 bit value at memory location val by one.
; 	A = ??, X & Y are unchanged.
.macro _dec32 val
		.local @l2,@l1,@l0
		lda val+0
		bne @l0
		lda val+1
		bne @l1
		lda val+2
		bne @l2
		dec val+3
@l2:	dec val+2
@l1:	dec val+1
@l0:	dec val+0
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

.macro saveptr ptr
	lda ptr
	pha
	lda ptr+1
	pha
.endmacro 

.macro restoreptr ptr
	pla
	sta ptr+1
	pla
	sta ptr
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
