#!/usr/bin/env python -u 

import py65.monitor

class AsmunitMonitor(py65.monitor.Monitor):

    def _install_mpu_observers(self, getc_addr, putc_addr):
        #print("_install_mpu_observers()")
        instrument_addr = 0x0202
		  
        super(AsmunitMonitor, self)._install_mpu_observers(getc_addr, putc_addr)
        def writeCycles(address, cycles):
           #self.stdout.write("\nwriteCycles: %x %x\n" % (self._mpu.processorCycles, cycles))
           self._mpu.memory[instrument_addr+1] = cycles>>24 & 0xff				
           self._mpu.memory[instrument_addr+2] = cycles>>16 & 0xff
           self._mpu.memory[instrument_addr+3] = cycles>>8 & 0xff
           self._mpu.memory[instrument_addr+4] = cycles & 0xff
        def resetCycles(address, value):
           writeCycles(address, self._mpu.processorCycles);
        def readCycles(address):
           cycles = self._mpu.memory[instrument_addr+1]<<24 | self._mpu.memory[instrument_addr+2]<<16 | self._mpu.memory[instrument_addr+3]<<8 | self._mpu.memory[instrument_addr+4]
           cycles += 0x04 # adjust cl with cycles from assertCycles macro in asmunit.inc
           delta_cl = self._mpu.processorCycles-cycles
           writeCycles(address, delta_cl);
           return delta_cl
        self._mpu.memory.subscribe_to_write([instrument_addr], resetCycles)
        self._mpu.memory.subscribe_to_read([instrument_addr], readCycles)

def main(args=None):
    mon = AsmunitMonitor(args)
    try:
        import readline
        readline = readline  # pyflakes
    except ImportError:
        pass

    try:
        mon.cmdloop()
    except KeyboardInterrupt:
        mon._output('')
	 
	 
if __name__ == "__main__":
    main()