.setcpu "65C02"

; minimal monitor for EhBASIC and 6502 simulator V1.05
; Modified to support the Replica 1 by Jeff Tranter <tranter@pobox.com>
; Steckschwein

; To run EhBASIC on the simulator load and assemble [F7] this file, start the simulator
; running [F6] then start the code with the RESET [CTRL][SHIFT]R. Just selecting RUN
; will do nothing, you'll still have to do a reset to run the code.


.include "../kernel/kernel.inc"
.include "../kernel/kernel_jumptable.inc"
.include "../asminc/common.inc"

.include "../kernel/fat32.inc"
.include "../kernel/uart.inc"
.include "fcntl.inc"
.include "appstart.inc"

appstart $b200

.include "basic.asm"
.include "ext/gfx.asm"		    ;extensions

ESC = $1B        ; Escape character
CR  = $0D        ; Return character
LF  = $0A        ; Line feed character

; put the IRQ and MNI code in RAM so that it can be changed
IRQ_vec	= VEC_SV+2		; IRQ code vector	(VEC_SV = ccflag+$0b)
NMI_vec	= IRQ_vec+$0A	; NMI code vector
; NOTE: ccflag + $18 -> $02a8

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
		
		lda	#0				;init text mode
		sta 	GFX_MODE		
	
		JMP	LAB_COLD		; do EhBASIC cold start

openfile:
        pha             ; save file open mode
        jsr strparam2buf
@open:
        SetVector buf, filenameptr
		lda #<buf
		ldx #>buf
        ply
		jmp krn_open

io_error:
        ldx #$24
        jmp LAB_XERR

bsave:
		lda #O_WRONLY
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

		stz fd_area + F32_fd::FileSize + 2,x
		stz fd_area + F32_fd::FileSize + 3,x

		jsr krn_write
		bne io_error
		jmp krn_close

bload:
		lda #O_RDONLY
		jsr openfile
		bne io_error

		lda Smemh
		sta read_blkptr + 1

		lda Smeml
		sta read_blkptr + 0

		jsr krn_read
		bne io_error

		phx
		jsr krn_getfilesize
		clc
		adc Smeml
		sta Svarl

		txa
		adc Smemh
		sta Svarh
		plx

		jsr krn_close

        LDA   #<LAB_RMSG   ; "READY"
        LDY   #>LAB_RMSG
        JSR   LAB_18C3
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

; IRQ_CODE:
; 	PHA				; save A
;     lda #'i'
;     jsr V_OUTP
; 	LDA	IrqBase		; get the IRQ flag byte
; 	LSR				; shift the set b7 to b6, and on down ...
; 	ORA	IrqBase		; OR the original back in
; 	STA	IrqBase		; save the new IRQ flag byte
; 	PLA				; restore A
; 	RTI

; EhBASIC NMI support

; NMI_CODE:
; 	PHA				; save A
;    	lda #'n'
;    	jsr V_OUTP
; 	LDA	NmiBase		; get the NMI flag byte
; 	LSR				; shift the set b7 to b6, and on down ...
; 	ORA	NmiBase		; OR the original back in
; 	STA	NmiBase		; save the new NMI flag byte
; 	PLA				; restore A
; 	RTI

END_CODE:

;LAB_mess:
	;.byte	$0D,$0A,"6502 EhBASIC [C]old/[W]arm ?",$00
					; sign on string

; system vectors
	;.org	$FFFA
	;.word	NMI_vec		; NMI vector
	;.word	RES_vec		; RESET vector
	;.word	IRQ_vec		; IRQ vector
