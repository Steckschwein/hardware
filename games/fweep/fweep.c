/*
  Fweep -- a Z-machine interpreter for versions 1 to 10 except 6.
  This program is license under GNU GPL v3 or later version.
*/

#define VERSION "0.8.4"

#include "types.h"

typedef struct {
	/*
  int var8[sizeof(U8)==1?1:-9];
  int var16[sizeof(U16)==2?1:-9];
  int var32[sizeof(U32)==4?1:-9];
  int var64[sizeof(U64)==8?1:-9];
  */
  int var8[1];
  int var16[2];
  int var32[4];
  int var64[8];
} Typechecker;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

typedef char boolean;
typedef U8 byte;

typedef struct {
  U32 pc;
  U16 start;
  U8 argc;
  boolean stored;
} StackFrame;

const char zscii_conv_1[128]={//TODO FIXME offsets
  //[155-128]=
  'a','o','u','A','O','U','s','>','<','e','i','y','E','I','a','e','i','o','u','y','A','E','I','O','U','Y',
  'a','e','i','o','u','A','E','I','O','U','a','e','i','o','u','A','E','I','O','U','a','A','o','O','a','n',
  'o','A','N','O','a','A','c','C','t','t','T','T','L','o','O','!','?'
};

const char zscii_conv_2[128]={//TODO FIXME offsets
  //[155-128]=
  'e','e','e', 
  //[161-128]=
  's','>','<', 
  //[211-128]=
  'e','E', 
  //[215-128]=
  'h','h','h','h', 
  //[220-128]=
  'e','E'
};

const char v1alpha[78]="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789.,!?_#'\"/\\<-:()";
const char v2alpha[78]="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ^0123456789.,!?_#'\"/\\-:()";

//const boolean optarg[128]={['a']=1,['e']=1,['g']=1,['i']=1,['o']=1,['r']=1,['s']=1};
char*opts[128];

char*story_name;
FILE*story;
FILE*transcript;
FILE*inlog;
FILE*outlog;
FILE*auxfile;
byte auxname[11];
boolean original=1;
boolean verified=0;
boolean allow_undo=1;
char escape_code=0;
int sc_rows=25;
int sc_columns=80;

U32 routine_start;
U32 text_start;
int packed_shift;
int address_shift;

U32 object_table;
U32 dictionary_table;
U32 restart_address;
U32 synonym_table;
U32 alphabet_table;
U32 static_start;
U32 global_table;

//TODO FIXME U8 memory[0x200000];
U8 memory[0x2000];
#define version (*memory)
//TODO FIXME U8 undomem[0x40000];
U8 undomem[0x4000];
U32 program_counter;
StackFrame frames[256];
U16 stack[1024];
int frameptr;
int stackptr;
StackFrame u_frames[256];
U16 u_stack[1024];
int u_frameptr;
int u_stackptr;
U32 u_program_counter;
#define copy_array(d,s) memcpy(d,s,sizeof(s))

U16 stream3addr[16];
int stream3ptr=-1;
boolean texting=1;
boolean window=0;
boolean buffering=1;
boolean logging=0;
boolean from_log=0;
int cur_row=2;
int cur_column;
int lmargin=0;
int rmargin=0;

U8 arcfour_i;
U8 arcfour_j;
U8 arcfour_s[256];
U16 predictable_max;
U16 predictable_value;
boolean unpredictable;

U16 inst_args[8];
#define inst_sargs ((S16*)inst_args)
char text_buffer[1024];
int textptr;
U8 cur_prop_size;

int zch_shift;
int zch_shiftlock;
int zch_code;

U8 instruction_use[256];
boolean break_on;
boolean instruction_bkpt[256];
U32 address_bkpt[16];
U32 continuing;
boolean lastdebug;
U16 oldscore=0;

void debugger(void);

S16 get_random(S16 max) {
  int k,v,m;
  if(predictable_max) {
    predictable_value=(predictable_value+1)%predictable_max;
    return (predictable_value%max)+1;
  } else {
    m=max-1;
    m|=m>>1;
    m|=m>>2;
    m|=m>>4;
    m|=m>>8;
    if(unpredictable) arcfour_i^=time(0);
    for(;;) {
      arcfour_i++;
      arcfour_j+=(k=arcfour_s[arcfour_i]);
      arcfour_s[arcfour_i]=arcfour_s[arcfour_j]; arcfour_s[arcfour_j]=k;
      arcfour_i++;
      arcfour_j+=(k=arcfour_s[arcfour_i]);
      arcfour_s[arcfour_i]=arcfour_s[arcfour_j]; arcfour_s[arcfour_j]=k;
      v=arcfour_s[(arcfour_s[arcfour_i]+arcfour_s[arcfour_j])&255]<<8;
      arcfour_i++;
      arcfour_j+=(k=arcfour_s[arcfour_i]);
      arcfour_s[arcfour_i]=arcfour_s[arcfour_j]; arcfour_s[arcfour_j]=k;
      v|=arcfour_s[(arcfour_s[arcfour_i]+arcfour_s[arcfour_j])&255];
      v&=m;
      if(v<max) return v+1;
    }
  }
}

void randomize(U16 seed) {
  int i,j,k;
  unpredictable=!seed;
  predictable_value=0;
  if(seed<1000 && seed) {
    predictable_max=seed;
    return;
  }
  predictable_max=0;
  if(!seed) seed=(U16)time(0);
  for(i=0;i<256;i++) arcfour_s[i]=i;
  arcfour_i=0;
  arcfour_j=seed&255;
  for(i=0,j=0;i<256;i++) {
    j=(j+arcfour_s[i]+(seed>>(i&7)))&255;
    k=arcfour_s[i]; arcfour_s[i]=arcfour_s[j]; arcfour_s[j]=k;
  }
  get_random(4);
  get_random(4);
  get_random(4);
}

//TODO FIXME inline
U16 read16(U32 address) {
  return (memory[address]<<8)|memory[address+1];
}

//TODO FIXME inline
void write16(U32 address,U16 value) {
  memory[address]=value>>8;
  memory[address+1]=value&255;
}

void text_flush(void) {
  static char junk[256];
  text_buffer[textptr]=0;
  if(textptr+cur_column>=sc_columns-rmargin) {
    putchar('\n');
    cur_row++;
    cur_column=0;
    while(cur_column<lmargin) {
      putchar(32);
      cur_column++;
    }
  }
  if(cur_row>=sc_rows && sc_rows!=255 && !from_log) {
    printf("[MORE]");
    fflush(stdout);
    fgets(junk,256,stdin);
    cur_row=2;
  }
  fputs(text_buffer,stdout);
  cur_column+=textptr;
  fflush(stdout);
  textptr=0;
}

//TODO FIXME inline
void char_print(U8 zscii) {
  if(!zscii) return;
  if(stream3ptr!=-1) {
    U16 w=read16(stream3addr[stream3ptr]);
    memory[stream3addr[stream3ptr]+2+w]=zscii;
    write16(stream3addr[stream3ptr],w+1);
    return;
  }
  if((memory[0x11]&1) && !window) {
    if(transcript) fputc(zscii,transcript);
    else memory[0x10]|=4;
  }
  if(texting && !window) {
    if(zscii&0x80) {
      text_buffer[textptr++]=zscii_conv_1[zscii&0x7F];
      if(zscii_conv_2[zscii&0x7F]) text_buffer[textptr++]=zscii_conv_2[zscii&0x7F];
    } else if(zscii&0x6F) {
      text_buffer[textptr++]=zscii;
    }
    if(zscii<=32 || textptr>1000 || !buffering) text_flush();
    if(zscii==13) {
      putchar('\n');
      cur_row++;
      cur_column=0;
      while(cur_column<lmargin) {
        putchar(32);
        cur_column++;
      }
    }
  }
}

boolean verify_checksum(void) {
  U32 size=read16(0x1A);
  U16 sum=0;
  if(verified) return 1;
  if(version<4) size<<=1;
  else if(version<6) size<<=2;
  else if(version<10) size<<=3;
  else size<<=4;
  clearerr(story);
  if(size) size-=0x40;
  fseek(story,0x40,SEEK_SET);
  while(size--) sum+=fgetc(story);
  return verified=(sum==read16(0x1C));
}

