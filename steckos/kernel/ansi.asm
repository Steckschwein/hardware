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
    bne @cont
    inc ansi_index
@cont:

    stz ansi_state
    rts
@store:

    phx
    phy
    ldx ansi_index
    and #%11001111


    pha
    lda #0
    sta ansi_param1,x
    lda ansi_state
    ror
    bcs @skip_mul
    ; cmp #$40
    ; bne @skip_mul
    ply

    lda multable,y
    inc ansi_state
    bra @end
@skip_mul:
    pla
    clc
    adc ansi_param1,x
@end:
    sta ansi_param1,x
    ply
    plx
    rts
multable:
	.byte 0,10,20,30,40,50,60,70,80,90
