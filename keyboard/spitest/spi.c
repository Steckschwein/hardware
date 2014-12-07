#include <stdio.h>
#include <stdlib.h>
#include <avr/io.h>
#include <avr/interrupt.h>

#include "spi.h"



/*
    Initialize USI as slave
*/
void spiInitSlave()
{

	/* Set MISO output, all others input */
	DDR_SPI = (1<<DD_MISO);
	/* Enable SPI */
	SPCR = (1<<SPE);

}


unsigned char spiTransfer(unsigned char val)
{
	SPDR = val;

	/* Wait for reception complete */
	while(!(SPSR & (1<<SPIF)));
	/* Return data register */
	return SPDR;
}
	