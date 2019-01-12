#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>

#define DIR_Entry_Size 32
#define BLOCK_SIZE 512
#define DIR_ENTRIES_PER_BLOCK BLOCK_SIZE / DIR_Entry_Size
#define DIRENTRY_FILENAME 11
#define EOC 0x0fffffff //end of cluster chain is everything greater or equal to 0x0ffffff8 - 24 Bit cluster number on fat32, the highest 4 bits are reserved and will be unmask

//
// od -Ax -t x1 --endian=little /dev/sdb|head -20

#define BS_Partition0	446

#define PE_Bootflag		 0
#define PE_CHSBegin		 1
#define PE_TypeCode		 4
#define PE_CHSEnd		 6
#define PE_LBABegin		 8
#define PE_NumSectors	 12

#define BS_BootSig		 38
#define BS_VolID		 39
#define BS_VolLab		 43
#define BS_FilSysType	 54	; One of the strings �FAT12 �, �FAT16 �, or �FAT �.

unsigned char block_fat[BLOCK_SIZE];
unsigned int boffs_fat;
unsigned char block_data[BLOCK_SIZE];
unsigned int boffs_data;

unsigned long fat_lba_addr=0;
unsigned long fat_lba_addr_n=0;

extern int errno;

struct PartitionEntry{
	unsigned char Bootflag;
	unsigned int TypeCode;
	unsigned long NumSectors;
	unsigned long LBABegin;
};

#define BPB_BytsPerSec 	 0xb
#define BPB_SecPerClus	 0xd
#define BPB_RsvdSecCnt	 0xe	// Number of reserved sectors. Should be 32 for FAT32
#define BPB_NumFATs		 0x10
#define BPB_Media		 21	// For removable media, 0xF0 is frequently used.
						// The legal values for this field are 0xF0, 0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, and 0xFF.
#define BPB_FATSz32		 0x24
#define BPB_RootClus	 0x2c
#define BPB_FSInfo		 0x30

struct F32_Volume{
	unsigned short BytsPerSec;
	unsigned short FSInfoSec;
	unsigned char SecPerClus;
	unsigned short RsvdSecCnt;
	unsigned char NumFATs;
	unsigned long FATSz32;
	unsigned long RootClus;

	unsigned long LbaFat;
	unsigned long LbaFat2;
	unsigned long LbaCluster;
};

struct F32_FSInfo{
	unsigned long FreeClus;
	unsigned long LastClus;
};

typedef struct {
	unsigned char Name[11];
	unsigned char Attr;
	unsigned char Reserved[2];
	unsigned short CrtTime;
	unsigned short CrtDate;
	unsigned short LstModDate;
	unsigned short FstClusHI;
	unsigned short WrtTime;
	unsigned short WrtDate;
	unsigned short FstClusLO;
	unsigned long FileSize;
} F32DirEntry;

struct F32_fd{
	unsigned char filename[12];
	unsigned char attr;
	unsigned long startCluster;
	unsigned long size;

	unsigned long currentCluster;
	unsigned long seekPos;
};

void error(FILE *f1, FILE *f2, int error){
	printf("Error: %d\n",error);
	if(f1 != NULL)
        fclose(f1);
	if(f2 != NULL)
        fclose(f2);
}

int readBlock(unsigned char *msg, unsigned char *buf, FILE *fd, unsigned long lba_addr){
	unsigned long offset = (lba_addr << 9);//  fileOffset => lba_addr * 512

	if(msg != NULL)
		printf("readBlock($%x): %s\n", lba_addr, msg);

//	fpos_t pos;
//	int s = fgetpos (fd, &pos);
//	printf("lba: $%x offset: %d $%x pos: $%x\n", lba_addr, s, offset, pos);
	int s = fseeko(fd, offset, SEEK_SET);
	if(s != 0){
		fprintf(stderr, "readBlock($%x): Error seek file: (%x): %s\n", lba_addr, offset, strerror(errno));
		return s;
	}
	int n = fread(buf, 1, BLOCK_SIZE, fd);
	if(n != BLOCK_SIZE){
		fprintf(stderr, "readBlock($%x): Error reading file : %s\n", lba_addr, strerror(errno));
		return n;
	}
	return n;
}

