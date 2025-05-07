project=chuck
ISE_HOME=~/Xilinx_ISE/14.7/ISE_DS/ISE

chip=XC9572
package=PC84
speed=7

FIT_OPTIONS=-ofmt vhdl
FIT_OPTIONS+=-optimize density 
FIT_OPTIONS+=-keepio 
FIT_OPTIONS+=-loc on 
FIT_OPTIONS+=-slew slow 
FIT_OPTIONS+=-init low 
FIT_OPTIONS+=-nomlopt 
#FIT_OPTIONS+=-inputs 36
#FIT_OPTIONS+=-pterms 90 
FIT_OPTIONS+=-power auto 
FIT_OPTIONS+=-wysiwyg

#UNUSED_PIN_OPTION=float
#PIN_TERMINATION=float
#INTSTYLE=ise
INTSTYLE=silent

#chainLoc=0

xstFile=$(project).xst
syrFile=$(project).syr
ucfFile=$(project).ucf
ngdFile=$(project).ngd
ngcFile=$(project).ngc

BINDIR=$(ISE_HOME)/bin/lin64

CMD_XST=$(BINDIR)/xst
CMD_NGD=$(BINDIR)/ngdbuild
CMD_FIT=$(BINDIR)/cpldfit
CMD_SIM=$(BINDIR)/tsim
CMD_TAE=$(BINDIR)/taengine
CMD_HPR=$(BINDIR)/hprep6
CMD_IMP=$(BINDIR)/impact


.PHONY: all clean prog

all: $(project).jed 


%.ngc: 
	$(CMD_XST) -intstyle $(INTSTYLE) -ifn $(xstFile) -ofn $(syrFile) $<

%.ngd: %.ngc
	$(CMD_NGD) -intstyle $(INTSTYLE) -dd _ngo -uc $(ucfFile) -p $(chip)-$(package)-$(speed) $< $@

%.vm6: %.ngd
	$(CMD_FIT) -intstyle $(INTSTYLE) -p $(chip)-$(speed)-$(package) $(FIT_OPTIONS) $<

%.nga: 
	$(CMD_SIM) -intstyle $(INTSTYLE) $(project) $@

%.jed: %.vm6 %.vhd 
	$(CMD_HPR) -s IEEE1149 -n $(project) -i $<

prog: all
	$(CMD_IMP) -batch impact.cmd 

clean:
	rm -f *.bld *.gyd *.lso *.mfd *.ng? *.pad *.pnx *.rpt *.vm6 *.syr *.xml *_ngdbuild.xrpt *_pad.csv *_xst.xrpt *.jed tmperr.err *.log
	rm -rf _ngo xlnx_auto_0_xdb _xmsgs xst
