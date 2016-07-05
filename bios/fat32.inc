cluster_begin_lba 		= $0303 ; begin of cluster area, 4 bytes
sectors_per_cluster 	= $0307 ; sectors per cluster, 1 byte
root_dir_first_clus 	= $0308 ; first cluster of root dir, 4 bytes
filesize = $a1
blocks = $a0

fat_bad_block_signature		= 	$01
fat_invalid_partition_type	=	$02
fat_invalid_sector_size		=	$03
fat_invalid_num_fats		=	$04
fat_open_error				=	$05
fat_too_many_files			=   $06
fat_file_not_found			=   $07
fat_file_not_open			=   $08
fat_file_not_dir			=   $10
; SD card error codes
sd_no_card					= 	$ff
sd_invalid_card				=	$0f
sd_init_failed				= 	$f1

BS_Partition0	= 446
BS_Signature	= 510   ; must be 0x55AA


;--------------------------------------------------------------------------------------
; partition entry
;--------------------------------------------------------------------------------------
PE_Bootflag		= 0
PE_CHSBegin		= 1
PE_TypeCode		= 4
PE_CHSEnd		= 6
PE_LBABegin		= 8
PE_NumSectors	= 12


BS_VolLab2		= 71

;--------------------------------------------------------------------------------------
; FAT32 Volume ID
;--------------------------------------------------------------------------------------
BPB_BytsPerSec 	= 11
BPB_SecPerClus	= 13
BPB_RsvdSecCnt	= 14	; Number of reserved sectors. Should be 32 for FAT32
BPB_NumFATs		= 16
BPB_Media		= 21	; For removable media, 0xF0 is frequently used. 
						; The legal values for this field are 0xF0, 0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, and 0xFF. 
BPB_FATSz32		= $24
BPB_RootClus	= $2c
BS_BootSig		= 38
BS_VolID		= 39
BS_VolLab		= 43
BS_FilSysType	= 54	; One of the strings “FAT12 ”, “FAT16 ”, or “FAT ”.

;--------------------------------------------------------------------------------------
; FAT32 Directory Entry
;--------------------------------------------------------------------------------------
DIR_Name		= $00	;Filename, 8 Bytes
DIR_Ext			= $08 	;Extension, 3 Bytes
DIR_Attr		= $0B	;8 Bits
DIR_FstClusHI	= $14	;16 Bits
DIR_WrtTime		= $16   ; File write time, 16 bits
						; Bits 0–4: 2-second count, valid value range 0–29 inclusive (0 – 58 seconds). 
						; Bits 5–10: Minutes, valid value range 0–59 inclusive.
						; Bits 11–15: Hours, valid value range 0–23 inclusive.
DIR_WrtDate		= $18	; file write date, 16 bits
						; Bits 0–4: Day of month, valid value range 1-31 inclusive.
						; Bits 5–8: Month of year, 1 = January, valid value range 1–12 inclusive.
						; Bits 9–15: Count of years from 1980, valid value range 0–127 inclusive (1980–2107).
DIR_FstClusLO	= $1A	;16 Bits
DIR_FileSize	= $1C	;32 Bits