int writeBlock(unsigned char *msg, unsigned char *buf, FILE *fd, unsigned long lba_addr){
	unsigned long offset = (lba_addr << 9);//  fileOffset => lba_addr * 512
	int s = fseeko(fd, offset, SEEK_SET);
	if(s != 0){
		fprintf(stderr, "writeBlock($%x): Error seek file (%x): %s\n", lba_addr, offset, strerror(errno));
		return s;
	}
	int n;
/*	n = fwrite(buf, 1, BLOCK_SIZE, fd);
	if(n != BLOCK_SIZE){
		fprintf(stderr, "writeBlock($%x): Error writing to file : %s\n", lba_addr, strerror(errno));
		return n;
	}
*/
	printf("writeBlock($%x): %s\n", lba_addr, msg);
	return n;
}

unsigned long long _32(unsigned char *buf, int offset){
	return (buf[offset+3]<<24 | buf[offset+2]<<16 | buf[offset+1]<<8 | buf[offset]);
}

unsigned long _16(unsigned char *buf, int offset){
	return (buf[offset+1]<<8 | buf[offset]);
}

void dumpBuffer(unsigned char *msg, unsigned char *buf){
	printf("%s", msg);
	for(int n=0;n<BLOCK_SIZE;n++){
		if(n % 16 == 0)
			printf("\n%08x: ", n);
		printf("%02x ", buf[n]);
	}
	printf("\n");
}

int match(char *s, char *s2){
	for(int i=0;i<DIRENTRY_FILENAME;i++){
		if(s[i] != s2[i])
			return 0;
	}
	return 1;
}

unsigned int findDirEntry(char *filename, struct F32_fd *fileFound){
	for(int n = 0;n<DIR_ENTRIES_PER_BLOCK;n++){
		boffs_data = n*DIR_Entry_Size;
		if(block_data[boffs_data] == 0)//end of dir
			return 0;
		if(block_data[boffs_data] == 0xe5)//deleted?
			continue;
		if(block_data[boffs_data+11] == 0x0f)//long file name?
			continue;
//		printf("%s <=> %s\n", &block_data[boffs_data], filename);
		if(match(&block_data[boffs_data], filename) == 1){
			printf("matched...\n");
			strncpy(fileFound->filename, filename, DIRENTRY_FILENAME);//filename
			fileFound->filename[11] = '\0';
			fileFound->attr = block_data[boffs_data+11];
			fileFound->startCluster = (_16(block_data, boffs_data+20) << 16) | _16(block_data, boffs_data+26);
			fileFound->size = _32(block_data, boffs_data+28);

			fileFound->currentCluster = fileFound->startCluster;
			fileFound->seekPos = 0;
			return 2;
		}
	}
	//TODO eof block
	return 1;
}

int dumpDirEntry(unsigned char *buf, unsigned int offs){

	F32DirEntry dirEntry;
	memcpy(&dirEntry, &buf[offs], sizeof(F32DirEntry));
	char tmp[12];
	strncpy(tmp, &buf[offs], 11);//filename
	tmp[11] = '\0';
	char fod = ((buf[offs+11] & 0x10) == 0 ? 'F' : 'D');
	char deleted = (buf[offs] == 0xe5 ? '-' : ' ');
	// files with size 0 - cluster number in the directory should be zero.
	// >= 0x0ffffff8- end of cluster chain
	unsigned long cln = (_16(buf, offs+20) << 16) | _16(buf, offs+26);
	unsigned int time = _16(buf, offs+22);
	unsigned int date = _16(buf, offs+24);
	unsigned long size = _32(buf, offs+28);
	//unsigned long size = _32(buf, offs+28);
	printf("%c %c %s $%x size: %ld, cln: $%x ts: $%x $%x\n", deleted, fod, tmp, buf[offs+11], size, cln, date, time);
}

int dumpDirEntries(unsigned char *buf, unsigned int *cnt){
	int i = 0;
	int n = 0;
	for(;n<DIR_ENTRIES_PER_BLOCK;n++){
		int offs = n*DIR_Entry_Size;
		if(buf[offs] == 0)//end of dir
			return 0;
	//	if(buf[offs] == 0xe5)//deleted?
	//		continue;
		if(buf[offs+11] == 0x0f)//long file name?
			continue;
		dumpDirEntry(buf, offs);
		(*cnt)++;
	}
	return 1;
}

struct fat_page{
	unsigned long cluster_nr;
};


