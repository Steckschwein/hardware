--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:09:56 05/04/2019
-- Design Name:   
-- Module Name:   /home/dommas/steckschwein-code/firmware/chuck/chuck_test.vhd
-- Project Name:  chuck
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: decoder
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use std.env.finish;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY chuck_test IS
END chuck_test;
 
ARCHITECTURE behavior OF chuck_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT chuck
    PORT(
	      RESET 		: IN  	std_logic;
         CLKIN 		: IN  	std_logic;
         CPU_phi2		: OUT  	std_logic;
			CPU_d			: INOUT 	std_logic_vector(7 downto 0);
         CPU_a			: IN  	std_logic_vector(15 downto 0);
			EXT_a			: OUT 	std_logic_vector(18 downto 13);
         CPU_rw 		: IN  	std_logic;
         CPU_rdy		: OUT  	std_logic;
         RD 			: OUT  	std_logic;
         WR 			: OUT  	std_logic;
         CS_ROM 		: OUT  	std_logic;
         CS_RAM 		: OUT 	std_logic;
         CS_UART 		: OUT  	std_logic;
         CS_VIA 		: OUT  	std_logic;
         CSR_VDP 		: OUT  	std_logic;
         CSW_VDP 		: OUT  	std_logic;
         CS_OPL 		: OUT  	std_logic
	--		CS_IO01 		: OUT  	std_logic;
	--		CS_IO02 		: OUT  	std_logic;
	--		CS_IO03 		: OUT  	std_logic;
	--		RD_OPL 		: OUT  	std_logic;
   --     WR_OPL 		: OUT  	std_logic
    );
    END COMPONENT;
    

   --Inputs   
	signal RESET  : std_logic := '0';
   signal CLKIN  : std_logic := '0';
   signal CPU_a  : std_logic_vector(15 downto 0) := (others => '0');
   signal CPU_rw : std_logic := '0';

	--BiDirs
	signal CPU_d : std_logic_vector(7 downto 0) := (others => 'Z');
	
 	--Outputs
	signal EXT_a : std_logic_vector(18 downto 13) := (others => '0');
	signal CPU_rdy : std_logic := 'Z';
   signal CS_ROM : std_logic;
   signal CS_UART : std_logic;
   signal CSR_VDP : std_logic;
	signal CSW_VDP : std_logic;
	signal CS_OPL : std_logic;
   signal CPU_phi2 : std_logic;
   signal RD : std_logic;
   signal WR : std_logic;
   signal CS_RAM : std_logic;
   signal CS_VIA : std_logic;
--	signal RD_OPL : std_logic;
--	signal WR_OPL : std_logic;
--	signal CS_IO01 : std_logic;
--	signal CS_IO02 : std_logic;
--	signal CS_IO03 : std_logic;


   -- Clock period definitions
   constant CLKIN_period : time := 64 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: chuck PORT MAP (
			 RESET => RESET,
          CLKIN => CLKIN,
          CPU_phi2 => CPU_phi2,
			 CPU_d => CPU_d,
          CPU_a => CPU_a,
			 EXT_a => EXT_a,
          CPU_rw => CPU_rw,
          CPU_rdy => CPU_rdy,
          RD => RD,
          WR => WR,
          CS_ROM => CS_ROM,
          CS_RAM => CS_RAM,
          CS_UART => CS_UART,
          CS_VIA => CS_VIA,
          CSR_VDP => CSR_VDP,
          CSW_VDP => CSW_VDP,
  
          CS_OPL => CS_OPL
--			 CS_IO01 => CS_IO01,
--			 CS_IO02 => CS_IO02,
--			 CS_IO03 => CS_IO03,
--			 
--			 RD_OPL => RD_OPL,
--			 WR_OPL => WR_OPL
			 
        );

   -- Clock process definitions
   CLKIN_process :process
   begin
		CLKIN <= '0';
		wait for CLKIN_period/2;
		CLKIN <= '1';
		wait for CLKIN_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		RESET <= '0';
		CPU_rw <= '1';
