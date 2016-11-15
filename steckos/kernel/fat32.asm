.include "kernel.inc"
.include "fat32.inc"
.include "errno.inc"
.include "filedes.inc"

.import sd_read_block, sd_read_multiblock, sd_write_block, sd_select_card, sd_deselect_card
.import sd_read_block_data
;.importzp ptr1
        
.export fat_mount
.export fat_open, fat_isOpen, fat_chdir
.export fat_read, fat_read2, fat_find_first, fat_find_next
.export fat_close_all, fat_close, fat_getfilesize


.ifdef DEBUG ; DEBUG
    .import krn_hexout, krn_primm, krn_chrout, krn_strout, krn_print_crlf
.endif

.segment "KERNEL"

.macro saveClusterNo where
	ldy #DIR_FstClusHI +1
	lda (sd_read_blkptr),y
	sta where +3

	dey
	lda (sd_read_blkptr),y
	sta where +2

	ldy #DIR_FstClusLO +1
	lda (sd_read_blkptr),y
	sta where +1
	
	dey
	lda (sd_read_blkptr),y
	sta where
.endmacro

		;in: 
		;	a/x - count 
		;	dw	- word as pointer to target adress
		;	db	- byte as offset into fd_area
		;out:
		;	a/x - bytes read on success, -1 on error and errno set accordingly
fat_read2:
		cmp		#0
		bne		@_r0			; edge case, test if the count argument is zero?
		cpx		#0
		bne		@_r1			
        stz     __oserror
		bra		@_rexit
@_r0:	
		cpx		#2				; a was not zero, if cpx is >= $2 we have to read > BLOCK_SIZE, cannot store to target ptr :/
	
@_r1:			
		sta		krn_ptr3			; save count
		stx		krn_ptr3+1
		eor     #$ff				; the count argument
        sta     krn_ptr1
        txa
        eor     #$ff
        sta     krn_ptr1+1          ; remember -count-1
		
		pla
		sta		sd_read_blkptr
		pla
		sta 	sd_read_blkptr+1
		plx							; pop fd
        debugcpu "fr2"
        jsr calc_lba_addr
		jsr calc_blocks
;        debug32s "r2 lb:", lba_addr
;		debug24s "r2 bc:", blocks
;		SetVector block_data, sd_read_blkptr		; vector to kernel block_data area		
		jsr sd_read_block
		lda	errno
		debugA "r2"
		rts
@_rexit:
		pla
		pla
		pla
		rts		
		
		;in: 
		;	x - offset into fd_area
fat_read:
        stz errno
        
        debugcpu "fr"
        jsr calc_lba_addr
		jsr calc_blocks
;        debug32s "fr lba:", lba_addr
;		debug24s "fr bc:", blocks
;        debug32s "fr fs: ", fd_area + (FD_Entry_Size*2) + FD_file_size ;1st file entry
		jmp sd_read_multiblock
;		jmp sd_read_block
 
 
		;in:
        ;   a/x - pointer to the file path
        ;out: 
        ;   a - errno 
        ;   x - index into fd_area of the opened directory
fat_chdir:
		jsr fat_open			; change dir using temp dir to not clobber the current dir, maybe we will run into an error
		bne	@l_err_exit			; exit on error
        lda	fd_area + FD_file_attr, x
		bit #FD_ATTR_DIR		; check that there is no error and we have a directory
		beq	@l_err

        phx
		ldx #FD_INDEX_TEMP_DIR  ; the temp dir fd is now set to the last dir of the path and we proofed that it's valid with the code above
        ldy #FD_INDEX_CURRENT_DIR
        jsr	fat_clone_fd        ; therefore we can simply clone the temp dir to current dir fd - ftw...
        plx
        lda #0                  ; ok, no error
        rts
@l_err:
		lda	#EINVAL				; TODO FIXME error code for "Not a directory"
@l_err_exit:
		debugA	"cde"
		rts
 
 
