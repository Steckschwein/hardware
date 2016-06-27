.setcpu "65c02"
addr 		= $e0
adrl     	= addr
adrh     	= addr+1

; Cursor Position and buffer
crs_x	= $e2	;  cursor x 
crs_y	= $e3	;  cursor y
crs_ptr = $e4	; 16 bit screen buffer pointer

tmp0=$f6
tmp1=$f7

; TODO FIXME free zp space if necessary by using DATA RAM instead of zp space here
screen_status		=$f8	; 
screen_write_lock  	=$f9	; 0
screen_frames		=$fa	; 0
saved_char			=$fb	; ' '

; pointer for string output functions 
msgptr 		= $fe
DPL			= msgptr
DPH			= msgptr+1

user_isr 	        = $028a

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