--		ROMOFF <= '1';	
		CPU_d <= "00000000";

      wait for 100 ns;	
		RESET <= '1';
		
		wait for CLKIN_period/2;

	
      -- insert stimulus here 
		-- hold reset state for 100 ns.
 
		-- Test RAM
		CPU_a <= "0000000000000000";
		wait for CLKIN_period/2;

		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_RAM		= '0' report "CS_RAM not selected" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CSR_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CSW_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CS_OPL		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
	
		wait for CLKIN_period*10;
		
		CPU_a <= "0000000111110000"; -- $01f0
		wait for CLKIN_period/2;

		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_RAM		= '0' report "CS_RAM not selected" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CSR_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CSW_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CS_OPL		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		
		wait for CLKIN_period*10;

		CPU_a <= "0000001010000000"; -- $0280
		wait for CLKIN_period/2;
		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_RAM		= '0' report "CS_RAM not selected" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CSR_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CSW_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CS_OPL		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		
		wait for CLKIN_period*10;


		CPU_a <= "0000011111110000"; -- $07f0
		wait for CLKIN_period/2;
		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_RAM		= '0' report "CS_LORAM not selected" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CSR_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CSW_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CS_OPL		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;

		wait for CLKIN_period*10;
	

		report "Test IO area";
		report "1. Select UART ($0200)";
		-- Test IO area	
		-- Select UART ($0200)
		CPU_a <= "0000001000000000";
		wait for CLKIN_period/2;
		assert CS_UART	 	= '0' report "UART not selected" severity error;
		assert CS_RAM		= '1' report "CS_RAM selected but should not" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CSR_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CSW_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CS_OPL		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;

		wait for CLKIN_period*10;
		
		-- select VIA ($0210)
		report "2. select VIA ($0210)";

		CPU_a <= "0000001000010000";
		wait for CLKIN_period/2;

		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_VIA		= '0' report "CS_VIA not selected" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_RAM		= '1' report "CS_RAM selected but should not" severity error;
		assert CSR_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CSW_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CS_OPL		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
	
		wait for CLKIN_period*10;
		
		-- select VDP ($0220), read
		report "3. select VDP ($0220), read";

		CPU_a <= "0000001000100000";
		CPU_rw <= '1';
		wait for CLKIN_period/2;

		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CSR_VDP		= '0' report "CSR_VDP not selected " severity error;
		assert CSW_VDP		= '1' report "CSW_VDP selected but should not" severity error;
		assert CS_OPL		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_RAM		= '1' report "CS_RAM selected but should not" severity error;
		
		wait for CLKIN_period*10;

		-- select VDP ($0220), write
		report "4. select VDP ($0220), write";
		CPU_a	<= "0000001000100000";
		CPU_rw <= '0';
		wait for CLKIN_period/2;

		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CSR_VDP		= '1' report "CSR_VDP selected but should not" severity error;
		assert CSW_VDP		= '0' report "CSW_VDP not selected" severity error;
		assert CS_OPL		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_RAM		= '1' report "CS_RAM selected but should not" severity error;
		
		wait for CLKIN_period*10;

		-- select CS_OPL ($0240)
		report "5. select CS_OPL ($0240)";

		CPU_a <= "0000001001000000";
		wait for CLKIN_period/2;

		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CSR_VDP		= '1' report "CS_VDP  selected but should not" severity error;
		assert CSW_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CS_OPL		= '0' report "CS_IO not selected" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_RAM		= '1' report "CS_RAM selected but should not" severity error;
		
		wait for CLKIN_period*10;
		
	
		-- test CS_RAM, CS_ROM
		-- read from $e000
		report "6. read from $e000 - test CS_RAM, CS_ROM";

		CPU_rw			<= '1'; -- reading
		CPU_a 			<= "1110000000000000" ;-- $E000
		wait for CLKIN_period/2;
		assert CS_ROM	= '0' report "CS_ROM not selectedX" severity error;
		assert CS_RAM	= '1' report "CS_RAM selected but should notY" severity error;

		wait for CLKIN_period*10;
		
		report "7. write $04 to $0203, reconfigure slot 3";

	
		CPU_a <= X"0233";
		CPU_d <= X"04";
		CPU_rw <= '0'; -- writing
		wait for CLKIN_period*2;
		CPU_rw <= '1'; -- reading
		