void map(unsigned char *buf, struct PartitionEntry *p){
	p->Bootflag = buf[BS_Partition0+PE_Bootflag];
	p->TypeCode = buf[BS_Partition0+PE_TypeCode];
	p->NumSectors = _32(buf, BS_Partition0+PE_NumSectors);
	p->LBABegin = _32(buf, BS_Partition0+PE_LBABegin);
}

void buildVolumeData(unsigned char *buf, unsigned long lba_begin, struct F32_Volume *p){
	p->BytsPerSec 	= _16(buf, BPB_BytsPerSec);
	p->SecPerClus 	= buf[BPB_SecPerClus];
	p->RsvdSecCnt 	= _16(buf, BPB_RsvdSecCnt);
	p->NumFATs 		= buf[BPB_NumFATs];
	p->FATSz32 		= _32(buf, BPB_FATSz32);
	p->RootClus 	= _32(buf,BPB_RootClus);
	p->FSInfoSec	= _16(buf, BPB_FSInfo);

	p->LbaFat = lba_begin + p->RsvdSecCnt;
	p->LbaFat2 = lba_begin + p->RsvdSecCnt + p->FATSz32;
	//align LbaCluster upon root cluster cause
	//lba_addr = cluster_lba + (cluster# - BPB_RootClus) * Sektoren/Cluster and therefore
	//lba_addr = cluster_lba - (BPB_RootClus * Sektoren/Cluster) + (cluster# * Sektoren/Cluster)
	unsigned long align = (p->RootClus * p->SecPerClus);
	p->LbaCluster = p->LbaFat + (p->FATSz32 * p->NumFATs) - align;
}

void buildFSInfo(unsigned char *buf, struct F32_FSInfo *p_fsInfo){
	p_fsInfo->FreeClus = _32(buf,0x1e8);
	p_fsInfo->LastClus = _32(buf,0x1ec);
}

void inc32(unsigned long *lba_addr){
	(*lba_addr)++;
}

unsigned long calcFatLbaAddress(struct F32_Volume *vol, unsigned long cluster_nr){
	return vol->LbaFat + (cluster_nr>>7);// div 128 -> 4 (32bit) * 128 cluster numbers per block (512 bytes)
}
unsigned long calcFat2LbaAddress(struct F32_Volume *vol, unsigned long cluster_nr){
	return vol->LbaFat2 + (cluster_nr>>7);// div 128 -> 4 (32bit) * 128 cluster numbers per block (512 bytes)
}

unsigned long calcDataLbaAddress(struct F32_Volume *vol, unsigned long cluster_nr){
	return vol->LbaCluster + (cluster_nr * vol->SecPerClus);
}

int isEnd(unsigned long cln){
	return ((cln & EOC) == EOC);
}

unsigned long long currentTimeMillis(){
	struct timeval te;
    gettimeofday(&te, NULL); // get current time
    long long milliseconds = te.tv_sec*1000LL + te.tv_usec/1000; // caculate milliseconds
    return milliseconds;
}

unsigned long nextClusterNumber(FILE *fd, struct F32_Volume *vol, unsigned long cln){    
    fat_lba_addr_n = calcFatLbaAddress(vol, cln);//lba address of cluster within fat
    //		if(fat_lba_addr != fat_lba_addr_n){//optimization
        printf("read fat block at fat lba: $%x\n", fat_lba_addr_n);
        int n = readBlock("readFat", block_fat, fd, fat_lba_addr_n);
        if(n != BLOCK_SIZE){
            error(fd, NULL, n);
            return -1;
        }
        fat_lba_addr = fat_lba_addr_n;
        //dumpBuffer(block_fat);
    //		}
    
	unsigned int offs = (cln << 2 & (BLOCK_SIZE-1));//offset within 512 byte block, cluster nr * 4 (32 Bit) and Bit 8-0 gives the offset
	unsigned long nextCluster = _32(block_fat, offs);
//	printf("ncln: $%x\n", nextCluster);
	return nextCluster;
}

