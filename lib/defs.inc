; Cursor Position and buffer
crs_x	= $e6
crs_y	= $e7
crs_ptr	= $e8 	; 2 byte ram address pointer

entries 	= $f2   ; TODO FIXME shell cleanup... use temp instead

dirptr 		= $f4 ; 2 byte
paramvec	= $f8

; pointer to filename for fs operations (open...)
filenameptr		= $fa

; pointer for io block operations
sd_blkptr 	= $fc

; pointer for string output functions 
msgptr 		= $fe
; zeropage end

; MEMCTL Register
memctl    			= $0230

; 
; vector addresses
;
irqvec				= $0280
nmivec				= $0282
outvec				= $0284
invec				= $0286

ram_end 			= $0288
ram_end_l   		= ram_end
ram_end_h   		= ram_end+1

user_isr 	        = $028a

retvec				= $0290

fat_dir_action_hook		= $0292
fat_dir_display_hook	= fat_dir_action_hook
fat_dir_filter_hook		= $0294

; irq vector safe point
irqsafe				= $0296
sd_card_status 		= $0298  
; SD CArd command parameter/result buffer
sd_cmd_param 		= $02a0
sd_cmd_chksum		= sd_cmd_param+4
sd_cmd_result 		= $02a5

current_dir_first_cluster 	= $02b0 ; first cluster of current dir
; SD Card error
; $ff - No Card
; $0f - Invalid Card
; $00 - No error

lba_addr = $20
errno	 				= $0300

cluster_begin_lba 		= $0303 ; begin of cluster area, 4 bytes
sectors_per_cluster 	= $0307 ; sectors per cluster, 1 byte
root_dir_first_clus 	= $0308 ; first cluster of root dir, 4 bytes
filename_buf			= $030c ; file name buffer, 11 bytes
dir_attrib_mask			= $0319 ;
fd_area					= $0320 ; File descriptor area, 6x8byte until $0350 
open_file_cluster		= $0320

xxx						= $0350 ;
fat_first_block			= $0350
sd_blktarget 		= $0400

steckos_start		= $1000	

charset  	 		=$e000
charset_6x8  		=$e800
