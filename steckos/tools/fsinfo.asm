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
        .byte "Begin LBA     :$", $00
        lda part0 + PartitionEntry::LBABegin+3
        jsr krn_hexout
        lda part0 + PartitionEntry::LBABegin+2
        jsr krn_hexout
        lda part0 + PartitionEntry::LBABegin+1
        jsr krn_hexout
        lda part0 + PartitionEntry::LBABegin+0
        jsr krn_hexout

        jsr krn_primm
        .byte $0a, "Size (sectors):$", $00
        lda part0 + PartitionEntry::NumSectors+3
        jsr krn_hexout
        lda part0 + PartitionEntry::NumSectors+2
        jsr krn_hexout
        lda part0 + PartitionEntry::NumSectors+1
        jsr krn_hexout
        lda part0 + PartitionEntry::NumSectors+0
        jsr krn_hexout


        jsr krn_primm
        .byte $0a,$0a,"Filesystem Info: ",$0a,$00


        jsr krn_primm
        .byte "Bytes / sector    :$",$00

        lda volid + VolumeID::BytsPerSec+1
        jsr krn_hexout
        lda volid + VolumeID::BytsPerSec
        jsr krn_hexout

        crlf

        jsr krn_primm
        .byte "Sectors / cluster :$",$00

        lda volid + VolumeID::SecPerClus
        jsr krn_hexout


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
        .byte $0a,"Reserved sectors  :$",$00

        lda volid + VolumeID::RsvdSecCnt+1
        jsr krn_hexout
        lda volid + VolumeID::RsvdSecCnt
        jsr krn_hexout

        crlf

        jsr krn_primm
        .byte "Sectors / FAT     :$",$00

        lda volid + VolumeID::FATSz32+3
        jsr krn_hexout
        lda volid + VolumeID::FATSz32+2
        jsr krn_hexout
        lda volid + VolumeID::FATSz32+1
        jsr krn_hexout
        lda volid + VolumeID::FATSz32+0
        jsr krn_hexout

        crlf

        jsr krn_primm
        .byte "FSInfo sector LBA :$",$00

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

        lda lba_addr+3
        jsr krn_hexout
        lda lba_addr+2
        jsr krn_hexout
        lda lba_addr+1
        jsr krn_hexout
        lda lba_addr+0
        jsr krn_hexout

        SetVector data, read_blkptr
        jsr krn_sd_read_block

        jsr krn_primm
        .byte $0a,"Free clusters     :$",$00
        lda data+488+3
        jsr krn_hexout
        lda data+488+2
        jsr krn_hexout
        lda data+488+1
        jsr krn_hexout
        lda data+488+0
        jsr krn_hexout

        jsr krn_primm
        .byte $0a,"Next free cluster :$",$00
        lda data+492+3
        jsr krn_hexout
        lda data+492+2
        jsr krn_hexout
        lda data+492+1
        jsr krn_hexout
        lda data+492+0
        jsr krn_hexout

        crlf

        jmp (retvec)
lba_tmp: .res 4
.align 255,0
data:
