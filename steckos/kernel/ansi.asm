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
    rts
@cont:

    ; TODO
    ; Is alphanumeric?
    ; end sequence and execute requested action
    stz ansi_state
    rts
@store:

    phx
    phy
    ldx ansi_index

    ; Convert digit in A to binary
    and #%11001111
    pha

    ; clear ansi_param1 / NOT NEEDED ANYMORE
    lda #0
    sta ansi_param1,x

    ; bit 0 of ansi_state set?
    ; no? multiply by 10, then store to ansi_param1
    ; yes? skip multiplication, and add to ansi_param1
    lda ansi_state
    ror
    bcs @skip_mul

    ply
    lda multable,y ; get multiple of A (now in Y) into A
    inc ansi_state ; set bit 0 of ansi_state to indicate the first digit has been processed
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
