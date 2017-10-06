; enable debug for this module
.ifdef DEBUG_FAT32
	debug_enabled=1
.endif

.include "common.inc"
.include "kernel.inc"
.include "fat32.inc"
.include "rtc.inc"
.include "errno.inc"	; from ca65 api
.include "fcntl.inc"	; from ca65 api

.import sd_read_block, sd_read_multiblock, sd_write_block, sd_write_multiblock, sd_select_card, sd_deselect_card
.import sd_read_block_data
.import __rtc_systime_update
.import string_fat_name
.import string_fat_mask
.import dirname_mask_matcher

.export fat_mount
.export fat_open, fat_isOpen, fat_chdir, fat_get_root_and_pwd

.export fat_mkdir, fat_rmdir, fat_read_block
.export fat_read, fat_find_first, fat_find_next, fat_write

.export fat_close_all, fat_close, fat_getfilesize
.export calc_dirptr_from_entry_nr, inc_lba_address, calc_blocks

.segment "KERNEL"

		;	read one block, TODO - updates the seek position within FD
		;in:
		;	X	- offset into fd_area
		;out:
		;   Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_read_block:
		jsr fat_isOpen
		beq @l_err_exit

		jsr calc_blocks
		jsr calc_lba_addr
		jsr sd_read_block
		rts
@l_err_exit:
		lda #EINVAL
		rts

		;in:
		;	X - offset into fd_area
		;out:
		;	A - A = 0 on success, error code otherwise
fat_read:
		jsr fat_isOpen
		beq @l_err_exit

		jsr calc_blocks
		jsr calc_lba_addr
		jsr sd_read_multiblock
;		jsr sd_read_block
		rts
@l_err_exit:
		lda #EINVAL
		rts

		; in:
		;	X - offset into fd_area
		; out:
		;   Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_write:
		stx fat_file_fd_tmp									; save fd

		jsr fat_isOpen
		beq @l_not_open

		lda	fd_area + F32_fd::Attr, x
		bit #DIR_Attr_Mask_File								; regular file?
		bne @l_isfile
@l_not_open:
		lda #EINVAL
		jmp @l_exit
@l_isfile:
		jsr __fat_isroot									; check whether fd start cluster is root cluster - @see fat_alloc_fd, fat_open)
		bne	@l_write										; if not, we can directly update dir entry and write data afterwards

		saveptr write_blkptr								; save the write ptr

		jsr __fat_reserve_cluster							; otherwise start cluster is root, we try to find a free cluster, fat_file_fd_tmp has to be set
		bne @l_exit

		restoreptr write_blkptr								; restore write ptr
		ldx fat_file_fd_tmp									; restore fd, go on with writing data
@l_write:
		jsr calc_lba_addr									; calc lba and blocks of file payload
		jsr calc_blocks
.ifdef MULTIBLOCK_WRITE
.warning "SD multiblock writes are EXPERIMENTAL"
		jsr sd_write_multiblock
.else
@l:
		jsr sd_write_block
		bne @l_exit
		jsr inc_lba_address
		dec blocks
		bne @l
.endif
		ldx fat_file_fd_tmp									; restore fd
		lda fd_area + F32_fd::DirEntryLBA+3 , x				; set lba addr of dir entry...
		sta lba_addr+3
		lda fd_area + F32_fd::DirEntryLBA+2 , x
		sta lba_addr+2
		lda fd_area + F32_fd::DirEntryLBA+1 , x
		sta lba_addr+1
		lda fd_area + F32_fd::DirEntryLBA+0 , x
		sta lba_addr+0

		SetVector block_data, read_blkptr
		jsr sd_read_block									; and read the block with the dir entry
		bne @l_exit

		ldx fat_file_fd_tmp
		lda fd_area + F32_fd::DirEntryPos , x				; setup dirptr
		jsr calc_dirptr_from_entry_nr




		jsr __fat_set_direntry_cluster						; set cluster number of direntry entry via dirptr - TODO FIXME only necessary on first write
		jsr __fat_set_direntry_filesize						; set filesize of directory entry via dirptr
		jsr __fat_set_direntry_timedate						; set time and date




		jsr __fat_write_block_data							; lba_addr is already set from read, see above
@l_exit:
		debug16 "fwrite", dirptr
		rts

		; write new timestamp to direntry entry given as dirptr
		; in:
		;	dirptr
__fat_set_direntry_timedate:

		jsr __rtc_systime_update									; update systime struct
		jsr __fat_rtc_time

		ldy #F32DirEntry::WrtTime
		sta (dirptr), y

		txa
		ldy #F32DirEntry::WrtTime+1
		sta (dirptr), y

		jsr __fat_rtc_date
		ldy #F32DirEntry::WrtDate+0
		sta (dirptr), y
		ldy #F32DirEntry::LstModDate+0
		sta (dirptr), y
		txa
		ldy #F32DirEntry::WrtDate+1
		sta (dirptr), y
		ldy #F32DirEntry::LstModDate+1
		sta (dirptr), y

		rts

__fat_set_direntry_filesize:
		ldy #F32DirEntry::FileSize+3
		lda fd_area + F32_fd::FileSize+3 , x
		sta (dirptr),y
		lda fd_area + F32_fd::FileSize+2 , x
		ldy #F32DirEntry::FileSize+2
		sta (dirptr),y
		lda fd_area + F32_fd::FileSize+1 , x
		ldy #F32DirEntry::FileSize+1
		sta (dirptr),y
		ldy #F32DirEntry::FileSize+0
		lda fd_area + F32_fd::FileSize+0 , x
		sta (dirptr),y
		rts

		; copy cluster number from file descriptor to direntry given as dirptr
		; in:
		;	dirptr
__fat_set_direntry_cluster:
		ldy #F32DirEntry::FstClusHI+1
		lda fd_area + F32_fd::StartCluster+3 , x
		sta (dirptr), y
		dey
		lda fd_area + F32_fd::StartCluster+2 , x
		sta (dirptr), y

		ldy #F32DirEntry::FstClusLO+1
		lda fd_area + F32_fd::StartCluster+1 , x
		sta (dirptr), y
		dey
		lda fd_area + F32_fd::StartCluster+0 , x
		sta (dirptr), y
		rts

	;in:
        ;   A/X - pointer to the result buffer
		;	Y	- size of result buffer
        ;out:
		;	A - errno, 0 - means no error