.macro _open
		stz	pathFragment, x	;\0 terminate the current path fragment
        ;debugstr "_o", pathFragment		
        jsr	_fat_open
        debugA "o_"
		bne @l_exit
:
.endmacro

        ;in:
        ;   a/x - pointer to the file path
        ;out: 
        ;   x - index into fd_area of the opened file
        ;   a - errno
fat_open:
        sta krn_ptr1
        stx krn_ptr1+1			    ; save path arg given in a/x
        
        ldx #FD_INDEX_CURRENT_DIR   ; clone current dir fd to temp dir fd
        ldy #FD_INDEX_TEMP_DIR
        jsr fat_clone_fd
		
		ldy	#0
		;	trim wildcard at the beginning
@l1:	lda (krn_ptr1), y
		cmp	#' '
		bne	@l2
		iny 
		bne @l1
        lda #EINVAL
        rts
@l2:	;	starts with / ? - cd root
		cmp	#'/'
		bne	@l31
		jsr fat_open_rootdir
		iny
        lda	(krn_ptr1), y
		beq	@l_exit_noerr       ; end of input? so it was just the '/'
        cmp #' '                ; or space
        bne @l31
        bra @l_exit_noerr       ; exit, no error
@l31:   SetVector   pathFragment, filenameptr	; filenameptr to path fragment
@l3:	;	parse path fragments and change dirs accordingly
		ldx #0
@l_parse_1:
        lda	(krn_ptr1), y
		beq	@l_openfile
		cmp	#' '                ;TODO FIXME support file/dir name with spaces? it's beyond 8.3 file support
		beq	@l_openfile
		cmp	#'/'
		beq	@l_open
		
		sta pathFragment, x
		iny
		inx
		cpx	#8+1+3	            ; 8.3 file support only
		bne	@l_parse_1
        lda #EINVAL
        bra @l_exit
@l_open:
		_open
		iny
		bne	@l3
		;TODO FIXME handle overflow - <path argument> too large
		lda	#EINVAL
        bra @l_exit
@l_exit_noerr:
        lda #0
@l_exit:
		debugA	"f2e:"
		rts        
@l_openfile:
		_open				; return with x as offset to fd_area
        bra @l_exit_noerr
pathFragment: .res 8+1+3+1; 12 chars + \0 for path fragment


        ;in:
        ;   filenameptr - ptr to the filename
        ;out: 
        ;   x - index into fd_area of the opened file
        ;   a - errno
_fat_open:
        phy
        
		debugptr "fp:", filenameptr
		
        ldx #FD_INDEX_TEMP_DIR
		jsr fat_find_first
        ldx #FD_INDEX_TEMP_DIR
		bcs fat_open_found
		lda #ENOENT
		jmp end_open_err
        
lbl_fat_open_error:
        lda #EINVAL ; TODO FIXME
		jmp end_open_err

; found.
fat_open_found:
		ldy #DIR_Attr
		lda (dirptr),y
		debugA "d"
		bit #$10 			; is it a directory?
		bne @l2				; go on, do not allocate fd, index is set to FD_INDEX_TEMP_DIR

@l1:	bit #$20 ; Is file?
		beq lbl_fat_open_error

		jsr fat_alloc_fd
		beq @l2
        jmp end_open_err
@l2:	        
        debugcpu "fd"
        ;save 32 bit cluster number from dir entry
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

		; cluster no = 0? - its root dir, set to root dir first cluster
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
        ldy #DIR_Attr
        lda (dirptr),y
		sta fd_area + FD_file_attr, x

		lda #0 ; no error
end_open_err:
        ply
		cmp	#$00	;restore z flag
		rts

inc_blkptr:
		; Increment blkptr by 32 bytes, jump to next dir entry
		clc
		lda sd_read_blkptr
		adc #32
		sta sd_read_blkptr
		bcc @l
		inc sd_read_blkptr+1	
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


