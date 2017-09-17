; INIT0/SHELL

appstart	= $1000
cmdptr		= $d6
paramptr	= $d8
retvec 		= $da

; GENERAL
addr 		= $e0
adrl 		= addr
adrh 		= addr+1
; TEXTUI
crs_x		= $e2
crs_y   	= $e3
crs_ptr 	= $e4

; OUT
msgptr  	= $e6		; 2 bytes

; kernel pointer (internally used)
krn_ptr1    	= $e8	; 2 bytes
krn_ptr2    	= $ea	; 2 bytes
krn_ptr3    	= $ec	; 2 bytes

krn_tmp     	= $ee		; 16 bit tmp
krn_tmp1		= krn_tmp	; single byte alias tmp1
krn_tmp2		= krn_tmp+1	; single byte alias tmp2

; FAT32
filenameptr 	= $f0   ; 2 byte
dirptr 	    	= $f2 	; 2 byte

; SDCARD/storage block pointer
read_blkptr  	= $f9
write_blkptr 	= $fb
sd_tmp	     	= $fd

lba_addr 		= $0280		; 4 bytes
blocks			= $0288		; 3 bytes - blocks to read, 4GB -> 4294967296 >> 9 = 8388608 ($800000) max blocks/file 

krn_call_internal	= $028c		; jmp vector internally used

trampolin	= $0291


errno		= $0300
;TODO FIXME rename
;__oserror 	= errno
