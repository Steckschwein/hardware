.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "common.inc"
.include "ym3812.inc"

.import init_opl2, opl2_delay_data, opl2_delay_register

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
    oplSetReg1 $20, $01

    ; Set the modulator's level to about 40 dB
    oplSetReg1 $40, $10

    ; Modulator attack: quick; decay: long
    oplSetReg1 $60, $F0

    ; Modulator sustain: medium; release: medium
    oplSetReg1 $80, $77

    ; Set voice frequency's LSB (it'll be a D#)
    oplSetReg1 $A0, $98

    ; Set the carrier's multiple to 1
    oplSetReg1 $23, $01

    ; Set the carrier to maximum volume (about 47 dB)
    oplSetReg1 $43, $00

    ; Carrier attack: quick; decay: long
    oplSetReg1 $63, $F0

    ; Carrier sustain: medium; release: medium
    oplSetReg1 $83, $77

    ; Turn the voice on; set the octave and freq MSB
    oplSetReg1 $B0, $31


    keyin
    oplSetReg1 $B0, $11

    jmp (retvec)
