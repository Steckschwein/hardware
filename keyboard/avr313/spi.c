#include <stdio.h>
#include <stdlib.h>
#include <avr/io.h>
#include <avr/interrupt.h>


#include "spi.h"
#include "kb.h"

//SPI Transfer Complete Interrupt starting on page 124 in datasheet
ISR( SPI_STC_vect)
{ 
	if (kb_buffcnt == 0)
	{
		spiin = 0;
	}
	else
	{
		spiin = *kb_outptr++;

		// Pointer wrapping
		if (kb_outptr >= kb_buffer + KB_BUFF_SIZE)
			kb_outptr = kb_buffer;

		// Decrement buffer count
		kb_buffcnt--;
	}

	spiout = SPDR;
	SPDR = spiin;
}


/*
    Initialize USI as slave
*/
void spiInitSlave()
{
	/* Set MISO output, all others input */
	DDR_SPI = (1<<DD_MISO);
	/* Enable SPI */
	// SPCR = (1<<SPE);
	SPCR = 0xC0;
	spiin = 0;

}
