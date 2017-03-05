;.ifndef __DEBUG_INC
;.define	__DEBUG_INC ""

.import _debugout
		
.macro debug msg
.ifdef DEBUG
		jsr	_debugout
		.asciiz msg
.endif
.endmacro

.macro _debugA st
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

.macro _debugptr s, p
.ifdef DEBUG
.endif
.endmacro

.macro _debugstr s, p
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

.macro _debug8 v
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

.macro _debug_newline
.ifdef DEBUG
    crlf
.endif
.endmacro

.macro _debug8s st, v8
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

.macro _debug16s st, v16
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

.macro _debug24s st, v24
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

.macro _debug32s st, v32
.ifdef DEBUG
.endif
.endmacro

;.endif