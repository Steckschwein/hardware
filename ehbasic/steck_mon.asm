.setcpu "65C02"
__LOADADDR__ = $1000
.export __LOADADDR__
.segment "LOADADDR"
.word __LOADADDR__
.segment "CODE"

; minimal monitor for EhBASIC and 6502 simulator V1.05
; Modified to support the Replica 1 by Jeff Tranter <tranter@pobox.com>
; Steckschwein

; To run EhBASIC on the simulator load and assemble [F7] this file, start the simulator
; running [F6] then start the code with the RESET [CTRL][SHIFT]R. Just selecting RUN
; will do nothing, you'll still have to do a reset to run the code.

.include "../steckos/kernel/kernel.inc"
.include "../steckos/kernel/kernel_jumptable.inc"
.include "../steckos/kernel/fat32.inc"
.include "../steckos/kernel/uart.inc"

.include "basic.asm"

ESC = $1B        ; Escape character
CR  = $0D        ; Return character
LF  = $0A        ; Line feed character

; put the IRQ and MNI code in RAM so that it can be changed
IRQ_vec	= VEC_SV+2		; IRQ code vector
NMI_vec	= IRQ_vec+$0A	; NMI code vector

; reset vector points here

RES_vec:
;		CLD			; clear decimal mode
;		LDX	#$FF		; empty stack
;		TXS			; set the stack
		
; set up vectors and interrupt code, copy them to page 2
 		LDY	#END_CODE-LAB_vec	; set index/count
LAB_stlp:
 		LDA	LAB_vec-1,Y		; get byte from interrupt code
		STA	VEC_IN-1,Y		; save to RAM
 		DEY				; decrement index/count
 		BNE	LAB_stlp		; loop if more to do
    
		JMP	LAB_COLD		; do EhBASIC cold start

openfile:
		jsr LAB_EVEX
		lda Dtypef
		bne @go
		; not a string, trigger syntax error
		ldx #$02
		jsr LAB_XERR
@go:
		ldy #$00
@l:
		lda (ssptr_l),y
		beq @open
		cmp #'"'
		beq @term
		iny
		bne @l
@term:
		lda #$00
		sta (ssptr_l),y
@open:	
		lda ssptr_l
		ldx ssptr_h
		jsr krn_open
		;bne	io_error
		rts
io_error:
		pha
		jsr	krn_primm
		.asciiz "io error: "
		pla
		jmp krn_hexout		

bsave:
		jsr openfile		
		bne io_error

		lda Smemh
		sta write_blkptr + 1
		lda Smeml
		sta write_blkptr + 0

		sec
		lda Svarl
		sbc Smeml
		sta fd_area + F32_fd::FileSize + 0,x

		lda Svarh
		sbc Smemh
		sta fd_area + F32_fd::FileSize + 1,x

		;lda #$00
		stz fd_area + F32_fd::FileSize + 2,x
		stz fd_area + F32_fd::FileSize + 3,x

		jsr krn_write
		bne io_error
		jmp krn_close
		
bload:
		jsr openfile
		bne io_error

		lda Smemh
		sta read_blkptr + 1

		lda Smeml
		sta read_blkptr + 0

		jsr krn_read
		bne io_error


		clc
		lda Smeml
		adc fd_area + F32_fd::FileSize + 0,x
		sta Svarl

		lda Smemh
		adc fd_area + F32_fd::FileSize + 1,x
		sta Svarh

		jsr krn_close
		bne io_error
		
		jsr krn_primm
		.byte "Ok", $0a, $00
		JMP   LAB_1319		

.ifdef UART
uart_in:
	lda #$01        ; Maske fuer DataReady Bit
	bit uart1lsr
	beq @l1
	lda uart1rxtx

	;jsr krn_uart_rx
        cmp #$00 
        beq @l1
        sec
        rts
@l1:
        clc
        rts
.endif


; vector tables

LAB_vec:
.ifdef UART
	.word	uart_in		; byte in
	.word	krn_uart_tx		; byte out
.else
	.word	krn_getkey		; byte in
	.word	krn_chrout		; byte out
.endif
	.word	bload		; load vector for EhBASIC
	.word	bsave		; save vector for EhBASIC

; EhBASIC IRQ support

IRQ_CODE:
	PHA				; save A
    lda #'i'
    jsr V_OUTP
	LDA	IrqBase		; get the IRQ flag byte
	LSR				; shift the set b7 to b6, and on down ...
	ORA	IrqBase		; OR the original back in
	STA	IrqBase		; save the new IRQ flag byte
	PLA				; restore A
	RTI

; EhBASIC NMI support

NMI_CODE:
	PHA				; save A
   	lda #'n'
   	jsr V_OUTP
	LDA	NmiBase		; get the NMI flag byte
	LSR				; shift the set b7 to b6, and on down ...
	ORA	NmiBase		; OR the original back in
	STA	NmiBase		; save the new NMI flag byte
	PLA				; restore A
	RTI

END_CODE:

;LAB_mess:
	;.byte	$0D,$0A,"6502 EhBASIC [C]old/[W]arm ?",$00
					; sign on string

; system vectors
	;.org	$FFFA
	;.word	NMI_vec		; NMI vector
	;.word	RES_vec		; RESET vector
	;.word	IRQ_vec		; IRQ vector