fat_get_root_and_pwd:
		sta	krn_ptr1
		stx	krn_ptr1+1
		tya
		eor	#$ff
		;sta	krn_ptr3		;save -size-1 for easy loop


@l1:	ldx #FD_INDEX_CURRENT_DIR
		lda fd_area + F32_fd::StartCluster + 3, x
		ora fd_area + F32_fd::StartCluster + 2, x
		lda volumeID+VolumeID::RootClus +1
		sta fd_area + F32_fd::StartCluster +1, x
		lda volumeID+VolumeID::RootClus +0
		sta fd_area + F32_fd::StartCluster +0, x

		bne @l2
		Copy fd_area + F32_fd::StartCluster, cluster_nr, 3	;save cluster current dir for matcher
		lda #<parent_dir
		ldx #>parent_dir
		jsr fat_chdir
		bne	@err
		jsr fat_find_first_intern


		SetVector clusternr_matcher, krn_call_internal
		bne	@end
		ldy #F32DirEntry::Name	;Name offset is 0
@l2:	lda (dirptr),y
		sta	(krn_ptr1),y	; '0' term string
		inc krn_ptr1
		beq @err
		iny
		cpy #$0b
		bne	@l1
		lda	#0
@end:
		rts
@err:	lda #ERANGE
		bra	@end

cluster_nr:
		.res 4
parent_dir:
		.asciiz ".."
clusternr_matcher:
		sec
		; TODO implement me
		rts

		;in:
        ;   A/X - pointer to string with the file path
        ;out:
		;   Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
        ;   X - index into fd_area of the opened directory - !!! ATTENTION !!! X is exactly the FD_INDEX_TEMP_DIR on success
__fat_opendir:
		jsr __fat_open_path
		bne	@l_exit					; exit on error
		lda	fd_area + F32_fd::Attr, x
		bit #DIR_Attr_Mask_Dir		; check that there is no error and we have a directory
		bne	@l_ok
		jsr fat_close				; not a directory, so we opened a file. just close them immediately and free the allocated fd
		lda	#EINVAL					; TODO FIXME error code for "Not a directory"
		bra @l_exit
@l_ok:	lda #EOK					; ok
@l_exit:
		debug "f_od"
		rts

		;in:
        ;   A/X - pointer to string with the file path
        ;out:
		;   Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
        ;   X - index into fd_area of the opened directory
fat_chdir:
		jsr __fat_opendir
		bne	@l_exit
		phx
		ldx #FD_INDEX_TEMP_DIR  		; the temp dir fd is now set to the last dir of the path and we proofed that it's valid with the code above
		ldy #FD_INDEX_CURRENT_DIR
		jsr	fat_clone_fd        		; therefore we can simply clone the temp dir to current dir fd - FTW!
		plx
		lda #EOK						; ok
@l_exit:
		debug "f_cd"
		rts

        ;in:
        ;   A/X - pointer to the file name
fat_rmdir:
		jsr __fat_opendir
		bne	@l_exit

		lda	#DIR_Entry_Deleted			; ($e5)
		sta (dirptr)					; mark dir entry as deleted
		debug "rmdir"
		;TODO implement fat/fat2 update, free the unused cluster(s)
		;TODO write back updated block_data

		lda #EOK						; ok
@l_exit:
		debug "rmdir"
		rts


        ; in:
        ; 	A/X - pointer to the directory name
		; out:
		;   Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_mkdir:
		jsr __fat_opendir
		beq	@err_exists
		cmp	#ENOENT									; we expect 'no such file or directory' error, otherwise a file with same name already exists
		bne @l_exit

		copypointer dirptr, krn_ptr2
		jsr string_fat_name							; build fat name upon input string (filenameptr) and store them directly to current dirptr!
		bne @l_exit

		jsr fat_alloc_fd							; alloc new fd - try to alloc fd here already, right before any fat writes which may fail
		bne @l_exit									; and we want to avoid an error in between the different block writes
		stx fat_file_fd_tmp							; save fd
		jsr __fat_set_fd_lba						; update dir lba addr and dir entry number within fd

		m_memcpy lba_addr, fat_lba_tmp, 4			; found..., save lba_addr pointing to the block the current dir entry resides (dirptr)
		debug32 "slba", fat_lba_tmp
		jsr __fat_reserve_cluster					; find free cluster, stored in fd_area for fd with fat_file_fd_tmp
		bne @l_exit_close
		m_memcpy fat_lba_tmp, lba_addr, 4			; restore lba_addr of dirptr
		debug32 "rlba", lba_addr

		ldx fat_file_fd_tmp							; load fd
		lda #DIR_Attr_Mask_Dir						; set type directory
		jsr __fat_prepare_dir_entry					; prepare dir entry, expects cluster number set in fd_area of newly allocated fd (fat_file_fd_tmp)
		jsr __fat_write_dir_entry					; create dir entry at current dirptr
		bne @l_exit_close

		jsr __fat_write_newdir_entry				; write the data of the newly created directory fd (fat_file_fd_tmp) with prepared data from dirptr
@l_exit_close:
		pha
		ldx fat_file_fd_tmp
		jsr fat_close						 		; free the allocated file descriptor
		pla
		bra @l_exit
@err_exists:
		lda	#EEXIST
@l_exit:
		debug "mkdir"
		rts

		;TODO check valid fsinfo block
		;TODO check whether clnr is maintained, test 0xFFFFFFFF ?
		;TODO improve calc, currently fixed to cluster-=1
__fat_update_fsinfo:
		m_memcpy fat_fsinfo_lba, lba_addr, 4
		SetVector block_fat, read_blkptr
		jsr	sd_read_block
		bne @l_exit
;		debug32 "fi_fcl", block_fat+FSInfo_FreeClus
		_dec32 block_fat+FSInfo_FreeClus
@l_write:
;		debug32 "fi_fcl", block_fat+FSInfo_FreeClus
		jmp __fat_write_block_fat
@l_exit:
		rts

		; create the "." and ".." entry of the new directory
		; in:
		;	dirptr - set to current dir entry within block_data
		;	fat_file_fd_tmp - the file descriptor into fd_area where the found cluster should be stored
