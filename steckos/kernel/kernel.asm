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


.include "common.inc"
.include "kernel.inc"
.include "vdp.inc"

shell_addr	 = $d800

text_mode_40 = 1

;kbd_frame_div  = $01

.segment "KERNEL"

.import init_via1
.import init_rtc
.import spi_r_byte, spi_rw_byte, spi_deselect, spi_select_rtc
.import init_uart, uart_tx, uart_rx, uart_rx_nowait
.import textui_init0, textui_update_screen, textui_chrout, textui_put
.import getkey
.import textui_enable, textui_disable, vdp_display_off,  textui_blank, textui_update_crs_ptr, textui_crsxy, textui_scroll_up, textui_cursor_onoff

.import init_sdcard

.import fat_mount, fat_open, fat_close, fat_close_all, fat_read, fat_find_first, fat_find_next
.import fat_mkdir, fat_chdir, fat_rmdir
.import fat_unlink
.import fat_write
.import fat_fseek
.import fat_fread, fat_get_root_and_pwd
.import fat_getfilesize

.import sd_read_block, sd_write_block

.import execv
.import strout, primm

kern_init:
	sei

	; copy trampolin code for ml monitor entry to ram
	ldx #$00
@copy:
	lda trampolin_code,x
	sta trampolin,x
	inx
	cpx #(trampolin_code_end - trampolin_code)
	bne @copy

	jsr init_via1
	jsr init_rtc
	jsr init_uart

	SetVector user_isr_default, user_isr

	jsr textui_init0

	cli

	jsr primm
	.byte $d5,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$b8,$0a
	.byte $b3," steckOS Kernel "
	.include "version.inc"
	.byte $20,$b3,$0a
	.byte $d4,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$be,$0a
	.byte $00

	SetVector do_upload, retvec ; retvec per default to do_upload. end up in do_upload again, if a program exits safely

	jsr init_sdcard
	bne do_upload

	jsr fat_mount
	beq @l_init
	pha
	jsr primm
	.asciiz "mount error ("
	pla

	and #%00001111
	ora #'0'
	jsr krn_chrout

	jsr primm
	.byte ")",$0a,0
	bra do_upload

@l_init:
	lda #<filename
	ldx #>filename
	jsr execv

do_upload:
	jsr upload

	ldx #$ff
	txs

	jmp (startaddr)

;----------------------------------------------------------------------------------------------
; IO_IRQ Routine. Handle IRQ
;----------------------------------------------------------------------------------------------
do_irq:
	PHX                     ;
	PHA                     ;
	TSX                     ; get stack pointer
	LDA   $0103,X           ; load INT-P Reg off stack
	AND   #$10              ; mask BRK
	BNE   @BrkCmd           ; BRK CMD
	PLA                     ;
	PLX                     ;
	;jmp   (INTvector)       ; let user routine have it
	bra @irq
@BrkCmd:
	pla                     ;
	plx                     ;
	jmp   do_nmi
; system interrupt handler
; handle keyboard input and text screen refresh
@irq:
	save
	cld	;clear decimal flag, maybe an app has modified it during execution

	bit	a_vreg
	bpl @exit	   ; VDP IRQ flag set?
	jsr	textui_update_screen
	jsr call_user_isr
@exit:
	restore
	rti

call_user_isr:
	jmp (user_isr)
user_isr_default:
	rts

;----------------------------------------------------------------------------------------------
; IO_NMI Routine. Handle NMI
;----------------------------------------------------------------------------------------------
ACC = $45
XREG = $46
YREG = $47
STATUS = $48
SPNT = $49

do_nmi:
	sta ACC
	stx XREG
	sty YREG
	pla
	sta STATUS
	tsx
	stx SPNT


	jmp trampolin


do_reset:
	; disable interrupt
	sei

	; clear decimal flag
	cld

	; init stack pointer
	ldx #$ff
	txs

	jmp kern_init

startaddr = $b0 ; FIXME - find better location for this
endaddr   = $fd
length	  = $ff

upload:
	save
	crlf
	printstring "Serial Upload"

	; load start address
	jsr uart_rx
	sta startaddr

	jsr uart_rx
	sta startaddr+1

	jsr upload_ok

	; load number of bytes to be uploaded
	jsr uart_rx
	sta length

	jsr uart_rx
	sta length+1

	; calculate end address
	clc
	lda length
	adc startaddr
	sta endaddr

	lda length+1
	adc startaddr+1
	sta endaddr+1

	lda startaddr
	sta addr
	lda startaddr+1
	sta addr+1

	jsr upload_ok

	sei	; disable interrupt while loading the actual data
	ldy #$00
