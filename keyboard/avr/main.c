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


	spiInitSlave();
	keyboardInit();
	sei();

	while(1)
	{		
		// SS_PIN must be low for us to do something
		//if(PINB & (1 << SS_PIN)) 
		if (! spiSelected())
		{
    			continue;
  		}


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
