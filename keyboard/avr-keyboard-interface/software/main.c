//---------------------------------------------------------------------------------

// main.c

//---------------------------------------------------------------------------------

#include <avr/interrupt.h>
#include <stdio.h>
#include <stdlib.h>
#include <avr/io.h>

#include "keyboard.h"
#include "keycodes.h"

int main( void )
{
	unsigned char key, tmp = 0;
	
	keyboardInit( );
	
	DDRB = 0xff;
	PORTB = 0x00;
	
	sei( );

	while( 1 )
	{

		if (( key = getKey( )) != 0 )
		{
			PORTB=key;
			continue;

			switch ( key )
			{
				case '1':
				{
					PORTB = 1;
					break;
				}
				case '2':
				{
					PORTB = 2;
					break;
				}
				case '3':
				{
					PORTB = 3;
					break;
				}
				case UP:
				{
					tmp = PINB & 0x03;
					if ( ++tmp == 4 )
					PORTB = tmp;
				}
				case DOWN:
				{
					tmp = PINB & 0x03;
					if ( --tmp == 255 )
						tmp = 0;
					PORTB = tmp;
				}
				default:
				{
					PORTB = 0;
				}
			}
		}
		PORTB=0;
	}
	return 0;
}
