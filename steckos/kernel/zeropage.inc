; INIT0/SHELL
cmdptr				= $d6
paramptr			= $d8
retvec 				= $da

; GENERAL
addr = $e0
adrl = addr
adrh = addr+1
; TEXTUI
crs_x	= $e2
crs_y   = $e3
crs_ptr = $e4

; OUT
msgptr  = $e6		; 2 bytes

; SPI
spitmp 	= $ea

; FAT32
filenameptr = $f0   ; 2 byte
dirptr 		= $f2 	; 2 byte

; SDCARD
sd_read_blkptr = $f9
sd_write_blkptr = $fb
sd_tmp	  = $fd

lba_addr 		= $0280		; 4 bytes
lba_addr_data	= lba_addr
lba_addr_fat 	= $0284		; 4 bytes 
blocks			= $0288		; 3 bytes - blocks to read, 4GB -> 4294967296 >> 9 = 8388608 ($800000) max blocks/file 

errno	 	    = $0300