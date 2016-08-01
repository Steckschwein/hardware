.ifdef DEBUG

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
.endif