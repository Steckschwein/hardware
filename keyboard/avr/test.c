#include <avr/interrupt.h>
#include <stdio.h>
#include <stdlib.h>
#include <avr/io.h>

int main( void )
{	
	DDRB = 0x0f;
	PORTB = 0x0f;
	for (;;) {}

	return 0;
}