;GENERAL

addr = $e0
adrl = addr
adrh = addr+1
; TEXTUI
crs_x	= $e2
crs_y   = $e3
crs_ptr = $e4
; TODO FIXME free zp space if necessary by using DATA RAM instead of zp space here
screen_status 		= $e6
screen_write_lock 	= $e7
screen_frames		= $e8
saved_char			= $e9
txtui_tmp0			= $ea
txtui_tmp1			= $eb

; OUT
msgptr  = $ec		; 2 bytes

; SPI
spitmp 	= $ee

; FAT32
; lba_addr = $f0		; 4 bytes
; blocks	 = $f4
filenameptr = $f5   ; 2 byte
dirptr 		= $f7 	; 2 byte


; SDCARD 
sd_read_blkptr = $f9
sd_write_blkptr = $fb
sd_tmp	  = $fd


lba_addr = $0280		; 4 bytes
blocks	 = $0285