U32 text_print(U32 address);

//TODO FIXME inline
void zch_print(int z) {
  int zsl;
  if(zch_shift==3) {
    zch_code=z<<5;
    zch_shift=4;
  } else if(zch_shift==4) {
    zch_code|=z;
    char_print(zch_code);
    zch_shift=zch_shiftlock;
  } else if(zch_shift>=5) {
    zsl=zch_shiftlock;
    text_print(read16(synonym_table+(z<<1)+((zch_shift-5)<<6))<<1);
    zch_shift=zch_shiftlock=zsl;
  } else if(z==0) {
    char_print(32);
    zch_shift=zch_shiftlock;
  } else if(z==1 && version==1) {
    char_print(13);
    zch_shift=zch_shiftlock;
  } else if(z==1) {
    zch_shift=5;
  } else if((z==4 || z==5) && (version>2 && version<9) && (zch_shift==1 || zch_shift==2)) {
    zch_shift=zch_shiftlock=zch_shift&(z-3);
  } else if(z==4 && (version<3 || version>8)) {
    zch_shift=zch_shiftlock=(zch_shift+1)%3;
  } else if(z==5 && (version<3 || version>8)) {
    zch_shift=zch_shiftlock=(zch_shift+2)%3;
  } else if((z==2 && (version<3 || version>8)) || z==4) {
    zch_shift=(zch_shift+1)%3;
  } else if((z==3 && (version<3 || version>8)) || z==5) {
    zch_shift=(zch_shift+2)%3;
  } else if(z==2) {
    zch_shift=6;
  } else if(z==3) {
    zch_shift=7;
  } else if(z==6 && zch_shift==2) {
    zch_shift=3;
  } else if(z==7 && zch_shift==2 && version!=1) {
    char_print(13);
    zch_shift=zch_shiftlock;
  } else {
    if(alphabet_table) char_print(memory[alphabet_table+z+(zch_shift*26)-6]);
    else if(version==1) char_print(v1alpha[z+(zch_shift*26)-6]);
    else char_print(v2alpha[z+(zch_shift*26)-6]);
    zch_shift=zch_shiftlock;
  }
}

U32 text_print(U32 address) {
  U16 t;
  zch_shift=zch_shiftlock=0;
  for(;;) {
    t=read16(address);
    address+=2;
    zch_print((t>>10)&31);
    zch_print((t>>5)&31);
    zch_print(t&31);
    if(t&0x8000) return address;
  }
}

//TODO FIXME inline
void make_rectangle(U32 addr,int width,int height,int skip) {
  int old_column=cur_column;
  int w,h;
  for(h=0;h<height;h++) {
    for(w=0;w<width;w++) char_print(memory[addr++]);
    addr+=skip;
    if(h!=height-1) {
      char_print(13);
      for(w=0;w<old_column;w++) char_print(32);
    }
  }
  text_flush();
}

//TODO FIXME inline
U16 fetch(U8 var) {
  if(var&0xF0) {
    return read16(global_table+((var-16)<<1));
  } else if(var) {
    return stack[frames[frameptr].start+var-1];
  } else {
    return stack[--stackptr];
  }
}

void store(U8 var,U16 value) {
  if(var&0xF0) {
    write16(global_table+((var-16)<<1),value);
  } else if(var) {
    stack[frames[frameptr].start+var-1]=value;
  } else {
    stack[stackptr++]=value;
  }
}

//TODO FIXME inline
void storei(U16 value) {
  store(memory[program_counter++],value);
}

void enter_routine(U32 address,boolean stored,int argc) {
  int c=memory[address];
  int i;
  frames[frameptr].pc=program_counter;
  frames[++frameptr].argc=argc;
  frames[frameptr].start=stackptr;
  frames[frameptr].stored=stored;
  program_counter=address+1;
  if(version<5) {
    for(i=0;i<c;i++) {
      stack[stackptr++]=read16(program_counter);
      program_counter+=2;
    }
  } else {
    for(i=0;i<c;i++) stack[stackptr++]=0;
  }
  if(argc>c) argc=c;
  for(i=0;i<argc;i++) stack[frames[frameptr].start+i]=inst_args[i+1];
}

void exit_routine(U16 result) {
  stackptr=frames[frameptr].start;
  program_counter=frames[--frameptr].pc;
  if(frames[frameptr+1].stored) store(memory[program_counter-1],result);
}

void branch(U32 cond) {
  int v=memory[program_counter++];
  if(!(v&0x80)) cond=!cond;
  if(v&0x40) v&=0x3F; else v=((v&0x3F)<<8)|memory[program_counter++];
  if(cond) {
    if(v==0 || v==1) exit_routine(v);
    else program_counter+=(v&0x1FFF)-((v&0x2000)|2);
  }
}

//TODO FIXME inline
void obj_tree_put(U16 obj,int f,U16 v) {
  if(version>3) write16(object_table+118+obj*14+f*2,v);
  else memory[object_table+57+obj*9+f]=v;
}

#define obj_tree_get(o,f) (version>3?read16(object_table+118+(o)*14+(f)*2):memory[object_table+57+(o)*9+(f)])
#define parent(x) obj_tree_get(x,0)
#define sibling(x) obj_tree_get(x,1)
#define child(x) obj_tree_get(x,2)
#define set_parent(x,y) obj_tree_put(x,0,y)
#define set_sibling(x,y) obj_tree_put(x,1,y)
#define set_child(x,y) obj_tree_put(x,2,y)
#define attribute(x) (version>3?object_table+112+(x)*14:object_table+53+(x)*9)
#define obj_prop_addr(o) (read16(version>3?(object_table+124+(o)*14):(object_table+60+(o)*9))<<address_shift)

//TODO FIXME inline
void insert_object(U16 obj,U16 dest) {
  U16 p=parent(obj);
  U16 s=sibling(obj);
  U16 x;
  if(p) {
    if(opts['d']) fprintf(stderr,"\n** Detaching %u from %u.\n",obj,p);
    // Detach object from parent
    x=child(p);
    if(x==obj) {
      set_child(p,sibling(x));
    } else {
      while(sibling(x)) {
        if(sibling(x)==obj) {
          set_sibling(x,sibling(sibling(x)));
          break;
        }
        x=sibling(x);
      }
    }
  }
  if(dest) {
    if(opts['d']) fprintf(stderr,"\n** Attaching %u to %u.\n",obj,dest);
    // Attach object to new parent
    set_sibling(obj,child(dest));
    set_child(dest,obj);
  } else {
    set_sibling(obj,0);
  }
  set_parent(obj,dest);
}

//TODO FIXME inline
U32 property_address(U16 obj,U8 p) {
  U32 a=obj_prop_addr(obj);
  U8 n=1;
  a+=(memory[a]<<1)+1;
  if(opts['d']) fprintf(stderr,"\n** Finding property %u of object %u.\n",p,obj);
  while(memory[a]) {
    if(version<4) {
      n=memory[a]&31;
      cur_prop_size=(memory[a]>>5)+1;
    } else if(memory[a]&0x80) {
      n=memory[a]&(version>8?127:63);
      cur_prop_size=memory[++a]&63?0:64;
    } else {
      n=memory[a]&63;
      cur_prop_size=(memory[a]>>6)+1;
    }
    a++;
    //if(n<p) return 0;
    if(n==p) return a;
    a+=cur_prop_size;
  }
  return 0;
}

