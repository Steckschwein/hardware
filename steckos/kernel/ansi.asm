.include "kernel.inc"

.segment "KERNEL"
.export ansi_chrout
.import krn_chrout


ESCAPE = 27
CSI    = '['

ansi_chrout:
    bit ansi_state
    bmi @check_csi
    bvs @store_csi_byte
    cmp #ESCAPE
    bne @out
    pha
    lda #$80
    sta ansi_state
    pla
    rts
@check_csi:
    cmp #CSI
    beq @is_csi
    stz ansi_state
@out:
    jmp krn_chrout
@is_csi:
    ; next bytes will be the ansi sequence
    pha
    lda #$40
    sta ansi_state
    pla
    stz ansi_index
    rts
@store_csi_byte:
    ; number? $30-$39
    cmp #$30
    bcs @n
    stz ansi_state
    rts
@n:
    cmp #$39
    bcc @store

    cmp #';'
    beq @store
    
    stz ansi_state
    rts

@store:

    phx
    ldx ansi_index
    sta $00,x
    inx
    stx ansi_index
    plx
    rts
