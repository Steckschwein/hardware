.include "kernel.inc"
.include "fat32.inc"
.segment "KERNEL"
.import sd_read_block, sd_read_multiblock, sd_write_block, sd_select_card, sd_deselect_card
.export fat_mount, fat_open, fat_open_rootdir, fat_close, fat_read, fat_find_first, fat_find_next

; DEBUG
.import hexout, primm


FD_start_cluster = $00
FD_file_size = $08


.macro saveClusterNo where
	ldy #DIR_FstClusHI +1
	lda (sd_blkptr),y
	sta where +3

	dey
	lda (sd_blkptr),y
	sta where +2

	ldy #DIR_FstClusLO +1
	lda (sd_blkptr),y
	sta where +1
	
	dey
	lda (sd_blkptr),y
	sta where
.endmacro

; !macro saveClusterNo .where {
; 	ldy #DIR_FstClusHI +1
; 	lda (sd_blkptr),y
; 	sta .where +3

; 	dey
; 	lda (sd_blkptr),y
; 	sta .where +2

; 	; stz .where +3
; 	; stz .where +2
; 	ldy #DIR_FstClusLO +1
; 	lda (sd_blkptr),y
; 	sta .where +1
	
; 	dey
; 	lda (sd_blkptr),y
; 	sta .where

; } 

; blocks = tmp7

fat_read:
		jsr calc_lba_addr
		jsr calc_blocks

        debug32 lba_addr
        debugHex blocks

		jmp sd_read_multiblock
;		jmp sd_read_block
 
fat_open:
		pha
		phy

		stz errno

		ldx #$00
		jsr calc_lba_addr

        debug32 lba_addr

		jsr fat_find_first
		bcs fat_open_found

lbl_fat_no_such_file:
		lda #fat_file_not_found
		sta errno
		jmp end_open

lbl_fat_open_error:
		lda #fat_open_error
		sta errno
		jmp end_open

; found.
fat_open_found:
		ldy #$00
@loo:	lda (dirptr),y
		iny
		cpy #11
		bne @loo 
		ldy #DIR_Attr
		lda (dirptr),y
		bit #$10 ; Is a directory
		beq @l1

		ldx #$00 ; direcories always go to fd #0
		saveClusterNo current_dir_first_cluster
		; bra .end_open 
		bra @l2

@l1:	bit #$20 ; Is file
		beq lbl_fat_open_error

		jsr fat_alloc_fd
		cpx #$ff
		beq lbl_fat_open_error
	
@l2:
		ldy #DIR_FstClusHI +1
		lda (dirptr),y
		sta fd_area + FD_start_cluster +3, x

		dey	
		lda (dirptr),y
		sta fd_area + FD_start_cluster +2, x
		
		ldy #DIR_FstClusLO +1
		lda (dirptr),y
		sta fd_area + FD_start_cluster +1, x
		
		dey
		lda (dirptr),y
		sta fd_area + FD_start_cluster +0, x

	; Cluster no = 0? assume its root dir and add 2

		lda fd_area + FD_start_cluster + 3, x
		bne @l3
		lda fd_area + FD_start_cluster + 2, x
		bne @l3
		lda fd_area + FD_start_cluster + 1, x
		bne @l3
		lda fd_area + FD_start_cluster + 0, x
		bne @l3


		lda root_dir_first_clus +1
		sta fd_area + FD_start_cluster +1, x
		lda root_dir_first_clus +0
		sta fd_area + FD_start_cluster +0, x

@l3:
		ldy #DIR_FileSize + 3
		lda (dirptr),y
		sta fd_area + FD_file_size + 3, x
		ldy #DIR_FileSize + 2
		lda (dirptr),y
		sta fd_area + FD_file_size + 2, x
		ldy #DIR_FileSize + 1
		lda (dirptr),y
		sta fd_area + FD_file_size + 1, x
		ldy #DIR_FileSize + 0
		lda (dirptr),y
		sta fd_area + FD_file_size + 0, x

end_open:
		ply
		pla

		rts

inc_blkptr:
		; Increment blkptr by 32 bytes, jump to next dir entry
		clc
		lda sd_blkptr
		adc #32
		sta sd_blkptr
		bcc @l
		inc sd_blkptr+1	
@l:
		rts

fat_check_signature:
		rts
		lda #$55
		cmp sd_blktarget + BS_Signature
		bne @l1
		asl ; $aa
		cmp sd_blktarget + BS_Signature+1
		beq @l2
