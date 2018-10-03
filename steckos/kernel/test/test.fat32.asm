	.include "asmunit.inc" 	; test api
	.include "fat32.inc"
	.include "zeropage.inc"
	
	.import __calc_fat_lba_addr
	.import __fat_isroot
	
.segment "KERNEL"	; test must be placed into kernel segment, cuz we wanna use the same linker config

		jsr _setup
		
		ldx #0
		lda #0												;setup fd0 as root cluster
		sta fd_area+F32_fd::CurrentCluster+0,x		
		sta fd_area+F32_fd::CurrentCluster+1,x
		sta fd_area+F32_fd::CurrentCluster+2,x
		sta fd_area+F32_fd::CurrentCluster+3,x
		
		jsr __fat_isroot
		assertZero 1		; expext "is root"
		
		
		jsr __calc_fat_lba_addr

		assertX 0
		assertA 0
		assert32 $00002800, lba_addr
		
		brk

_setup:
	lda #1
	sta volumeID+VolumeID::BPB + BPB::SecPerClus
	
	lda #$00
	sta cluster_begin_lba+0
	lda #$28
	sta cluster_begin_lba+1
	lda #$00
	sta cluster_begin_lba+2
	sta cluster_begin_lba+3
	
	stz lba_addr+0
	stz lba_addr+1
	stz lba_addr+2
	stz lba_addr+3

	rts

		
.export __rtc_systime_update=mock__rtc_systime_update
.export read_block=mock_read_block
.export sd_read_multiblock=mock_sd_read_multiblock
.export write_block=mock_write_block

mock_sd_read_multiblock:
mock_read_block:
mock_write_block:
mock__rtc_systime_update:
		rts
		
		
.segment "ASMUNIT"