__fat_write_newdir_entry:
		ldy #F32DirEntry::Attr																			; copy from (dirptr), start with F32DirEntry::Attr, the name is skipped and overwritten below
@l_dir_cp:
		lda (dirptr), y
		sta block_data, y																				; 1st dir entry
		sta block_data+1*.sizeof(F32DirEntry), y														; 2nd dir entry
		iny
		cpy #.sizeof(F32DirEntry)
		bne @l_dir_cp

		ldx #.sizeof(F32DirEntry::Name) + .sizeof(F32DirEntry::Ext)	-1									; erase name and build the "." and ".." entries
		lda #$20
@l_clr_name:
		sta block_data, x																				; 1st dir entry
		sta block_data+1*.sizeof(F32DirEntry), x														; 2nd dir entry
		dex
		bne @l_clr_name
		lda #'.'
		sta block_data+F32DirEntry::Name																; 1st entry "."
		sta block_data+1*.sizeof(F32DirEntry)+F32DirEntry::Name+0										; 2nd entry ".."
		sta block_data+1*.sizeof(F32DirEntry)+F32DirEntry::Name+1

		ldx #FD_INDEX_TEMP_DIR																			; due to fat_opendir/fat_open the fd of temp dir (FD_INDEX_TEMP_DIR) contains the last visited directory ("..") - FTW!
		debug32 "cd_cln", fd_area + FD_INDEX_TEMP_DIR + F32_fd::StartCluster
		lda fd_area+F32_fd::StartCluster+0,x
		sta block_data+1*.sizeof(F32DirEntry)+F32DirEntry::FstClusLO+0
		lda fd_area+F32_fd::StartCluster+1,x
		sta block_data+1*.sizeof(F32DirEntry)+F32DirEntry::FstClusLO+1
		lda fd_area+F32_fd::StartCluster+2,x
		sta block_data+1*.sizeof(F32DirEntry)+F32DirEntry::FstClusHI+0
		lda fd_area+F32_fd::StartCluster+3,x
		sta block_data+1*.sizeof(F32DirEntry)+F32DirEntry::FstClusHI+1

		ldx #$80
@l_erase:
		stz block_data+2*.sizeof(F32DirEntry), x														; all dir entries, but "." and ".." (+2), are set to 0
		stz block_data+$080, x
		stz block_data+$100, x
		stz block_data+$180, x
		dex
		bpl @l_erase

		ldx fat_file_fd_tmp
		jsr calc_lba_addr
		jsr __fat_write_block_data
		bne @l_exit

		m_memset block_data, 0, 2*.sizeof(F32DirEntry)													; now erase the "." and ".." entries too
		ldx volumeID+VolumeID::SecPerClus																; fill up (VolumeID::SecPerClus - 1) reamining blocks of the cluster with empty dir entries
		dex
		debug32 "er_d", lba_addr
@l_erase2:
		jsr inc_lba_address																				; next block within cluster
		jsr __fat_write_block_data
		bne @l_exit
		dex
		bne @l_erase2																					; write until VolumeID::SecPerClus - 1
@l_exit:
		rts

__fat_write_block_fat:
		debug32 "wbf_lba", lba_addr
.ifdef FAT_DUMP_FAT_WRITE
		debugdump "wbf", block_fat
.endif
		lda #>block_fat
		bra	__fat_write_block
__fat_write_block_data:
		lda #>block_data
__fat_write_block:
		sta write_blkptr+1
		stz write_blkptr	;page aligned
.ifndef FAT_NOWRITE
		jmp sd_write_block
.else
		lda #EOK
		rts
.endif


		; write new dir entry to dirptr and set new end of directory marker
		; in:
		;	dirptr - set to current dir entry within block_data
		; out:
		;	Z=1 on success, Z=0 otherwise, A=error code
__fat_write_dir_entry:
		debug16 "lsd_pt", dirptr

		;TODO FIXME duplicate code here! - @see fat_find_next:
		lda dirptr+1
		sta krn_ptr1+1
		lda dirptr														; create the end of directory entry
		clc
		adc #DIR_Entry_Size
		sta krn_ptr1
		bcc @l2
		inc krn_ptr1+1
@l2:
		lda krn_ptr1+1 													; end of block? :/ edge-case, we have to create the end-of-directory entry at the next block
		cmp #>(block_data + sd_blocksize)
		bne @l_eod														; no, write one block only

		jsr __fat_write_block_data										; write the current block with the updated dir entry first
		bne @l_exit

		ldx #$80														; fill the new dir block with 0 to mark eod
@l_erase:
		stz block_data+$000, x
		stz block_data+$080, x
		stz block_data+$100, x
		stz block_data+$180, x
		dex
		bpl @l_erase
		jsr inc_lba_address												; increment lba address to write to next block
		debug32 "eod", lba_addr
		;TODO FIXME test end of cluster, if so reserve a new one, update cluster chain for directory ;)
@l_eod:
		;TODO FIXME erase the rest of the block, currently 0 is assumed
		jsr __fat_write_block_data										; write the updated dir entry to device
@l_exit:
		debug "f_wde"
		rts

__fat_rtc_high_word:
		lsr
		ror	krn_tmp2
		lsr
		ror	krn_tmp2
		lsr
		ror	krn_tmp2
		ora krn_tmp
		tax
		rts

		; out
		;	A/X with time from rtc struct in fat format
__fat_rtc_time:
		stz krn_tmp2
		lda rtc_systime_t+time_t::tm_hour								; hour
		asl
		asl
		asl
		sta krn_tmp
		lda rtc_systime_t+time_t::tm_min								; minutes 0..59
		jsr __fat_rtc_high_word
		lda rtc_systime_t+time_t::tm_sec								; seconds/2
		lsr
		ora krn_tmp2
		debug "rtime"
		rts

		; out
		;	A/X with date from rtc struct in fat format
__fat_rtc_date:
		stz krn_tmp2
		lda rtc_systime_t+time_t::tm_year								; years since 1900
		sec
		sbc	#80															; fat year is 1980..2107 (bit 15-9)
		asl
		sta krn_tmp
		lda rtc_systime_t+time_t::tm_mon								; month from rtc is (0..11), adjust +1
		inc
		jsr __fat_rtc_high_word
		lda rtc_systime_t+time_t::tm_mday								; day of month (1..31)
		ora krn_tmp2
		debug "rdate"
		rts

		; in:
		;	A - attribute flag for new directory entry
		;	dirptr of the directory entry to prepare
