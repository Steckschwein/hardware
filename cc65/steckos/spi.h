#ifndef _SPI_H
#define _SPI_H

extern unsigned char __fastcall__ spi_read(void);
extern unsigned char __fastcall__ spi_write(unsigned char b);
extern void __fastcall__ spi_deselect(void);

#endif