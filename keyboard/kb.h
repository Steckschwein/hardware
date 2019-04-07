// Keyboard communication routines

#ifndef __KB_INCLUDED
#define __KB_INCLUDED

// Keyboard konnections
#define PIN_KB  PIND
#define PORT_KB PORTD
#define CLOCK   PD2
#define DATAPIN PD6
#define MOUSE_DATAPIN PD7

#define MODE_RECEIVE 0
#define MODE_SEND    1

volatile uint8_t mode;
volatile uint8_t send_data;
volatile uint8_t send_parity;


void init_kb(void);
void request_to_send();
uint8_t parity(uint8_t);


uint8_t send(uint8_t);

void decode(unsigned char sc);
void put_kbbuff(unsigned char c);
// int  get_kbchar(void);

void put_scanbuff(unsigned char c);
int  get_scanchar(void);

int  get_mousechar(void);

#define SCAN_BUFF_SIZE 12
 uint8_t scan_buffer[SCAN_BUFF_SIZE];
 uint8_t *scan_inptr;
 uint8_t *scan_outptr;
 uint8_t scan_buffcnt;

#ifdef MOUSE
#define MOUSE_BUFF_SIZE 12
 uint8_t mouse_buffer[SCAN_BUFF_SIZE];
 uint8_t *mouse_inptr;
 uint8_t *mouse_outptr;
 uint8_t mouse_buffcnt;
#endif

#define KB_BUFF_SIZE 8
 uint8_t kb_buffer[KB_BUFF_SIZE];
 uint8_t *kb_inptr;
 uint8_t *kb_outptr;
 uint8_t kb_buffcnt;

#endif

#define RESET_TRIG 	PC0
#define NMI			PC1
#define	IRQ			PC2
