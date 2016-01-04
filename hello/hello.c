#include <stdio.h>
#include <stdlib.h>
#include <conio.h> 

#define NEWLINE cprintf("\r\n")
#define PRINTF  cprintf 

typedef unsigned char byte;

void setBgColor(unsigned char color){
    *(byte*) 0x0221 = color;  /* color */
    *(byte*) 0x0221 = 0x87;  /* reg 7 */
}

unsigned int fibonacci(unsigned int fib){
    if(fib == 0)
        return 0;
    if(fib <= 2)
        return 1;
    return fibonacci(fib-2) + fibonacci(fib -1);
}
    

int main (void)
{
    typedef unsigned char byte;
    typedef unsigned word;
    int i;
    unsigned int fib = 0;
    
    const char *text = "Hallo World!";
    for(i=0;i<2048;i++){
        setBgColor(i);
        cprintf("%s %d", text, i);
        gotoxy(0,10);
    }
    
    for(;;){
        NEWLINE;
        cprintf("Fibanncci Folge?");
        i = cgetc();
        fib = (i-'0');
        NEWLINE;
        for(i=0;i<=fib;i++){
            cprintf("%d ", fibonacci(i));
        }
    }
    
    return EXIT_SUCCESS;
}