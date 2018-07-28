.export rot13

rot13:
	cmp #'z'+1		; $7B
	bcs @out
	cmp #'A'		; $41
	bcc @out
	cmp #'O'-1		; $4E
	bcc @add
	cmp #'Z'+1		; $5B
	bcc @sub
	cmp #'a'		; $61
	bcc @out
	cmp #'o'-1		; $6E
	bcc @add

@sub:
	sec
	sbc #13
	rts
@add:
	;clc ; carry will always be clear when we get here, so save one byte
	adc #13
@out:
    rts

