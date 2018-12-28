.include "kernel.inc"

.segment "KERNEL"
.export ansi_chrout
.import textui_chrout, textui_update_crs_ptr


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
    jmp textui_chrout
@is_csi:
    ; next bytes will be the ansi sequence
    pha
    lda #$40
    sta ansi_state
    stz ansi_index
    pla
    rts
@store_csi_byte:
    ; number? $30-$39
    cmp #'0'
    bcs @n
    stz ansi_state
    rts
@n:
    cmp #'9'+1
    bcc @store

    cmp #';'
    bne @cont
    inc ansi_index
    dec ansi_state
    rts
@cont:
    cmp #'A' ; cursor up
    bne @n1
    lda crs_y
    sec
    sbc ansi_param1
    sta crs_y
    bra @seq_end
@n1:
    cmp #'B' ; cursor up
    bne @n2
    lda crs_y
    clc
    adc ansi_param1
    sta crs_y
    bra @seq_end
@n2:
    cmp #'C' ; cursor right
    bne @n3
    lda crs_x
    sec
    sbc ansi_param1
    sta crs_x
    bra @seq_end
@n3:
    cmp #'D' ; cursor left
    bne @n4
    lda crs_x
    clc
    adc ansi_param1
    sta crs_x
    bra @seq_end
@n4:
    cmp #'H'
    bne @n5
    ; cmp #'f'
    ; bne @n5

    lda ansi_param1
    sta crs_x
    lda ansi_param2
    sta crs_y
    bra @seq_end
@n5:

    ; TODO
    ; Is alphanumeric?
    ; end sequence and execute requested action
@seq_end:
    stz ansi_state
    jmp textui_update_crs_ptr
    ;rts
@store:

    phx
    phy
    ldx ansi_index

    ; Convert digit in A to binary
    and #%11001111
    pha

    ; bit 0 of ansi_state set?
    ; no? multiply by 10, then store to ansi_param1
    ; yes? skip multiplication, and add to ansi_param1
    lda ansi_state
    ror
    bcc @skip

    ldy ansi_param1,x
    clc
    pla
    adc @multable,y
    sta ansi_param1,x

    bra @end
@skip:
    pla
    sta ansi_param1,x
    inc ansi_state ; set bit 0 of ansi_state to indicate the first digit has been processed

@end:
    ply
    plx
    rts
@multable:
	.byte 0,10,20,30,40,50,60,70,80,90
