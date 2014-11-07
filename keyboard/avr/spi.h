#ifndef SPI_H
#define SPI_H

#define CTRL_PORT   DDRB
#define DATA_PORT   PORTB
#define SS_PIN      PB4
#define CLK_PIN     PB7
#define DI_PIN      PB5
#define DO_PIN      PB6

void spiInitSlave();
unsigned char spiTransfer(unsigned char);

volatile uint8_t transferComplete ;
// volatile char slaveSelect;

#endif