__fat_prepare_dir_entry:
		ldy #F32DirEntry::Attr										; store attribute
		sta (dirptr), y

		lda #0
		ldy #F32DirEntry::Reserved									; unused
		sta (dirptr), y

		ldy #F32DirEntry::CrtTimeMillis
		sta (dirptr), y												; ms to 0, ms not supported by rtc

		jsr __rtc_systime_update									; update systime struct
		jsr __fat_rtc_time
		jsr __fat_set_direntry_timedate

		ldy #F32DirEntry::WrtTime
		lda (dirptr),y
		ldy #F32DirEntry::CrtTime
		sta (dirptr),y
		ldy #F32DirEntry::WrtTime+1
		lda (dirptr),y
		ldy #F32DirEntry::CrtTime+1
		sta (dirptr),y

		ldy #F32DirEntry::WrtDate
		lda (dirptr),y
		ldy #F32DirEntry::CrtDate
		sta (dirptr),y
		ldy #F32DirEntry::WrtDate+1
		lda (dirptr),y
		ldy #F32DirEntry::CrtDate+1
		sta (dirptr),y

		ldx fat_file_fd_tmp
		jsr __fat_set_direntry_cluster
		jmp __fat_set_direntry_filesize

__fat_write_fat_blocks:
		jsr __fat_write_block_fat				; lba_addr is already setup by __fat_find_free_cluster
		bne @err_exit
		clc										; calc fat2 lba_addr = lba_addr + VolumeID::FATSz32
		.repeat 4, i
			lda lba_addr + i
			adc volumeID + VolumeID::FATSz32 + i
			sta lba_addr + i
		.endrepeat
		jsr __fat_write_block_fat
@err_exit:
		rts

		; find and reserve next free cluster and maintains the fsinfo block
		; in:
		;	fat_file_fd_tmp - the file descriptor into fd_area where the found cluster should be stored
		; out:
		;	Z=1 on success, Z=0 otherwise and A=error code
__fat_reserve_cluster:
		jsr __fat_find_free_cluster					; find free cluster, stored in fd_area for the fd given within fat_file_fd_tmp
		bne @l_err_exit
		jsr __fat_mark_free_cluster					; mark cluster in block with EOC - TODO cluster chain support
		jsr __fat_write_fat_blocks					; write the updated fat block for 1st and 2nd FAT to the device
		bne @l_err_exit
		jmp __fat_update_fsinfo						; update the fsinfo sector/block
@l_err_exit:
		rts

		; in:
		;	Y - offset in block
		; 	read_blkptr - points to block_fat either 1st or 2nd page
__fat_mark_free_cluster:
;		debugdump "block", block_fat+$190
		lda #$ff
		sta (read_blkptr), y
		iny
		sta (read_blkptr), y
		iny
		sta (read_blkptr), y
		iny
		lda #$0f
		sta (read_blkptr), y
;		debugdump "block", block_fat+$190
		rts

		; in:
		;	fat_file_fd_tmp - file descriptor
		; out:
		;	Z=1 on success
		;		Y=offset in block_fat of found cluster
		;		lba_addr with fat block where the found cluster resides
		;		the found cluster is stored within fd_area+F32_fd::StartCluster, x (fat_file_fd_tmp) with the found cluster number
		;	Z=0 on error, A=error code
__fat_find_free_cluster:
		;TODO improve, use a previously saved lba_addr and/or found cluster number
		stz lba_addr+3			; init lba_addr with fat_begin lba addr
		stz lba_addr+2			; TODO FIXME we assume that 16 bit are sufficient for fat lba address
		lda fat_lba_begin+1
		sta lba_addr+1
		lda fat_lba_begin+0
		sta lba_addr+0

		SetVector	block_fat, read_blkptr
@next_block:
		debug32 "f_lba", lba_addr
		jsr	sd_read_block		; read fat block
		bne @exit
		dec read_blkptr+1		; TODO FIXME clarification with TW - sd_read_block increments block ptr highbyte

		ldy	#0
@l1:	lda	block_fat+0,y		; 1st page find cluster entry with 00 00 00 00
		ora block_fat+1,y
		ora block_fat+2,y
		ora block_fat+3,y
		beq	@l_found_lb			; branch, A=0 here
		lda	block_fat+$100+0,y	; 2nd page find cluster entry with 00 00 00 00
		ora block_fat+$100+1,y
		ora block_fat+$100+2,y
		ora block_fat+$100+3,y
		beq	@l_found_hb
		iny
		iny
		iny
		iny
		bne @l1
		jsr inc_lba_address		; inc lba_addr, next fat block
		lda lba_addr+1			; end of fat reached?
		cmp	fat2_lba_begin+1	; cmp with fat2_begin_lba
		bne @next_block
		lda lba_addr+0
		cmp	fat2_lba_begin+0
		bne	@next_block			;
		lda #ENOSPC				; end reached, answer ENOSPC () - "No space left on device"
@exit:	debug32 "free_cl", fd_area+F32_fd::StartCluster+$40 ;(almost the 3rd entry)
		rts
@l_found_hb:
		lda #>(block_fat+$100)	; set read_blkptr to begin 2nd page of fat_buffer - @see __fat_mark_free_cluster
		sta read_blkptr+1
		lda #$40				; adjust clnr with +$40 clusters since it was found in 2nd page
