#include <stdio.h>     // Standard input/output definitions
#include <stdlib.h>     
#include <string.h>    // String function definitions
#include <unistd.h>   // UNIX standard function definitions
#include <fcntl.h>      // File control definitions
#include <errno.h>     // Error number definitions
#include <termios.h>  // POSIX terminal control definitions 

#define BUFSIZE 65535
#define BAUDRATE	B115200
char * device = "/dev/cu.usbserial-FTAJMAUJ";
char buffer[BUFSIZE];

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

int main(int argc, char *argv[])
{
		int port,n;
		
		uint16_t length;
		char buf[2];

		FILE *fp; // input file
		fp = fopen(argv[1], "r");
		if (!fp )
		{
		printf("Open error %d: %s\n", errno, argv[1]);
		return 1;
		}

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
		cfsetospeed(&specs,BAUDRATE);
		cfsetispeed(&specs,BAUDRATE);


		//our custom specifications set to the port
		//TCSANOW - constant that prompts the system to set
		//specifications immediately.
		tcsetattr(port,TCSANOW,&specs);

	
		// Send start address 0x1000
		uint16_t startaddr = 0x1000;
		
		buf[0] = (uint8_t)startaddr;
		buf[1] = (uint8_t)(startaddr >> 8);
		n = write(port,buf,2); // n = no of bytes written
		if (n<0) 
		{
		 	printf("\nError");
		}


		read(port, buf, 2);
		if (strncmp(buf, "OK", 2) != 0)
		{
			printf("Error sending startaddr\n");
			exit(1);
		}


		buf[0] = (uint8_t)length;
		buf[1] = (uint8_t)(length >> 8);

		n = write(port,buf,2); // n = no of bytes written
		if (n<0) {
			printf("\nError");
		}

		read(port, buf, 2);
		if (strncmp(buf, "OK", 2) != 0)
		{
			printf("Error sending length\n");
			exit(1);
		}


		n = write(port, buffer, length);
		read(port, buf, 2);
		if (strncmp(buf, "OK", 2) != 0)
		{
			printf("Error sending data at byte %d\n", n);
			exit(1);
		}

		printf("%d bytes written.\n", n);

		//close the port
		close(port);
		return(0);
} 

