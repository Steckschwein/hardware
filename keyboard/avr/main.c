//---------------------------------------------------------------------------------

// main.c

//---------------------------------------------------------------------------------

#include <avr/interrupt.h>
#include <stdio.h>
#include <stdlib.h>
#include <avr/io.h>
#include <avr/delay.h>

#include "keyboard.h"
#include "keycodes.h"

void pump(uint8_t b)
{
	uint8_t bit=7;

	do
	{
		if (b & _BV(bit))
		{
			PORTA |= _BV(1);
		}
		else
		{
			PORTA &= ~_BV(1);
		}
		
	;	_delay_ms(5);
		PORTA |= _BV(0);
	;	_delay_ms(5);
		PORTA &= ~_BV(0);
	
	}
	while(bit-- > 0);
}	

int main( void )
{
	
	unsigned char key, tmp = 0;
	
	keyboardInit( );
	
	DDRB = 0xff;
	PORTB = 0x00;
	
	DDRA = 3;
	PORTA=0;

	sei( );

	while( 1 )
	{
		if (( key = getKey( )) != 0 )
		{
			PORTB=key;
			//pump(key);
			_delay_ms(10);
		}
		PORTB=0;
		//pump(0);
	}
	return 0;
}
