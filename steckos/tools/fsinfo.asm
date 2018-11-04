; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

.include "kernel.inc"
.include "kernel_jumptable.inc"
.include "common.inc"

.include "../kernel/fat32.inc"
.include "../kernel/sdcard.inc"

.include "appstart.inc"
data = $2000
part0 = data + BootSector::Partitions + PartTable::Partition_0

appstart $1000

        stz lba_addr+0
        stz lba_addr+1
        stz lba_addr+2
        stz lba_addr+3

        SetVector data, read_blkptr
        jsr krn_sd_read_block

        m_memcpy part0 + PartitionEntry::LBABegin, lba_addr, 4

        jsr krn_primm
        .byte "Partition info: ",$0a,"Bootable      :",$00
        lda part0 + PartitionEntry::Bootflag
        and #$0f
        ora #'0'
        jsr krn_chrout

        jsr krn_primm
        .byte $0a,"Type Code     :$", $00
        lda part0 + PartitionEntry::TypeCode
        jsr hexout
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


        SetVector data, read_blkptr
        jsr krn_sd_read_block

        jsr krn_primm
        .byte $0a,$0a,"Filesystem Info: ",$00

        jsr krn_primm
        .byte $0a,"Media Type        :$",$00
        lda data + F32_VolumeID::BPB + BPB::Media
        jsr hexout

        jsr krn_primm
        .byte $0a,"OEM Name          :",$00

        ldx #$00
@l:
        lda data + F32_VolumeID::OEMName,x
        jsr krn_chrout
        inx
        cpx #$08
        bne @l

        jsr krn_primm
        .byte $0a,"Volume Label      :",$00
        ldx #$00
@l1:
        lda data + F32_VolumeID::EBPB + EBPB::VolumeLabel,x
        jsr krn_chrout
        inx
        cpx #$0b
        bne @l1

        jsr krn_primm
        .byte $0a,"FS Type           :",$00
        ldx #$00
@l2:
        lda data + F32_VolumeID::EBPB + EBPB::FSType,x
        jsr krn_chrout
        inx
        cpx #$08
        bne @l2


        jsr krn_primm
        .byte $0a,"Bytes / sector    :",$00

        ldx data + F32_VolumeID::BPB + BPB::BytsPerSec+1
        lda data + F32_VolumeID::BPB + BPB::BytsPerSec
        jsr BINBCD16
        ldx #$02
        jsr display_bcd


        jsr krn_primm
        .byte $0a,"Sectors / cluster :",$00

        lda data + F32_VolumeID::BPB + BPB::SecPerClus
        ldx #$00
        jsr BINBCD16
        ldx #$02
        jsr display_bcd

        jsr krn_primm
        .byte $0a,"Number of FATs    :",$00

        lda data + F32_VolumeID::BPB + BPB::NumFATs
        and #$0f
        ora #'0'
        jsr krn_chrout

        jsr krn_primm
        .byte $0a,"Active FAT        :",$00

        lda data + F32_VolumeID::EBPB + EBPB::MirrorFlags
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

        ldx data + F32_VolumeID::BPB + BPB::RsvdSecCnt+1
        lda data + F32_VolumeID::BPB + BPB::RsvdSecCnt
        jsr BINBCD16
        ldx #$02
        jsr display_bcd
        crlf

        jsr krn_primm
        .byte "Sectors / FAT     :",$00

        m_memcpy data + F32_VolumeID::EBPB + EBPB::FATSz32, tmp0, 4
        jsr BINBCD32
        ldx #$05
        jsr display_bcd

        jsr krn_primm
        .byte $0a,"FSInfo sector LBA :",$00

        lda data + F32_VolumeID::EBPB + EBPB::FSInfoSec
        clc
        adc lba_addr+0
        sta lba_addr+0

        lda data + F32_VolumeID::EBPB + EBPB::FSInfoSec+1
        adc lba_addr+1
        sta lba_addr+1


        lda #$00
        adc lba_addr+2
        sta lba_addr+2
        lda #$00
        adc lba_addr+3
        sta lba_addr+3

        m_memcpy lba_addr, tmp0, 4

        jsr BINBCD32
        ldx #$05
        jsr display_bcd


        SetVector data, read_blkptr
        jsr krn_sd_read_block

        jsr krn_primm
        .byte $0a,"Free clusters     :",$00
        m_memcpy data + F32FSInfo::FreeClus, tmp0, 4

        jsr BINBCD32
        ldx #$05
        jsr display_bcd

        jsr krn_primm
        .byte $0a,"Last cluster      :",$00
        m_memcpy data + F32FSInfo::LastClus, tmp0, 4

        jsr BINBCD32
        ldx #$05
        jsr display_bcd

        crlf

        jmp (retvec)

BINBCD16:
        sta tmp0
		stx tmp0+1
        SED             ; Switch to decimal mode
        STZ BCD+0
        STZ BCD+1
        STZ BCD+2
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
        STZ BCD+0
        STZ BCD+1
        STZ BCD+2
        STZ BCD+3
        STZ BCD+4
        STZ BCD+5

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
        STA BCD+4;
        LDA BCD+5       ; ... thru whole result
        ADC BCD+5
        STA BCD+5

        DEX             ; And repeat for next bit
        BNE @CNVBIT
        CLD             ; Back to binary

        rts

display_bcd:
@l1:    lda BCD,x
        bne @l
        dex
        bpl @l1
@l:
        lda BCD,x
        jsr hexout
        dex
        bpl @l
        rts

hexout:
		pha
		phx

		tax
		lsr
		lsr
		lsr
		lsr
		jsr hexdigit
		txa
		jsr hexdigit
		plx
		pla
		rts

hexdigit:
		and     #%00001111      ;mask lsd for hex print
		ora     #'0'            ;add "0"
		cmp     #'9'+1          ;is it a decimal digit?
		bcc     @l	            ;yes! output it
		adc     #6              ;add offset for letter a-f
@l:
		jmp 	krn_chrout

BCD: .res 6
tmp0: .res 2
;.align 255,0
;data:
