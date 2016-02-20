#include <stdio.h>
#include <stdlib.h>
#include <sys/utsname.h>
#include <conio.h>

int main (void)
{                  
    /* Get the uname data */
    struct utsname buf;
    if (uname (&buf) != 0) {
        //perror ("uname");
        return EXIT_FAILURE;
    }

    cprintf ("\n\r%s %s %s %s %s", 
            buf.sysname, 
            buf.nodename, 
            buf.release,
            buf.version, 
            buf.machine);

    return EXIT_SUCCESS;
}

 