.setcpu "65c02"
.include "zeropage.inc"

current_dir_first_cluster 	= $02b0 ; first cluster of current dir
filename_buf				= $030c ; file name buffer, 11 bytes
fd_area						= $0320 ; File descriptor area, 6x8byte until $0350 
fat_first_block				= $0350
sd_blktarget 				= $0400

errno	 			= $0300

user_isr 	        = $028a

.macro debugHex v
    pla
    lda v
    jsr hexout
    debug_newline
    pha
.endmacro

.macro debug_newline v32
    jsr primm
    .byte $0a,$0d,$00
.endmacro

.macro debug32 v32
    pha
    lda v32
    jsr hexout
    lda v32+1
    jsr hexout
    lda v32+2
    jsr hexout
    lda v32+3
    jsr hexout
    debug_newline
    pla
.endmacro

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
