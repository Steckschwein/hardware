//---------------------------------------------------------------------------------

// main.c

//---------------------------------------------------------------------------------

#include <avr/interrupt.h>
#include "keyboard.h"
#include "keycodes.h"
#include "spi.h"

int main( void )
{
	unsigned char key;

	keyboardInit();
	spiInitSlave();

	sei();

	while(1)
	{		
		while ( slaveSelect ) {}

		if (( key = getKey()) != 0 )
		{	
			spiTransfer(key);	

			// PORTB = key;
			// _delay_ms(10);
		}
		// PORTB=0;
	}

	return 0;
}
