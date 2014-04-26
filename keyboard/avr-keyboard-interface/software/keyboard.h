 
#ifndef __KEYBOARD_H__
#define __KEYBOARD_H__

// data = white = PORTD3
// gnd = black
// vcc = red
// clock = brown = INT0 (PORTD2)

extern unsigned char flags;

void keyboardInit( void );
unsigned char getKey( void );

#endif
