/*
  ZAUX -- a program to translate Z-machine auxiliary files.
  Licensed under GNU LGPL v3 or later version.
*/

#include "types.h"

typedef struct {
  int var8[sizeof(U8)==1?1:-9];
  int var16[sizeof(U16)==2?1:-9];
  int var32[sizeof(U32)==4?1:-9];
  int var64[sizeof(U64)==8?1:-9];
} Typechecker;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef U8 byte;

FILE*auxfile;
U8 mem[0x10000];
U16 filesize;
byte auxname[11];

void aux_filename(const char*filename) {
  int len=strlen(filename);
  int i,j,k,d;
  for(i=0;i<11;i++) auxname[i]=32;
  for(i=j=d=0;i<len && j<11;i++) {
    k=filename[i];
    if(k=='.') {
      d=j=8;
    } else {
      if(k>='a' && k<='z') k+='A'-'a';
      auxname[j++]=k;
    }
  }
  if(!d) {
    auxname[8]='A';
    auxname[9]='U';
    auxname[10]='X';
  }
}

U16 aux_free_chunk(const U16*pos,const U16*size,int chunk) {
  int i=0;
  int r=0;
  int x,y;
  while(i<32) {
    x=(y=pos[i])+((size[i]+65)>>6);
    if(!size[i]) {
      i++;
    } else if ((y>=r && y<r+chunk) || (x>r && x<r+chunk)) {
      r=x;
      i=0;
    } else {
      i++;
    }
  }
  return r;
}

U16 aux_save(const char*filename,U16 maxlen) {
  int i,j,p,s;
  byte fn[11];
  static const byte bl[11]={32,32,32,32,32,32,32,32,32,32,32};
  U16 pos[32];
  U16 size[32];
  clearerr(auxfile);
  if(filename) aux_filename(filename);
  // Find the free file number
  for(i=0;i<32;i++) {
    fseek(auxfile,i*13,SEEK_SET);
    fread(fn,1,11,auxfile);
    if(memcmp(fn,bl,11)) {
      pos[i]=fgetc(auxfile)<<8;
      pos[i]|=fgetc(auxfile);
      fseek(auxfile,(p<<6)+416,SEEK_SET);
      size[i]=fgetc(auxfile)<<8;
      size[i]|=fgetc(auxfile);
    } else {
      pos[i]=size[i]=0;
    }
    if(!memcmp(fn,auxname,11)) {
      // Delete it
      fseek(auxfile,i*13,SEEK_SET);
      for(j=0;j<11;j++) fputc(32,auxfile);
    }
  }
  for(i=0;i<32;i++) {
    fseek(auxfile,i*13,SEEK_SET);
    fread(fn,1,11,auxfile);
    if(!memcmp(fn,bl,11)) break;
  }
  fflush(auxfile);
  s=maxlen;
  if(i==32 || !s) return 0;
  // Figure out what position to save
  p=aux_free_chunk(pos,size,(s+65)>>6);
  // Write filename
  fseek(auxfile,i*13,SEEK_SET);
  fwrite(auxname,1,11,auxfile);
  fputc(p>>8,auxfile);
  fputc(p&255,auxfile);
  // Write data
  fseek(auxfile,(p<<6)+416,SEEK_SET);
  fputc(s>>8,auxfile);
  fputc(s&255,auxfile);
  fwrite(mem,1,s,auxfile);
  return 1;
}

U16 aux_restore(const char*filename,U16 maxlen) {
  int i,p,s;
  byte fn[11];
  clearerr(auxfile);
  if(filename) aux_filename(filename);
  for(i=0;i<32;i++) {
    fseek(auxfile,i*13,SEEK_SET);
    fread(fn,1,11,auxfile);
    if(!memcmp(fn,auxname,11)) {
      p=fgetc(auxfile)<<8;
      p|=fgetc(auxfile);
      fseek(auxfile,(p<<6)+416,SEEK_SET);
      s=fgetc(auxfile)<<8;
      s|=fgetc(auxfile);
      if(s>maxlen) s=maxlen;
      fread(mem,1,s,auxfile);
      return s;
    }
  }
  return 0;
}

