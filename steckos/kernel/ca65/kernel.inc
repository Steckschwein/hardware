.setcpu "65c02"
.macro SetVector word, addr 
			lda #<word
			sta addr
			lda #>word
			sta addr+1
.endmacro