@l_found_lb:					; A=0 here, if called from above
		ldx fat_file_fd_tmp
		debug32 "fc_lba", lba_addr
		sta fd_area+F32_fd::StartCluster+0, x
		tya
		lsr						; offset Y>>2 (div 4, 32 bit clnr)
		lsr
		adc fd_area+F32_fd::StartCluster+0, x	; C=0 always here, y is multiple of 4 and 2 lsr
		sta fd_area+F32_fd::StartCluster+0, x	; safe clnr

		debug32 "fc_tmp2", fd_area+F32_fd::StartCluster+$40 ;(almost the 3rd entry)

		;m_memcpy lba_addr, safe_lba TODO FIXME fat lba address, reuse them at next search

		; to calc them we have to clnr = (block number * 512) / 4 + (Y / 4) => (lba_addr - fat_lba_begin) << 7 + (Y>>2)
		; to avoid the <<7, we simply <<8 and do one ror
		sec
		lda lba_addr+0
		sbc fat_lba_begin+0
		sta krn_tmp				; save A
		lda lba_addr+1
		sbc fat_lba_begin+1		; now we have 16bit blocknumber
		lsr						; clnr = blocks<<7
		sta fd_area+F32_fd::StartCluster+2, x
		lda krn_tmp				; restore A
		ror
		sta fd_area+F32_fd::StartCluster+1, x
		lda #0
		ror						; clnr += offset within block - already saved in F32_fd::StartCluster+0, x s.above
		adc fd_area+F32_fd::StartCluster+0, x
		sta fd_area+F32_fd::StartCluster+0, x
		lda #0					; exit found
		sta fd_area+F32_fd::StartCluster+3, x
		bra @exit


        ; in:
        ;   A/X - pointer to string with the file path
		;	  Y - file mode constant
		;		O_RDONLY        = $01
		;		O_WRONLY        = $02
		;		O_RDWR          = $03
		;		O_CREAT         = $10
		;		O_TRUNC         = $20
		;		O_APPEND        = $40
		;		O_EXCL          = $80
        ; out:
        ;   X - index into fd_area of the opened file
		;   Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_open:
		sty fat_file_mode_tmp			; save open flag
		jsr __fat_open_path
		bne	@l_error					;
		lda	fd_area + F32_fd::Attr, x	;
		bit #DIR_Attr_Mask_File			; regular file or directory?
		beq	@l_err_dir
		lda #EOK					; ok
		bra @l_exit
@l_error:
		cmp #ENOENT					; no such file or directory ?
		bne @l_exit					; other error, then exit
		lda fat_file_mode_tmp		; check if we should create a new file
		and #O_CREAT | O_WRONLY | O_APPEND
		beq @l_err_enoent			; nothing set, exit with ENOENT

		debug "r+"
		copypointer dirptr, krn_ptr2
		jsr string_fat_name							; build fat name upon input string (filenameptr)
		bne @l_exit
		jsr fat_alloc_fd							; alloc new fd for the new file we want to create
		bne @l_exit									; and we want to avoid an error in between the different block writes
		stx fat_file_fd_tmp							; save fd
		jsr __fat_set_fd_lba						; update dir lba addr and dir entry number within fd

		lda #DIR_Attr_Mask_File						; create as regular file
		jsr __fat_prepare_dir_entry
		jsr __fat_write_dir_entry					; create dir entry at current dirptr
		bne @l_exit_close

		ldx fat_file_fd_tmp							; newly opened file descriptor to X
		lda #EOK									; and exit with A=0 (EOK)
		bra @l_exit
@l_exit_close:
		pha 										; save error
		ldx fat_file_fd_tmp
		jsr fat_close						 		; free the allocated file descriptor
		pla
		bra @l_exit
@l_err_enoent:
		lda	#ENOENT
		bra @l_exit
@l_err_dir:
		lda	#EINVAL									; TODO FIXME error code for "Is a directory"
@l_exit:
		debug "fopen"
		rts

        ; in:
        ;   A/X - pointer to string with the file path
        ; out:
        ;   X - index into fd_area of the opened file
		;   Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
		;	Note: regardless of return value, the dirptr points the last visited directory entry and the corresponding lba_addr is set to the block where the dir entry resides.
		;		  furthermore the filenameptr points to the last inspected path fragment of the given input path
.macro _open
		stz	filename_buf, x	;\0 terminate the current path fragment
		jsr	__fat_open
		;debugdump "o_", filename_buf
		bne @l_exit
.endmacro
__fat_open_path:
		sta krn_ptr1
		stx krn_ptr1+1			    ; save path arg given in a/x

		ldx #FD_INDEX_CURRENT_DIR   ; clone current dir fd to temp dir fd
		ldy #FD_INDEX_TEMP_DIR		; we use temp dir to not clobber the current dir, maybe we will run into an error
		jsr fat_clone_fd

		ldy	#0						;	trim wildcard at the beginning
@l1:	lda (krn_ptr1), y
		cmp	#' '
		bne	@l2
		iny
		bne @l1
		bra @l_err_einval		; overflow, >255 chars
@l2:	;	starts with '/' ? - we simply cd root first
		cmp	#'/'
		bne	@l31
		jsr fat_open_rootdir
		iny
        lda	(krn_ptr1), y		;end of input?
		beq	@l_exit				;yes, so it was just the '/', exit with A=0
@l31:
		SetVector   filename_buf, filenameptr	; filenameptr to filename_buf
@l3:	;	parse input path fragments into filename_buf try to change dirs accordingly
		ldx #0
@l_parse_1:
		lda	(krn_ptr1), y
		beq	@l_openfile
		cmp	#' '                ;TODO FIXME support file/dir name with spaces? it's beyond 8.3 file support
		beq	@l_openfile
		cmp	#'/'
		beq	@l_open

		sta filename_buf, x
		iny
		inx
		cpx	#8+1+3		+1		; buffer overflow ? - only 8.3 file support yet
		bne	@l_parse_1
		bra @l_err_einval
@l_open:
		_open
		iny
		bne	@l3					;overflow - <path argument> exceeds 255 chars
@l_err_einval:
		lda	#EINVAL
@l_exit:
		debug	"fop"
		rts
@l_openfile:
		_open					; return with X as offset into fd_area with new allocated file descriptor
		lda #EOK
		bra @l_exit

        ;in:
        ;   filenameptr - ptr to the filename
        ;out:
        ;   X - index into fd_area of the opened file
		;   Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
__fat_open:
		phy

		ldx #FD_INDEX_TEMP_DIR
		jsr fat_find_first
		ldx #FD_INDEX_TEMP_DIR
		bcs fat_open_found
		lda #ENOENT
		jmp end_open_err

lbl_fat_open_error:
		lda #EINVAL ; TODO FIXME error code
		jmp end_open_err