calc_blocks: ;blocks = filesize / BLOCKSIZE -> filesize >> 9 (div 512) +1 if filesize LSB is not 0
		lda fd_area + FD_file_size+3,x
		lsr
		sta blocks + 2
		lda fd_area + FD_file_size+2,x
		ror
		sta blocks + 1
		lda fd_area + FD_file_size+1,x
		ror
		sta blocks
		bcs @l1
		lda fd_area + FD_file_size+0,x
		beq @l2
@l1:	inc blocks
		bne @l2
		inc blocks+1
		bne @l2
		inc blocks+2
@l2:	rts

; calculate LBA address of first block from cluster number found in file descriptor entry
; file descriptor index must be in x
calc_data_lba_addr:
calc_lba_addr:
		pha
		phx
		
		lda fd_area + FD_start_cluster +3, x 
		cmp #$ff
		beq file_not_open
		
        ; lba_addr = cluster_begin_lba_m2 + (cluster_number * sectors_per_cluster);
        lda fd_area + FD_start_cluster  +0,x
        sta lba_addr
        lda fd_area + FD_start_cluster  +1,x
        sta lba_addr +1
        lda fd_area + FD_start_cluster  +2,x
        sta lba_addr +2
        lda fd_area + FD_start_cluster  +3,x
        sta lba_addr +3
        
        ;sectors_per_cluster -> is a power of 2 value, therefore cluster << n, where n ist the number of bit set in sectors_per_cluster
        lda sectors_per_cluster
@lm:    lsr
        beq @lme    ; 1 sec/cluster nothing at all
        tax
        asl lba_addr +0
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

;vol->LbaFat + (cluster_nr>>7);// div 128 -> 4 (32bit) * 128 cluster numbers per block (512 bytes)
calc_fat_lba_addr:
		;instead of shift right 7 times in a loop, we copy over the hole byte (same as >>8) - and simple shift left once (<<1)
		lda fd_area + F32_fd::CurrentCluster	+0,	x
		asl
		lda fd_area + F32_fd::CurrentCluster	+1,x
		rol
		sta lba_addr_fat+0
		lda fd_area + F32_fd::CurrentCluster	+2,x
		rol
		sta lba_addr_fat+1
		lda fd_area + F32_fd::CurrentCluster	+3,x
		rol
		sta lba_addr_fat+2
		lda fd_area + F32_fd::CurrentCluster	+3,x
		rol
		rol		
		and	#$01;only bit 0
        sta lba_addr_fat+3
        ; add fat_begin_lba and lba_addr_fat
		clc
		lda fat_begin_lba+0
		adc lba_addr_fat +0
		sta lba_addr_fat +0
		lda fat_begin_lba+1
		adc lba_addr_fat +1
		sta lba_addr_fat +1
		lda fat_begin_lba+2
		adc lba_addr_fat +2
		sta lba_addr_fat +2
		lda fat_begin_lba+3
		adc lba_addr_fat +3
		sta lba_addr_fat +3
		rts	

		; check whether the EOC (end of cluster chain) cluster number is reached
		; @return Z = 1 if EOC detected
fat_cln_end:
		lda fd_area + F32_fd::CurrentCluster+3, x
		and	#<(FAT_EOC>>24)
		cmp	#<(FAT_EOC>>24)
		bne	@e
		lda fd_area + F32_fd::CurrentCluster+2, x
		cmp	#<(FAT_EOC>>16)
		bne	@e
		lda fd_area + F32_fd::CurrentCluster+1, x
		cmp	#<(FAT_EOC>>8)
		bne	@e
		lda fd_area + F32_fd::CurrentCluster+0, x
		and #<FAT_EOC
		cmp	#<FAT_EOC
@e:		rts
		
		; extract next cluster number from the 512 fat block buffer
		; unsigned int offs = (cla << 2 & (BLOCK_SIZE-1));//offset within 512 byte block, cluster nr * 4 (32 Bit) and Bit 8-0 gives the offset