unsigned long findFreeCluser(FILE *fd, struct F32_Volume *vol){
	unsigned char found = 0;
	unsigned int fbnr;
	unsigned long cluster = -1;

	for(fbnr = 0;found == 0 && fbnr<vol->FATSz32;fbnr++){//fat size in sectors == amount of blocks
		unsigned int n = readBlock(NULL, block_fat, fd, vol->LbaFat + fbnr);
		//printf("search cluster, block: $%x\r", fbnr);
		for (boffs_fat=0;boffs_fat<BLOCK_SIZE;boffs_fat+=4){//+4 -> 32 bit cluster nr
			if((block_fat[boffs_fat+0]
			|	block_fat[boffs_fat+1]
			|	block_fat[boffs_fat+2]
			|	block_fat[boffs_fat+3]) == 0x0){//free cluster is marked with 0 0 0 0
				cluster = (fbnr << 7) + (boffs_fat >> 2);
				printf("free cluster $%x at block: $%x boffs: $%x\n", cluster, fbnr, boffs_fat);
				//dumpBuffer(block_fat);
				found=1;
				break;
			}
		}
	}
	return cluster;
}

int show_dir(FILE *fd, struct F32_Volume *vol, unsigned long dir_cln){
	unsigned int e=0;
    int r = -1;
    unsigned long cln = dir_cln;
    for(;!isEnd(cln) && r!=0;){
        unsigned long data_lba_addr = calcDataLbaAddress(vol, cln);
        for(int i=0;i<vol->SecPerClus;i++){//
            unsigned int n = readBlock("show_dir", block_data, fd, data_lba_addr);
            if(n != BLOCK_SIZE){
                printf("Error: %d\n",n);return 1;
            }
    //		dumpBuffer(block_data);
            r = dumpDirEntries(block_data, &e);
            if(r == 0)//0 - eod
                break;
            inc32(&data_lba_addr);
        }
        cln = nextClusterNumber(fd, vol, cln);
    }
	printf("dir entries: %d\n", e);
}

int mkdir(FILE *fd, struct F32_Volume *vol, unsigned long cd_clnr, unsigned long cd_data_lba_addr, char* filename){
	printf("mkdir %s\n", filename);

	unsigned long clnr = findFreeCluser(fd, vol);
	if(clnr == -1)
		return 1;

	dumpBuffer("mkdir fat block", block_fat);
	unsigned long eoc = EOC;
	memcpy(&block_fat[boffs_fat], &eoc, 4);
	dumpBuffer("mkdir fat block", block_fat);

	//create dir entry
	F32DirEntry entry;
	time_t now = time(NULL);// get current time
	struct tm *ts = localtime(&now);
	strncpy(entry.Name,filename,11);
	entry.Attr = 1<<4;
	entry.FstClusHI = (clnr >> 16);
	entry.CrtTime = entry.WrtTime = (ts->tm_hour << 11) | (ts->tm_min << 5) | (ts->tm_sec);
	unsigned int date = ((ts->tm_year - 80) << 9) | (ts->tm_mon + 1 << 5) | (ts->tm_mday);
	entry.CrtDate = entry.WrtDate = date;
	entry.LstModDate = date;
	entry.FstClusLO = (clnr & 0xffff);
	entry.FileSize = 0;
	memcpy(&block_data[boffs_data], &entry, sizeof(F32DirEntry));
	dumpBuffer("updated block with dir entry", block_data);

	writeBlock("update dir entry", block_data, fd, cd_data_lba_addr);
	unsigned long fat_lba_addr = calcFatLbaAddress(vol, clnr);//lba address of cluster within fat
	unsigned long fat2_lba_addr = calcFat2LbaAddress(vol, clnr);//lba address of cluster within fat
	writeBlock("update fat block", block_fat, fd, fat_lba_addr);
	writeBlock("update fat block", block_fat, fd, fat2_lba_addr);

	//create dir entries for . and .. in new directory
	strncpy(entry.Name,".          ",11);
	entry.FstClusHI = (clnr >> 16);
	entry.FstClusLO = (clnr & 0xffff);
	memcpy(&block_data[0* sizeof(F32DirEntry)], &entry, sizeof(F32DirEntry));

	strncpy(entry.Name,"..         ",11);
	if(cd_clnr == vol->RootClus){// if root cl nr, set to cl nr 0
		cd_clnr = 0;
		printf("parent dir (..) set to root clnr\n");
	}
	entry.FstClusHI = (cd_clnr >> 16);
	entry.FstClusLO = (cd_clnr & 0xffff);
	memcpy(&block_data[1* sizeof(F32DirEntry)], &entry, sizeof(F32DirEntry));

	dumpBuffer("new dir data", block_data);

	//erase all remaining dir entries within the 1st block
	memset(&block_data[2* sizeof(F32DirEntry)], 0, BLOCK_SIZE - 2*sizeof(F32DirEntry));
	unsigned long newdir_data_lba_addr = calcDataLbaAddress(vol, clnr);
	writeBlock("new dir data", block_data, fd, newdir_data_lba_addr);

	//erase all remaining blocks of this directory
	memset(&block_data, 0, BLOCK_SIZE);
	for(int i=1;i<=vol->SecPerClus;i++){
		inc32(&newdir_data_lba_addr);
		writeBlock("erase dir block", block_data, fd, newdir_data_lba_addr);
	}
}

