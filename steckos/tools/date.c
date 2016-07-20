#include <stdlib.h>
#include <conio.h>
#include <time.h>
#include "../../cc65/steckos/spi.h"
#include "../../cc65/steckos/rtc.h"

int main (void)
{
    time_t t = _systime();
    cprintf ("%s\n\r", asctime(localtime(&t)));
   
    return EXIT_SUCCESS;
}