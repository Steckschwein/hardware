.macro debugA st
.ifdef DEBUG
	pha
	phy
	
	pha
	jsr krn_primm
    .asciiz st, " A "
	pla
    jsr krn_hexout
    debug_newline
	ply
	pla
.endif
.endmacro

.macro debugcpu st
.ifdef DEBUG
    pha
	phx		;TODO FIXME investigate, we must not save x here, but if we dont do so, we run into trouble
    phy
    
    phy
    phx 
    pha
    jsr krn_primm
    .asciiz st, " AXY "
    pla
    jsr krn_hexout
    pla
    jsr krn_hexout
    pla
    jsr krn_hexout
    debug_newline
	
    ply
	plx
    pla    
.endif
.endmacro

.macro debugptr s, p
.ifdef DEBUG
    pha
    phy
    jsr krn_primm
    .byte s,"'",0
    lda p
    sta msgptr
    lda p+1
    sta msgptr+1
    jsr krn_strout
    lda #'''
    jsr krn_chrout
    debug_newline
    ply
    pla
.endif
.endmacro

.macro debugstr s, p
.ifdef DEBUG
	pha
    phy
    jsr krn_primm
    .byte s,"'",0
    lda #<p
    sta msgptr
    lda #>p
    sta msgptr+1
    jsr krn_strout
    lda #'''
    jsr krn_chrout
    debug_newline
    ply
    pla
.endif
.endmacro

.macro debug8 v
.ifdef DEBUG
    pha
    phy
    lda v
    jsr krn_hexout
    debug_newline
    ply
    pla
.endif
.endmacro

.macro debug_newline
.ifdef DEBUG
    crlf
.endif
.endmacro

.macro debug8s st, v8
.ifdef DEBUG
    pha
    phy
    jsr krn_primm
    .byte st
    .byte 0    
    lda v8
    jsr krn_hexout
    debug_newline
    ply
    pla
.endif
.endmacro

.macro debug16s st, v16
.ifdef DEBUG
    pha
    phy
    jsr krn_primm
    .asciiz st
    lda v16+1
    jsr krn_hexout
    lda v16+0
    jsr krn_hexout
    debug_newline
    ply
    pla
.endif
.endmacro

.macro debug24s st, v24
.ifdef DEBUG
    pha
    phy
    jsr krn_primm
    .byte st,0
    lda v24+2
    jsr krn_hexout
    lda v24+1
    jsr krn_hexout
    lda v24+0
    jsr krn_hexout
    debug_newline
    ply
    pla
.endif
.endmacro

.macro debug32s st, v32
.ifdef DEBUG
    pha
    phy
    jsr krn_primm
    .byte st
    .byte 0    
    lda v32+3
    jsr krn_hexout
    lda v32+2
    jsr krn_hexout
    lda v32+1
    jsr krn_hexout
    lda v32+0
    jsr krn_hexout
    debug_newline
    ply
    pla
.endif
.endmacro
