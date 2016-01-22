#include <stdio.h>
#include <stdlib.h>
#include <conio.h> 

typedef unsigned char byte;

void setBgColor(unsigned char color){
    *(byte*) 0x0221 = color;  /* color */
    *(byte*) 0x0221 = 0x87;  /* reg 7 */
}  

unsigned long fibonacci(unsigned long fib){
    if(fib == 0)
        return 0;
    if(fib <= 2)
        return 1;
    return fibonacci(fib-2) + fibonacci(fib -1);
}

//int main (void)
int main (int argc, const char* argv[])
{
    typedef unsigned char byte;
    typedef unsigned word;
    
    const char *text = "Hallo World!";
    unsigned char buffer[32];
    
    unsigned long i;

    clrscr();
    for(i=0;i<20;i++){
        cprintf("%lu: %lu\n\r", i, fibonacci(i));
    }   
    
    return EXIT_SUCCESS;
}