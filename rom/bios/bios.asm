.setcpu "65c02"
.include "bios.inc"
.include "sdcard.inc"
.include "fat32.inc"

.export set_filenameptr
.segment "BIOS"
.import init_uart, upload
.import init_via1
.import hexout, primm, print_crlf
.import vdp_init, vdp_chrout, vdp_detect
.import init_sdcard
.import fat_mount, fat_read, fat_find_first, calc_lba_addr
.import read_nvram

do_reset:
			; disable interrupt
			sei

			; clear decimal flag
			cld

			; init stack pointer
			ldx #$ff
			txs

   			; Check zeropage and Memory
check_zp:
		    ; Start at $ff
			ldy #$ff
			; Start with pattern $03 : $ff
@l2:		ldx #num_patterns
@l1:		lda pattern,x
			sta $00,y
			cmp $00,y
			bne zp_broken

			dex
			bne @l1

			dey
			bne @l2

check_stack:
			;check stack
			ldy #$ff
@l2:		ldx #num_patterns
@l1:		lda pattern,x
			sta $0100,y
			cmp $0100,y
			bne stack_broken

			dex
			bne @l1

			dey
			bne @l2

check_memory:
			lda #>start_check
			sta ptr1h
			ldy #<start_check
			stz ptr1l

@l2:		ldx #num_patterns  ; 2 cycles
@l1:		lda pattern,x      ; 4 cycles
	  		sta (ptr1l),y   ; 6 cycles
			cmp (ptr1l),y   ; 5 cycles
			bne @l3				  ; 2 cycles, 3 if taken

			dex  				  ; 2 cycles
			bne @l1			  ; 2 cycles, 3 if taken

			iny  				  ; 2 cycles		
			bne @l2				  ; 2 cycles, 3 if taken

			; Stop at $e000 to prevent overwriting BIOS Code when ROMOFF
			ldx ptr1h		  ; 3 cycles
			inx				  ; 2 cycles
			stx ptr1h		  ; 3 cycles
			cpx #$e0			  ; 2 cycles

			bne @l2 			  ; 2 cycles, 3 if taken
@l3:  		sty ptr1l		  ; 3 cycles
		
	  					  ; 42 cycles

	  		; save end address
	  		; lda ptr1l
	  		; sta ram_end_l
	  		; lda ptr1h
	  		; sta ram_end_h
	  		
	  	   

			bra mem_ok

mem_broken:
			lda #$40
			bra stop

zp_broken:
			lda #$80
			bra stop

stack_broken:
			lda #$40
stop:
			sta $0230
@loop:		bra @loop


mem_ok:
			jsr vdp_init

			jsr primm
			.byte "BIOS "
			.include "version.inc"
			.byte $0a,0

			printstring "Memcheck $"
	  	lda ptr1h
			jsr hexout
	  	lda ptr1l
			jsr hexout
      jsr print_crlf
      
      jsr vdp_detect
      
			jsr init_via1

			SetVector param_defaults, paramvec

			jsr set_filenameptr

			jsr read_nvram

			jsr init_uart
      
			jsr init_sdcard
			lda errno
			beq boot_from_card
			; display sd card error message
			cmp #$0f
			bne @l1
			printstring "Invalid SD card"
@l1:		cmp #$1f
			bne @l2
			printstring "SD card init failed"
@l2:		cmp #$ff
			bne @l3
			printstring "No SD card"
@l3:
foo:		jsr upload
			jmp startup

boot_from_card:
			printstring "Boot from SD card.. "
			jsr fat_mount

			lda errno
			beq @findfile
			jsr print_crlf
			printstring "FAT32 mount error: "
			jsr hexout

@findfile:
			; copyPointer paramvec, ptr1
			; clc
			; lda #param_filename
			; adc ptr1l
			; sta ptr1l
			; bcc @l4
			; inc ptr1h

@l4: 
			jsr fat_find_first
			bcs @loadfile

			jsr print_crlf

			ldy #$00
@loop:
      lda (ptr1),y
			jsr vdp_chrout
			iny
			cpy #$0b
			bne @loop
			printstring " not found."

			bra foo
@loadfile:
			ldy #DIR_FstClusHI + 1
			lda (dirptr),y
			sta root_dir_first_clus + 3
			ldy #DIR_FstClusHI 
			lda (dirptr),y
			sta root_dir_first_clus + 2
			ldy #DIR_FstClusLO + 1
			lda (dirptr),y
			sta root_dir_first_clus + 1
			ldy #DIR_FstClusLO 
			lda (dirptr),y
			sta root_dir_first_clus
			jsr calc_lba_addr
			
			.repeat 4, i
				ldy #DIR_FileSize + i
				lda (dirptr),y
				sta filesize + i
			.endrep

			SetVector steckos_start, startaddr
			SetVector steckos_start, sd_blkptr
			jsr fat_read			

		; re-init stack pointer
startup:
			ldx #$ff
			txs

			; jump to new code
			jmp (startaddr)



set_filenameptr:
			copyPointer paramvec, ptr1
			clc
			lda #param_filename
			adc ptr1l
			sta ptr1l
			bcc @l4
			inc ptr1h
@l4:
			rts







dummy_irq:
		rti


num_patterns = $02	
pattern:
	.byte $aa,$55,$00

param_defaults:
	.byte $42
	.byte $00
	.byte "LOADER  BIN"
	.word $0001
	.byte %00000011
	; !fill .default_params + param_checksum - *, $00
	; .res    param_defaults + param_checksum - * , $AA
	; .byte $00

.SEGMENT "VECTORS"

;----------------------------------------------------------------------------------------------
; Interrupt vectors
;----------------------------------------------------------------------------------------------
; $FFFA/$FFFB NMI Vector
.word mem_ok
; $FFFC/$FFFD reset vector
;*= $fffc
.word do_reset
; $FFFE/$FFFF IRQ vector
;*= $fffe
.word dummy_irq
