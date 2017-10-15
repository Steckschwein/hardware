.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "common.inc"

.include "../kernel/fat32.inc"
.include "../kernel/sdcard.inc"

.include "appstart.inc"

;data = $2000
volid = $0308
part0 = data + BootSector::Partitions + PartTable::Partition_0

appstart $1000

        stz lba_addr+0
        stz lba_addr+1
        stz lba_addr+2
        stz lba_addr+3

        SetVector data, read_blkptr
        jsr krn_sd_read_block

        m_memcpy part0 + PartitionEntry::LBABegin, lba_tmp, 4

        jsr krn_primm
        .byte "Partition info: ",$0a,"Bootable      :",$00
        lda part0 + PartitionEntry::Bootflag
        and #$0f
        ora #'0'
        jsr krn_chrout

        jsr krn_primm
        .byte $0a,"Type Code     :$", $00
        lda part0 + PartitionEntry::TypeCode
        jsr krn_hexout
        crlf

        jsr krn_primm
        .byte "Begin LBA     :", $00
        m_memcpy part0 + PartitionEntry::LBABegin, tmp0, 4
        jsr BINBCD32

        ldx #$05
        jsr display_bcd
        jsr krn_primm
        .byte $0a, "Size (sectors):", $00

        m_memcpy part0 + PartitionEntry::NumSectors, tmp0, 4
        jsr BINBCD32

        ldx #$05
        jsr display_bcd

        jsr krn_primm
        .byte $0a,$0a,"Filesystem Info: ",$0a,$00

        jsr krn_primm
        .byte "Bytes / sector    :",$00

        ldx volid + VolumeID::BytsPerSec+1
        lda volid + VolumeID::BytsPerSec
        jsr BINBCD16
        ldx #$02
        jsr display_bcd


        jsr krn_primm
        .byte $0a,"Sectors / cluster :",$00

        lda volid + VolumeID::SecPerClus
        ldx #$00
        jsr BINBCD16
        ldx #$02
        jsr display_bcd

        jsr krn_primm
        .byte $0a,"Number of FATs    :",$00

        lda volid + VolumeID::NumFATs
        and #$0f
        ora #'0'
        jsr krn_chrout

        jsr krn_primm
        .byte $0a,"Active FAT        :",$00

        lda volid + VolumeID::MirrorFlags
        bit #$00
        bpl @both

        and #$0f
        ora #'0'
        jsr krn_chrout
        bra @foo
@both:
        jsr krn_primm
        .byte "both",$00
@foo:
        jsr krn_primm
        .byte $0a,"Reserved sectors  :",$00

        ldx volid + VolumeID::RsvdSecCnt+1
        lda volid + VolumeID::RsvdSecCnt
        jsr BINBCD16
        ldx #$02
        jsr display_bcd
        crlf

        jsr krn_primm
        .byte "Sectors / FAT     :",$00

        m_memcpy volid + VolumeID::FATSz32, tmp0, 4
        jsr BINBCD32
        ldx #$05
        jsr display_bcd

        jsr krn_primm
        .byte $0a,"FSInfo sector LBA :",$00

        lda volid + VolumeID::FSInfoSec
        clc
        adc lba_tmp+0
        sta lba_addr+0

        lda volid + VolumeID::FSInfoSec+1
        adc lba_tmp+1
        sta lba_addr+1


        lda #$00
        adc lba_tmp+2
        sta lba_addr+2
        lda #$00
        adc lba_tmp+3
        sta lba_addr+3

        m_memcpy lba_addr, tmp0, 4

        jsr BINBCD32
        ldx #$05
        jsr display_bcd


        SetVector data, read_blkptr
        jsr krn_sd_read_block

        jsr krn_primm
        .byte $0a,"Free clusters     :",$00
        m_memcpy data+488, tmp0, 4
        ;m_memcpy data + F32FSinfo::FreeClus, tmp0, 4

        jsr BINBCD32
        ldx #$05
        jsr display_bcd

        jsr krn_primm
        .byte $0a,"Next free cluster :",$00
        m_memcpy data+492, tmp0, 4
;        m_memcpy data + F32FSinfo::LastClus, tmp0, 4

        jsr BINBCD32
        ldx #$05
        jsr display_bcd

        crlf

        jmp (retvec)

BINBCD16:
        sta tmp0
		stx tmp0+1
        SED             ; Switch to decimal mode
        LDA #0          ; Ensure the result is clear
        STA BCD+0
        STA BCD+1
        STA BCD+2
        LDX #16         ; The number of source bits

@CNVBIT:
        ASL tmp0+0       ; Shift out one bit
        ROL tmp0+1
        LDA BCD+0       ; And add into result
        ADC BCD+0
        STA BCD+0
        LDA BCD+1       ; propagating any carry
        ADC BCD+1
        STA BCD+1
        LDA BCD+2       ; ... thru whole result
        ADC BCD+2
        STA BCD+2
        DEX             ; And repeat for next bit
        BNE @CNVBIT
        CLD             ; Back to binary

        rts

BINBCD32:
        lda tmp0
        SED             ; Switch to decimal mode
        LDA #0          ; Ensure the result is clear
        STA BCD+0
        STA BCD+1
        STA BCD+2
        STA BCD+3
        STA BCD+4
        STA BCD+5


        LDX #32         ; The number of source bits

@CNVBIT:
        ASL tmp0+0       ; Shift out one bit
        ROL tmp0+1
        ROL tmp0+2
        ROL tmp0+3

        LDA BCD+0       ; And add into result
        ADC BCD+0
        STA BCD+0
        LDA BCD+1       ; propagating any carry
        ADC BCD+1
        STA BCD+1
        LDA BCD+2       ; ... thru whole result
        ADC BCD+2
        STA BCD+2
        LDA BCD+3       ; ... thru whole result
        ADC BCD+3
        STA BCD+3
        LDA BCD+4       ; ... thru whole result
        ADC BCD+4
        STA BCD+4;        LDA BCD+5       ; ... thru whole result
        ADC BCD+5
        STA BCD+5

        DEX             ; And repeat for next bit
        BNE @CNVBIT
        CLD             ; Back to binary

        rts

display_bcd:
        ;ldx #$05
        @l:
        lda BCD,x
;        beq @out
        jsr krn_hexout
@out:
        dex
        bpl @l
        rts



lba_tmp: .res 4
BCD: .res 6
tmp0: .res 2
.align 255,0
data:
