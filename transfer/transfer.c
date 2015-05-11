/*
	Steckschwein serial transfer program
	usage:
		transfer -d /dev/cu.usbserial-FTAJMAUJ -a 0x1000 ../hello/hello.bin
*/

#include <stdio.h>     // Standard input/output definitions
#include <stdlib.h>     
#include <ctype.h>     
#include <string.h>    // String function definitions
#include <unistd.h>   // UNIX standard function definitions
#include <fcntl.h>      // File control definitions
#include <errno.h>     // Error number definitions
#include <termios.h>  // POSIX terminal control definitions 
#include <inttypes.h>

#define BUFSIZE 	65535
#define BAUDRATE	B115200

struct address
{
	uint8_t h;
	uint8_t l;
};

// function to open the port
int open_port(char * device)
{
          int port;
          //open the port and store the file descriptor in 'port'
          port = open(device, O_RDWR | O_NOCTTY | O_NDELAY);
          if (port == -1)
          {
                 // Could not open the port
                fprintf(stderr, "Error opening serial device %s: %s\n", device, strerror(errno));

          }
          else
          {
                fcntl(port, F_SETFL, 0); //leave this
          }
          return (port);
}

int main(int argc, char *argv[])
{
		char * device 		= NULL;
		char * filename 	= NULL;
		uint16_t startaddr 	= 0x1000;

		int port,n,c;
		
		uint16_t length;
		char buf[2];
		char buffer[BUFSIZE];

		struct address addr;


		char *end;

		device = getenv("SERIAL_DEVICE");

		opterr = 0;
		while ((c = getopt (argc, argv, "d:a:")) != -1)
		{
			switch (c)
			{
				case 'd':
					device = optarg;
					break;
				case 'a':
					startaddr = strtol(optarg, &end, 0);
					break;

			}
		}

		
		if (argc == optind)
		{
			fprintf(stderr, "No filename provided\n");
			return 1;	
		}

		filename = argv[argc - 1];

		if (! device)
		{
			fprintf(stderr, "No serial device provided\n");
			return 1;			
		}


		FILE *fp; // input file
		fp = fopen(filename, "r");
		if (!fp )
		{
			fprintf(stderr, "Error opening %s: %s\n", filename, strerror(errno));
			return 1;
		}

		length = fread(buffer, 1, sizeof(buffer), fp);
		fclose(fp);


		//termios - structure contains options for port manipulation
		struct termios specs; // for setting baud rate 

		//setup part
		port = open_port(device);

		if (port < 0)
		{
			return 1;
		}
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
		
		
		addr.h = (uint8_t)startaddr;
		addr.l = (uint8_t)(startaddr >> 8);
		// buf[0] = (uint8_t)startaddr;
		// buf[1] = (uint8_t)(startaddr >> 8);
		n = write(port,&addr,2); // n = no of bytes written
		if (n<0) 
		{
		 	printf("\nError");
		}


		read(port, buf, 2);
		if (strncmp(buf, "OK", 2) != 0)
		{
			fprintf(stderr, "Error sending startaddr\n");
			exit(1);
		}


		addr.h = (uint8_t)length;
		addr.l = (uint8_t)(length >> 8);

		n = write(port, &addr,2); // n = no of bytes written
		if (n<0) {
			printf("\nError");
		}

		read(port, buf, 2);
		if (strncmp(buf, "OK", 2) != 0)
		{
			fprintf(stderr, "Error sending length\n");
			exit(1);
		}

		printf("Sending $%04X bytes of data to $%04X\n", length, startaddr);

		n = write(port, buffer, length);
		read(port, buf, 2);
		if (strncmp(buf, "OK", 2) != 0)
		{
			fprintf(stderr, "Error sending data at byte %d\n", n);
			exit(1);
		}

		printf("$%04X (%d) bytes written.\n", n, n);

		//close the port
		close(port);
		return(0);
} 

