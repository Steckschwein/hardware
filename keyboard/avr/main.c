//---------------------------------------------------------------------------------

// main.c

//---------------------------------------------------------------------------------

#include <avr/interrupt.h>
#include <util/delay.h>

#include "keyboard.h"
#include "keycodes.h"
#include "spi.h"

int main( void )
{
	uint8_t key;

	keyboardInit();
	spiInitSlave();

	sei();

	while(1)
	{		
		key = 0;

		while (slaveSelect == 0) {}
	
		
		if (( key = getKey()) != 0 )
		{	

			spiTransfer(key);	
					
	
	
		}

	}

	return 0;
}
