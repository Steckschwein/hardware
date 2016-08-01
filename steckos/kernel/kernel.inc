.setcpu "65c02"
.include "zeropage.inc"

user_isr 	        = $028e

.macro	printstring text
			jsr krn_primm
			.byte text
			.byte $0a,$0d,$00
.endmacro

.macro debugs st
.ifdef DEBUG
    jsr primm
    .byte st
    .byte 0    
.endif    
.endmacro

.macro debug8 v
.ifdef DEBUG
    pha
    lda v
    jsr hexout
    debug_newline
    pla
.endif
.endmacro

.macro crlf
	lda #$0a
	jsr krn_chrout
	lda #$0d
	jsr krn_chrout
.endmacro


.macro debug_newline v32
.ifdef DEBUG
    jsr primm
    .byte $0a,$0d,$00
.endif
.endmacro

.macro debug8s st, v8
.ifdef DEBUG
    pha
    jsr primm
    .byte st
    .byte 0    
    lda v8
    jsr hexout
    debug_newline
    pla
.endif
.endmacro

.macro debug24s st, v24
.ifdef DEBUG
    pha
    jsr primm
    .byte st
    .byte 0    
    lda v24+2
    jsr hexout
    lda v24+1
    jsr hexout
    lda v24+0
    jsr hexout
    debug_newline
    pla
.endif
.endmacro

.macro debug32s st, v32
.ifdef DEBUG
    pha
    jsr primm
    .byte st
    .byte 0    
    lda v32+3
    jsr hexout
    lda v32+2
    jsr hexout
    lda v32+1
    jsr hexout
    lda v32+0
    jsr hexout
    debug_newline
    pla
.endif
.endmacro

.macro debug32 v32
.ifdef DEBUG
    pha
    lda v32+3
    jsr hexout
    lda v32+2
    jsr hexout
    lda v32+1
    jsr hexout
    lda v32+0
    jsr hexout
    debug_newline
    pla
.endif
.endmacro

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

.macro Copy src, trgt, len

		ldx #len
:
		lda src,x
		sta trgt,x
		dex
		bpl :-

.endmacro

.macro toupper
	cmp #$60 ; Is lowercase?
	bcc :+
	and	#$DF
:
.endmacro

.macro tolower
	ora #$20
.endmacro
