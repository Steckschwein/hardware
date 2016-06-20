.include "kernel.inc"


shell_addr	 = $e000

text_mode_40 = 1

kbd_frame_div  = $01

.import init_via1
.import init_rtc
.import spi_r_byte, spi_rw_byte
.import init_uart, uart_tx, uart_rx
; .import textui_init0
; !src <defs.h.a>
; ; !src <bios.h.a>
; !src <via.h.a>
; !src <uart.h.a>
; !src <fat32.h.a>
; !src <params.h.a>
; !src <errors.h.a>


.segment "KERNEL"
kern_init:
	lda #$03
	sta $0230

	jsr init_via1
	jsr init_rtc

	; jsr textui_init0



@l:	jmp @l



;----------------------------------------------------------------------------------------------
; IO_IRQ Routine. Handle IRQ
;----------------------------------------------------------------------------------------------
do_irq:
			rti

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
; krn_keyin				jmp .keyin
; krn_mount 				jmp .fat_mount 
; krn_open 				jmp .fat_open
; krn_close 				jmp .fat_close
; krn_read 				jmp .fat_read 
; krn_open_rootdir 		jmp .fat_open_rootdir
; krn_find_first			jmp .fat_find_first
; krn_find_next			jmp .fat_find_next
; krn_textui_init 		jmp	.textui_init
; krn_textui_enable		jmp	.textui_enable
; krn_textui_disable		jmp .textui_disable			;disable textui
; krn_gfxui_on			jmp	.gfxui_on
; krn_gfxui_off			jmp	.gfxui_off
; krn_display_off			jmp vdp_display_off
; krn_getkey				jmp .getkey
; krn_chrout 				jmp chrout
; krn_strout 				jmp strout
; krn_textui_crsxy			jmp .textui_crsxy
; krn_textui_update_crs_ptr	jmp .textui_update_crs_ptr
; krn_textui_clrscr_ptr		jmp .textui_blank
; krn_hexout 				jmp .hexout
; krn_init_sdcard			jmp .init_sdcard
; krn_upload				jmp .upload
krn_spi_rw_byte:		jmp spi_rw_byte
krn_spi_r_byte:			jmp spi_r_byte
krn_uart_tx:			jmp uart_tx
krn_uart_rx:			jmp uart_rx

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