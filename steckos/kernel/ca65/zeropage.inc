;GENERAL

addr = $e0
adrl = addr
adrh = addr+1
; TEXTUI
crs_x	= $e2
crs_y   = $e3
crs_ptr = $e4

screen_status 		= $e6
screen_write_lock 	= $e7
screen_frames		= $e8
saved_char			= $e9
txtui_tmp0			= $ea
txtui_tmp1			= $eb

; OUT
msgptr  = $ec

; SPI
spitmp 	= $ed

; FAT32
lba_addr = $ee
lba_tmp  = $f2
blocks	 = $f3
filenameptr = $f4
dirptr 		= $f6 ; 2 byte


; SDCARD 
sd_tmp	  = $f8
sd_blkptr = $f9