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
lba_addr = $f0		; 4 bytes
lba_tmp  = $f4 		; 4 bytes
blocks	 = $f8
filenameptr = $f9   ; 2 byte
dirptr 		= $fb 	; 2 byte


; SDCARD 
sd_blkptr = $fd
sd_tmp	  = $ff
