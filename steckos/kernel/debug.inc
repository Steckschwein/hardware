
.macro debugcpu
.ifdef DEBUG
    pha
    phx
    phy
    jsr primm
    .asciiz "A X Y: "
    jsr hexout
    lda #' '
    jsr chrout
    txa
    jsr hexout
    lda #' '
    jsr chrout
    tya
    jsr hexout
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
    jsr primm
    .byte s,0
    lda p
    sta msgptr
    lda p+1
    sta msgptr+1
    jsr strout
    jsr primm
    .byte $0a,$0d,0
    ply
    pla
.endif
.endmacro

.macro debugstr s, p
.ifdef DEBUG
    pha
    phy
    jsr primm
    .byte s,0
    lda #<p
    sta msgptr
    lda #>p
    sta msgptr+1
    jsr strout
    jsr primm
    .byte $0a,$0d,0
    ply
    pla
.endif
.endmacro

.macro debugs st
.ifdef DEBUG
    pha
    phy
    jsr primm
    .byte st,$0a,$0d,0
    ply
    pla
.endif    
.endmacro

.macro debug8 v
.ifdef DEBUG
    pha
    phy
    lda v
    jsr hexout
    debug_newline
    ply
    pla
.endif
.endmacro

.macro debug_newline
.ifdef DEBUG
    jsr primm
    .byte $0a,$0d,$00
.endif
.endmacro

.macro debug8s st, v8
.ifdef DEBUG
    pha
    phy
    jsr primm
    .byte st
    .byte 0    
    lda v8
    jsr hexout
    debug_newline
    ply
    pla
.endif
.endmacro

.macro debug24s st, v24
.ifdef DEBUG
    pha
    phy
    jsr primm
    .byte st,0
    lda v24+2
    jsr hexout
    lda v24+1
    jsr hexout
    lda v24+0
    jsr hexout
    debug_newline
    ply
    pla
.endif
.endmacro

.macro debug32s st, v32
.ifdef DEBUG
    pha
    phy
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
    ply
    pla
.endif
.endmacro