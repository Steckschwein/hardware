.segment "ZEROPAGE"
.exportzp addr,adrh,adrl
.exportzp msgptr
.exportzp krn_ptr1, krn_ptr2, krn_ptr3
.exportzp krn_tmp, krn_tmp1, krn_tmp2, krn_tmp3, krn_tmp4
.exportzp crs_ptr
.exportzp filenameptr, dirptr
.exportzp read_blkptr, write_blkptr, sd_tmp
; GENERAL
addr: 	   .res 2
adrl 		= addr
adrh 		= addr+1
; OUT
msgptr:     .res 2

; kernel pointer (internally used)
krn_ptr1:   .res 2
krn_ptr2:   .res 2
krn_ptr3:   .res 2

; TEXTUI
crs_ptr: 	.res 2

; tmp
krn_tmp:   .res 1
krn_tmp1:  .res 1
krn_tmp2:  .res 1
krn_tmp3:  .res 1
krn_tmp4:  .res 1

filenameptr: .res 2   ; 2 byte
dirptr: 	 .res 2; 2 byte

read_blkptr:  .res 2
write_blkptr: .res 2
sd_tmp:       .res 1
