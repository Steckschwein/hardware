;----------------------------------------------------------------------------------------------
; SD Card commands
;----------------------------------------------------------------------------------------------
cmd0 	= $40       ; GO_IDLE_STATE
cmd1 	= $40 + 1 	; SEND_OP_COND
cmd8 	= $40 + 8   ; SEND_IF_COND
cmd12	= $40 + 12  ; STOP_TRANSMISSION
cmd16	= $40 + 16 	; SET_BLOCKLEN
cmd17	= $40 + 17	; READ_SINGLE_BLOCK
cmd18	= $40 + 18	; READ_MULTIPLE_BLOCK
cmd24	= $40 + 24	; WRITE_BLOCK
cmd55	= $40 + 55	; APP_CMD
cmd58	= $40 + 58	; READ_OCR
acmd41	= $40 + 41

sd_data_token = $fe
sd_card_status 		= $0298  
; SD CArd command parameter/result buffer
sd_cmd_param 		= $02a0
sd_cmd_chksum		= sd_cmd_param+4
sd_cmd_result 		= $02a5


; pointer for io block operations
sd_blkptr 	= $fc
