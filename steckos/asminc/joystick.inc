PORT_SEL_2              = !1<<7
PORT_SEL_1              = 1<<7
JOY_UP                  = 1<<0
JOY_DOWN                = 1<<1
JOY_LEFT                = 1<<2
JOY_RIGHT               = 1<<3
JOY_FIRE                = 1<<4

; UART address and registers
uart1		= $0200
uart1mcr	= uart1+4

.macro joy_off
lda #%00000100
ora uart1mcr
sta uart1mcr
.endmacro

.macro joy_on
; joysticks on
lda #%11111011
and uart1mcr
sta uart1mcr
;Port A directions
lda #%11000000 		; via port A - set PA7,6 to output (joystick port select), PA1-5 to input (directions)
sta via1ddra
.endmacro
