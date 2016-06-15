.import charset
; start memcheck here
start_check = $0300
ram_end 			= $0288
ram_end_l   		= ram_end
ram_end_h   		= ram_end+1

; Pointers
addr 		= $e0
adrl     	= addr
adrh     	= addr+1
ptr1		= $e2
ptr1l		= ptr1
ptr1h		= ptr1+1
ptr2		= $e4
ptr2l		= ptr2
ptr2h		= ptr2+1

; UART address and registers
uart1		= $0200
uart1rxtx	= uart1+0
uart1ier	= uart1+0
uart1dll	= uart1+0
uart1dlh	= uart1+1
uart1iir	= uart1+2
uart1fcr	= uart1+2
uart1lcr	= uart1+3
uart1mcr	= uart1+4
uart1lsr	= uart1+5
uart1msr	= uart1+6
uart1scr	= uart1+7

; VIA address and registers
via1        = $0210
via1porta   = via1+1
via1portb   = via1
via1ddrb    = via1+2
via1ddra    = via1+3
via1t1cl    = via1+4
via1t1ch    = via1+5
via1t2cl    = via1+8
via1t2ch    = via1+9
via1sr      = via1 + $0a
via1acr     = via1 + $0b
via1pcr     = via1 + $0c
via1ifr     = via1 + $0d
via1ier     = via1 + $0e

;----------------------------------------------------------------------------------------------
; SD Card commands
;----------------------------------------------------------------------------------------------
cmd0 	= $40       ; GO_IDLE_STATE
cmd1 	= $40 + 1 	; SEND_OP_COND
cmd8 	= $40 + 8   ; SEND_IF_COND
cmd12	= $40 + 12  ; STOP_TRANSMISSION
cmd16	= $40 + 16 	; SET_BLOCKLEN
cmd17	= $40 + 17	; READ_SINGLE_BLOCK
cmd18	= $40 + 18	; READ_MULTIPLE_BLOCK
cmd24	= $40 + 24	; WRITE_BLOCK
cmd55	= $40 + 55	; APP_CMD
cmd58	= $40 + 58	; READ_OCR
acmd41	= $40 + 41


tmp0		= $ea
tmp1		= $eb
tmp2		= $ec
tmp3		= $ed
tmp4		= $ee
tmp5		= $ef
tmp6		= $f0
tmp7		= $f1

sd_data_token = $fe
sd_card_status 		= $0298  
; SD CArd command parameter/result buffer
sd_cmd_param 		= $02a0
sd_cmd_chksum		= sd_cmd_param+4
sd_cmd_result 		= $02a5

lba_addr = $20
errno	 				= $0300
nvram		= $1000

dirptr 		= $f4 ; 2 byte
paramvec	= $f8


; pointer for io block operations
sd_blkptr 	= $fc

; pointer for string output functions 
msgptr 		= $fe


sd_blktarget 		= $0400

steckos_start		= $1000	

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


a_vdp		= $0220
a_vram		= a_vdp
a_vreg		= a_vdp+1

v_reg0_m3			= 1<<1
v_reg0_extV			= 1<<0

v_reg1_16k			= 1<<7
v_reg1_display_on	= 1<<6
v_reg1_int			= 1<<5
v_reg1_m1			= 1<<4
v_reg1_m2			= 1<<3
v_reg1_spr_size		= 1<<1
v_reg1_spr_mag		= 1<<0

v_reg0 	= $80
v_reg1 	= $81
v_reg2 	= $82
v_reg3 	= $83
v_reg4 	= $84
v_reg5 	= $85
v_reg6 	= $86
v_reg7  = $87

Transparent    =$00
Black          =$01
Medium_Green   =$02
Light_Green    =$03
Dark_Blue      =$04
Light_Blue     =$05;  5 Light Blue 
Dark_Red       =$06
Cyan           =$07 ;(Aqua Blue)
Medium_Red     =$08
Light_Red      =$09
Dark_Yellow    =$0a		;1010
Light_Yellow   =$0b		;1011
Dark_Green     =$0c		;1100
Magenta        =$0d ; (Purple)
Gray           =$0e
White          =$0f

WRITE_ADDRESS			=$40
ADDRESS_GFX_SPRITE		=$1b00

ADDRESS_GFX1_SCREEN		=$0800
ADDRESS_GFX1_PATTERN	=$3800
ADDRESS_GFX1_COLOR		=$1b80
ADDRESS_GFX1_SPRITE		=ADDRESS_GFX_SPRITE
ADDRESS_GFX1_SPRITE_PATTERN=$1000;ADDRESS_GFX1_PATTERN

ROWS=23
COLS=32

; Cursor Position and buffer
crs_x	= $e6
crs_y	= $e7

KEY_CR=$0d
KEY_LF=$0a
KEY_BACKSPACE=$08


param_sig		= $00 ; 1  byte  - parameter array signature byte. must be $42
param_version	= $01 ; 1  byte  - version number. initially zero
param_filename	= $02 ; 11 bytes - file to boot. example "LOADER  BIN"
param_uart_div	= $0d ; 2  bytes  - baudrate divisor value
param_lsr       = $0f ; 1  byte  - uart lcr value , default %00000011 (8N1)
param_checksum  = $5f ; checksum