@l1:	lda #fat_bad_block_signature
		sta errno
@l2:	rts


calc_blocks:
		pha
		lda fd_area + FD_file_size+3,x
		lsr
		lda fd_area + FD_file_size+2,x
		ror
		lda fd_area + FD_file_size+1,x
		ror
		sta blocks
		bcs @l1
		lda fd_area + FD_file_size+0,x
		beq @l2
@l1:	inc blocks
@l2:	pla
		rts


; calculate LBA address of first block from cluster number found in file descriptor entry
; file descriptor index must be in x
calc_lba_addr:
		pha
		phx
		
		lda fd_area + FD_start_cluster +3, x 

		cmp #$ff
		beq file_not_open
		
		; lba_addr = cluster_begin_lba + (cluster_number - 2) * sectors_per_cluster;
		sec
		lda fd_area + FD_start_cluster, x 
		sbc #$02
		sta lba_addr

		lda fd_area + FD_start_cluster + 1,x 
		sbc #$00
		sta lba_addr + 1
		lda fd_area + FD_start_cluster + 2,x 
		sbc #$00
		sta lba_addr + 2
		lda fd_area + FD_start_cluster + 3,x 
		sbc #$00
		sta lba_addr + 3
		
        ;sectors_per_cluster -> is a power of 2 value, therefore cluster << n, where n ist the number of bit set in sectors_per_cluster
        lda sectors_per_cluster
@lm:    lsr
        beq @lme    ; 1 sec/cluster nothing at all
        tax
        asl lba_addr
        rol lba_addr +1
        rol lba_addr +2
        rol lba_addr +3
        txa
        bra @lm
@lme:
        ; add cluster_begin_lba and lba_addr
		clc
		.repeat 4, i
			lda cluster_begin_lba + i
			adc lba_addr + i
			sta lba_addr + i
		.endrepeat
        
calc_end:
		plx
		pla

		rts

file_not_open:
		lda #fat_file_not_open
		sta errno
		bra calc_end

inc_lba_address:
		inc lba_addr + 0
		bne @l1
		inc lba_addr + 1
		bne @l1
		inc lba_addr + 2
		bne @l1
		inc lba_addr + 3
@l1:
		rts





;---------------------------------------------------------------------
; Mount FAT32 on Partition 0
;---------------------------------------------------------------------
fat_mount:
		save

		; set lba_addr to $00000000 since we want to read the bootsector
		
		.repeat 4, i
			stz lba_addr + i	
		.endrepeat
		

		SetVector sd_blktarget, sd_blkptr

		jsr sd_read_block
		
		jsr fat_check_signature

		lda errno
		beq @l1
		jmp end_mount
	
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
		jmp end_mount

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
		jmp end_mount
@l4:


		; Bytes per Sector, must be 512 = $0200
		lda sd_blktarget + BPB_BytsPerSec
		bne @l5
		lda sd_blktarget + BPB_BytsPerSec + 1
		cmp #$02
		beq @l6
@l5:	lda #fat_invalid_sector_size
		sta errno
		jmp end_mount
@l6:


		; Sectors per Cluster. Valid: 1,2,4,8,16,32,64,128
		lda sd_blktarget + BPB_SecPerClus
		sta sectors_per_cluster
		
		; cluster_begin_lba = Partition_LBA_Begin + Number_of_Reserved_Sectors + (Number_of_FATs * Sectors_Per_FAT);

		; add number of reserved sectors to fat_begin_lba. store in cluster_begin_lba
		clc

		lda lba_addr + 0
		adc sd_blktarget + BPB_RsvdSecCnt + 0
		sta cluster_begin_lba + 0
		sta fat_first_block + 0	
		lda lba_addr + 1
		adc sd_blktarget + BPB_RsvdSecCnt + 1
		sta cluster_begin_lba + 1
		sta fat_first_block + 1	

		lda lba_addr + 2
		adc #$00
		sta cluster_begin_lba + 2
		sta fat_first_block + 2	

		lda lba_addr + 3
		adc #$00
		sta cluster_begin_lba + 3
		sta fat_first_block + 3	


		; Number of FATs. Must be 2
		; lda sd_blktarget + BPB_NumFATs	
		; add sectors_per_fat * 2 to cluster_begin_lba

		ldy #$02
@l7:	clc
		ldx #$00	
@l8:	ror ; get carry flag back
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
		jsr fat_init_fdarea


		Copy sd_blktarget + BPB_RootClus, root_dir_first_clus, 3

		; now we have the lba address of the first sector of the first cluster

