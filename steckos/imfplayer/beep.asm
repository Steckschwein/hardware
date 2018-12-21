.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "common.inc"
.include "ym3812.inc"

.import init_opl2, opl2_delay_data, opl2_delay_register
.import hexout
.export char_out=krn_chrout

.include "appstart.inc"
appstart $1000

.segment "CODE"

.macro oplSetReg1 reg, val
    pha
    lda #reg
    sta opl_stat
    jsr opl2_delay_register

    lda #val
    sta opl_data
    jsr opl2_delay_data

    pla
.endmacro

    jsr init_opl2

    ; Set the modulator's multiple to 1
    ;oplSetReg1 $20, $01

    ; Set the modulator's level to about 40 dB
    ;oplSetReg1 $40, $10

    ; Modulator attack: quick; decay: long
    ;oplSetReg1 $60, $F0

    ; Modulator sustain: medium; release: medium
    ;oplSetReg1 $80, $77

    ; Set voice frequency's LSB (it'll be a D#)
    ;oplSetReg1 $A0, $98

    ; Set the carrier's multiple to 1
    ;oplSetReg1 $23, $01

    ; Set the carrier to maximum volume (about 47 dB)
    ;oplSetReg1 $43, $00

    ; Carrier attack: quick; decay: long
    ;oplSetReg1 $63, $F0

    ; Carrier sustain: medium; release: medium
    ;oplSetReg1 $83, $77

    ; Turn the voice on; set the octave and freq MSB
    ;oplSetReg1 $B0, $31
;
    save
    ldx #0
loop:
    lda reglist,x
    beq end
    sta opl_stat
    jsr opl2_delay_register

    lda datlist,x
    sta opl_data
    ldy #opl2_data_delay
:
    dey
    bne :-

    inx
    bne loop

end:
    crlf

    ldy #0
delay2:
    ldx #0
delay:
    nop
    nop
    nop
    nop
    nop
    dex
    bne delay
    dey
    bne delay2


    oplSetReg1 $B0, $11

    restore
    jmp (retvec)
reglist:
    .byte $20, $40, $60, $80, $a0, $23, $43, $63, $83, $b0, $00
datlist:
    .byte $01, $10, $F0, $77, $98, $01, $00, $F0, $77, $31
