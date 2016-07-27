// Keyboard communication routines

#ifndef __KB_INCLUDED
#define __KB_INCLUDED

// Keyboard konnections
#define PIN_KB  PIND
#define PORT_KB PORTD
#define CLOCK   2
#define DATAPIN 0

void init_kb(void);
void decode(unsigned char sc);
void put_kbbuff(unsigned char c);
// int  get_kbchar(void);

void put_scanbuff(unsigned char c);
int  get_scanchar(void);

#define SCAN_BUFF_SIZE 12
 uint8_t scan_buffer[SCAN_BUFF_SIZE];
 uint8_t *scan_inptr;
 uint8_t *scan_outptr;
 uint8_t scan_buffcnt;

#define KB_BUFF_SIZE 8
 uint8_t kb_buffer[KB_BUFF_SIZE];
 uint8_t *kb_inptr;
 uint8_t *kb_outptr;
 uint8_t kb_buffcnt;

#endif