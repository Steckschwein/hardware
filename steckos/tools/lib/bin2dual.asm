.include "../../kernel/kernel_jumptable.inc"
.include "../tools.inc"
.export bin2dual
.import char_out
.segment "CODE"


bin2dual:
        pha
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
        jsr char_out
        pla
        dex
        bpl @l
        plx
        pla
        rts
