.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "../kernel/fat32.inc"
.include "appstart.inc"

volid = $0308
appstart $1000

        jsr krn_primm
        .byte "Bytes / sector    : $",$00

        lda volid + VolumeID::BytsPerSec+1
        jsr krn_hexout
        lda volid + VolumeID::BytsPerSec
        jsr krn_hexout

        crlf

        jsr krn_primm
        .byte "Sectors / cluster : $",$00

        lda volid + VolumeID::SecPerClus
        jsr krn_hexout

        crlf

        jsr krn_primm
        .byte "Number of FATs    : $",$00

        lda volid + VolumeID::NumFATs
        jsr krn_hexout

        crlf

        jsr krn_primm
        .byte "Reserved sectors  : $",$00

        lda volid + VolumeID::RsvdSecCnt+1
        jsr krn_hexout
        lda volid + VolumeID::RsvdSecCnt
        jsr krn_hexout

        crlf

        jsr krn_primm
        .byte "Sectors / FAT     : $",$00

        lda volid + VolumeID::FATSz32+3
        jsr krn_hexout
        lda volid + VolumeID::FATSz32+2
        jsr krn_hexout
        lda volid + VolumeID::FATSz32+1
        jsr krn_hexout
        lda volid + VolumeID::FATSz32+0
        jsr krn_hexout

        crlf




        jmp (retvec)