--		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
--		assert CS_RAM	= '0' report "CS_RAM not selected" severity error;

		wait for CLKIN_period*10;

		report "6. read from $e000 - test CS_RAM, CS_ROM";
	
		CPU_a 			<= "1110000000000000" ;-- $E000
		wait for CLKIN_period/10;
		assert CS_RAM	= '0' report "CS_RAM not selected" severity error;
		assert CS_ROM	= '1' report "CS_ROM selected but should not" severity error;
	
		
		finish;
		
		
		-- test CS_RAM, CS_ROM
		-- write to $e000
		report "8. write to $e000";
		CPU_rw			<= '0'; -- writing
		CPU_a		<= "1110000000000000" ;-- $E000
		wait for CLKIN_period/2;
		assert CS_ROM		= '1' 	report "CS_ROM selected but should not" severity error;
		assert CS_RAM		= '0' 	report "CS_RAM not selected $E000" severity error;	

		wait for CLKIN_period*10;

		-- read from $f000
		CPU_rw			<= '1'; -- reading
		CPU_a 			<= "1111000000000000" ;-- $F000
		wait for CLKIN_period/2;
		assert CS_ROM		= '0' 	report "CS_ROM not selected" severity error;
		assert CS_RAM		= '1' 	report "CS_RAM selected but should not" severity error;

		finish;
		wait for CLKIN_period*10;
	
		-- test CS_RAM, CS_ROM, ROMOFF
		-- write to $f000
		report "9. write to $f000";

		CPU_rw			<= '0'; -- writing
		CPU_a 			<= "1111000000000000" ;-- $F000
		wait for CLKIN_period/2;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_RAM		= '0' report "CS_RAM not selected" severity error;	

		report "10. write $01 to $0230, enable ROMOFF";
	
		CPU_rw			<= '0';
		CPU_a 		   <= "0000001000110000";
		CPU_d        <= "00000001";

		wait for CLKIN_period;


		CPU_a 			<= "1111000000000000" ;-- $F000
		CPU_rw			<= '1'; -- read
		wait for CLKIN_period;

		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_RAM		= '0' report "CS_RAM not selected" severity error;

		wait for CLKIN_period*10;

		CPU_a			<= "1110000000000001" ;-- $e001
		CPU_rw			<= '1'; -- read
		wait for CLKIN_period;

		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_RAM		= '0' report "CS_RAM not selected" severity error;

		wait for CLKIN_period*10;
		
		report "11. write $06 to $0230, disable ROMOFF";
	
		CPU_rw			<= '0';
		CPU_a		   <= "0000001000110000";
		CPU_d        <= "00000110";

		wait for CLKIN_period;
		
		CPU_a	<= "1110000000000001" ;-- $e001
		CPU_rw			<= '1'; -- read
		wait for CLKIN_period;
	
		assert CS_ROM		= '0' report "CS_ROM not selected" severity error;
		assert CS_RAM		= '1' report "CS_RAM selected but should not" severity error;
	
		
		wait for CLKIN_period*10;
		
		report "12. read from $0230";
		CPU_rw	<= '1'; -- read
		CPU_a   <= "0000001000110000";
	
		wait for CLKIN_period;
		
		assert CPU_d		= "00000110" report "register read failed" severity error;
	
		
		wait for CLKIN_period*10;
		
		wait for CLKIN_period*10;
		
		report "13. write $06 to $0230, disable ROMOFF";
	
		CPU_rw			<= '0';
		CPU_a   <= "0000001000110000";
		CPU_d   <= "00111001";

		wait for CLKIN_period;
	
		

	
		
		
		
		finish;
   end process;

END;
