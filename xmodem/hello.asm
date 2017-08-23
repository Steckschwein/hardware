!src "../steckos/kernel/kernel_jumptable.inc"

* = $2000

	!for i,1,$1fd {
	nop
	}
	jsr krn_primm	
	!text "Hello World!",13,10,0

loop:	jmp loop


