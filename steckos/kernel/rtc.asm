.include "kernel.inc"
.include "rtc.inc"
.include "via.inc"
.import spi_rw_byte, spi_r_byte, spi_deselect

.export init_rtc, spi_select_rtc
;kernel api
.export	rtc_systime
;kernel internal
.export __rtc_systime_update, __rtc_systime_t

.segment "KERNEL"

spi_device_rtc=$76;#%01110110

spi_select_rtc:
		lda #spi_device_rtc
		sta via1portb
		rts

init_rtc:
		; disable RTC interrupts
		; Select SPI SS for RTC
		jsr spi_select_rtc

		lda #$8f
		jsr spi_rw_byte
		lda #$00
		jsr spi_rw_byte

		; Deselect SPI SS for RTC
		jmp spi_deselect

		
		;in:
		;	A/X pointer to time_t struct @see asminc/rtc.inc
		;out:
		;	Z=0 ok, Z=1 and A with error
rtc_systime:
		sta krn_ptr1		;safe pointer
		stx krn_ptr1+1
		jsr __rtc_systime_update
		ldy	#.sizeof(time_t)
@cp:	lda	__rtc_systime_t, y
		sta (krn_ptr1), y
		dey
		bne @cp
		rts		;exit Z=0 here
		
		
		;in:
		;	-
		;out:
		;	-
__rtc_systime_update:
		jsr	spi_select_rtc
		
		lda #0				;0 means rtc read, start from first address (seconds)
		jsr spi_rw_byte

		jsr spi_r_byte     ;seconds
		jsr BCD2dec
		sta __rtc_systime_t+time_t::tm_sec

		jsr spi_r_byte     ;minute
		jsr BCD2dec
		sta __rtc_systime_t+time_t::tm_min

		jsr spi_r_byte     ;hour
		jsr BCD2dec
		sta __rtc_systime_t+time_t::tm_hour

		jsr spi_r_byte     ;week day
		sta __rtc_systime_t+time_t::tm_wday
		
		jsr spi_r_byte     					;day of month
		jsr BCD2dec
		sta __rtc_systime_t+time_t::tm_mday

		jsr spi_r_byte     					;month
		dec                     			;dc1306 gives 1-12, but 0-11 expected
		jsr BCD2dec
		sta __rtc_systime_t+time_t::tm_mon

		jsr spi_r_byte   					;year value - rtc year 2000+year register
		jsr BCD2dec
		clc
		adc #100            				;time_t year starts from 1900
		sta __rtc_systime_t+time_t::tm_year

		jmp spi_deselect
	
; dec = (((BCD>>4)*10) + (BCD&0xf))
BCD2dec:tax
		and     #%00001111
		sta     krn_tmp1
		txa
		and     #%11110000      ; highbyte => 10a = 8a + 2a
		lsr                     ; 2a
		sta     krn_tmp2
		lsr						; 
		lsr                     ; 8a
		adc     krn_tmp2        ; = *10
		adc     krn_tmp1
		rts

;----------------------------------------------------------------------------
; last known timestamp with date set to 1970-01-01
__rtc_systime_t: .tag time_t