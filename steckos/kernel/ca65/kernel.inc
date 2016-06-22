.setcpu "65c02"
addr 		= $e0
adrl     	= addr
adrh     	= addr+1

; pointer for string output functions 
msgptr 		= $fe
DPL			= msgptr
DPH			= msgptr+1

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