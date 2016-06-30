.setcpu "65c02"
addr 		= $e0
adrl     	= addr
adrh     	= addr+1

; Cursor Position and buffer
crs_x	= $e2	;  cursor x 
crs_y	= $e3	;  cursor y
crs_ptr = $e4	; 16 bit screen buffer pointer

current_dir_first_cluster 	= $02b0 ; first cluster of current dir
filename_buf				= $030c ; file name buffer, 11 bytes
fd_area						= $0320 ; File descriptor area, 6x8byte until $0350 
fat_first_block				= $0350
sd_blktarget 				= $0400



lba_tmp 			= $f0
tmp0				= $f6
tmp1				= $f7

; TODO FIXME free zp space if necessary by using DATA RAM instead of zp space here
screen_status		= $f8	; 
screen_write_lock  	= $f9	; 0
screen_frames		= $fa	; 0
saved_char			= $fb	; ' '

dirptr 		= $f4 ; 2 byte

; TODO FIXME CLASH with screen_frames
;
; pointer to filename for fs operations (open...)
filenameptr		= $fa

; pointer for io block operations
sd_blkptr 	= $fc


; pointer for string output functions 
msgptr 		= $fe
DPL			= msgptr
DPH			= msgptr+1

lba_addr = $20
blocks = $a0
errno	 			= $0300

user_isr 	        = $028a

.macro SetVector word, addr 
			lda #<word
			sta addr
			lda #>word
			sta addr+1
.endmacro

.macro save
	pha
	phy
	phx
.endmacro

.macro restore
	plx
	ply
	pla
.endmacro

.macro Copy src, trgt, len

		ldx #len
:
		lda src,x
		sta trgt,x
		dex
		bpl :-

.endmacro

.macro toupper
	cmp #$60 ; Is lowercase?
	bcc :+
	and	#$DF
:
.endmacro

.macro tolower
	ora #$20
.endmacro