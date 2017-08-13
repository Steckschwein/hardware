.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/asminc/common.inc"


BINBCD16:	SED		; Switch to decimal mode
		LDA #0		; Ensure the result is clear
		STA BCD+0
		STA BCD+1
		STA BCD+2
		LDX #16		; The number of source bits

CNVBIT:		ASL BIN+0	; Shift out one bit
		ROL BIN+1
		LDA BCD+0	; And add into result
		ADC BCD+0
		STA BCD+0
		LDA BCD+1	; propagating any carry
		ADC BCD+1
		STA BCD+1
		LDA BCD+2	; ... thru whole result
		ADC BCD+2
		STA BCD+2
		DEX		; And repeat for next bit
		BNE CNVBIT
		CLD		; Back to binary

		lda BCD+2
		jsr krn_hexout
		lda BCD+1
		jsr krn_hexout
		lda BCD
		jsr krn_hexout

loop:		jmp loop 

; A test value to be converted

		

BIN:		.word  12345
BCD:		.res  3

