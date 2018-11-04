; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

; INIT0/SHELL

appstart	= $1000

; shell related - TODO FIXME away from kernel stuff, conflicts with basic. but after basic start, we dont care about shell zp. maybe if we want to return to shell one day !!!
cmdptr		= $d6
paramptr	= $d8
retvec 		= $da

; GENERAL
addr 		= $e0
adrl 		= addr
adrh 		= addr+1
; TEXTUI
crs_ptr 	= $e2
crs_x		= $028c
crs_y   	= $028d

; OUT
msgptr  	= $e4		; 2 bytes

; kernel pointer (internally used)
krn_ptr1    	= $e6	; 2 bytes			;
krn_ptr2    	= $e8	; 2 bytes			;
krn_ptr3    	= $ea	; 2 bytes

krn_tmp     	= $ec		; 16 bit tmp
krn_tmp2		= krn_tmp+1	; single byte alias tmp1
krn_tmp3		= krn_tmp+2	; single byte alias tmp2
krn_tmp4		= krn_tmp+3	; single byte alias tmp2

; FAT32
filenameptr 		= $f0   ; 2 byte
dirptr 	    		= $f2 	; 2 byte

; SDCARD/storage block pointer
read_blkptr  		= $f4
write_blkptr 		= $f6
sd_tmp	     		= $f8

lba_addr 			= $0280		; 4 bytes
blocks				= $0284		; 3 bytes blocks to read, 3 bytes sufficient to address 4GB -> 4294967296 >> 9 = 8388608 ($800000) max blocks/file

trampolin			= $0010
