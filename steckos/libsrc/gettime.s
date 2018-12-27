;
; Marko Lauke 08.11.2018
; Oliver Schmidt, 14.8.2018
; Stefan Haubenthal, 27.7.2009
;
; int __fastcall__ clock_gettime (clockid_t clk_id, struct timespec *tp);
;

        .include        "time.inc"
		.include		"../kernel/kernel_jumptable.inc"
		.include		"rtc.inc"

        .import         pushax, steaxspidx, incsp1, incsp3, return0
        .importzp       ptr1, tmp1, tmp2

;----------------------------------------------------------------------------
.code

.proc _clock_gettime
        jsr pushax             ; save *tp ptr

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
        dec                    ;dc1306 gives 1-12, but 0-11 expected
        jsr BCD2dec
        sta TM+tm::tm_mon

        jsr krn_spi_r_byte     ;year value - rtc year 2000+<year register>
        jsr BCD2dec
        clc
        adc #100               ;TM starts from 1900, so add the difference
        sta TM+tm::tm_year

        jsr krn_spi_deselect

        lda #<TM               ; pointer to TM struct
        ldx #>TM
        jsr _mktime

        ; store tv_sec into output tp struct
        ldy #timespec::tv_sec
        jsr steaxspidx          ; Pops address pushed by pushax (s. above)

        ; Cleanup stack
        jsr incsp1

        ; Return success
        jmp return0

; dec = (((BCD>>4)*10) + (BCD&0xf))
BCD2dec:
        tax
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
; TM struct with date set to 1970-01-01
.data

TM:     .tag    tm