int main(int argc, char* argv[]){

	FILE *fd,*fd_out;
	struct PartitionEntry pe;
	struct F32_Volume vol;
	struct F32_FSInfo fsInfo;

	unsigned long data_lba_addr;

	// FILE* res = fopen(".", "r+");
	// fprintf(stdout, "fopen(%x): %x %s\n", res, errno, strerror(errno));
	// return 0;

	//dir entry
	//char filename[12] = "TESTDIR    \0";

//	char filename[12] = "32767   DAT\0";
	//char filename[12] = "32K     DAT\0";
	//char filename[12] = "32769   DAT\0";
	//char filename[12] = "511BYTE DAT\0";
//	char filename[12] = "512     DAT\0";
//	char filename[12] = "513BYTE DAT\0";
	//char filename[12] = "2048K   DAT\0";
//	char filename[12] = "1024K   DAT\0";
	//char filename[12] = "96K     DAT\0";
	//char filename[12] = "8192K   DAT\0";
//	char filename[12] = "2048    DAT\0";
	//char filename[12] = "1024    DAT\0";
/*	char filename[12] = "TEST    BIN\0";
	char filename[12] = "PIC1    CFG\0";
*/
//	char filename[12] = "FELIX   PPM\0";
char filename[12] = "FELIZ   PPM\0";

	fd = fopen("/dev/sdb", "rb+");
	if(fd==NULL){
		fprintf(stderr, "cannot open...");
		return 1;
	}
	fd_out = fopen("output.dat", "w");
	if(fd_out==NULL){
		fprintf(stderr, "cannot open...");
		return 1;
	}

	//read partition - block 0
	int n = readBlock("read partition", block_data, fd, 0);
	if(n != BLOCK_SIZE){
		error(fd, fd_out, n);
		return 1;
	}
	map(block_data, &pe);

	printf("Boot-Flag: %x\n", pe.Bootflag);
	printf("Type: $%02x\n", pe.TypeCode);
	printf("Max Sectors: %u (%u MB)\n", pe.NumSectors, (pe.NumSectors*(unsigned long long)512/1024/1024));//FIXME broken by design the sector size is not known at this time
	printf("LBA-Begin: $%x\n", pe.LBABegin);

	n = readBlock("read volume block", block_data, fd, pe.LBABegin);//volume id
	if(n != BLOCK_SIZE){
		printf("%d\n",n);
		return 1;
	}
	buildVolumeData(block_data, pe.LBABegin, &vol);

	printf("Volume-ID:\n");
	printf("Bytes/Sektor: %d\n", vol.BytsPerSec);
	printf("Sektors/Cluster: $%x (%d)\n", vol.SecPerClus, vol.SecPerClus);
	printf("Res. Sectors: $%x (%d)\n", vol.RsvdSecCnt, vol.RsvdSecCnt);
	printf("FATs: %d\n", vol.NumFATs);
	printf("Sectors per FAT: $%x (%ld)\n", vol.FATSz32, vol.FATSz32);
	printf("Root-Dir Cluster: %ld\n", vol.RootClus);
	printf("lba_fat : $%x ($%x + $%x)\n", vol.LbaFat, pe.LBABegin, vol.RsvdSecCnt);
	printf("lba_fat2: $%x ($%x + $%x)\n", vol.LbaFat2, vol.LbaFat, vol.FATSz32);
	printf("lba_cluster: $%x ($%x + ($%x * $%x))\n", vol.LbaCluster, vol.LbaFat, vol.FATSz32, vol.NumFATs);
	printf("FSInfoSec: %x\n", vol.FSInfoSec);

	//FIXME works easily, cause we have 512 Bytes/Sektor and 512 byte per sd-card block otherwise we have to do more calculation
	if(vol.BytsPerSec != BLOCK_SIZE){
		fprintf(stderr, "%d != %d is not supported!\n", vol.BytsPerSec, BLOCK_SIZE);
		return 1;
	}

	// ###################### test and dump FSInfo
	if(vol.FSInfoSec != 0 && vol.FSInfoSec != 0xffff){
		n = readBlock("read fsinfo block", block_data, fd, pe.LBABegin + vol.FSInfoSec);
		if(n != BLOCK_SIZE){
			printf("%d\n",n);
			return 1;
		}
		dumpBuffer("fs info", block_data);
		buildFSInfo(block_data, &fsInfo);
		printf("LastClus: $%x (%ld)\n", fsInfo.LastClus, fsInfo.LastClus);
		printf("FreeClus: $%x (%ld)\n", fsInfo.FreeClus, fsInfo.FreeClus);
	}


	// ###################### poc dump list directory
	unsigned long dirCln = vol.RootClus;
	//unsigned long dirCln = 0x3940;//0xb1e9;//vol.RootClus;//0x7005; //
	printf("Reading Dir (cln: $%x)...\n", dirCln);
	show_dir(fd, &vol, dirCln);

	// ###################### find_first/find_next

	//for mkdir
	unsigned int r;
	struct F32_fd fileFound;
	data_lba_addr = calcDataLbaAddress(&vol, dirCln);
	for(int i=0;i<vol.SecPerClus;i++){//
		n = readBlock("find dir entry", block_data, fd, data_lba_addr);
		if(n != BLOCK_SIZE){
			printf("Error: %d\n",n); return 1;
		}
		r = findDirEntry(filename, &fileFound);
		if(r == 0 || r== 2)//0 - eod or 2 - found
			break;
		inc32(&data_lba_addr);
	}
	printf("r: %d\n", r);
	if(r == 2){
		printf("file found '%s' found\n", fileFound.filename);
		data_lba_addr = calcDataLbaAddress(&vol, fileFound.startCluster);
		unsigned long blocks = fileFound.size >> 9; //(div BLOCK_SIZE);
		if((fileFound.size & 0x1ff) != 0) blocks++;
		printf("data cluster nr $%x, $%x blocks to read, lba $%x\n", fileFound.startCluster, blocks, data_lba_addr);
	}
	//############### poc mkdir
	else if(r == 0){//end of dir above
		dumpDirEntry(block_data, boffs_data);
		printf("eod reached, boffs $%x\n", boffs_data);
		dumpBuffer("block with dir entry", block_data);
		r = mkdir(fd, &vol, dirCln, data_lba_addr, filename);
		if(r == 1)
			error(fd, fd_out, r);
	}


	// ###################### buffered read poc - fat_read for files with unlimited size (at least fat32 file size). uses only two 512 byte buffers (block_data/block_fat)

	unsigned long ts = currentTimeMillis();
	unsigned long cln = fileFound.startCluster;
	printf("fat cln: $%x boffs: $%x bnr: $%x\n", cln, (cln << 2 & (BLOCK_SIZE-1)), (cln >> 7));
	unsigned long blocks = fileFound.size >> 9; //(div BLOCK_SIZE);
	if((fileFound.size & 0x1ff) != 0){
		blocks++;
	}

	l1: for(;!isEnd(cln) && blocks>0;){
		data_lba_addr = calcDataLbaAddress(&vol, cln);
		printf("data cluster nr $%x, $%x blocks to read, lba $%x\n", cln, blocks, data_lba_addr);
		//vol.SecPerClus <=> BLOCK_SIZE :) FTW!
		for(unsigned int i=0;i<vol.SecPerClus;i++){
			n = readBlock("readData", block_data, fd, data_lba_addr);
			if(n != BLOCK_SIZE){
				error(fd, fd_out, n);
				return 1;
			}
			//dumpBuffer(block_data);
			n = fwrite(block_data, sizeof(char), BLOCK_SIZE, fd_out);
			if(n != BLOCK_SIZE){
				error(fd, fd_out, n);
				return 1;
			}
			if(--blocks == 0)
				goto l1;

			inc32(&data_lba_addr);
		}
		//
		cln = nextClusterNumber(fd, &vol, cln);
	}

	ts = currentTimeMillis() - ts;
	printf("read %ld bytes took %ldms\n", fileFound.size, ts);

	fclose(fd);
	fclose(fd_out);
}
