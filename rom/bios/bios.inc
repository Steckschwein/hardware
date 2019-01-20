.setcpu "65c02"
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

; Address pointers for serial upload
startaddr	= ptr1
endaddr		= ptr2
length		= $e0

DPL 		= $00
DPH 		= $01






tmp0		= $ea
tmp1		= $eb
tmp2		= $ec
tmp3		= $ed
tmp4		= $ee
tmp5		= $ef
tmp6		= $f0
tmp7		= $f1



lba_addr = $20
errno	 				= $0300
nvram		= $1000

dirptr 		= $f4 ; 2 byte
paramvec	= $f8


; pointer for string output functions 
msgptr 		= $fe


sd_blktarget 		= $0400

steckos_start		= $1000	





param_sig		= $00 ; 1  byte  - parameter array signature byte. must be $42
param_version	= $01 ; 1  byte  - version number. initially zero
param_filename	= $02 ; 11 bytes - file to boot. example "LOADER  BIN"
param_uart_div	= $0d ; 2  bytes  - baudrate divisor value
param_lsr       = $0f ; 1  byte  - uart lcr value , default %00000011 (8N1)
param_checksum  = $5f ; checksum


.macro SetVector word, addr 
			lda #<word
			sta addr
			lda #>word
			sta addr+1
.endmacro

.macro	printlnstring text
			jsr primm
			.byte text, $0a, 0
.endmacro

.macro	printstring text
			jsr primm
			.asciiz text
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
@l:	lda src,x
	sta trgt,x
	dex
	bpl @l
.endmacro

.macro copyPointer fromptr, toptr 
	.repeat 2, i
		lda fromptr+i
		sta toptr	+i	
	.endrep
.endmacro