U8 system_input(char**out) {
  char*p;
  U32 i;
input_again:
  text_flush();
  cur_row=2;
  cur_column=0;
  if(!fgets(text_buffer,1023,stdin)) {
    fprintf(stderr,"*** Unable to continue.\n");
    exit(1);
  }
  p=text_buffer+strlen(text_buffer);
  while(p!=text_buffer && p[-1]<32) *--p=0; // Let's removing "CRLF", etc
  if(escape_code && *text_buffer==escape_code) {
    *out=text_buffer+2;
    switch(text_buffer[1]) {
      case '"':
        text_buffer[1]=escape_code;
        *out=text_buffer+1;
        break;
      case '1':
	  case '2':
	  case '3':
	  case '4':
	  case '5':
	  case '6':
	  case '7':
	  case '8':
	  case '9':
        return text_buffer[1]+133-'1';
      case ';':
        if(transcript) {
          fputc(0,transcript);
          fputs(text_buffer+2,transcript);
          fputc(13,transcript);
        }
        goto input_again;
      case '<':
        return 131;
      case '>':
        return 132;
      case '?':
        fputs(
          "Arrow keys: ^v<>    Function keys: 123456789\n"
          "Other keys: x (delete) s (space) e (escape) \" (escape_code)\n"
          " B0 = breakpoints off   B1 = breakpoints on\n"
          " F0 = read keyboard   F1 = read logged input\n"
          " L0 = disable input logging   L1 = enable input logging\n"
          " S0 = transcript off   S1 = transcript on\n"
          " U = instruction usage   U* = save instruction usage to file\n"
          " Y = clear instruction usage\n"
          " ;* = send comment to transcript\n"
          " b = break into debugger\n"
          " q = quit\n"
          " r* = initialize random number generator\n"
          " y = show status line (version 1, 2, 3 only)\n"
        ,stderr);
        goto input_again;
      case 'B':
        break_on=text_buffer[2]&1;
        goto input_again;
      case 'F':
        from_log=text_buffer[2]&1;
        goto input_again;
      case 'L':
        logging=text_buffer[2]&1;
        goto input_again;
      case 'S':
        memory[0x11]&=0xFE;
        memory[0x11]|=text_buffer[2]&1;
        goto input_again;
      case 'U':
        if(text_buffer[2]) {
          FILE*fp=fopen(text_buffer+2,"wb");
          if(!fp) goto input_again;
          fwrite(instruction_use,1,256,fp);
          fclose(fp);
        } else {
          for(i=0;i<256;i++) if(instruction_use[i]&0x06) printf(".%02X.\n",i);
        }
        goto input_again;
      case 'Y':
        memset(instruction_use,0,256);
        goto input_again;
      case '^':
        return 129;
      case 'b':
        debugger();
        if(lastdebug) return 0;
        goto input_again;
      case 'e':
        return 27;
      case 'q':
        exit(0);
        break;
      case 'r':
        randomize(strtol(text_buffer+2,0,0));
        goto input_again;
      case 's':
        text_buffer[1]=' ';
        *out=text_buffer+1;
        break;
      case 'v':
        return 130;
      case 'x':
        return 8;
      case 'y':
        if(version>3) {
          fprintf(stderr,"*** Status line not available in this Z-machine version.\n");
        } else {
          text_print(obj_prop_addr(fetch(16))+1);
          char_print(13);
          printf(version==3 && (memory[0x01]&2)?"Time: %02u:%02u\n":"Score: %d\nTurns: %d\n",(S16)fetch(17),fetch(18));
        }
        goto input_again;
    }
  } else {
    *out=text_buffer;
  }
  return 13;
}

//TODO FIXME inline
U64 dictionary_get(U32 addr) {
  U64 v=0;
  int c=version>3?6:4;
  while(c--) v=(v<<8)|memory[addr++];
  return v;
}

U64 dictionary_encode(U8*text,int len) {
  U64 v=0;
  int c=version>3?9:6;
  int i;
  const U8*al=(alphabet_table?(const U8*)memory+alphabet_table:(const U8*)(version>1?v2alpha:v1alpha));
  while(c && len && *text) {
    // Since line breaks cannot be in an input line of text, and VAR:252 is only available in version 5, line breaks need not be considered here.
    // However, because of VAR:252, spaces still need to be considered.
    if(!(c%3)) v<<=1;
    if(*text==' ') {
      v<<=5;
    } else {
      for(i=0;i<78;i++) {
        if(*text==al[i] && i!=52 && i!=53) {
          v<<=5;
          if(i>=26) {
            v|=i/26+(version>2?3:1);
            c--;
            if(!c) return v|0x8000;
            if(!(c%3)) v<<=1;
            v<<=5;
          }
          v|=(i%26)+6;
          break;
        }
      }
      if(i==78) {
        v<<=5;
        v|=version>2?5:3;
        c--;
        if(!c) return v|0x8000;
        if(!(c%3)) v<<=1;
        v<<=5;
        v|=6;
        c--;
        if(!c) return v|0x8000;
        if(!(c%3)) v<<=1;
        v<<=5;
        v|=*text>>5;
        c--;
        if(!c) return v|0x8000;
        if(!(c%3)) v<<=1;
        v<<=5;
        v|=*text&31;
      }
    }
    c--;
    text++;
    len--;
  }
  while(c) {
    if(!(c%3)) v<<=1;
    v<<=5;
    v|=5;
    c--;
  }
  return v|0x8000;
}

void add_to_parsebuf(U32 parsebuf,U32 dict,U8*d,int k,int el,int ne,int p,U16 flag) {
  U64 v=dictionary_encode(d,k);
  U64 g;
  int i;
  if(opts['d']) {
    fprintf(stderr,"** Word at %d (length %d): \"",p,k);
    for(i=0;i<k;i++) fputc(d[i],stderr);
    fprintf(stderr,"\"\n");
  }
  for(i=0;i<ne;i++) {
    g=dictionary_get(dict)|0x8000;
    if(g==v) {
      if(opts['d']) fprintf(stderr,"** Found at $%08X\n",dict);
      memory[parsebuf+(memory[parsebuf+1]<<2)+5]=p+1+(version>4);
      memory[parsebuf+(memory[parsebuf+1]<<2)+4]=k;
      write16(parsebuf+(memory[parsebuf+1]<<2)+2,dict);
      break;
    }
    dict+=el;
  }
  if(i==ne && !flag) {
    if(opts['d']) fprintf(stderr,"** Not found\n");
    memory[parsebuf+(memory[parsebuf+1]<<2)+5]=p+1+(version>4);
    memory[parsebuf+(memory[parsebuf+1]<<2)+4]=k;
    write16(parsebuf+(memory[parsebuf+1]<<2)+2,0);
  }
  memory[parsebuf+1]++;
}

#define Add_to_parsebuf() if(k)add_to_parsebuf(parsebuf,dict,d,k,el,ne,p1,flag),k=0;p1=p+1;
void tokenise(U32 text,U32 dict,U32 parsebuf,int len,U16 flag) {
  boolean ws[256];
  U8 d[10];
  int i,el,ne,k,p,p1;
  memset(ws,0,256*sizeof(boolean));
  if(!dict) {
    for(i=1;i<=memory[dictionary_table];i++) ws[memory[dictionary_table+i]]=1;
    dict=dictionary_table;
  }
  for(i=1;i<=memory[dict];i++) ws[memory[dict+i]]=1;
  memory[parsebuf+1]=0;
  k=p=p1=0;
  el=memory[dict+memory[dict]+1];
  ne=read16(dict+memory[dict]+2);
  if(ne<0) ne*=-1; // Currently, it won't care about the order; it doesn't use binary search.
  dict+=memory[dict]+4;
  while(p<len && memory[text+p] && memory[parsebuf+1]<memory[parsebuf]) {
    i=memory[text+p];
    if(i>='A' && i<='Z') i+='a'-'A';
    if(i=='?' && opts['q']) i=' ';
    if(i==' ') {
      Add_to_parsebuf();
    } else if(ws[i]) {
      Add_to_parsebuf();
      *d=i;
      k=1;
      Add_to_parsebuf();
    } else if(k<10) {
      d[k++]=i;
    } else {
      k++;
    }
    p++;
  }
  Add_to_parsebuf();
}
#undef Add_to_parsebuf

