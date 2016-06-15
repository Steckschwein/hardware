.export fat_mount, fat_read, fat_find_first, calc_lba_addr
.import sd_read_block
.include "bios.inc"
.segment "BIOS"

;---------------------------------------------------------------------
; Mount FAT32 on Partition 0
;---------------------------------------------------------------------
fat_mount:
		save

		; set lba_addr to $00000000 since we want to read the bootsector
		; .repeat 4,i
		; 	stz lba_addr + i	           
		; .endrep

		ldx #$03
@l:		stz lba_addr,x
		dex
		bpl @l

			
		SetVector sd_blktarget, sd_blkptr

		jsr sd_read_block

		jsr fat_check_signature

		lda errno
		beq @l1
		; jmp @end_mount
		restore
		rts

@l1:
		part0 = sd_blktarget + BS_Partition0

		lda part0 + PE_TypeCode
		cmp #$0b
		beq @l2
		cmp #$0c
		beq @l2

		; type code not $0b or $0c
		lda #fat_invalid_partition_type
		sta errno
		; jmp @end_mount
		restore
		rts

@l2:
		ldx #$00

@l3:
		lda part0 + PE_LBABegin,x
		sta lba_addr,x
		inx
		cpx #$04
		bne @l3


		; Write LBA start address to sd param buffer
		; +SDBlockAddr fat_begin_lba

		SetVector sd_blktarget, sd_blkptr	
		; Read FAT Volume ID at LBABegin and Check signature
		jsr sd_read_block

		jsr fat_check_signature
		lda errno
		beq @l4
		; jmp @end_mount
		restore
		rts
@l4:
		; Bytes per Sector, must be 512 = $0200
		lda sd_blktarget + BPB_BytsPerSec
		bne @l5
		lda sd_blktarget + BPB_BytsPerSec + 1
		cmp #$02
		beq @l6
@l5:
		lda #fat_invalid_sector_size
		sta errno
		jmp @end_mount
@l6:
		; Sectors per Cluster. Valid: 1,2,4,8,16,32,64,128
		lda sd_blktarget + BPB_SecPerClus
		sta sectors_per_cluster
		
		; cluster_begin_lba = Partition_LBA_Begin + Number_of_Reserved_Sectors + (Number_of_FATs * Sectors_Per_FAT);

		; add number of reserved sectors to fat_begin_lba. store in cluster_begin_lba
		clc

		.repeat 2,i 
			lda lba_addr + i
			adc sd_blktarget + BPB_RsvdSecCnt + i
			sta cluster_begin_lba + i	
		.endrep

		.repeat 2,i 
			lda lba_addr + i + 2
			adc #$00
			sta cluster_begin_lba + i + 2
		.endrep


		ldy #$02
@l7:
		clc
		ldx #$00	
@l8:
		ror ; get carry flag back
		lda sd_blktarget + BPB_FATSz32,x ; sectors per fat
		adc cluster_begin_lba,x
		sta cluster_begin_lba,x
		inx
		rol ; save status register before cpx to save carry
		cpx #$04	
		bne @l8
		dey
		bne @l7

		; init file descriptor area
		; jsr .fat_init_fdarea

		Copy sd_blktarget + BPB_RootClus, root_dir_first_clus, 3


		; now we have the lba address of the first sector of the first cluster

@end_mount:
		; jsr .sd_deselect_card
		restore
		; rts

		; fall through to open_rootdir
	
fat_open_rootdir:
		; Open root dir
		; +Copy root_dir_first_clus, current_dir_first_cluster, 3
		jmp calc_lba_addr
		; rts

; calculate LBA address of first block from cluster number found in file descriptor entry
; file descriptor index must be in x
calc_lba_addr:
		pha

		sec
		lda root_dir_first_clus
		sbc #$02
		sta tmp0 
		lda root_dir_first_clus + 1
		sbc #$00
		sta tmp0 + 1
		lda root_dir_first_clus + 2
		sbc #$00
		sta tmp0 + 2
		lda root_dir_first_clus + 3
		sbc #$00
		sta tmp0 + 3


		Copy cluster_begin_lba, lba_addr, 3
		
		ldx sectors_per_cluster
@l1:	clc
		; FOOBAR
		lda tmp0 + 0
		adc lba_addr + 0
		sta lba_addr + 0	
		lda tmp0 + 1
		adc lba_addr + 1
		sta lba_addr + 1	
		lda tmp0 + 2
		adc lba_addr + 2
		sta lba_addr + 2	
		lda tmp0 + 3
		adc lba_addr + 3
		sta lba_addr + 3	

		dex
		bne @l1

		pla

		rts

fat_check_signature:
		lda #$55
		cmp sd_blktarget + BS_Signature
		bne @l1
		asl ; $aa
		cmp sd_blktarget + BS_Signature+1
		beq @l2
@l1:	lda #fat_bad_block_signature
		sta errno
@l2:	rts

inc_lba_address:
		inc lba_addr + 0
		bne @l
		inc lba_addr + 1
		bne @l
		inc lba_addr + 2
		bne @l
		inc lba_addr + 3
@l:
		rts


fat_find_first:

		SetVector sd_blktarget, sd_blkptr
		ldx #$00
		jsr calc_lba_addr


nextblock:	
		SetVector sd_blktarget, dirptr	
		jsr sd_read_block
		dec sd_blkptr+1

nextentry:
		lda (dirptr)
		bne @l1
		clc 				; first byte of dir entry is $00?
		rts   				; we are at the end, clear carry and return
@l1:	
		ldy #DIR_Attr		; else check if long filename entry
		lda (dirptr),y 		; we are only going to filter those here (or maybe not?)
		cmp #$0f

		beq fat_find_next
		
		jsr match
		bcs found

fat_find_next:
		lda dirptr
		clc
		adc #$20
		sta dirptr
		bcc @l2
		inc dirptr+1
@l2:
		lda dirptr+1 	; end of block?
		cmp #$06
		bcc nextentry			; no, show entr
		; increment lba address to read next block 
		jsr inc_lba_address	
		bra nextblock

found:
		rts



match:
		phy
		ldy #$00
@l1:	lda (dirptr),y
		; jsr vdp_chrout
		cmp (ptr1),y
		bne @l2
		iny
		cpy #$0b
		bne @l1
		sec
		ply
		rts
@l2:	ply
		clc
		rts


calc_blocks:
		pha
		lda filesize+3,x
		lsr
		lda filesize+2,x
		ror
		lda filesize+1,x
		ror
		sta blocks
		bcs @l1
		lda filesize,x
		beq @l2
@l1:	inc blocks
@l2:	pla
		rts

fat_read:
		jsr calc_lba_addr
		jsr calc_blocks

@l1:	jsr sd_read_block
		inc sd_blkptr+1 ; 3 bytes, 6 cycles

		jsr inc_lba_address
		
		dec blocks
		bne @l1
		
		rts

