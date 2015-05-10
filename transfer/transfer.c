#include <stdio.h>     // Standard input/output definitions
#include <stdlib.h>     
#include <string.h>    // String function definitions
#include <unistd.h>   // UNIX standard function definitions
#include <fcntl.h>      // File control definitions
#include <errno.h>     // Error number definitions
#include <termios.h>  // POSIX terminal control definitions 

char * device = "/dev/cu.usbserial-FTAJMAUJ";
char buffer[65535];
// function to open the port
int open_port(void)
{
          int port;
          //open the port and store the file descriptor in 'port'
          port = open(device, O_RDWR | O_NOCTTY | O_NDELAY);
          if (port == -1)
          {
                 // Could not open the port
                perror("open_port: Unable to open DEVICE - ");
          }
          else
          {
                fcntl(port, F_SETFL, 0); //leave this
          }
          return (port);
}


int main()
{
          int port,n;
          char str[30];
          int length;
          char * p = buffer;

          FILE *fp; // input file
          fp = fopen("hello.bin", "r");
          length = fread(buffer, 1, sizeof(buffer), fp);
          fclose(fp);

          
          //termios - structure contains options for port manipulation
          struct termios specs; // for setting baud rate 

          //setup part
          port = open_port();
          tcgetattr(port, &specs); 

          //now the specs points to the opened port's specifications
          specs.c_cflag = (CLOCAL | CREAD ); //control flags


          //output flags
          //CR3 - delay of 150ms after transmitting every line
          specs.c_oflag = (OPOST | CR3);


         //set Baud Rate to 115200bps
         cfsetospeed(&specs,B115200);
         cfsetispeed(&specs,B115200);


         //our custom specifications set to the port
         //TCSANOW - constant that prompts the system to set
         //specifications immediately.
          tcsetattr(port,TCSANOW,&specs);
         
          //execution part
         // printf("\nEnter the data:\t");
         // scanf("%s",str);
        str[0] = 0x00;
        str[1] = 0x10;
         n = write(port,str,2); // n = no of bytes written
         if (n<0) {
              printf("\nError");
         }

        read(port, str, 2);
        if (strncmp(str, "OK", 2) != 0)
        {
            printf("ERROR1\n");
            exit(1);
        }

        str[0] = length;
        str[1] = 0x00;
        n = write(port,str,2); // n = no of bytes written
        if (n<0) {
            printf("\nError");
        }

        read(port, str, 2);
        if (strncmp(str, "OK", 2) != 0)
        {
            printf("ERROR2\n");
            exit(1);
        }


        n = write(port, buffer, length);
        read(port, str, 2);
        if (strncmp(str, "OK", 2) != 0)
        {
            printf("ERROR2\n");
            exit(1);
        }

        printf("%d bytes written.\n", n);

         //close the port
        close(port);
        return(0);
} 

