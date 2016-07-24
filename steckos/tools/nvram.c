#include <conio.h>  
#include <stdlib.h>  
#include <string.h>  
#include <ctype.h>  
#include "../include/spi.h"
#include "../include/rtc.h"

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
	unsigned short uart_baudrate;
	unsigned char uart_lsr;
};

struct baudrate
{
	unsigned short divisor;
	unsigned long int baudrate;
};

const struct baudrate baudrates[] = {
	// {2304,	50},
	// {1536,	75},
	// {1047,	110},
	// {768, 	150},
	{384,	300},
	{192,	600},
	{96,	1200},
	{48,	2400},
	{32,	3600},
	{12,	9600},
	{6,		19200},
	{3,		38400L},
	{2,		56000L},
	{1,		115200}

};

unsigned char i,j,x;
struct nvram n;
unsigned char * p;
unsigned long l;


void write_nvram()
{		
	n.signature = 0x42;
	n.uart_lsr  = 0x03; // 8N1
	p = (unsigned char *)&n;
    
    spi_select_rtc();

	spi_write(0xA0);

	for(i = 0; i<=sizeof(n); i++)
	{
		spi_write(*p++);
	}

    spi_deselect();
}

void read_nvram()
{	
    unsigned char r;
	p = (unsigned char *)&n;
    spi_select_rtc();
    spi_write(0x20);

	for(i = 0; i<=sizeof(n); i++)
	{
        *p++ = spi_read();
	}
    
    spi_deselect();
}

void usage()
{
	cprintf(
		"set/get nvram values\r\nusage:\r\nnvram get filename|baudrate\r\nnvram set filename|baudrate <value>\r\nnvram list\r\n",
	);
}

unsigned long int lookup_divisor(unsigned short div)
{
	static unsigned char i;

	for (i=0; i<14; ++i)
	{
		if (baudrates[i].divisor == div)
		{
			return baudrates[i].baudrate ;	
		}
	}

	return 0;
}

unsigned short lookup_baudrate(unsigned long int baud)
{
	static unsigned char i;

	for (i=0; i<14; ++i)
	{
		if (baudrates[i].baudrate == baud )
		{
			return baudrates[i].divisor;	
		}
	}

	return 0;
}

int main (int argc, const char* argv[])
{
	// unsigned char i;

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
	 	memcpy(n.filename, "LOADER  BIN", 11);
	
	 	n.uart_baudrate = 0x0001; // 115200 baud
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
			cprintf("%.*s\r\n", 11, n.filename);
		}

		else if (strcmp(argv[2], "baudrate") == 0)
		{
			cprintf("%ld\r\n", lookup_divisor(n.uart_baudrate));
		}

	}
	else if (strcmp(argv[1], "set") == 0)
	{
		if (argc < 3)
		{
			usage();
			return 0;			
		}	

		else if (strcmp(argv[2], "baudrate") == 0)
		{

			unsigned short divisor = lookup_baudrate(atol(argv[3]));
			if (divisor == 0)
			{
				cprintf("Invalid baudrate\r\n");
				return 1;
			} 
	
			n.uart_baudrate = divisor;

		}
		else if (strcmp(argv[2], "filename") == 0)
		{
			if (strlen(argv[3]) > 12)
			{
				cprintf("\r\nInvalid filename\r\n");
				return 1;				
			}


			x=0;
			for (i=0;i<10, argv[3][i] != '\0' ;++i)
			{
				if (argv[3][i] == '.') 
				{
					for (j=0;j<8-i;++j)
					{
						n.filename[x] = ' ';
						++x;
					}
					continue;
				}
		
				n.filename[x] = argv[3][i] & ~0x20;
				++x;
			}
		}

		write_nvram();
	}
	else if (strcmp(argv[1], "list") == 0) 
	{
		cprintf("Signature  : $%02x\r\nOS filename: %.11s\r\nBaud rate  : %ld\r\n", 
			n.signature, 
			n.filename,
			lookup_divisor(n.uart_baudrate)
		);
	}

	return EXIT_SUCCESS;
}