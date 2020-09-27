#ifndef SPI_H
#define SPI_H

#define DDR_SPI DDRB
#define DD_MISO PB4

volatile uint8_t spiout;
volatile uint8_t spiin;;

void spiInitSlave();

#endif
