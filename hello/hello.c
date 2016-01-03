#include <stdio.h>
#include <stdlib.h>
#include <conio.h> 

typedef unsigned char byte;

void setBgColor(unsigned char color){
    *(byte*) 0x0221 = color;  /* color */
    *(byte*) 0x0221 = 0x87;  /* reg 7 */
}    
int main (void)
{
    typedef unsigned char byte;
    typedef unsigned word;
    
    const char *text = "Hallo World!";
    
    unsigned int i;
    
    
    for(i=0;i<32768;i++){
        setBgColor(i);
        cprintf("%s %d\n\r", text, i);
    }
        
    return EXIT_SUCCESS;
}