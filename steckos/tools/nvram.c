#include <conio.h>  
#include <stdlib.h>  
#include <string.h>  
#include "../../cc65/spi.h"

/*
param_sig	= $00 ; 1  byte  - parameter array signature byte. must be $42
param_version	= $01 ; 1  byte  - version number. initially zero
param_filename	= $02 ; 11 bytes - file to boot. example "LOADER  BIN"
param_baud	= $0d ; 1  byte  - baudrate divisor value, entry# from .uart_divisor, default 15 (9600 baud)    
param_lsr       = $0e ; 1  byte  - uart lcr value , default %00000011 (8N1)
param_checksum  = $5f ; checksum
*/

struct nvram 
{
	unsigned char signature;
	unsigned char version;
	unsigned char filename[11];
	unsigned char uart_baudrate;
	unsigned char uart_lsr;
};

unsigned char c,i;
struct nvram n;
unsigned char * p;



void write_nvram()
{
	p = (unsigned char *)&n;
	*(unsigned char*) 0x210 = 0x76; // select NVRAM

	spi_write(0xA0);

	for(i = 0; i<=sizeof(n); i++)
	{
		spi_write(*p++);
	}

	*(unsigned char*) 0x210 = 0x7e;
}

void read_nvram()
{	
	p = (unsigned char *)&n;
	*(unsigned char*) 0x210 = 0x76; // select NVRAM

	spi_write(0x20);
	

	for(i = 0; i<=sizeof(n); i++)
	{
		*p++ = spi_read();
	}
	
	*(unsigned char*) 0x210 = 0x7e;

}

void usage()
{
	cprintf("USAGE\r\n");
}

int main (int argc, const char* argv[])
{

	unsigned long baudrates[] = {
	-1,
	50,	
	75,
	110,	
	134,
	150,
	300,
	600,
	1200,
	1800,	
	2000,	
	2400,	
	3600,
	4800,
	7200,	
	9600,	
	19200,
	38400,	
	56000,	
	115200
	};

	// unsigned char *x = "115200";
	

	unsigned long l;


	if (argc == 1) 
	{
		usage();
		return 0;
	}


	read_nvram();

	if (n.signature != 0x42)
	{
		cprintf("NVRAM signature invalid.\r\nSetting to default values ... ");
		n.signature 	= 0x42;
		n.version 		= 0;
		strcpy(n.filename, "loader.bin");
	
		n.uart_baudrate = 0x13; // 115200 baud
		n.uart_lsr		= 0x03; // 8N1

		write_nvram();
		cprintf("done.\r\n");
	}



	if (strcmp(argv[1], "get") == 0)
	{
		if (argc < 2) 
		{
			usage();
			return 0;
		}

		if (strcmp(argv[2], "filename") == 0)
		{
			cprintf("%s\r\n", n.filename);
		}
		else if (strcmp(argv[2], "baudrate") == 0)
		{
			cprintf("%lu\r\n", baudrates[n.uart_baudrate % 20]);
		}
		else if (strcmp(argv[2], "all") == 0) 
		{
			cprintf("\r\n");
			cprintf("Signature  : $%02x\r\n", n.signature);
			cprintf("Version    : $%02x\r\n", n.version);
			cprintf("OS filename: %s\r\n", n.filename);
			cprintf("Baud rate  : %lu\r\n", baudrates[n.uart_baudrate % 20]);
			cprintf("UART LSR   : $%02x\r\n", n.uart_lsr);
		}

	}

	if (strcmp(argv[1], "set") == 0)
	{
		if (argc < 3)
		{
			usage();
			return 0;			
		}	

		else if (strcmp(argv[2], "baudrate") == 0)
		{
			l = atol(argv[3]);

			for (i = 1;i<=19;i++)
			{
				if (l == baudrates[i]) break;
			}

			if (i > 19)
			{
				cprintf("\r\nInvalid baudrate\r\n");
				return 1;
			}

			n.uart_baudrate = i;
		}
		else if (strcmp(argv[2], "filename") == 0)
		{
			if (strlen(argv[3]) > 11)
			{
				cprintf("\r\nInvalid filename\r\n");
				return 1;				
			}

			strncpy(n.filename, argv[3], 11);
		}

		write_nvram();
	}




	return 0;
}