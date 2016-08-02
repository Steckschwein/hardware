#include <stdio.h>
#include <stdlib.h>
#include <conio.h> 

unsigned long fibonacci(unsigned long fib){
    if(fib == 0)
        return 0;
    if(fib <= 2)
        return 1;
    return fibonacci(fib-2) + fibonacci(fib -1);
}

int main (int argc, const char* argv[])
{
    unsigned long i;
    unsigned long n;

    cprintf("\n\r");
    
    if(argc < 2){
        cprintf("\n%s <Zahl>\n\r", argv[0]);
        return EXIT_FAILURE;
    }
    
    //clrscr();
    n = atol(argv[1]);
    for(i=0;i<n;i++){
        cprintf("%lu: %lu\n\r", i, fibonacci(i));
    }   
    
    return EXIT_SUCCESS;
}