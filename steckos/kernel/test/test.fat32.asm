	.include "asmunit.inc" 	; test api
	.include "fat32.inc"
	.include "zeropage.inc"
	
	.import __calc_lba_addr
	.import __fat_isroot
	
.segment "KERNEL"	; test must be placed into kernel segment, cuz we wanna use the same linker config

		jsr setUp

		test_name "isRoot"
		
		ldx #0				
		jsr __fat_isroot
		assertZero 1		; expect fd0 - "is root"
		assertX 0

		ldx #4
		jsr __fat_isroot
		assertZero 0		; expect fd0 - "is not root"
		assertX 4		
		
		test_name "calc_lba"
		
		ldx #0
		jsr __calc_lba_addr
		assertX 0
		assert32 $00006800, lba_addr ; expect $67fe + $2 => the root dir lba
		
		ldx #4
		jsr __calc_lba_addr
		assertX 4
		assert32 $000068e6, lba_addr ; expect $67fe + (clnr * sec/cl) => $67fe + $e8 * 1 = $68e6		
		
;		jsr mock
		
		brk

setUp:
	lda #1
	sta volumeID+VolumeID::BPB + BPB::SecPerClus

	lda #$00
	sta volumeID + VolumeID::EBPB + EBPB::RootClus+3
	sta volumeID + VolumeID::EBPB + EBPB::RootClus+2
	sta volumeID + VolumeID::EBPB + EBPB::RootClus+1
	lda #$02
	sta volumeID + VolumeID::EBPB + EBPB::RootClus+0
	
	lda #$00						;cl lba $67fe
	sta cluster_begin_lba+3
	sta cluster_begin_lba+2
	lda #$67
	sta cluster_begin_lba+1
	lda #$fe
	sta cluster_begin_lba+0
	
	ldx #0
	lda #0												;setup fd0 as root cluster
	sta fd_area+F32_fd::CurrentCluster+0,x		
	sta fd_area+F32_fd::CurrentCluster+1,x
	sta fd_area+F32_fd::CurrentCluster+2,x
	sta fd_area+F32_fd::CurrentCluster+3,x
	
	ldx #4
	lda #0												;setup fd1 as with test cluster
	sta fd_area+F32_fd::CurrentCluster+1,x
	sta fd_area+F32_fd::CurrentCluster+2,x
	sta fd_area+F32_fd::CurrentCluster+3,x
	lda #$e8
	sta fd_area+F32_fd::CurrentCluster+0,x		
	
	rts

		
.export __rtc_systime_update=mock
.export read_block=mock
.export sd_read_multiblock=mock
.export write_block=mock
.export dirname_mask_matcher=mock
.export cluster_nr_matcher=mock
.export fat_name_string=mock
.export path_inverse=mock
.export put_char=mock
.export string_fat_mask=mock
.export string_fat_name=mock


mock:
		clc
		assertCarry 1; fail, if a mock is called and thus is not implemented yet ;)
		rts
		
		
.segment "ASMUNIT"
