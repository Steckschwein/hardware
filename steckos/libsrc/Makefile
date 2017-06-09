TARGET=steckschwein-kernel
TARGET_SYS=none
	
.PHONY: all mostlyclean clean install zip lib $(TARGET)

.SUFFIXES:

ifdef CMD_EXE
  DIRLIST = $(strip $(foreach dir,$1,$(wildcard $(dir))))
  MKDIR = mkdir $(subst /,\,$1)
  RMDIR = $(if $(DIRLIST),rmdir /s /q $(subst /,\,$(DIRLIST)))
else
  MKDIR = mkdir -p $1
  RMDIR = $(RM) -r $1
endif

# Every target requires its individual vpath setting but the vpath directive
# acts globally. Therefore each target is built in a separate make instance.

ifeq ($(words $(MAKECMDGOALS)),1)
  ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),$(TARGETS)))
    TARGET = $(MAKECMDGOALS)
  endif
endif


all: ../lib/$(TARGET).lib

clean:
	rm -f ../lib/$(TARGET).lib
	$(call RMDIR,../libwrk)

mostlyclean:
	$(call RMDIR,../libwrk)


CA65FLAGS =
CC65FLAGS = -Or -W error

SRCDIR=.
SRCDIRS = $(SRCDIR)
SRCDIRS +=  t99xx
SRCDIRS +=  $(CC65_HOME)/libsrc/conio     	\
			$(CC65_HOME)/libsrc/runtime	 	\
			$(CC65_HOME)/libsrc/zlib		\
			$(CC65_HOME)/libsrc/common	 
	#		$(CC65_HOME)/libsrc/serial   \
	#		$(CC65_HOME)/libsrc/tgi      \
#            $(CC65_HOME)/libsrc/dbg      \
 #           $(CC65_HOME)/libsrc/em       \
  #          $(CC65_HOME)/libsrc/joystick \
   #         $(CC65_HOME)/libsrc/mouse    \

vpath %.s $(SRCDIRS)
vpath %.c $(SRCDIRS) 

OBJS := $(patsubst %.s,%.o,$(foreach dir,$(SRCDIRS),$(wildcard $(dir)/*.s)))
OBJS += $(patsubst %.c,%.o,$(foreach dir,$(SRCDIRS),$(wildcard $(dir)/*.c)))

OBJS := $(addprefix ../libwrk/$(TARGET)/,$(sort $(notdir $(OBJS))))
	
DEPS = $(OBJS:.o=.d) 

AR65 := $(if $(wildcard ../bin/ar65*),../bin/ar65,ar65)
CA65 := $(if $(wildcard ../bin/ca65*),../bin/ca65,ca65)
CC65 := $(if $(wildcard ../bin/cc65*),../bin/cc65,cc65)
LD65 := $(if $(wildcard ../bin/ld65*),../bin/ld65,ld65)

export CC65_HOME := $(abspath ..)

define ASSEMBLE_recipe
$(if $(QUIET),,@echo $(TARGET) - $<)
@$(CA65) -t $(TARGET_SYS) --cpu 65c02 $(CA65FLAGS) --create-dep $(@:.o=.d) -o $@ $<
endef # ASSEMBLE_recipe

define COMPILE_recipe
$(if $(QUIET),,@echo $(TARGET) - $<)
@$(CC65) -t $(TARGET_SYS) $(CC65FLAGS) --create-dep $(@:.o=.d) --dep-target $@ -o $(@:.o=.s) $<
@$(CA65) -t $(TARGET_SYS) -o $@ $(@:.o=.s)
endef # COMPILE_recipe

../libwrk/$(TARGET)/%.o: %.s | ../libwrk/$(TARGET)
	$(ASSEMBLE_recipe)

../libwrk/$(TARGET)/%.o: %.c | ../libwrk/$(TARGET)
	$(COMPILE_recipe)
	
../lib/$(TARGET).lib: $(OBJS) | ../lib
	$(AR65) a $@ $?

../libwrk/$(TARGET) ../lib ../target/$(TARGET)/util:
	@$(call MKDIR,$@)

-include $(DEPS)

# TODO design fdtable.o 
#kernel-lib: $(OBJS) crt0.o mainargs.o cputc.o cgetc.o gotoxy.o clrscr.o kbhit.o spi.o rtc.o sysuname.o systime.o oserror.o open.o read.o close.o inviocb.o do_oserr.o sysremove.o sysrename.o closedir.o write.o dir.o seekdir.o rewinddir.o telldir.o opendir.o initcwd.o
#	$(AR65) a ../lib/steckschwein-kernel.lib \
#			zeropage.o pushax.o	\
#			crt0.o cputc.o cgetc.o gotoxy.o clrscr.o spi.o rtc.o kbhit.o mainargs.o sysuname.o systime.o oserror.o open.o read.o close.o inviocb.o do_oserr.o sysremove.o sysrename.o closedir.o write.o dir.o seekdir.o rewinddir.o telldir.o opendir.o initcwd.o
#steckschwein: ../lib/$(TARGET).lib
#	$(AR65) a ../lib/steckschwein-kernel.lib $(OBJS)

gfx-lib: zeropage.o t99xx/t99xx.o t99xx/mode3.o t99xx/mode2.o t99xx/mode1.o t99xx/mode_mc.o
	$(AR65) a ../lib/steckschwein-gfx.lib zeropage.o \
		t99xx/t99xx.o \
		t99xx/mode3.o \
		t99xx/mode2.o \
		t99xx/mode1.o \
		t99xx/mode_mc.o