void extractfile(const char*filename) {
  FILE*fp;
  char fnout[13];
  U16 size=aux_restore(0,65535);
  int i;
  char*p=fnout;
  if(!filename) {
    filename=fnout;
    for(i=0;i<8;i++) if(auxname[i]>32) *p++=auxname[i];
    *p++='.';
    for(i=8;i<11;i++) if(auxname[i]>32) *p++=auxname[i];
  }
  fp=fopen(filename,"wb");
  if(!fp) {
    fprintf(stderr,"Unable to open '%s' for writing.\n",filename);
    exit(1);
  }
  fwrite(mem,1,size,fp);
  fclose(fp);
}

void addfile(const char*filename) {
  FILE*fp=fopen(filename,"rb");
  long size;
  if(!fp) {
    fprintf(stderr,"Unable to open '%s' for reading.\n",filename);
    exit(1);
  }
  fseek(fp,0,SEEK_END);
  size=ftell(fp);
  fseek(fp,0,SEEK_SET);
  if(size&~65535) {
    fprintf(stderr,"File is too large.\n");
    exit(1);
  }
  fread(mem,1,size,fp);
  fclose(fp);
  aux_save(0,size);
}

void copy_archive(const char*filename) {
  FILE*src=auxfile;
  FILE*dest=fopen(filename,"r+b");
  int i;
  U16 size;
  if(!dest) {
    fprintf(stderr,"Destination archive '%s' does not exist.\n",filename);
    exit(1);
  }
  for(i=0;i<32;i++) {
    fseek(src,i*13,SEEK_SET);
    fread(auxname,1,11,src);
    auxfile=src;
    size=aux_restore(0,65535);
    auxfile=dest;
    aux_save(0,size);
  }
  auxfile=src;
  fclose(dest);
}

inline void help(void) {
  fprintf(stderr,
    "usage: zaux <command> <auxfile> <...>\n"
    "  a <files>: Add files to the archive.\n"
    "  c <filename>: Copy the archive to another file.\n"
    "  d <filename>: Delete a file from the archive.\n"
    "  f <filename>: Convert the filename into Z-machine format.\n"
    "  g <files>: Get files from the archive.\n"
    "  l: List the files in the archive.\n"
    "  r <intname> <extname>: Read a file from the archive.\n"
    "  w <intname> <extname>: Write a file into the archive.\n"
    "  x: Extract all files.\n"
  );
}

int main(int argc,char**argv) {
  int i,j;
  if(argc<3) {
    help();
    return 1;
  }
  auxfile=fopen(argv[2],"r+b");
  if(!auxfile) {
    auxfile=fopen(argv[2],"w+b");
    for(i=0;i<416;i++) fputc(32,auxfile);
    fclose(auxfile);
    auxfile=fopen(argv[2],"r+b");
  }
  if(!auxfile) {
    fprintf(stderr,"Unable to create archive.\n");
    return 1;
  }
  switch(argv[1][0]) {
    case 'a':
      for(i=3;i<argc;i++) {
        aux_filename(argv[i]);
        addfile(argv[i]);
      }
      break;
    case 'c':
      if(argc<4) goto improper_command;
      copy_archive(argv[3]);
      break;
    case 'd':
      if(argc<4) goto improper_command;
      aux_save(argv[3],0);
      break;
    case 'f':
      if(argc<4) goto improper_command;
      aux_filename(argv[3]);
      for(j=0;j<11;j++) {
        if(j==8) putchar('.');
        if(auxname[j]>32) putchar(auxname[j]);
      }
      putchar('\n');
      break;
    case 'g':
      for(i=3;i<argc;i++) {
        aux_filename(argv[i]);
        extractfile(argv[i]);
      }
      break;
    case 'l':
      for(i=0;i<32;i++) {
        fseek(auxfile,i*13,SEEK_SET);
        fread(auxname,1,11,auxfile);
        if(*auxname>32) {
          for(j=0;j<11;j++) {
            if(j==8) putchar('.');
            if(auxname[j]>32) putchar(auxname[j]);
          }
          putchar('\n');
        }
      }
      break;
    case 'r':
      if(argc<5) goto improper_command;
      aux_filename(argv[3]);
      extractfile(argv[4]);
      break;
    case 'w':
      if(argc<5) goto improper_command;
      aux_filename(argv[3]);
      addfile(argv[4]);
      break;
    case 'x':
      for(i=0;i<32;i++) {
        fseek(auxfile,i*13,SEEK_SET);
        fread(auxname,1,11,auxfile);
        if(*auxname>32) extractfile(0);
      }
      break;
    default:
    improper_command:
      fprintf(stderr,"The command '%c' is not a proper command.\n",argv[1][0]);
      return 1;
  }
  fclose(auxfile);
  return 0;
}
