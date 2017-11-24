.include "../../kernel/kernel_jumptable.inc"
.include "../tools.inc"
.export bin2dual
.segment "CODE"


bin2dual:
        phx
        ldx #$07
@l:
        rol
        bcc @skip
        pha
        lda #'1'
        bra @out
@skip:
        pha
        lda #'0'
@out:
        jsr krn_chrout
        pla
        dex
        bpl @l
        plx
        rts