end_mount:
		; jsr .sd_deselect_card
		restore
		; rts

		; fall through to open_rootdir
	
fat_open_rootdir:
		; Open root dir
		Copy root_dir_first_clus, fd_area + FD_start_cluster, 3
		Copy root_dir_first_clus, current_dir_first_cluster, 3
		jmp calc_lba_addr
		; rts

fat_init_fdarea:
		ldx #$00
@l1:	lda #$ff
		sta fd_area + FD_start_cluster +3 , x

		txa ; 2 cycles
		clc ; 2 cycles
		adc #$08 ; 2  cycles
		tax ; 2 cycles

		cpx #$80
		bne @l1

		rts

fat_alloc_fd:
		ldx #$08
		
@l1:	lda fd_area + FD_start_cluster +3, x
		cmp #$ff
		beq @l2

		txa ; 2 cycles
		clc ; 2 cycles
		adc #$08 ; 2  cycles
		tax ; 2 cycles

		cpx #$80
		bne @l1

		; Too many open files, no free file descriptor found
		lda #fat_too_many_files
		sta errno
		
		
@l2:
		rts

fat_close:
		lda #$ff
		sta fd_area + FD_start_cluster +3 , x
		rts


fat_find_first:
		ldy #$00
@l1:	lda (filenameptr),y
		beq @l2
		toupper
		sta filename_buf,y
		
		iny
		cpy #12
		bne @l1
@l2:	lda #$00
		sta filename_buf,y

		SetVector sd_blktarget, sd_blkptr
		ldx #$00
		jsr calc_lba_addr
		
ff_l3:	SetVector sd_blktarget, dirptr	
		jsr sd_read_block
		dec sd_blkptr+1


ff_l4:
		lda (dirptr)
		bne @l5
		clc 				; first byte of dir entry is $00?
		rts   				; we are at the end, clear carry and return	
@l5:
		ldy #DIR_Attr		; else check if long filename entry
		lda (dirptr),y 		; we are only going to filter those here (or maybe not?)
		cmp #$0f
		beq fat_find_next
		
		jsr match
		bcs ff_end

fat_find_next:
		lda dirptr
		clc
		adc #$20
		sta dirptr
		bcc @l6
		inc dirptr+1
@l6:

		lda dirptr+1 	; end of block?
		cmp #$06
		bcc ff_l4			; no, show entr
		; increment lba address to read next block 
		jsr inc_lba_address	
		bra ff_l3

ff_end:
		rts



match:
	ldx #0
	ldy #0

	; 0..1 in input may be "." or "..", so compare dir entry with .
match_skip_dots:
	lda	#'.'
	cmp	filename_buf,x
	bne	match_0

	cmp (dirptr),y
	bne m_not_found
	inx					; 2nd "." ?
	iny
	lda	filename_buf,x
	bne	match_skip_dots_1 ; end of input ?
	lda	#' '
	cmp (dirptr),y
	bne m_not_found
match_skip_dots_1:
	cpy #02
	bne match_skip_dots
	bra	match_ext_0	
	
match_0:
	lda filename_buf,x
	beq m_found		;end of input, found
	cmp #'*'
	beq m_n
	cmp #'?'
	beq m_1			; ? found - skip compare, matches anything - note: multiple ? will end up in consuming the input string char by char until ' '
	cmp #'.'		; . found
	bne m_r

	inx
match_ext_0:
	lda #' '		; seek to dir entry extension offset	
match_ext:
	cmp (dirptr),y
	bne match_0
match_ext_1:
	iny
	cpy #DIR_Attr
	beq	m_found		; end of dir?
	bra	match_ext
	
m_r:	cmp	#'a'		; regular char, match uppercase
		bcc m_r_match
		cmp #'z'
		bcs m_r_match
		and #$df		; uppercase
m_r_match:	
		cmp (dirptr),y	; regular char, compare
		bne m_not_found
m_1:
		inx
		iny
		cpy #DIR_Attr
		bne match_0
	
		lda filename_buf,x	;input chars left?
		beq m_found
		bra m_not_found
	
m_n:	inx
		cmp filename_buf,x	; skip read multiple '*'
		beq m_n
		
		lda #' '
m_n1:
		cmp (dirptr),y		; until ' '
		beq match_ext_1		; then go on with skip until extension above
m_n2:
		iny		
		cpy #DIR_Attr
		bne m_n1	; end of dir entry? found...
m_found:
		sec
	 	rts
m_not_found:
		clc
	 	rts