; found.
fat_open_found:
		ldy #F32DirEntry::Attr
		lda (dirptr),y
		bit #DIR_Attr_Mask_Dir 		; directory?
		bne @l2						; go on, do not allocate fd, use index (X) which is already set to FD_INDEX_TEMP_DIR
		bit #DIR_Attr_Mask_File 	; is file?
		beq lbl_fat_open_error
		jsr fat_alloc_fd
		bne end_open_err
@l2:
		;save 32 bit cluster number from dir entry
		ldy #F32DirEntry::FstClusHI +1
		lda (dirptr),y
		sta fd_area + F32_fd::StartCluster + 3, x
		dey
		lda (dirptr),y
		sta fd_area + F32_fd::StartCluster + 2, x

		ldy #F32DirEntry::FstClusLO +1
		lda (dirptr),y
		sta fd_area + F32_fd::StartCluster + 1, x
		dey
		lda (dirptr),y
		sta fd_area + F32_fd::StartCluster + 0, x

		ldy #F32DirEntry::FileSize + 3
		lda (dirptr),y
		sta fd_area + F32_fd::FileSize + 3, x
		dey
		lda (dirptr),y
		sta fd_area + F32_fd::FileSize + 2, x
		dey
		lda (dirptr),y
		sta fd_area + F32_fd::FileSize + 1, x
		dey
		lda (dirptr),y
		sta fd_area + F32_fd::FileSize + 0, x

		ldy #F32DirEntry::Attr
		lda (dirptr),y
		sta fd_area + F32_fd::Attr, x

		jsr __fat_set_fd_lba

		lda #EOK ; no error
end_open_err:
		ply
		cmp	#0			;restore z flag
		rts

inc_blkptr:
		; Increment blkptr by 32 bytes, jump to next dir entry
		clc
		lda read_blkptr
		adc #32
		sta read_blkptr
		bcc @l
		inc read_blkptr+1
@l:
		rts

fat_check_signature:
		lda #$55
		cmp sd_blktarget + BootSector::Signature
		bne @l1
		asl ; $aa
		cmp sd_blktarget + BootSector::Signature + 1
		beq @l2
@l1:	lda #fat_bad_block_signature
@l2:	rts


calc_blocks: ;blocks = filesize / BLOCKSIZE -> filesize >> 9 (div 512) +1 if filesize LSB is not 0
		lda fd_area + F32_fd::FileSize + 3,x
		lsr
		sta blocks + 2
		lda fd_area + F32_fd::FileSize + 2,x
		ror
		sta blocks + 1
		lda fd_area + F32_fd::FileSize + 1,x
		ror
		sta blocks
		bcs @l1
		lda fd_area + F32_fd::FileSize + 0,x
		beq @l2
@l1:	inc blocks
		bne @l2
		inc blocks+1
		bne @l2
		inc blocks+2
@l2:	debug16 "cbl", blocks
		rts

; calculate LBA address of first block from cluster number found in file descriptor entry
; file descriptor index must be in x
;		in:	X - file descriptor index
calc_lba_addr:
		pha
		phx

		jsr	__fat_isroot
		bne	@l_scl
		.repeat 4,i
			lda volumeID + VolumeID::RootClus + i
			sta lba_addr + i
		.endrepeat
		bra @l_calc
@l_scl:
		; lba_addr = cluster_begin_lba_m2 + (cluster_number * VolumeID::SecPerClus);
		.repeat 4,i
			lda fd_area + F32_fd::StartCluster + i,x
			sta lba_addr + i
		.endrepeat
@l_calc:
		;SecPerClus is a power of 2 value, therefore cluster << n, where n ist the number of bit set in VolumeID::SecPerClus
		lda volumeID+VolumeID::SecPerClus
@lm:	lsr
		beq @lme    ; 1 sector/cluster therefore skip multiply
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
		debug32 "c_lba", lba_addr
calc_end:
		plx
		pla
		rts


inc_lba_address:
		inc32 lba_addr
		rts

;vol->LbaFat + (cluster_nr>>7);// div 128 -> 4 (32bit) * 128 cluster numbers per block (512 bytes)
calc_fat_lba_addr:
		;instead of shift right 7 times in a loop, we copy over the hole byte (same as >>8) - and simply shift left 1 bit (<<1)
		lda fd_area + F32_fd::CurrentCluster	+0,	x
		asl
		lda fd_area + F32_fd::CurrentCluster	+1,x
		rol
		sta lba_addr+0
		lda fd_area + F32_fd::CurrentCluster	+2,x
		rol
		sta lba_addr+1
		lda fd_area + F32_fd::CurrentCluster	+3,x
		rol
		sta lba_addr+2
		lda fd_area + F32_fd::CurrentCluster	+3,x
		rol
		rol
		and	#$01;only bit 0
		sta lba_addr+3
		; add fat_lba_begin and lba_addr
		clc
		lda fat_lba_begin+0
		adc lba_addr +0
		sta lba_addr +0
		lda fat_lba_begin+1
		adc lba_addr +1
		sta lba_addr +1
		lda fat_lba_begin+2

		lda fat_lba_begin+3
		adc lba_addr +3
		sta lba_addr +3
		rts

		; check whether cluster of fd is the root cluster number as given in VolumeID::RootClus
		; in:
		;	X - file descriptor
		; out:
		;	Z=1 if it is the root cluster, Z=0 otherwise
__fat_isroot:
		lda fd_area+F32_fd::StartCluster+3,x				; check whether start cluster is the root dir cluster nr (0x00000000) as initial set by fat_alloc_fd
		ora fd_area+F32_fd::StartCluster+2,x
		ora fd_area+F32_fd::StartCluster+1,x
		ora fd_area+F32_fd::StartCluster+0,x
.ifdef DEBUG
		beq @l
		debug "isroot"
@l:
.endif
		rts

		; check whether the EOC (end of cluster chain) cluster number is reached
		;
		; out:
		;	Z = 1 if EOC detected, Z=0 otherwise
is_fat_cln_end:
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
		; set lba_addr to $00000000 since we want to read the bootsector
		.repeat 4, i
			stz lba_addr + i
		.endrepeat

		SetVector sd_blktarget, read_blkptr
		jsr sd_read_block

		jsr fat_check_signature
		beq @l1
		jmp end_mount
