setmode -bscan 
setcable -p usb1 

#identify
addDevice -p 1 -file "chuck.jed"
program -p 1 -e -v
quit