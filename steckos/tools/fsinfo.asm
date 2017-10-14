.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "common.inc"

.include "../kernel/fat32.inc"
.include "../kernel/sdcard.inc"

.include "appstart.inc"

data = $2000
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

        jsr krn_primm
        .byte "FSInfo sector     : $",$00

        lda volid + VolumeID::FSInfoSec+1
        sta sd_cmd_param+1
        jsr krn_hexout
        lda volid + VolumeID::FSInfoSec
        sta sd_cmd_param+0
        jsr krn_hexout

;       stz sd_cmd_param+0
;        stz sd_cmd_param+1
        stz sd_cmd_param+2
        stz sd_cmd_param+3
        stz sd_cmd_chksum

        crlf
;        SetVector data, read_blkptr
;        jsr krn_sd_read_block


;        lda data
;        jsr krn_hexout
;        lda data+1
;        jsr krn_hexout
;        lda data+2
;        jsr krn_hexout
;        lda data+3
;        jsr krn_hexout



        jmp (retvec)