U8 line_input(void) {
  char*ptr;
  char*p;
  int c,cmax;
  U8 res;
  if(from_log && inlog && feof(inlog)) from_log=0;
  if(from_log) {
    p=text_buffer;
    for(;;) {
      c=fgetc(inlog);
      if(c==8) {
        if(p>text_buffer) p--;
      } else if(c==0 || c==13 || c==27 || (c>128 && c<145) || c>251 || c==EOF) {
        res=c;
        if(c==EOF) from_log=0;
        break;
      } else if((c>31 && c<127) || (c>154 && c<252)) {
        *p++=c;
      }
    }
    *p=0;
  } else {
    if(opts['n'] && version<4 && ((S16)fetch(17))!=oldscore) {
      c=((S16)fetch(17))-oldscore;
      printf("\n[The score has been %screased by %d.]\n",c>=0?"in":"de",c>=0?c:-c);
      oldscore=(S16)fetch(17);
    }
    res=system_input(&ptr);
    if(lastdebug) return;
  }
  if(logging && outlog) {
    fprintf(outlog,"%s",ptr);
    fputc(res,outlog);
  }
  if(memory[0x11]&1) {
    if(transcript) {
      fputs(ptr,transcript);
      fputc(13,transcript);
    } else {
      memory[0x10]|=4;
    }
  }
  if(version<9) {
    p=ptr;
    while(*p) {
      if(*p>='A' && *p<='Z') *p|=0x20;
      p++;
    }
  }
  p=ptr;
  c=0;
  cmax=memory[inst_args[0]];
  if(version>4) {
    // "Left over" characters are not implemented.
    while(*p && c<cmax) {
      memory[inst_args[0]+c+2]=*p++;
      ++c;
    }
    memory[inst_args[0]+1]=c;
    if(inst_args[1]) tokenise(inst_args[0]+2,0,inst_args[1],c,0);
  } else {
    while(*p && c<cmax) {
      memory[inst_args[0]+c+1]=*p++;
      ++c;
    }
    memory[c+1]=0;
    tokenise(inst_args[0]+1,0,inst_args[1],c,0);
  }
  return res;
}

U8 char_input(void) {
  char*ptr;
  U8 res;
  if(from_log && inlog && feof(inlog)) from_log=0;
  if(from_log) {
    res=fgetc(inlog);
  } else {
    res=system_input(&ptr);
    if(res==13 && *ptr) res=*ptr;
  }
  if(logging && outlog) fputc(res,outlog);
  return res;
}

void game_restart(void) {
  U32 addr=64;
  stackptr=frameptr=0;
  program_counter=restart_address;
  clearerr(story);
  fseek(story,64,SEEK_SET);
  while(!feof(story)) {
    if(!fread(memory+addr,1024,1,story)) return;
    addr+=1024;
  }
}

inline void game_save_many(FILE*fp,long count) {
  long i;
  while(count>0) {
    fputc(0,fp);
    if(count>=129) {
      i=count;
      if(i>0x3FFF) i=0x3FFF;
      fputc(((i-1)&0x7F)|0x80,fp);
      fputc((i-((i-1)&0x7F)-0x80)>>7,fp);
      count-=i;
    } else {
      fputc(count-1,fp);
      count=0;
    }
  }
}

void game_save(U8 storage) {
  char filename[1024];
  FILE*fp;
  int i;
  U8 c;
  long o,q;
  if(from_log) {
    store(storage,0);
    return;
  }
  printf("\n*** Save? ");
  fflush(stdout);
  gets(filename);
  if(*filename=='.' && !filename[1]) sprintf(filename,"%s.sav",story_name);
  cur_column=0;
  if(!*filename) {
    if(version<4) branch(0); else store(storage,0);
    return;
  } else if(*filename=='*') {
    if(version<4) branch(1); else store(storage,strtol(filename+1,0,0));
    return;
  }
  fp=fopen(filename,"wb");
  if(!fp) {
    if(version<4) branch(0); else store(storage,0);
    return;
  }
  if(version<4) branch(1); else store(storage,2);
  frames[frameptr].pc=program_counter;
  frames[frameptr+1].start=stackptr;
  fputc(frameptr+1,fp);
  for(i=0;i<=frameptr;i++) {
    fputc((frames[i+1].start-frames[i].start)>>1,fp);
    fputc((((frames[i+1].start-frames[i].start)&1)<<7)|((!frames[i].stored)<<6)|(frames[i].pc>>16),fp);
    fputc((frames[i].pc>>8)&255,fp);
    fputc(frames[i].pc&255,fp);
  }
  for(i=0;i<stackptr;i++) {
    fputc(stack[i]>>8,fp);
    fputc(stack[i]&255,fp);
  }
  clearerr(story);
  fseek(story,o=0x38,SEEK_SET);
  q=0;
  while(o<static_start) {
    c=fgetc(story);
    if(memory[o]==c) {
      q++;
    } else {
      game_save_many(fp,q);
      q=0;
      fputc(memory[o]^c,fp);
    }
    o++;
  }
  fclose(fp);
  if(version<4) return;
  fetch(storage);
  store(storage,1);
}

void game_restore(void) {
  char filename[1024];
  FILE*fp;
  int i,c,d;
  long o;
  if(opts['r']) {
    fp=fopen(opts['r'],"rb");
    opts['r']=0;
  } else {
    if(from_log) return;
    printf("\n*** Restore? ");
    fflush(stdout);
    gets(filename);
    if(*filename=='.' && !filename[1]) sprintf(filename,"%s.sav",story_name);
    cur_column=0;
    if(!*filename) return;
    fp=fopen(filename,"rb");
  }
  if(!fp) return;
  frameptr=fgetc(fp)-1;
  stackptr=0;
  for(i=0;i<=frameptr;i++) {
    c=fgetc(fp);
    d=fgetc(fp);
    frames[i].start=stackptr;
    stackptr+=(c<<1)|(d>>7);
    frames[i].stored=!(d&0x40);
    frames[i].pc=(d&0x3F)<<16;
    frames[i].pc|=fgetc(fp)<<8;
    frames[i].pc|=fgetc(fp);
  }
  for(i=0;i<stackptr;i++) {
    stack[i]=fgetc(fp)<<8;
    stack[i]|=fgetc(fp);
  }
  clearerr(story);
  fseek(story,o=0x38,SEEK_SET);
  i=0;
  while(o<static_start) {
    d=fgetc(fp);
    if(d==EOF) break;
    if(d) {
      memory[o++]=fgetc(story)^d;
    } else {
      c=fgetc(fp);
      if(c&0x80) c+=fgetc(fp)<<7;
      while(c-->=0) memory[o++]=fgetc(story);
    }
  }
  fclose(fp);
  while(o<static_start) memory[o++]=fgetc(story);
  program_counter=frames[frameptr].pc;
}

inline void switch_output(int st) {
  switch(st) {
    case 1:
      texting=1;
      break;
    case 2:
      memory[0x11]|=1;
      break;
    case 3:
      if(stream3ptr!=15) {
        stream3addr[++stream3ptr]=inst_args[1];
        write16(inst_args[1],0);
      }
      break;
    case 4:
      if(outlog) logging=1;
      break;
    case -1:
      texting=0;
      break;
    case -2:
      memory[0x11]&=~1;
      break;
    case -3:
      if(stream3ptr!=-1) stream3ptr--;
      break;
    case -4:
      logging=0;
      break;
  }
}

