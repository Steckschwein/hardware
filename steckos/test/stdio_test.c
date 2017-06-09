#include <stdlib.h>
#include <stdio.h>
#include <dirent.h>
#include <string.h>
#include <unistd.h> 
#include <conio.h>
#include <errno.h> 

int test(int r);
int test_file_io(void);
int test_dir_io(void);

unsigned char *fileName = "1.txt";

int main(int argc, char *argv[])
{
//	cprintf("argc %d\n", argc);
/*	if (argc < 2) {
        return EXIT_FAILURE;
    }
*/
//	test(test_file_io());
	test(test_dir_io());
	return EXIT_SUCCESS;
}


int test(int r){
	if(r != EXIT_SUCCESS)
		cprintf("FAILED!\n");
	else
		cprintf("PASS!\n");
	return r;
}

int test_file_io(){

    FILE *f1;
    unsigned int i;
    unsigned int n;
    unsigned char buf[128];

	f1 = fopen(fileName, "r");
	if (!f1) {
		cprintf("could not open '%s': %s\n", fileName, strerror(errno)); 
		return EXIT_FAILURE;
	}
	cprintf("file '%s' opened fd='%d'\n", fileName, f1);
	
    i = fread(buf, sizeof(char), sizeof(buf), f1);
    if (i == -1) {
        cprintf("read error '%s': %s\n", fileName, strerror(errno)); 
        return EXIT_FAILURE;
    }
    cprintf("fread %d\n", i);
    for(n=0;n<i && n<i;n++){
        cprintf("%x ", buf[n]);
    }
/*    if (feof(f1)) {
        cprintf("end of file reached..., read %d bytes\n", i);
        return EXIT_SUCCESS;
    }
*/	
    i = fclose(f1);
    if (i == -1) {
        cprintf("close error '%s': %s\n", fileName, strerror(errno)); 
        return EXIT_FAILURE;
    }    
    return EXIT_SUCCESS;	
}

int test_dir_getcwd(){
	char buf[64];
	getcwd(buf, sizeof(buf));
	cprintf("cwd: %s}\n", buf);
}

int test_dir_io(){
	char* name = "1";
    unsigned char go = 0;
    DIR *D;
    register struct dirent* E;

    // Explain usage and wait for a key 
/*    cprintf ("Use the following keys:\n"
            "  g -> go ahead without stop\n"
            "  q -> quit directory listing\n"
            "  r -> return to last entry\n"
            "  s -> seek back to start\n"
            "Press any key to start ...\n");
    cgetc ();
*/
    // Open the directory 
    D = opendir (name);
    if (D == 0) {
        cprintf("error opening %s: %s\n", name, strerror (errno));
        return 1;
    }
    // Output the directory 
    errno = 0;
    cprintf("contents of \"%s\":\n", name);
    while ((E = readdir (D)) != 0) {
		cprintf ("dirent.d_name[] : \"%s\"\n", E->d_name);
//        cprintf ("dirent.d_blocks : %10u\n",   E->d_blocks);
//        cprintf ("dirent.d_type   : %10d\n",   E->d_type);
        cprintf ("telldir()       : %10lu\n",  telldir (D));
        cprintf ("---\n");
        if (!go) {
            switch (cgetc ()) {
                case 'g':
                    go = 1;
                    break;

                case 'q':
                    goto done;

                case 'r':
 //                   seekdir (D, E->d_off);
                    break;

                case 's':
                    rewinddir (D);
                    break;

            }
        }
    }
done:
    if (errno == 0) {
        cprintf ("Done\n");
    } else {
        cprintf("Done: %d (%s)\n", errno, strerror (errno));
    }

    // Close the directory
    closedir (D);

    return EXIT_SUCCESS;	
}