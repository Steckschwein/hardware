#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>  /* File Control Definitions          */
#include <termios.h>/* POSIX Terminal Control Definitions*/
#include <unistd.h> /* UNIX Standard Definitions         */
#include <errno.h>  /* ERROR Number Definitions          */
#include <sys/stat.h>
int main()
{
	struct termios SerialPortSettings;
	char filename[] = "bios/loader.bin";
	FILE * fp;
	struct stat st;
	unsigned short address = 0x1000;
	unsigned short size;
	unsigned char * buffer;
	int fd;
	char read_buffer[32];                
	int  bytes_read = 0;                 
	int  bytes_written  =  0 ;   

	stat(filename, &st);
	size = st.st_size;
	printf("size: %d\n", (int)size);

	buffer = malloc(size);

	fp = fopen(filename, "r");
        if (!fread(buffer, size, 1, fp))
	{
		fprintf(stderr, "Error opening file.");
		return 1;
	}
	fclose(fp);


	fd = open("/dev/ttyUSB0",O_RDWR | O_NOCTTY);
	if (!fd)
	{
		fprintf(stderr, "Error opening serial device.");
		return 1;
	}

  	tcgetattr(fd, &SerialPortSettings);
	cfsetispeed(&SerialPortSettings,B115200);
	cfsetospeed(&SerialPortSettings,B115200);

	SerialPortSettings.c_cflag &= ~PARENB;   // No Parity
	SerialPortSettings.c_cflag &= ~CSTOPB; //Stop bits = 1 

	SerialPortSettings.c_cflag &= ~CSIZE; /* Clears the Mask       */
	SerialPortSettings.c_cflag |=  CS8;   /* Set the data bits = 8 */

	SerialPortSettings.c_cflag &= ~CRTSCTS;

	SerialPortSettings.c_cflag |= CREAD | CLOCAL;

	SerialPortSettings.c_iflag &= ~(IXON | IXOFF | IXANY);
	SerialPortSettings.c_iflag &= ~(ICANON | ECHO | ECHOE | ISIG);

	/* Setting Time outs */                                       
	SerialPortSettings.c_cc[VMIN]  = 2; /* Read 10 characters */  
	SerialPortSettings.c_cc[VTIME] = 0;  /* Wait indefinitely   */

	tcsetattr(fd,TCSANOW,&SerialPortSettings);

                                                          
	bytes_written = write(fd,&address,sizeof(address));
//	printf("written: %d\n", bytes_written);

                             
	bytes_read = read(fd,&read_buffer,2);
//	printf("read: %d, [%s]\n", bytes_read, read_buffer);


	bytes_written = write(fd,&size,sizeof(size));
	printf("written: %d\n", bytes_written);

	bytes_read = read(fd,&read_buffer,2);
//	printf("read: %d, [%s]\n", bytes_read, read_buffer);

	bytes_written = 0;
	for(unsigned char * p = buffer; p <= buffer+size; p++)
	{
		bytes_written += write(fd, p, 1);
	}
	
	printf("bytes written: %d\n", bytes_written);

	bytes_read = read(fd,&read_buffer,2);
	//printf("read: %d, [%s]\n", bytes_read, read_buffer);


  	close(fd);
	free(buffer);
}
