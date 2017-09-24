;----------------------------------------------------------------------------
; time struct with date set to 1970-01-01
.struct time_t
		tm_sec	.byte		;0-59
        tm_min	.byte		;0-59
        tm_hour	.byte		;0-23
        tm_mday	.byte		;1-31
        tm_mon	.byte	1	;0-11 0-jan, 11-dec
        tm_year	.word  70	;years since 1900
        tm_wday	.byte		;
 ;       tm_yday
  ;      tm_isdst
.endstruct

;----------------------------------------------------------------------------
; last known timestamp with date set to 1970-01-01
rtc_systime_t = $0300