/*
 * steckos adaption
 */
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <dirent.h>
#include <string.h>
#include "dir.h"

#include <conio.h>
/*****************************************************************************/
/*                                   Data                                    */
/*****************************************************************************/
extern char _cwd[FILENAME_MAX];

// from global dirent.h
DIR* __fastcall__ opendir (register const char* name)
{
/*	if(length(name)>8+3){
		_directerrno (ENOMEM);
		return NULL;
	}
*/

    register DIR* dir;

    /* Alloc DIR */
    if ((dir = malloc (sizeof (*dir))) == NULL) {

        /* May not have been done by malloc() */
        _directerrno (ENOMEM);

        /* Return failure */
        return NULL;
    }

    /* Interpret dot as current working directory */
    if (*name == '.') {
        //name = _cwd;
    }

    /* Open directory file */
    if ((dir->fd = open (name, O_RDONLY)) != -1) {

        /* Read directory key block */
        if (read (dir->fd,
                  dir->block.bytes,
                  sizeof (dir->block)) == sizeof (dir->block)) {

            // Get directory entry infos from directory header
            //dir->entry_length      = dir->block.bytes[0x23];
            //dir->entries_per_block = dir->block.bytes[0x24];

            // Skip directory header entry
            //dir->current_entry = 1;
			memcpy(&dir->name, name, 8+3+1);

//			cprintf("%s", dir->name);

            // Return success
            return dir;
        }
        // EOF: Most probably no directory file at all
        if (_oserror == 0) {
            _directerrno (EINVAL);
        }
        // Cleanup directory file
        close (dir->fd);
    }

    // Cleanup DIR
    free (dir);

    //Return failure
    return NULL;
}
