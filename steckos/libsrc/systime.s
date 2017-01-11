;
; Stefan Haubenthal, 27.7.2009
;
; time_t _systime (void);
; /* Similar to time(), but:
; **   - Is not ISO C
; **   - Does not take the additional pointer
; **   - Does not set errno when returning -1
; */
;

        .include        "time.inc"
		.include		"../kernel/kernel_jumptable.inc"
		
        .constructor    initsystime
        .importzp       tmp1, tmp2
		
rtc_read=0

;----------------------------------------------------------------------------
.code

.proc   __systime

	jsr	krn_spi_select_rtc
    
	lda #rtc_read
	jsr krn_spi_rw_byte

	jsr krn_spi_r_byte     ;seconds
    jsr BCD2dec
	sta TM+tm::tm_sec

	jsr krn_spi_r_byte     ;minute
    jsr BCD2dec
	sta TM+tm::tm_min

	jsr krn_spi_r_byte     ;hour
    jsr BCD2dec
	sta TM+tm::tm_hour

	jsr krn_spi_r_byte     ;week day
    sta TM+tm::tm_wday
    
	jsr krn_spi_r_byte     ;day of month
    jsr BCD2dec
    sta TM+tm::tm_mday

	jsr krn_spi_r_byte     ;month
    dec                     ;dc1306 gives 1-12, but 0-11 expected
    jsr BCD2dec
    sta TM+tm::tm_mon

	jsr krn_spi_r_byte     ;year value - rtc yeat 2000+year register
    jsr BCD2dec
    clc
    adc #100                ;TM starts from 1900, so add the difference
    sta TM+tm::tm_year

    jsr krn_spi_deselect
    
    lda     #<TM                    ; pointer to TM struct
    ldx     #>TM
    jmp     _mktime

; dec = (((BCD>>4)*10) + (BCD&0xf))
BCD2dec:tax
        and     #%00001111
        sta     tmp1
        txa
        and     #%11110000      ; *16
        lsr                     ; *8
        sta     tmp2
        lsr
        lsr                     ; *2
        adc     tmp2            ; = *10
        adc     tmp1
        rts

.endproc

;----------------------------------------------------------------------------
; Constructor that writes to the 1/10 sec register of the TOD to kick it
; into action. If this is not done, the clock hangs. We will read the register
; and write it again, ignoring a possible change in between.
.segment "INIT"

.proc   initsystime

        rts

.endproc

;----------------------------------------------------------------------------
; TM struct with date set to 1970-01-01
.data

TM:     .word           0       ; tm_sec    ;0-59
        .word           0       ; tm_min    ;0-59
        .word           0       ; tm_hour   ;1-23
        .word           1       ; tm_mday   ;1-31
        .word           0       ; tm_mon    ;0-11 0-jan, 11-dec
        .word           70      ; tm_year
        .word           0       ; tm_wday
        .word           0       ; tm_yday
        .word           0       ; tm_isdst
