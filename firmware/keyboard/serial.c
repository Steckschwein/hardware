#include <avr/pgmspace.h>
#include <avr/interrupt.h>

#include "serial.h"

#define ESC 0x1b
#define BUFF_SIZE 64

#define BAUD 19200UL

#include <util/setbaud.h>

void init_uart(void)
{
    UBRRH = UBRRH_VALUE;
    UBRRL = UBRRL_VALUE;
    UCSRB |= (1<<TXEN);                           // UART TX einschalten
    UCSRC = (1<<URSEL)|(1 << UCSZ1)|(1 << UCSZ0); // Asynchron 8N1
}

int putchar(int c)
{
    /*
    while (!(UCSRA & (1<<UDRE)))
    {
    }

    UDR = c;
    */

    if(UCSRA & (1<<UDRE))         /* Senden, wenn UDR frei ist                    */
    {
        UDR = c;               /* schreibt das Zeichen x auf die Schnittstelle */
    }

    return 0;
}



