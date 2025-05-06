project="chuck"
ISE_HOME=~/Xilinx_ISE/14.7/ISE_DS/ISE

chip=XC9572
package=PC84
speed=7


chipTypeNgd=$chip-$package-$speed
chipTypeFit=$chip-$speed-$package

UNUSED_PIN_OPTION=float
PIN_TERMINATION=float
INTSTYLE=silent
chainLoc=0

xstFile="$project.xst"
syrFile="$project.syr"
ucfFile="$project.ucf"
ngdFile="$project.ngd"
ngcFile="$project.ngc"

BINDIR=$ISE_HOME/bin/lin64

CMD_XST=$BINDIR/xst
CMD_NGD=$BINDIR/ngdbuild
CMD_FIT=$BINDIR/cpldfit
CMD_SIM=$BINDIR/tsim
CMD_TAE=$BINDIR/taengine
CMD_HPR=$BINDIR/hprep6

echo Synthesize
$CMD_XST -intstyle $INTSTYLE -ifn $xstFile -ofn $syrFile || exit 1
echo Translate
$CMD_NGD -intstyle $INTSTYLE -dd _ngo -uc $ucfFile -p $chipTypeNgd $ngcFile $ngdFile || exit 2
echo Fit
$CMD_FIT -intstyle $INTSTYLE -p $chipTypeFit \
	-ofmt vhdl \
	-optimize density \
	-keepio \
	-loc on \
	-slew slow \
	-init low \
	-nomlopt \
	-inputs 36 \
	-pterms 90 \
	-power auto \
	chuck.ngd || exit 3


#$CMD_SIM -intstyle $INTSTYLE chuck chuck.nga || exit 4
#$CMD_TAE -intstyle $INTSTYLE -f chuck -w --format html1 -l timing_report.htm || exit 5

echo Generate JED file
$CMD_HPR -s IEEE1149 -n chuck -i chuck

#xc3sprog  -c xpc -L -v -p 0 chuck.jed
