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

.ifdef DEBUG_RTC; enable debug for this module
	debug_enabled=1
.endif

.include "kernel.inc"
.include "rtc.inc"
.include "via.inc"
.import spi_rw_byte, spi_r_byte, spi_deselect, spi_select_device

.export init_rtc
;kernel api
.export	rtc_systime, spi_select_rtc
;kernel internal
.export __rtc_systime_update

.segment "KERNEL"

spi_device_rtc=%01110110

        ; out:
        ;   Z=1 spi for rtc could be selected (not busy), Z=0 otherwise
spi_select_rtc:
		lda #spi_device_rtc
		jmp spi_select_device

init_rtc:
		; disable RTC interrupts
		; Select SPI SS for RTC
		lda #spi_device_rtc
		sta via1portb
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
@cp:	lda	rtc_systime_t, y
		sta (krn_ptr1), y
		dey
		bne @cp
		rts		;exit Z=0 here        
        
		;in:
		;	-
		;out:
		;
__rtc_systime_update:
		jsr spi_select_rtc
		beq :+
		rts		
:		debug "update systime"
		lda #0				;0 means rtc read, start from first address (seconds)
		jsr spi_rw_byte

		jsr spi_r_byte     ;seconds
		jsr BCD2dec
		sta rtc_systime_t+time_t::tm_sec

		jsr spi_r_byte     ;minute
		jsr BCD2dec
		sta rtc_systime_t+time_t::tm_min

		jsr spi_r_byte     ;hour
		jsr BCD2dec
		sta rtc_systime_t+time_t::tm_hour

		jsr spi_r_byte     ;week day
		sta rtc_systime_t+time_t::tm_wday

		jsr spi_r_byte     					;day of month
		jsr BCD2dec
		sta rtc_systime_t+time_t::tm_mday

		jsr spi_r_byte     					;month
		dec                     			;dc1306 gives 1-12, but 0-11 expected
		jsr BCD2dec
		sta rtc_systime_t+time_t::tm_mon

		jsr spi_r_byte   					;year value - rtc year 2000+year register
		jsr BCD2dec
		clc
		adc #100            				;time_t year starts from 1900
		sta rtc_systime_t+time_t::tm_year
		debug32 "rtc0", rtc_systime_t
		debug32 "rtc1", rtc_systime_t+4
		jmp spi_deselect

; dec = (((BCD>>4)*10) + (BCD&0xf))
BCD2dec:tax
		and     #%00001111
		sta     krn_tmp
		txa
		and     #%11110000      ; highbyte => 10a = 8a + 2a
		lsr                     ; 2a
		sta     krn_tmp2
		lsr						;
		lsr                     ; 8a
		adc     krn_tmp2        ; = *10
		adc     krn_tmp
		rts
