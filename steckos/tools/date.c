#include <stdlib.h>
#include <conio.h>
#include <time.h>

int main (void)
{
    time_t t = _systime();
    cprintf ("%s\n", asctime(localtime(&t)));
   
    return EXIT_SUCCESS;
}