fat_next_cln:
		lda fd_area + F32_fd::CurrentCluster  +0,x
		asl
		asl
		tay
		lda fd_area + F32_fd::CurrentCluster  +0,x
		and #$c0	; we dont <<2 the bit15-8 of the cluster number but test bit 7,6 - if one is set, we simply use the "high" page of the block + the bit7-0 <<2 offset in y
		bne	fat_next_cln_hi
		lda	block_fat+0, y
		sta fd_area + F32_fd::CurrentCluster+0, x
		lda	block_fat+1, y
		sta fd_area + F32_fd::CurrentCluster+1, x
		lda	block_fat+2, y
		sta fd_area + F32_fd::CurrentCluster+2, x
		lda	block_fat+3, y
		sta fd_area + F32_fd::CurrentCluster+3, x
		rts
fat_next_cln_hi:
		lda	block_fat+$100, y
		sta fd_area + F32_fd::CurrentCluster+0, x
		lda	block_fat+$100+1, y
		sta fd_area + F32_fd::CurrentCluster+1, x
		lda	block_fat+$100+2, y
		sta fd_area + F32_fd::CurrentCluster+2, x
		lda	block_fat+$100+3, y
		sta fd_area + F32_fd::CurrentCluster+3, x		
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

		SetVector sd_blktarget, sd_read_blkptr

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

		SetVector sd_blktarget, sd_read_blkptr	
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
        
		; cluster_begin_lba = Partition_LBA_Begin + Number_of_Reserved_Sectors + (Number_of_FATs * Sectors_Per_FAT) -  (2 * sec/cluster);

		; add number of reserved sectors to fat_begin_lba. store in cluster_begin_lba
		clc

		lda lba_addr + 0
		adc sd_blktarget + BPB_RsvdSecCnt + 0
		sta cluster_begin_lba + 0
		sta fat_begin_lba + 0	
		lda lba_addr + 1
		adc sd_blktarget + BPB_RsvdSecCnt + 1
		sta cluster_begin_lba + 1
		sta fat_begin_lba + 1	

		lda lba_addr + 2
		adc #$00
		sta cluster_begin_lba + 2
		sta fat_begin_lba + 2	

		lda lba_addr + 3
		adc #$00
		sta cluster_begin_lba + 3
		sta fat_begin_lba + 3	


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
		cpx #$04 ; 32Bit
		bne @l8
		dey
		bne @l7

        ; cluster_begin_lba_m2 -> cluster_begin_lba - (BPB_RootClus*sec/cluster)        
        debug8s "sec/cl:", sectors_per_cluster
        debug32s "clb1:", cluster_begin_lba
        		
        ;TODO FIXME we assume 2 here insteasd of using the value in BPB_RootClus
        ; cluster_begin_lba_m2 -> cluster_begin_lba - (2*sec/cluster) -> sec/cluster << 1
        lda sectors_per_cluster ; max sec/cluster can be 128, with 2 (BPB_RootClus) * 128 wie may subtract max 256
        asl
        sta lba_addr        ;   used as tmp
        stz lba_addr +1     ;   safe carry
        rol	lba_addr +1     
        sec	                ;   subtract from cluster_begin_lba
        lda cluster_begin_lba
        sbc lba_addr
        sta cluster_begin_lba
        lda cluster_begin_lba +1
        sbc lba_addr +1
        sta cluster_begin_lba +1
        lda cluster_begin_lba +2
        sbc #0
        sta cluster_begin_lba +2
        lda cluster_begin_lba +3
        sbc #0
        sta cluster_begin_lba +3 
        
        debug32s "clb2:", cluster_begin_lba
        
		; init file descriptor area
		jsr fat_init_fdarea

		Copy sd_blktarget + BPB_RootClus, root_dir_first_clus, 3
		; now we have the lba address of the first sector of the first cluster

