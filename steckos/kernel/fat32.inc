volumeID				= $02b0 ; address of VolumeID struct $30 bytes - sizeof(VolumeID)
cluster_begin_lba 		= $0300 ; begin of cluster area, 4 bytes
fat_lba_begin			= $0304	; begin of fat area, 2 bytes  - TODO FIXME we assume 16bit are sufficient since fat is placed at the beginning of the device
fat2_lba_begin			= $0306	; end of first fat and begin of 2nd fat (mirror) area, 2 bytes - TODO FIXME we assume 16bit ...
fat_clnr_tmp			= $0308 ; 4 bytes
;sectors_per_cluster 	= $030f ; sectors per cluster, 1 byte

root_dir_first_clus 	= $0310 ; first cluster of root dir, 4 bytes
filename_buf			= $0314 ; file name buffer, 11 bytes
					;	= $031f ; UNUSED
fd_area					= $0320 ; File descriptor area until $0400

sd_blktarget			= $0400
block_data				= sd_blktarget
block_fat               = $0600
sd_blocksize			= $200

; TODO FIXME replace with errno.inc from cc65 api
fat_bad_block_signature		= $01
fat_invalid_partition_type	= $02
fat_invalid_sector_size		= $03
fat_invalid_num_fats		= $04
fat_open_error			= $05
;fat_too_many_files		= $06
;fat_file_not_found		= $07
fat_file_not_open		= $08
fat_file_not_dir		= $10
fat_file_too_large		= $11

; SD card error codes
sd_no_card			= $ff
sd_invalid_card			= $0f
sd_init_failed			= $f1

; these correspond exactly to sd card R1 response error codes
sd_parameter_error		= $40
sd_address_error		= $20
sd_erase_sequence_error		= $10
sd_cmd_crc_error		= $08
sd_cmd_illegal_error		= $04
sd_erase_reset_error		= $02
sd_idle_state			= $01

;--------------------------------------------------------------------------------------
; partition entry
;--------------------------------------------------------------------------------------
.struct PartitionEntry
	Bootflag	.byte
	CHSBegin	.byte 3
	TypeCode	.byte
	CHSEnd		.byte 3	
	LBABegin	.dword
	NumSectors	.dword
.endstruct

PartType_FAT32		= $0b
PartType_FAT32_LBA	= $0c

;--------------------------------------------------------------------------------------
; FAT bootsector and partition table
;--------------------------------------------------------------------------------------
.struct PartTable
	Partition_0	.tag PartitionEntry
	Partition_1	.tag PartitionEntry
	Partition_2	.tag PartitionEntry
	Partition_3	.tag PartitionEntry
.endstruct

.struct BootSector
	Bootcode	.byte 446
	Partitions	.tag PartTable
	Signature	.word
.endstruct

;BS_VolLab2		= 71



;--------------------------------------------------------------------------------------
; FAT32 Volume ID
;--------------------------------------------------------------------------------------
.struct VolumeID
	Reserved	.byte 11
	BytsPerSec	.word ; 12	; 512 usually
	SecPerClus	.byte ; 13	; power of 2
	RsvdSecCnt	.word ; 14	; Number of reserved sectors. Should be 32 for FAT32
	NumFATs		.byte ; 16
	Reserved2	.byte 4 ; 17
	Media		.byte	; 21 ; For removable media, 0xF0 is frequently used. 
				; The legal values for this field are 
				; 0xF0, 0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, and 0xFF. 
	MirrorFlags	.word   ; Bits 0-3: number of active FAT (if bit 7 is 1)
        			; Bits 4-6: reserved
        			; Bit 7: one: single active FAT; zero: all FATs are updated at runtime
        			; Bits 8-15: reserved
				; https://www.win.tue.nl/~aeb/linux/fs/fat/fat-1.html
	Reserved3	.byte 12
	FATSz32		.dword		; sectors per FAT
	Reserved4	.byte 4
	RootClus	.dword
.endstruct

; TODO: do we need these?
;BS_BootSig		= 38
;BS_VolID		= 39
;BS_VolLab		= 43
;BS_FilSysType	= 54	; One of the strings “FAT12 ”, “FAT16 ”, or “FAT ”.

FAT_EOC			= $0fffffff	; end of cluster chain marker

;--------------------------------------------------------------------------------------
; FAT32 Directory Entry
;--------------------------------------------------------------------------------------
.struct F32DirEntry
	Name		.byte 8
	Ext			.byte 3
	Attr		.byte 
	Reserved	.byte 2
	CrtTime		.word
	CrtDate		.word
	Reserved2	.byte 2
	FstClusHI	.word
	WrtTime		.word
	WrtDate		.word
	FstClusLO	.word
	FileSize	.byte 4
.endstruct

DIR_Attr_Mask_Dir   		= 1<<4;
DIR_Attr_Mask_File  		= 1<<5;
DIR_Attr_Mask_LongFilename	= 1<<0 | 1<<1 | 1<<2 | 1<<3;
DIR_Entry_Size      		= .sizeof(F32DirEntry)
DIR_Entry_Deleted			= $e5
;--------------------------------------------------------------------------------------
; File descriptor struct
;--------------------------------------------------------------------------------------

.struct F32_fd
	StartCluster	.word 2	; +4
	FileSize		.word 2	; +4
	Attr			.byte
	CurrentCluster	.word 2
	SeekPos			.word 2
	DirEntryLBA		.word 2 ; LBA of the block where the dir entry of the file is located
	DirEntryPos		.byte	; block offset within the block (DirEntryPos * DIR_Entry_Size)
	Reserved		.byte 10;fill up to $20
.endstruct
FD_Size = .sizeof(F32_fd)


FD_Entry_Size = .sizeof(F32_fd)  
FD_Entries_Max = ($3ff - fd_area) / FD_Entry_Size

;FD_start_cluster = $00  ; 32 Bit cluster nr
;FD_file_size = $04              ; 32 Bit file size
;FD_file_attr = $08              ; 8 Bit fat32 Attributes

FD_INDEX_CURRENT_DIR = 0                            ; current dir always go to fd #0
FD_INDEX_TEMP_DIR    = FD_Entry_Size    ; temp dir always go to fd #1