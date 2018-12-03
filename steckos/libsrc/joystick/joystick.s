.include "joystick.inc"
.include "via.inc"

.export read_joystick
;
;   in:
;       .A - joystick to read either JOY_PORT1 or JOY_PORT2
;            @see use joystick.inc
;   out: 
;       .A - joystick buttons
;
read_joystick:
        and #$80            ;select joy port
        sta	via1porta
        lda	via1porta		;read port input
        rts