@l1:
		part0 = sd_blktarget + BootSector::Partitions + PartTable::Partition_0

		lda part0 + PartitionEntry::TypeCode
		cmp #PartType_FAT32
		beq @l2
		cmp #PartType_FAT32_LBA
		beq @l2
		; type code not PartType_FAT32 or PartType_FAT32_LBA
		lda #fat_invalid_partition_type
		jmp end_mount
@l2:
		m_memcpy part0 + PartitionEntry::LBABegin, lba_addr, 4

		SetVector sd_blktarget, read_blkptr
		; Read FAT Volume ID at LBABegin and Check signature
		jsr sd_read_block

		jsr fat_check_signature
		beq @l4
		jmp end_mount
@l4:

.ifdef DEBUGFAT
		jsr krn_primm
		.asciiz "MF: "
		lda sd_blktarget + VolumeID::MirrorFlags
		jsr krn_hexout
.endif
		m_memcpy	sd_blktarget+11, volumeID, .sizeof(VolumeID) ; +11 skip first 11 bytes, we are not interested in

		; Bytes per Sector, must be 512 = $0200
		lda	volumeID+VolumeID::BytsPerSec+0
		bne @l5
		lda	volumeID+VolumeID::BytsPerSec+1
		cmp #$02
		beq @l6
@l5:	lda #fat_invalid_sector_size
		jmp end_mount
@l6:
		; cluster_begin_lba = Partition_LBA_Begin + Number_of_Reserved_Sectors + (Number_of_FATs * Sectors_Per_FAT) -  (2 * sec/cluster);
		; fat_lba_begin		= Partition_LBA_Begin + Number_of_Reserved_Sectors
		; fat2_lba_begin	= Partition_LBA_Begin + Number_of_Reserved_Sectors + Sectors_Per_FAT

		; add number of reserved sectors to calculate fat_lba_begin. also store in cluster_begin_lba for further calculation
		clc
		lda lba_addr + 0
		adc volumeID + VolumeID::RsvdSecCnt + 0
		sta cluster_begin_lba + 0
		sta fat_lba_begin + 0
		lda lba_addr + 1
		adc volumeID + VolumeID::RsvdSecCnt + 1
		sta cluster_begin_lba + 1
		sta fat_lba_begin + 1
		lda lba_addr + 2
		adc #$00
		sta cluster_begin_lba + 2
		sta fat_lba_begin + 2
		lda lba_addr + 3
		adc #$00
		sta cluster_begin_lba + 3
		sta fat_lba_begin + 3

		; Number of FATs. Must be 2
		; cluster_begin_lba = fat_lba_begin + (sectors_per_fat * VolumeID::NumFATs (2))
		ldy volumeID + VolumeID::NumFATs
@l7:	clc
		ldx #$00
@l8:	ror ; get carry flag back
		lda volumeID + VolumeID::FATSz32,x ; sectors per fat
		adc cluster_begin_lba,x
		sta cluster_begin_lba,x
		inx
		rol ; save status register before cpx to save carry
		cpx #$04 ; 32Bit
		bne @l8
		dey
		bne @l7

		; calc begin of 2nd fat (end of 1st fat)
		; TODO FIXME - we assume 16bit are sufficient for now since fat is placed at the beginning of the device
		clc
		lda volumeID + VolumeID::FATSz32+0 ; sectors/blocks per fat
		adc fat_lba_begin	+0
		sta fat2_lba_begin	+0
		lda volumeID + VolumeID::FATSz32+1
		adc fat_lba_begin	+1
		sta fat2_lba_begin	+1

		; calc fs_info lba address
		clc
		lda lba_addr+0
		adc volumeID+VolumeID::FSInfoSec+0
		sta fat_fsinfo_lba+0
		lda lba_addr+1
		adc volumeID+VolumeID::FSInfoSec+1
		sta fat_fsinfo_lba+1
		lda #0
		sta fat_fsinfo_lba+3
		adc #0				; 0 + C
		sta fat_fsinfo_lba+2

		; cluster_begin_lba_m2 -> cluster_begin_lba - (VolumeID::RootClus*VolumeID::SecPerClus)
		debug8 "sec/cl", volumeID+VolumeID::SecPerClus
		debug32 "r_cl", volumeID+VolumeID::RootClus
		debug32 "s_lba", lba_addr
		debug16 "r_sec", volumeID + VolumeID::RsvdSecCnt
		debug16 "f_lba", fat_lba_begin
		debug32 "f_sec", volumeID + VolumeID::FATSz32
		debug16 "f2_lba", fat2_lba_begin
		debug16 "fi_sec", volumeID+VolumeID::FSInfoSec
		debug32 "fi_lba", fat_fsinfo_lba
		debug32 "cl_lba", cluster_begin_lba
		debug16 "fbuf", filename_buf

		;TODO FIXME we assume 2 here insteasd of using the value in VolumeID::RootClus
		; cluster_begin_lba_m2 -> cluster_begin_lba - (2*sec/cluster) => cluster_begin_lba - (sec/cluster << 1)
		lda volumeID+VolumeID::SecPerClus ; max sec/cluster can be 128, with 2 (BPB_RootClus) * 128 wie may subtract max 256
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

		;debug32s "clb2:", cluster_begin_lba

		; init file descriptor area
		jsr fat_init_fdarea

		; alloc file descriptor for current dir. which is cluster number 0 on fat32 - Note: the RootClus offset is compensated within calc_lba_addr
		ldx #FD_INDEX_CURRENT_DIR
		jsr __fat_alloc_fd
end_mount:
		debug "f_mnt"
		rts

		; out:
		;   x - FD_INDEX_TEMP_DIR offset to fd area
fat_open_rootdir:
		ldx #FD_INDEX_TEMP_DIR					; set temp directory to cluster number 0 - Note: the RootClus offset is compensated within calc_lba_addr
		jmp __fat_alloc_fd

		; clone source file descriptor with offset x into fd_area to target fd with y
		; in:
		;   x - source offset into fd_area
		;   y - target offset into fd_area
fat_clone_fd:
		lda #FD_Entry_Size
		sta krn_tmp
@l1:	lda fd_area, x
		sta fd_area, y
		inx
		iny
		dec krn_tmp
		bpl @l1
		rts

		; in:
		;	x - offset to fd_area
		; out:
		;	Z=0 if file is open, Z=1 otherwise