end_mount:
		restore
		Copy root_dir_first_clus, fd_area + FD_INDEX_CURRENT_DIR + FD_start_cluster, 3
        ldx #FD_INDEX_CURRENT_DIR
        rts
        ;   
        ; out:
        ;   x - FD_INDEX_TEMP_DIR offset to fd area
fat_open_rootdir:
        Copy root_dir_first_clus, fd_area + FD_INDEX_TEMP_DIR + FD_start_cluster, 3
        ldx #FD_INDEX_TEMP_DIR
		rts

        ; clone source file descriptor with offset x into fd_area to target fd with y
        ; in:
        ;   x - source offset into fd_area
        ;   y - target offset into fd_area
fat_clone_fd:
        lda #FD_Entry_Size
        sta krn_tmp
@l1:    lda fd_area, x
        sta fd_area, y
        inx
        iny
        dec krn_tmp
        bpl @l1
        rts
        
		; in:
		;	x - offset to fd_area
		; out: 
		;	carry - if set, the file is not open
fat_isOpen:
		lda fd_area + FD_start_cluster +3, x
		cmp #$ff	;#$ff means not open, carry is set...
		rts

fat_init_fdarea:
		ldx #$00
fat_init_fdarea_with_x:		
        lda #$ff
@l1:	sta fd_area + FD_start_cluster +3 , x
        inx
		cpx #(FD_Entry_Size*FD_Entries_Max)
		bne @l1
		rts
		
        ;
		; return: 
        ;       x - with index to fd_area, otherwise A is set with errno
fat_alloc_fd:
		ldx #(2*FD_Entry_Size)	; skip 2 entries, they're reserverd for current and temp dir
@l1:	lda fd_area + FD_start_cluster +3, x
		cmp #$ff	;#$ff means unused, return current x as offset
		beq @l2

		txa ; 2 cycles
		adc #FD_Entry_Size; carry must be clear from cmp #$ff above
		tax ; 2 cycles

		cpx #(FD_Entry_Size*FD_Entries_Max)
		bne @l1

		; Too many open files, no free file descriptor found
		lda #EMFILE
        rts
@l2:    lda #0
		rts

        ; in:
        ;   x - offset into fd_area
        ; out:
        ;   A - error code if one, A = 0 otherwise
fat_close:
        lda fd_area + FD_start_cluster +3 , x
        cmp #$ff	;#$ff means not open, carry is set...
        bcs @l1
        lda #$ff    ; otherwise mark as closed
        sta fd_area + FD_start_cluster +3 , x
@l1:    lda #0         
        rts

fat_close_all:
		ldx #(2*FD_Entry_Size)	; skip 2 entries, they're reserverd for current and temp dir
		bra	fat_init_fdarea_with_x

        ; in:
        ;   x - directory fd index into fd_area		

	; get size of file in fd
	; in:
	;   x - fd offset
	; out:
	;   a - filesize lo
	;   x - filesize hi

fat_getfilesize:
	lda fd_area + FD_file_size + 0, x
	pha
	lda fd_area + FD_file_size + 1, x
	tax
	pla
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

		SetVector sd_blktarget, sd_read_blkptr
		jsr calc_lba_addr
		debug32s "lba:", lba_addr
		
ff_l3:	SetVector sd_blktarget, dirptr	
		jsr sd_read_block
		dec sd_read_blkptr+1
		
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
		
		jsr match2
		bcs ff_end

        ; in:
        ;   x - directory fd index into fd_area
fat_find_next:
		lda dirptr
		clc
		adc #DIR_Entry_Size
		sta dirptr
		bcc @l6
		inc dirptr+1
@l6:
		lda dirptr+1 	; end of block?
		cmp #>(sd_blktarget + sd_blocksize)
		bcc ff_l4			; no, show entr
		; increment lba address to read next block 
		jsr inc_lba_address
		; TODO FIXME check whether the end of the cluster is reached
		bra ff_l3

ff_end:
		rts

