.include "kernel.inc"
.include "vdp.inc"

shell_addr	 = $e000

text_mode_40 = 1

;kbd_frame_div  = $01

.import init_via1
.import init_rtc
.import spi_r_byte, spi_rw_byte
.import init_uart, uart_tx, uart_rx
.import textui_init0, textui_update_screen, textui_chrout
.import strout, hexout, primm, print_crlf
.import keyin, getkey
;TODO FIXME testing purpose only
.import textui_enable, textui_disable, vdp_display_off
.import init_sdcard
.import fat_mount, fat_open, fat_open_rootdir, fat_close, fat_read, fat_find_first, fat_find_next
.segment "KERNEL"

kern_init:
	jsr init_via1
	jsr init_rtc

	jsr textui_init0
    
    cli
	
	SetVector user_isr_default, user_isr

	
	printstring "SteckOS Kernel 0.5"
	
	jsr init_sdcard
    debugHex errno

	jsr fat_mount
	debugHex errno

	SetVector filename, filenameptr

; 	ldy #$00
; @l:	lda (filenameptr),y
; 	beq @l2
; 	jsr textui_chrout
; 	iny
; 	cpy #$10
; 	bne @l
; @l2:
    debug_newline

	jsr fat_open
    debugHex errno

	SetVector $1000, sd_read_blkptr
    
    jsr fat_read
    debugHex errno
    
	ldx #$00
@x:
	lda $1000,x
	jsr hexout
	inx
	cpx #$09
	bne @x

	jsr fat_close
    debugHex errno

	ldx #$ff 
	txs 
	
	jmp $1000
    
loop:
	; jsr getkey
 ;    cmp #$00
	; beq loop
 ;    jsr textui_chrout
	bra loop

filename:	.asciiz "test.bin"
; filename:	.asciiz "shell.bin"
;----------------------------------------------------------------------------------------------
; IO_IRQ Routine. Handle IRQ
;----------------------------------------------------------------------------------------------
do_irq:
; system interrupt handler
; handle keyboard input and text screen refresh

	save

	bit	a_vreg
	bpl @exit	   ; VDP IRQ flag set?
	jsr	textui_update_screen
    
@exit:
	jsr call_user_isr

	restore
	rti

call_user_isr:
	jmp (user_isr)
user_isr_default:
	rts
		
;----------------------------------------------------------------------------------------------
; IO_NMI Routine. Handle NMI
;----------------------------------------------------------------------------------------------
do_nmi:
			rti
			

do_reset:
			; disable interrupt
			sei

			; clear decimal flag
			cld

			; init stack pointer
			ldx #$ff
			txs

			jmp kern_init


; strings
; .kernel_version 			!text "SteckOS Kernel 0.4",$0d,$0a,$00
; .crlf						!byte $0a,$0d,$00
; .txt_msg_loading 			!text "Loading ",$00
; .serial_upload				!text "Serial Upload ",$00
; .filename					!text "shell.bin",$00



.segment "JUMPTABLE"
; "kernel" jumptable
.export krn_keyin
krn_keyin:				jmp keyin
.export krn_mount		
krn_mount: 				jmp fat_mount 
.export krn_open
krn_open: 				jmp fat_open
.export krn_close
krn_close: 				jmp fat_close
.export krn_read
krn_read: 				jmp fat_read 
.export krn_open_rootdir
krn_open_rootdir: 		jmp fat_open_rootdir
.export krn_find_first
krn_find_first:			jmp fat_find_first
.export krn_find_next
krn_find_next:			jmp fat_find_next
.export krn_textui_init	
krn_textui_init:		jmp	textui_init0
.export krn_textui_enable
krn_textui_enable:		jmp	textui_enable
.export krn_textui_disable
krn_textui_disable:		jmp textui_disable			;disable textui

krn_gfxui_on:			jmp	krn_gfxui_on
krn_gfxui_off:			jmp	krn_gfxui_off

.export krn_display_off
krn_display_off:		jmp vdp_display_off
.export krn_getkey
krn_getkey:				jmp getkey
.export krn_chrout
krn_chrout:				jmp textui_chrout
.export krn_strout
krn_strout:				jmp strout
; krn_textui_crsxy			jmp .textui_crsxy
; krn_textui_update_crs_ptr	jmp .textui_update_crs_ptr
; krn_textui_clrscr_ptr		jmp .textui_blank
.export krn_hexout
krn_hexout:				jmp hexout

.export krn_init_sdcard
krn_init_sdcard:		jmp init_sdcard
; krn_upload				jmp .upload
.export krn_spi_rw_byte
krn_spi_rw_byte:		jmp spi_rw_byte

.export krn_spi_r_byte
krn_spi_r_byte:			jmp spi_r_byte

.export krn_uart_tx
krn_uart_tx:			jmp uart_tx

.export krn_uart_rx
krn_uart_rx:			jmp uart_rx
.export krn_primm
krn_primm: 				jmp primm

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