fat_isOpen:
		lda fd_area + F32_fd::StartCluster +3, x
		cmp #$ff		;#$ff means not open
		rts

fat_init_fdarea:
		ldx #$00
fat_init_fdarea_with_x:
		lda #$ff
@l1:	sta fd_area + F32_fd::StartCluster + 3 , x
		inx
		cpx #(FD_Entry_Size*FD_Entries_Max)
		bne @l1
		rts

		; update the dir entry position and dir lba_addr of the given file descriptor
		; in:
		;	X - file descriptor
__fat_set_fd_lba:
	 	lda lba_addr + 3
		sta fd_area + F32_fd::DirEntryLBA + 3, x
	 	lda lba_addr + 2
		sta fd_area + F32_fd::DirEntryLBA + 2, x
	 	lda lba_addr + 1
		sta fd_area + F32_fd::DirEntryLBA + 1, x
	 	lda lba_addr + 0
		sta fd_area + F32_fd::DirEntryLBA + 0, x

		jsr calc_dir_entry_nr
		sta fd_area + F32_fd::DirEntryPos, x
		rts

		; out:
		;	X - with index to fd_area
		;   Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_alloc_fd:
		ldx #(2*FD_Entry_Size)							; skip 2 entries, they're reserverd for current and temp dir
@l1:	lda fd_area + F32_fd::StartCluster +3, x

		cmp #$ff	;#$ff means unused, return current x as offset
		beq __fat_alloc_fd

		txa ; 2 cycles
		adc #FD_Entry_Size; carry must be clear from cmp #$ff above
		tax ; 2 cycles

		cpx #(FD_Entry_Size*FD_Entries_Max)
		bne @l1

		; Too many open files, no free file descriptor found
		lda #EMFILE
		rts
__fat_alloc_fd:									; also internally used
		stz fd_area+F32_fd::StartCluster+3,x	; init start cluster nr with root dir cluster which is 0 - @see Note in calc_lba_addr
		stz fd_area+F32_fd::StartCluster+2,x
		stz fd_area+F32_fd::StartCluster+1,x
		stz fd_area+F32_fd::StartCluster+0,x
		stz fd_area+F32_fd::FileSize+3,x		; init file size with 0, it's maintained during open
		stz fd_area+F32_fd::FileSize+2,x
		stz fd_area+F32_fd::FileSize+1,x
		stz fd_area+F32_fd::FileSize+0,x
		lda #EOK
		rts

        ; in:
        ;   X - offset into fd_area
        ; out:
		;   Z - Z=1 on success (A=0), Z=0 and A=error code otherwise
fat_close:
		lda fd_area + F32_fd::StartCluster +3, x
		cmp #$ff	;#$ff means not open, carry is set...
		bcs @l1
		lda #$ff    ; otherwise mark as closed
		sta fd_area + F32_fd::StartCluster +3, x
@l1:	lda #EOK
		rts

fat_close_all:
		ldx #(2*FD_Entry_Size)	; skip 2 entries, they're reserverd for current and temp dir
		bra	fat_init_fdarea_with_x

		; get size of file in fd
		; in:
		;   x - fd offset
		; out:
		;   a - filesize lo
		;   x - filesize hi
fat_getfilesize:
		lda fd_area + F32_fd::FileSize + 0, x
		pha
		lda fd_area + F32_fd::FileSize + 1, x
		tax
		pla
		rts

		; find first dir entry
		; in:
		;   X 			- fd offset
		;	filenameptr	- with file name to search
		; out:
		;	C 			- carry = 1 if found and dirptr is set to the dir entry found, carry = 0 otherwise
fat_find_first:
		SetVector fat_dirname_mask, krn_ptr2									; build fat dir entry mask from user input
		jsr	string_fat_mask
		debugdump "msk", fat_dirname_mask
		SetVector dirname_mask_matcher, krn_call_internal						; set callback to dirname matcher
		
		; internal find first, assumes that (krn_call_internal) is already setup
		; in:
		;   X - directory fd index into fd_area
fat_find_first_intern:
		lda volumeID+VolumeID::SecPerClus
		sta blocks
		jsr calc_lba_addr
		SetVector sd_blktarget, read_blkptr

ff_l3:	SetVector sd_blktarget, dirptr	; dirptr to begin of target buffer
		jsr sd_read_block
		dec read_blkptr+1	; set read_blkptr to origin address
ff_l4:
		lda (dirptr)
		beq ff_eod						; first byte of dir entry is $00 (end of directory)?
@l5:
		ldy #F32DirEntry::Attr			; else check if long filename entry
		lda (dirptr),y 					; we are only going to filter those here (or maybe not?)
		cmp #DIR_Attr_Mask_LongFilename
		beq fat_find_next

		jsr fat_find_first_matcher		; jmp indirect via (krn_call_internal), set to appropriate matcher strategy
		;debugdump "ff", filename_buf
		;debugdump "fb", buffer
		bcs ff_end

		; in:
		;   X - directory fd index into fd_area
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
		bcc ff_l4			; no, process entry
		dec blocks			; end of cluster reached?
		beq ff_eod			; TODO FIXME cluster chain support, dir may go on in next cluster ;)
		jsr inc_lba_address	; increment lba address to read next block
		bra ff_l3
ff_eod:
		clc					; we are at the end, C=0 and return
ff_end:
		rts

fat_find_first_matcher:
		jmp	(krn_call_internal)

calc_dirptr_from_entry_nr:
		stz dirptr

		lsr
		ror dirptr
		ror
		ror dirptr
		ror
		ror dirptr

		clc
		adc #>sd_blktarget
		sta dirptr+1
		rts

		; in:
		;	dirptr to block_data
		; out:
		;	A with dirptr div 32
calc_dir_entry_nr:
		lda dirptr
		sta krn_tmp

		lda dirptr+1
		and #$01		; div 32, just bit 0 of high byte must be taken into account. dirptr must be $0200 aligned
		.assert >block_data & $01 = 0, error, "block_data must be $0200 aligned!"
		clc
		rol krn_tmp
		rol
		rol krn_tmp
		rol
		rol krn_tmp
		rol
		rts