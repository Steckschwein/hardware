// Keyboard communication routines

#ifndef __KB_INCLUDED
#define __KB_INCLUDED

// Keyboard konnections
#define PIN_KB  PIND
#define PORT_KB PORTD
#define CLOCK   2
#define DATAPIN 0

volatile uint8_t last_scancode;
volatile uint8_t decoding ;

void init_kb(void);
void decode(unsigned char sc);
void put_kbbuff(unsigned char c);
int  get_kbchar(void);
void put_scanbuff(unsigned char c);
int  get_scanchar(void);

int  get_scbyte(void);

#endif