;	*.*	- matches any file or directory with extension
;	*	- matches any file or directory without extension
_CHARS_BLACKLIST:
;	.asciiz ".*+,/:;<=>?\[]|"
;	@see https://en.wikipedia.org/wiki/8.3_filename
; 				match input name[.[ext]] against 11 byte dir entry <name><ext>
match2:
				ldx #0
				ldy	#0
				phx					; 0 to stack, means match without extension
uppaercase:		lda	filename_buf,x
				cmp	#'.'
				bne	@store
				plp					; pop and ignore
				phx					; save the x offset
@store:			sta buffer,y
				iny
				inx
				cmp	#0
				bne	uppaercase		;no, next char
				plx
				beq	@patternmatch	; no extension or only extension pattern, match the hole filename
				lda	buffer			; x must be >=1 here
				cmp	#'.'			; starts with '.'
				beq	@skip_dots
				stz	buffer,x		; replace '.' with end of string
@skip_dots:		inx					; inc x, it has last index of '.'
				ldy	#7				; y index to offset of file extension at dirptr
				jsr	@NEXT			; match the extension
				bcc	@FAIL			;  no, exit if extension did not match
@patternmatch:	LDX #$00			;  yes, now match the filename
				LDY #$FF        ; Y is an index in the string
@NEXT:    		LDA buffer,X   	; Look at next pattern character
				CMP #'*'		; Is it a star?
				BEQ @STAR        ; Yes, do the complicated stuff
				INY             ; No, let's look at the string
				cpy	#8+3		 ;end of dir entry?
				beq @FOUND
				cmp	#0			 ; pattern end?
				BNE @quest		 ;  no
				lda	#' '		 ;  yes
				cmp (dirptr),y   ;  expect space in dir name
				bne	@FAIL
				rts
@quest:			CMP #'?'	     ; Is the pattern caracter a ques?
				BNE @REG         ; No, it's a regular character
				LDA (dirptr),Y     ; Yes, so it will match anything
				BEQ @FAIL        ;  except the end of string
@REG:			cmp	#'a'			; char [a-z] ?
				bcc @cmp
				cmp #'z'
				bcs @cmp
				and #$df			; uppercase
@cmp:			CMP (dirptr),Y     ; Are both characters the same?
				BNE @FAIL        ; No, so no match
				INX             ; Yes, keep checking
				CMP #0			; Are we at end of string?
				BNE @NEXT        ; Not yet, loop
@FOUND:   		RTS             ; Success, return with C=1

@STAR:    		INX             ; Skip star in pattern
				CMP buffer,X   ; String of stars equals one star
				BEQ @STAR        ;  so skip them also
@STLOOP:  			             ; We first try to match with * = ""
				phx             ;  and grow it by 1 character every
				phy             ; Save X and Y on stack
				JSR @NEXT        ; Recursive call
				ply             ; Restore X and Y
				plx
				BCS @FOUND       ; We found a match, return with C=1
				INY             ; No match yet, try to grow * string
				LDA (dirptr),Y     ; Are we at the end of string?
				cmp	#' '
				BNE @STLOOP      ; Not yet, add a character
@FAIL:    		CLC             ; Yes, no match found, return with C=0
				RTS		
buffer: .res 8+1+3,0

_match:
	ldx #0
	ldy #0
	; 0..1 in input may be "." or "..", so compare dir entry with .
match_skip_dots:
	lda	#'.'
	cmp	filename_buf,x
	bne	match_0

	cmp (dirptr),y
	bne m_not_found
	inx						
	iny
	lda	filename_buf,x
	bne	match_skip_dots_1 	; end of input ?
	lda	#' '
	cmp (dirptr),y
	bne m_not_found
match_skip_dots_1:
	cpy #02					; the 2 dots ..
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
	
m_r:	cmp	#'a'		; regular char a-z?
		bcc m_r_match
		cmp #'z'
		bcs m_r_match		
		and #$df		; otherwise, uppercase
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
		beq match_ext_1		; then go on and skip until extension above
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