void aux_filename(void) {
  int len=memory[inst_args[3]];
  int i,j,k,d;
  for(i=0;i<11;i++) auxname[i]=32;
  for(i=j=d=0;i<len && j<11;i++) {
    k=memory[inst_args[3]+i+1];
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

U16 aux_save(void) {
  int i,j,p,s;
  byte fn[11];
  static const byte bl[11]={32,32,32,32,32,32,32,32,32,32,32};
  U16 pos[32];
  U16 size[32];
  if(!auxfile) return 0;
  clearerr(auxfile);
  aux_filename();
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
  s=inst_args[2];
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
  fwrite(memory+inst_args[1],1,s,auxfile);
  return 1;
}

U16 aux_restore(void) {
  int i,p,s;
  byte fn[11];
  if(!auxfile) return 0;
  clearerr(auxfile);
  aux_filename();
  for(i=0;i<32;i++) {
    fseek(auxfile,i*13,SEEK_SET);
    fread(fn,1,11,auxfile);
    if(!memcmp(fn,auxname,11)) {
      p=fgetc(auxfile)<<8;
      p|=fgetc(auxfile);
      fseek(auxfile,(p<<6)+416,SEEK_SET);
      s=fgetc(auxfile)<<8;
      s|=fgetc(auxfile);
      if(s>inst_args[2]) s=inst_args[2];
      fread(memory+inst_args[1],1,s,auxfile);
      return s;
    }
  }
  return 0;
}

void execute_instruction(void) {
  U8 in=memory[program_counter++];
  U16 at;
  S16 m,n;
  U32 u=program_counter-1;
  static U64 y;
  U8 nbuf[5];
  int argc;
  instruction_use[in]|=0x01;
  if(in&0x80) {
    if(in>=0xC0 || in==0xBE) {
      // variable
      if(in==0xBE) in=memory[program_counter++];
      at=memory[program_counter++]<<8;
      if(in==0xEC || in==0xFA) at|=memory[program_counter++]; else at|=0x00FF;
      if((at&0xC000)==0xC000) argc=0;
      else if((at&0x3000)==0x3000) argc=1;
      else if((at&0x0C00)==0x0C00) argc=2;
      else if((at&0x0300)==0x0300) argc=3;
      else if((at&0x00C0)==0x00C0) argc=4;
      else if((at&0x0030)==0x0030) argc=5;
      else if((at&0x000C)==0x000C) argc=6;
      else if((at&0x0003)==0x0003) argc=7;
      else argc=8;
    } else {
      // short
      at=(in<<10)|0x3FFF;
      argc=(in<0xB0);
      if(argc) in&=0x8F;
    }
  } else {
    // long
    at=0x5FFF;
    if(in&0x20) at^=0x3000;
    if(in&0x40) at^=0xC000;
    in&=0x1F;
    in|=0xC0;
    argc=2;
  }
  if(break_on) {
    if(continuing==u || continuing==program_counter) {
      continuing=0;
    } else {
      if(instruction_bkpt[in]) { program_counter=u; debugger(); return; }
      for(n=0;n<16;n++) if(address_bkpt[n]==u) { program_counter=u; debugger(); return; }
    }
  }
  for(n=0;n<8;n++) {
    switch((at>>(14-n*2))&3) {
      case 0: // large
        inst_args[n]=memory[program_counter++]<<8;
        inst_args[n]|=memory[program_counter++];
        break;
      case 1: // small
        inst_args[n]=memory[program_counter++];
        break;
      case 2: // variable
        inst_args[n]=fetch(memory[program_counter++]);
        break;
      case 3: // omit
        inst_args[n]=0;
        break;
    }
  }
  instruction_use[in]|=argc?0x04:0x02;
  lastdebug=0;
  switch(in) {
    case 0x00: // Save game or auxiliary file
      if(argc) storei(aux_save());
      else game_save(memory[program_counter++]);
      break;
    case 0x01: // Restore game or auxiliary file
      storei(argc && auxfile?aux_restore():0);
      if(!argc) game_restore();
      break;
    case 0x02: // Logical shift
      if(inst_sargs[1]>0) storei(inst_args[0]<<inst_args[1]);
      else storei(inst_args[0]>>-inst_args[1]);
      break;
    case 0x03: // Arithmetic shift
      if(inst_sargs[1]>0) storei(inst_sargs[0]<<inst_sargs[1]);
      else storei(inst_sargs[0]>>-inst_sargs[1]);
      break;
    case 0x04: // Set font
      text_flush();
      storei((*inst_args==1 || *inst_args==4)?4:0);
      if(!opts['t']) putchar(*inst_args==3?14:15);
      break;
    case 0x08: // Set margins
      if(!window) {
        lmargin=inst_args[0];
        rmargin=inst_args[1];
        if(version==5) write16(40,inst_args[0]);
        if(version==5) write16(41,inst_args[1]);
        while(cur_column<*inst_args) {
          putchar(32);
          cur_column++;
        }
      }
      break;
    case 0x09: // Save undo buffer
      if(allow_undo) {
        copy_array(u_frames,frames);
        copy_array(u_stack,stack);
        memcpy(undomem,memory+0x40,static_start-0x40);
        u_frameptr=frameptr;
        u_stackptr=stackptr;
        u_program_counter=program_counter;
        storei(1);
      } else {
        storei(-1);
      }
      break;
    case 0x0A: // Restore undo buffer
      if(allow_undo) {
        copy_array(frames,u_frames);
        copy_array(stack,u_stack);
        memcpy(memory+0x40,undomem,static_start-0x40);
        frameptr=u_frameptr;
        stackptr=u_stackptr;
        program_counter=u_program_counter;
        storei((argc && version>8)?*inst_args:2);
      } else {
        storei(-1);
      }
      break;
    case 0x0B: // Call byte address
      program_counter++;
      enter_routine(*inst_args,1,argc-1);
      break;
    case 0x0C: // Get reference to stack or local variables
      if(*inst_args) storei(stackptr-1);
      else storei(frames[frameptr].start+*inst_args-1);
      break;
    case 0x0D: // Read through stack/locals reference
      storei(stack[*inst_args]);
      break;
    case 0x0E: // Write through stack/locals reference
      if(*inst_args<1024) stack[*inst_args]=inst_args[1];
      break;
    case 0x0F: // Read byte from long property
      u=property_address(inst_args[0],inst_args[1]);
      storei(memory[u]);
      break;
    case 0x1D: // Read word from long property
      u=property_address(inst_args[0],inst_args[1]);
      storei(read16(u));
      break;
    case 0x80: // Jump if zero
      branch(!*inst_args);
      break;
    case 0x81: // Sibling
      storei(sibling(*inst_args));
      branch(sibling(*inst_args));
      break;
    case 0x82: // Child
      storei(child(*inst_args));
      branch(child(*inst_args));
      break;
    case 0x83: // Parent
      storei(parent(*inst_args));
      break;
    case 0x84: // Property length
      in=memory[*inst_args-1];
      storei(version<4?(in>>5)+1:in&0x80?(in&63?:64):(in>>6)+1);
      break;
    case 0x85: // Increment
      store(*inst_args,fetch(*inst_args)+1);
      break;
    case 0x86: // Decrement
      store(*inst_args,fetch(*inst_args)-1);
      break;
    case 0x87: // Print by byte address
      text_print(*inst_args);
      break;
    case 0x88: // Call routine
      if(*inst_args) {
        program_counter++;
        enter_routine((*inst_args<<packed_shift)+routine_start,1,argc-1);
      } else {
        storei(0);
      }
      break;
    case 0x89: // Remove object
      insert_object(*inst_args,0);
      break;
    case 0x8A: // Print short name of object
      text_print(obj_prop_addr(*inst_args)+1);
      break;
    case 0x8B: // Return
      exit_routine(*inst_args);
      break;
    case 0x8C: // Unconditional jump
      program_counter+=*inst_sargs-2;
      break;
    case 0x8D: // Print by packed address
      text_print((*inst_args<<packed_shift)+text_start);
      break;
    case 0x8E: // Load variable
      at=fetch(*inst_args);
      store(*inst_args,at); // if it popped from the stack, please put it back on
      storei(at);
      break;
    case 0x8F: // Not // Call routine and discard result
      if(version>4) {
        if(*inst_args) enter_routine((*inst_args<<packed_shift)+routine_start,0,argc-1);
      } else {
        storei(~*inst_args);
      }
      break;
    case 0xB0: // Return 1
      exit_routine(1);
      break;
    case 0xB1: // Return 0
      exit_routine(0);
      break;
    case 0xB2: // Print literal
      program_counter=text_print(program_counter);
      break;
    case 0xB3: // Print literal and return
      program_counter=text_print(program_counter);
      char_print(13);
      exit_routine(1);
      break;
    case 0xB4: // No operation
      //NOP
      break;
    case 0xB5: // Save
      if(version>3) game_save(memory[program_counter++]);
      else game_save(0);
      break;
    case 0xB6: // Restore
      if(version>3) storei(0); else branch(0);
      game_restore();
      break;
    case 0xB7: // Restart
      game_restart();
      break;
    case 0xB8: // Return from stack
      exit_routine(stack[stackptr-1]);
      break;
    case 0xB9: // Discard from stack // Catch
      if(version>4) storei(frameptr);
      else stackptr--;
      break;
    case 0xBA: // Quit
      text_flush();
      exit(0);
      break;
    case 0xBB: // Line break
      char_print(13);
      break;
    case 0xBC: // Show status
      //NOP
      break;
    case 0xBD: // Verify checksum
      branch(verify_checksum());
      break;
    case 0xBF: // Check if game disc is original
      branch(original);
      break;
    case 0xC1: // Branch if equal
      for(n=1;n<argc;n++) {
        if(*inst_args==inst_args[n]) {
          branch(1);
          break;
        }
      }
      if(n==argc) branch(0);
      break;
    case 0xC2: // Jump if less
      branch(inst_sargs[0]<inst_sargs[1]);
      break;
    case 0xC3: // Jump if greater
      branch(inst_sargs[0]>inst_sargs[1]);
      break;
    case 0xC4: // Decrement and branch if less
      store(*inst_args,n=fetch(*inst_args)-1);
      branch(n<inst_sargs[1]);
      break;
    case 0xC5: // Increment and branch if greater
      store(*inst_args,n=fetch(*inst_args)+1);
      branch(n>inst_sargs[1]);
      break;
    case 0xC6: // Check if one object is the parent of the other
      branch(parent(inst_args[0])==inst_args[1]);
      break;
    case 0xC7: // Test bitmap
      branch((inst_args[0]&inst_args[1])==inst_args[1]);
      break;
    case 0xC8: // Bitwise OR
      storei(inst_args[0]|inst_args[1]);
      break;
    case 0xC9: // Bitwise AND
      storei(inst_args[0]&inst_args[1]);
      break;
    case 0xCA: // Test attributes
      branch(memory[attribute(*inst_args)+(inst_args[1]>>3)]&(0x80>>(inst_args[1]&7)));
      break;
    case 0xCB: // Set attribute
      memory[attribute(*inst_args)+(inst_args[1]>>3)]|=0x80>>(inst_args[1]&7);
      break;
    case 0xCC: // Clear attribute
      memory[attribute(*inst_args)+(inst_args[1]>>3)]&=~(0x80>>(inst_args[1]&7));
      break;
    case 0xCD: // Store to variable
      fetch(inst_args[0]);
      store(inst_args[0],inst_args[1]);
      break;
    case 0xCE: // Insert object
      insert_object(inst_args[0],inst_args[1]);
      break;
    case 0xCF: // Read 16-bit number from RAM/ROM
      storei(read16(inst_args[0]+(inst_sargs[1]<<1)));
      break;
    case 0xD0: // Read 8-bit number from RAM/ROM
      storei(memory[inst_args[0]+inst_sargs[1]]);
      break;
    case 0xD1: // Read property
      if(u=property_address(inst_args[0],inst_args[1])) storei(cur_prop_size==1?memory[u]:read16(u));
      else storei(read16(object_table+(inst_args[1]<<1)-2));
      break;
    case 0xD2: // Get address of property
      storei(property_address(inst_args[0],inst_args[1]));
      break;
    case 0xD3: // Find next property
      if(inst_args[1]) {
        u=property_address(inst_args[0],inst_args[1]);
        u+=cur_prop_size;
        storei(memory[u]&(version>8&&(memory[u]&128)?127:version>3?63:31));
      } else {
        u=obj_prop_addr(inst_args[0]);
        u+=(memory[u]<<1)+1;
        storei(memory[u]&(version>8&&(memory[u]&128)?127:version>3?63:31));
      }
      break;
    case 0xD4: // Addition
      storei(inst_sargs[0]+inst_sargs[1]);
      break;
    case 0xD5: // Subtraction
      storei(inst_sargs[0]-inst_sargs[1]);
      break;
    case 0xD6: // Multiplication
      storei(inst_sargs[0]*inst_sargs[1]);
      break;
    case 0xD7: // Division
      if(inst_args[1]) n=inst_sargs[0]/inst_sargs[1];
      else fprintf(stderr,"\n*** Division by zero\n",in);
      storei(n);
      break;
    case 0xD8: // Modulo
      if(inst_args[1]) n=inst_sargs[0]%inst_sargs[1];
      else fprintf(stderr,"\n*** Division by zero\n",in);
      storei(n);
      break;
    case 0xD9: // Call routine
      if(*inst_args) {
        program_counter++;
        enter_routine((*inst_args<<packed_shift)+routine_start,1,argc-1);
      } else {
        storei(0);
      }
      break;
    case 0xDA: // Call routine and discard result
      if(*inst_args) enter_routine((*inst_args<<packed_shift)+routine_start,0,argc-1);
      break;
    case 0xDB: // Set colors
      //NOP
      break;
    case 0xDC: // Throw
      frameptr=inst_args[1];
      exit_routine(*inst_args);
      break;
    case 0xDD: // Bitwise XOR
      storei(inst_args[0]^inst_args[1]);
      break;
    case 0xE0: // Call routine // Read from extended RAM
      if(version>8) {
        u=(inst_args[0]<<address_shift)+(inst_args[1]<<1)+inst_args[2];
        storei(read16(u));
      } else if(*inst_args) {
        program_counter++;
        enter_routine((*inst_args<<packed_shift)+routine_start,1,argc-1);
      } else {
        storei(0);
      }
      break;
    case 0xE1: // Write 16-bit number to RAM
      write16(inst_args[0]+(inst_sargs[1]<<1),inst_args[2]);
      break;
    case 0xE2: // Write 8-bit number to RAM
      memory[inst_args[0]+inst_sargs[1]]=inst_args[2];
      break;
    case 0xE3: // Write property
      u=property_address(inst_args[0],inst_args[1]);
      if(cur_prop_size==1) memory[u]=inst_args[2]; else write16(u,inst_args[2]);
      break;
    case 0xE4: // Read line of input
      n=line_input();
      if(version>4 && !lastdebug) storei(n);
      break;
    case 0xE5: // Print character
      char_print(*inst_args);
      break;
    case 0xE6: // Print number
      n=*inst_sargs;
      if(n==-32768) {
        char_print('-');
        char_print('3');
        char_print('2');
        char_print('7');
        char_print('6');
        char_print('8');
      } else {
        nbuf[0]=nbuf[1]=nbuf[2]=nbuf[3]=nbuf[4]=0;
        if(n<0) {
          char_print('-');
          n*=-1;
        }
        nbuf[4]=(n%10)|'0';
        if(n/=10) nbuf[3]=(n%10)|'0';
        if(n/=10) nbuf[2]=(n%10)|'0';
        if(n/=10) nbuf[1]=(n%10)|'0';
        if(n/=10) nbuf[0]=(n%10)|'0';
        char_print(nbuf[0]);
        char_print(nbuf[1]);
        char_print(nbuf[2]);
        char_print(nbuf[3]);
        char_print(nbuf[4]);
      }
      break;
    case 0xE7: // Random number generator
      if(*inst_sargs>0) storei(get_random(*inst_sargs));
      else randomize(-*inst_sargs),storei(0);
      break;
    case 0xE8: // Push to stack
      stack[stackptr++]=*inst_args;
      break;
    case 0xE9: // Pop from stack
      if(*inst_args) store(*inst_args,stack[--stackptr]);
      else stack[stackptr-2]=stack[stackptr-1],stackptr--;
      break;
    case 0xEA: // Split window
      //NOP
      break;
    case 0xEB: // Set active window
      window=*inst_args;
      break;
    case 0xEC: // Call routine
      if(*inst_args) {
        program_counter++;
        enter_routine((*inst_args<<packed_shift)+routine_start,1,argc-1);
      } else {
        storei(0);
      }
      break;
    case 0xED: // Clear window
      if(*inst_args!=1) {
        putchar('\n');
        textptr=0;
        cur_row=2;
        cur_column=0;
        while(cur_column<lmargin) {
          putchar(32);
          cur_column++;
        }
      }
      break;
    case 0xEE: // Erase line
      //NOP
      break;
    case 0xEF: // Set cursor position
      //NOP
      break;
    case 0xF0: // Get cursor position
      if(window) {
        memory[*inst_args]=sc_rows;
        memory[*inst_args+1]=cur_column+1;
      } else {
        memory[*inst_args]=0;
        memory[*inst_args+1]=0;
      }
      break;
    case 0xF1: // Set text style
      //NOP
      break;
    case 0xF2: // Buffer mode
      buffering=*inst_args;
      break;
    case 0xF3: // Select output stream
      switch_output(*inst_sargs);
      break;
    case 0xF4: // Select input stream
      if(inlog) from_log=*inst_args;
      break;
    case 0xF5: // Sound effects
      putchar(7);
      break;
    case 0xF6: // Read a single character
      n=char_input();
      if(!lastdebug) storei(n);
      break;
    case 0xF7: // Scan a table
      if(argc<4) inst_args[3]=0x82;
      u=inst_args[1];
      while(inst_args[2]) {
        if(*inst_args==(inst_args[3]&0x80?read16(u):memory[u])) break;
        u+=inst_args[3]&0x7F;
        inst_args[2]--;
      }
      storei(inst_args[2]?u:0);
      branch(inst_args[2]);
      break;
    case 0xF8: // Not
      storei(~*inst_args);
      break;
    case 0xF9: // Call routine and discard results // Write extended RAM
      if(version>8) {
        u=(inst_args[0]<<address_shift)+(inst_args[1]<<1)+inst_args[2];
        write16(u,inst_args[3]);
      } else if(*inst_args) {
        enter_routine((*inst_args<<packed_shift)+routine_start,0,argc-1);
      }
      break;
    case 0xFA: // Call routine and discard results
      if(*inst_args) enter_routine((*inst_args<<packed_shift)+routine_start,0,argc-1);
      break;
    case 0xFB: // Tokenise text
      if(argc<4) inst_args[3]=0;
      if(argc<3) inst_args[2]=0;
      tokenise(inst_args[0]+2,inst_args[2],inst_args[1],memory[inst_args[0]+1],inst_args[3]);
      break;
    case 0xFC: // Encode text in dictionary format
      y=dictionary_encode(memory+inst_args[0]+inst_args[2],inst_args[1]);
      write16(inst_args[3],y>>16);
      write16(inst_args[3]+2,y>>8);
      write16(inst_args[3]+4,y);
      break;
    case 0xFD: // Copy a table
      if(!inst_args[1]) {
        // zero!
        while(inst_args[2]) memory[inst_args[0]+--inst_args[2]]=0;
      } else if(inst_sargs[2]>0 && inst_args[1]>inst_args[0]) {
        // backward!
        m=inst_sargs[2];
        while(m--) memory[inst_args[1]+m]=memory[inst_args[0]+m];
      } else {
        // forward!
        if(inst_sargs[2]<0) inst_sargs[2]*=-1;
        m=0;
        while(m<inst_sargs[2]) memory[inst_args[1]+m]=memory[inst_args[0]+m],m++;
      }
      break;
    case 0xFE: // Print a rectangle of text
      make_rectangle(inst_args[0],inst_args[1],argc>2?inst_args[2]:1,argc>3?inst_sargs[3]:0);
      // (I assume the skip is signed, since many other things are, and +32768 isn't useful anyways.)
      break;
    case 0xFF: // Check argument count
      branch(frames[frameptr].argc>=*inst_args);
      break;
    default:
      fprintf(stderr,"\n*** Invalid instruction: %02X (near %06X)\n",in,program_counter);
      exit(1);
      break;
  }
}

inline void help(void) {
  puts(
    "Fweep -- a Z-machine interpreter for versions 1 to 10 except 6.\n"
    "Version " VERSION ".\n"
    "This program comes with ABSOLUTELY NO WARRANTY; for details see the\n"
    "COPYING file. This is free software, and you are welcome to\n"
    "redistribute it under certain conditions; see the COPYING file for\n"
    "details.\n"
    "\n"
    "usage: fweep [options] story\n"
    "\n"
    " -a *  = Set auxiliary file.\n"
    " -b    = Break into debugger.\n"
    " -d    = Object and parser debugging.\n"
    " -e *  = Escape code.\n"
    " -g *  = Set screen geometry by rows,columns.\n"
    " -i *  = Set command log file for input.\n"
    " -n    = Enable score notification.\n"
    " -o *  = Set command log file for output.\n"
    " -p    = Assume game disc is not original.\n"
    " -q    = Convert question marks to spaces before lexical analysis.\n"
    " -r *  = Restore save game.\n"
    " -s *  = Set transcript file.\n"
    " -t    = Select Tandy mode.\n"
    " -u    = Disable undo.\n"
    " -v    = Assume the checksum is correct without checking.\n"
  );
}

inline void parse_options(int argc,char**argv) {
  while(argc--) {
    if(**argv=='-') {
      if(optarg[argv[0][1]]) {
        argv++;
        argc--;
        opts[argv[-1][1]]=*argv;
      } else {
        char*p=*argv+1;
        while(*p) opts[*p++]=*argv;
      }
    } else if(**argv) {
      if(story_name) {
        fprintf(stderr,"\n*** You cannot open two story files at once.\n");
        exit(1);
      } else {
        story_name=*argv;
      }
    }
    argv++;
  }
}

void game_begin(void) {
  int i;
  if(!story) story=fopen(story_name,"rb");
  if(!story) {
    fprintf(stderr,"\n*** Unable to load story file: %s\n",story_name);
    exit(1);
  }
  if(opts['a'] && !auxfile) {
    auxfile=fopen(opts['a'],"r+b");
    if(!auxfile) {
      auxfile=fopen(opts['a'],"w+b");
      for(i=0;i<416;i++) fputc(32,auxfile);
      fclose(auxfile);
      auxfile=fopen(opts['a'],"r+b");
    }
    if(!auxfile) {
      fprintf(stderr,"\n*** Unable to create auxiliary file: %s\n",opts['a']);
      exit(1);
    }
  }
  if(opts['s'] && !transcript) transcript=fopen(opts['s'],"wb");
  if(opts['i'] && !inlog) inlog=fopen(opts['i'],"rb");
  if(opts['o'] && !outlog) outlog=fopen(opts['o'],"wb");
  rewind(story);
  fread(memory,64,1,story);
  switch(version) {
    case 1:
      packed_shift=1;
      memory[0x01]=0x10;
      break;
    case 2:
      packed_shift=1;
      memory[0x01]=0x10;
      break;
    case 3:
      packed_shift=1;
      memory[0x01]&=0x8F;
      memory[0x01]|=0x10;
      if(opts['t']) memory[0x01]|=0x08;
      break;
    case 4:
      packed_shift=2;
      memory[0x01]=0x00;
      break;
    case 5:
      packed_shift=2;
      alphabet_table=read16(0x34);
      break;
    case 7:
      packed_shift=2;
      routine_start=read16(0x28)<<3;
      text_start=read16(0x2A)<<3;
      alphabet_table=read16(0x34);
      break;
    case 8:
      packed_shift=3;
      alphabet_table=read16(0x34);
      break;
    case 9:
      packed_shift=3;
      address_shift=1;
      routine_start=read16(0x28)<<3;
      text_start=read16(0x2A)<<3;
      alphabet_table=read16(0x34)<<1;
      break;
    case 10:
      packed_shift=4;
      address_shift=2;
      routine_start=read16(0x28)<<4;
      text_start=read16(0x2A)<<4;
      alphabet_table=read16(0x34)<<2;
      break;
    default: unsupported:
      fprintf(stderr,"\n*** Unsupported Z-machine version: %d\n",version);
      exit(1);
      break;
  }
  restart_address=read16(0x06)<<address_shift;
  dictionary_table=read16(0x08)<<address_shift;
  object_table=read16(0x0A)<<address_shift;
  global_table=read16(0x0C)<<address_shift;
  static_start=read16(0x0E)<<address_shift;
  memory[0x11]&=0x53;
  if(version>1) synonym_table=read16(0x18)<<address_shift;
  if(version>3) {
    memory[0x1E]=opts['t']?11:1;
    memory[0x20]=sc_rows;
    memory[0x21]=sc_columns;
  }
  if(version>4) {
    memory[0x01]=0x10;
    memory[0x23]=sc_columns;
    memory[0x25]=sc_rows;
    memory[0x26]=1;
    memory[0x27]=1;
    memory[0x2C]=2;
    memory[0x2D]=9;
  }
  if(!(memory[2]&128)) write16(0x02,auxfile?0x0A02:0x0802);
  if(opts['b']) break_on=1;
  if(opts['e']) {
    if(opts['e'][0]>='0' && opts['e'][0]<='9') escape_code=strtol(opts['e'],0,0);
    else escape_code=opts['e'][0];
  }
  if(opts['g']) {
    char*p=opts['g'];
    sc_rows=sc_columns=0;
  }
  if(opts['p']) original=0;
  if(opts['u']) {
    allow_undo=0;
    memory[0x11]&=0x43;
  }
  if(opts['v']) verified=1;
  cur_row=2;
  cur_column=0;
  randomize(0);
  putchar('\n');
}

void debugger(void) {
  char buf[128];
  int i,j;
  continuing=0;
  text_flush();
  printf("\n*** Break at $%08X.\n",program_counter);
  for(;;) {
    putchar('*');
    fflush(stdout);
    if(!fgets(buf,128,stdin)) {
      fprintf(stderr,"*** Unable to continue.\n");
      exit(1);
    }
    switch(*buf) {
      case '?':
        puts(
          " a* = Memory dump in ASCII characters\n"
          " b* = Set breakpoint\n"
          " c  = Continue\n"
          " d* = Delete breakpoint\n"
          " e* = Encode text in dictionary format\n"
          " f* = Fetch Z-variable\n"
          " h* = Clear breakpoint of opcode\n"
          " i* = Set breakpoint of opcode\n"
          " j* = Set instruction pointer\n"
          " l  = List breakpoints\n"
          " m  = System data\n"
          " o* = Turn on/off output streams\n"
          " p* = Push to stack\n"
          " q  = Quit\n"
          " r  = Display state of random number generator and ARCFOUR memory\n"
          " r* = Reseed or ask for random number\n"
          " s* = Store to Z-variable from stack\n"
          " u* = Undo and claim: -1=not available, 0=failed, 1=saved, 2=restored\n"
          " w* = Write to memory\n"
          " x* = Exit routine (with result)\n"
          " y* = Memory dump in hex\n"
          " z  = Restart\n"
        );
        break;
      case 'a': // Dump memory with ASCII
        i=strtol(buf+1,0,16)&0x7FFFFFF0;
        printf("........ 0123456789ABCDEF");
        for(j=i;j<i+0x80;j++) {
          if(!(j&15)) printf("\n%08X ",j);
          putchar(memory[j]>=0x20 && memory[j]<0x7F?memory[j]:'.');
        }
        putchar('\n');
        break;
      case 'b': // Set address break
        for(i=0;i<16;i++) {
          if(!address_bkpt[i]) {
            address_bkpt[i]=strtol(buf+1,0,16);
            printf("Breakpoint [%d] set at $%08X.\n",i,address_bkpt[i]);
            break;
          }
        }
        if(i==16) puts("Cannot install any more breakpoints.");
        break;
      case 'c': // Continue
        puts("Continue.");
        continuing=program_counter;
        return;
      case 'd': // Delete address break
        address_bkpt[i=strtol(buf+1,0,0)&15]=0;
        printf("Breakpoint [%d] cleared.\n",i);
        break;
      case 'e': // Encode
        for(i=strlen(buf)-1;buf[i]<33;i--) buf[i]=0;
        printf("Encoded: $%ll016X.\n",dictionary_encode(buf+1,strlen(buf+1)));
        break;
      case 'f': // Fetch
        printf("Fetched: $%04X.\n",fetch(strtol(buf+1,0,0)));
        break;
      case 'h': // Clear instruction break
        instruction_bkpt[i=strtol(buf+1,0,16)]=0;
        printf("Breakpoint clear for opcode $%02X.\n",i);
        break;
      case 'i': // Set instruction break
        instruction_bkpt[i=strtol(buf+1,0,16)]=1;
        printf("Breakpoint set for opcode $%02X.\n",i);
        break;
      case 'j': // Jump
        if(buf[1]) program_counter=strtol(buf+1,0,16);
        printf("Program counter set to $%08X.\n",program_counter);
        lastdebug=1;
        break;
      case 'l': // List breakpoints
        for(i=0;i<16;i++) if(address_bkpt[i]) printf("[%d] $%08X\n",i,address_bkpt[i]);
        for(i=0;i<256;i++) if(instruction_bkpt[i]) printf(".$%02X",i);
        puts(".");
        break;
      case 'm': // System information
        printf("Version: %d\nGlobals: $%08X\nObjects: $%08X\nDictionary: $%08X\n",version,global_table,object_table,dictionary_table);
        printf("Restart: $%08X\nSynonym: $%08X\nAlphabet: $%08X\nRAM size: $%08X\n",restart_address,synonym_table,alphabet_table,static_start);
        printf("Flags: %c%c%c%c%c%c%c%c%c\n",
         original?'o':'-',verified?'v':'-',allow_undo?'u':'-',unpredictable?'-':'p',
         texting?'t':'-',window?'w':'-',buffering?'b':'-',logging?'l':'-',from_log?'f':'-');
        break;
      case 'o': // Set output stream
        switch_output(i=strtol(buf+1,0,0));
        printf("Output stream %d %sabled.\n",i<0?-i:i,i<0?"dis":"en");
        break;
      case 'p': // Push
        stack[stackptr++]=strtol(buf+1,0,0);
        printf("Stack pointer is now %u.\n",stackptr);
        break;
      case 'q': // Quit
        puts("Goodbye.");
        exit(0);
        break;
      case 'r': // Random number generator
        if(buf[1]<34) {
          printf("I=%d J=%d MAX=%d VALUE=%d",arcfour_i,arcfour_j,predictable_max,predictable_value);
          for(i=0;i<256;i++) {
            if(!(i&31)) putchar('\n');
            printf("%02X",arcfour_s[i]);
          }
          putchar('\n');
        } else {
          i=strtol(buf+1,0,0);
          if(i>0) printf("%d\n",get_random(i));
          else randomize(-i),puts("Randomized.");
        }
        break;
      case 's': // Store
        store(strtol(buf+1,0,0),i=stack[--stackptr]);
        printf("Stored: $%04X.\n",i);
        break;
      case 't': // View stack
        j=0;
        for(i=0;i<frameptr;i++) {
          while(j<frames[i].start) printf("$%04X.",stack[j++]);
          printf("\n[Frame %d: Arguments: %d. Return: $%08X.%s]\n",i,frames[i].argc,frames[i].pc,frames[i].stored?" Stored.":"");
        }
        while(j<stackptr) printf("$%04X.",stack[j++]);
        putchar('\n');
        break;
      case 'u': // Undo
        copy_array(frames,u_frames);
        copy_array(stack,u_stack);
        memcpy(memory+0x40,undomem,static_start-0x40);
        frameptr=u_frameptr;
        stackptr=u_stackptr;
        program_counter=u_program_counter;
        storei(strtol(buf+1,0,0));
        puts("Undone.");
        lastdebug=1;
        break;
      case 'w': // Write
        i=strtol(buf+1,0,16);
        for(;;) {
          printf("%08X: ",i);
          if(!fgets(buf,128,stdin)) break;
          if(*buf<'0') break;
          j=0;
          while(buf[j]>='0' && buf[j+1]>='0') {
            memory[i]=(((buf[j]&15)+(buf[j]&0x40?9:0))<<4)|((buf[j]&15)+(buf[j]&0x40?9:0));
            i+=1;
            j+=2;
          }
        }
        break;
      case 'x': // Exit routine
        exit_routine(strtol(buf+1,0,0));
        printf("Program counter is now $%08X.\n",program_counter);
        lastdebug=1;
        break;
      case 'y': // Dump memory
        i=strtol(buf+1,0,16)&0x7FFFFFF0;
        printf("........  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F");
        for(j=i;j<i+0x80;j++) {
          if(!(j&15)) printf("\n%08X ",j);
          printf("%02X ",memory[j]);
        }
        putchar('\n');
        break;
      case 'z': // Restart
        game_restart();
        puts("Restarted.");
        lastdebug=1;
        break;
      default:
        if(*buf>' ') puts("Wrong.");
    }
  }
}

int main(int argc,char**argv) {
  if(argc<2) {
    help();
    return 1;
  }
  parse_options(argc-1,argv+1);
  if(!story_name) {
    help();
    return 1;
  }
  game_begin();
  game_restart();
  if(opts['b']) debugger();
  for(;;) execute_instruction();
}