@l1:
	jsr uart_rx
	sta (addr),y

	iny
	cpy #$00
	bne @l2
	inc addr+1
@l2:

	; msb of current address equals msb of end address?
	lda addr+1
	cmp endaddr+1
	bne @l1 ; no? read next byte

	; yes? compare y to lsb of endaddr
	cpy endaddr
	bne @l1 ; no? read next byte

	cli
	; yes? write OK and jump to start addr

	jsr upload_ok

	lda #'O'
	jsr textui_chrout
	lda #'K'
	jsr textui_chrout

	crlf
	restore
	rts

upload_ok:
	lda #'O'
	jsr uart_tx
	lda #'K'
	jsr uart_tx
	rts

filename:	.asciiz "shell.prg"

; trampolin code to enter ML monitor on NMI
; this code gets copied to $1000 and executed there
trampolin_code:
	sei
	; switch to ROM bank 1
	lda #$02
	sta $0230
	; go!
	brk
	;jmp $f000
trampolin_code_end:

.segment "JUMPTABLE"		; "kernel" jumptable

.export krn_rmdir
krn_rmdir:							jmp fat_rmdir
.export krn_mkdir
krn_mkdir:							jmp fat_mkdir
.export krn_execv
krn_execv:							jmp execv

.export krn_uart_rx_nowait
krn_uart_rx_nowait:				jmp uart_rx_nowait

.export krn_mount
krn_mount: 				    		jmp fat_mount

.export krn_open
krn_open: 				    jmp fat_open

.export krn_chdir
krn_chdir: 				    jmp fat_chdir

.export krn_unlink
krn_unlink: 				jmp fat_unlink

.export krn_close
krn_close:						jmp fat_close
.export krn_close_all
krn_close_all:					jmp fat_close_all

.export krn_read
krn_read:						jmp fat_read

.export krn_fread
krn_fread:    					jmp fat_fread

.export krn_find_first
krn_find_first:				jmp fat_find_first
.export krn_find_next
krn_find_next:					jmp fat_find_next
.export krn_textui_init
krn_textui_init:				jmp	textui_init0
.export krn_textui_enable
krn_textui_enable:			jmp	textui_enable
.export krn_textui_disable
krn_textui_disable:			jmp textui_disable			;disable textui

.export krn_display_off
krn_display_off:				jmp vdp_display_off

.export krn_getkey
krn_getkey:						jmp getkey

.export krn_chrout
krn_chrout:						jmp textui_chrout
.export krn_putchar
krn_putchar:					jmp textui_put

.export krn_strout
krn_strout:						jmp strout

.export krn_textui_crsxy
krn_textui_crsxy:           jmp textui_crsxy

.export krn_textui_update_crs_ptr
krn_textui_update_crs_ptr:  jmp textui_update_crs_ptr

.export krn_textui_clrscr_ptr
krn_textui_clrscr_ptr:      jmp textui_blank

.export krn_fseek
krn_fseek:						jmp fat_fseek

.export krn_textui_crs_onoff
krn_textui_crs_onoff:   jmp textui_cursor_onoff

.export krn_init_sdcard
krn_init_sdcard:		jmp init_sdcard

.export krn_upload
krn_upload:				jmp do_upload

.export krn_spi_select_rtc
krn_spi_select_rtc:     jmp spi_select_rtc

.export krn_spi_deselect
krn_spi_deselect:       jmp spi_deselect

.export krn_spi_rw_byte
krn_spi_rw_byte:		jmp spi_rw_byte

.export krn_spi_r_byte
krn_spi_r_byte:			jmp spi_r_byte

.export krn_uart_tx
krn_uart_tx:			jmp uart_tx

.export krn_uart_rx
krn_uart_rx:			jmp uart_rx

.export krn_primm
krn_primm:      		jmp primm

.export krn_getcwd
krn_getcwd:      		jmp fat_get_root_and_pwd

.export krn_getfilesize
krn_getfilesize:      	jmp fat_getfilesize

.export krn_write
krn_write:    		jmp fat_write

.export krn_sd_write_block
krn_sd_write_block:    	jmp sd_write_block

.export krn_sd_read_block
krn_sd_read_block:    	jmp sd_read_block

;.import uart_rx_nowait
;.export krn_uart_rx_nowait
;krn_uart_rx_nowait:    	jmp uart_rx_nowait

.segment "VECTORS"
; ----------------------------------------------------------------------------------------------
; Interrupt vectors
; ----------------------------------------------------------------------------------------------
; $FFFA/$FFFB NMI Vector

.word do_nmi
; $FFFC/$FFFD reset vector
;*= $fffc
.word do_reset
; $FFFE/$FFFF IRQ vector
;*= $fffe
.word do_irq
