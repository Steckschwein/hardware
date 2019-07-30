--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:09:56 05/04/2019
-- Design Name:   
-- Module Name:   /home/dommas/steckschwein-code/firmware/glue/decoder_test.vhd
-- Project Name:  glue
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
 
ENTITY decoder_test IS
END decoder_test;
 
ARCHITECTURE behavior OF decoder_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT decoder
    PORT(
	      RESET : IN  std_logic;
    
         CLKIN : IN  std_logic;
         PHI2OUT : OUT  std_logic;
         A : IN  std_logic_vector(15 downto 0);
			AO : INOUT std_logic_vector(18 downto 13);
         RW : IN  std_logic;
         RDY : INOUT  std_logic;
         RD : OUT  std_logic;
         WR : OUT  std_logic;
         CS_ROM : INOUT  std_logic;
         CS_RAM : INOUT  std_logic;
         CS_UART : INOUT  std_logic;
         CS_VIA : INOUT  std_logic;
         CSR_VDP : INOUT  std_logic;
         CSW_VDP : INOUT  std_logic;
         CS_OPL : INOUT  std_logic;
			RD_OPL : OUT  std_logic;
         WR_OPL : OUT  std_logic

        );
    END COMPONENT;
    

   --Inputs   
	signal RESET : std_logic := '0';
   signal CLKIN : std_logic := '0';
   signal A : std_logic_vector(15 downto 0) := (others => '0');
   signal RW : std_logic := '0';

	--BiDirs
   signal RDY : std_logic := 'Z';
   signal CS_ROM : std_logic;
   signal CS_UART : std_logic;
   signal CSR_VDP : std_logic;
	signal CSW_VDP : std_logic;
	signal CS_OPL : std_logic;
  
	
 	--Outputs
	signal AO : std_logic_vector(18 downto 13) := (others => '0');

   signal PHI2OUT : std_logic;
   signal RD : std_logic;
   signal WR : std_logic;
   signal CS_RAM : std_logic;
   signal CS_VIA : std_logic;
	signal RD_OPL : std_logic;
	signal WR_OPL : std_logic;


   -- Clock period definitions
   constant CLKIN_period : time := 64 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: decoder PORT MAP (
			 RESET => RESET,
          CLKIN => CLKIN,
          PHI2OUT => PHI2OUT,
          A => A,
			 AO => AO,
          RW => RW,
          RDY => RDY,
          RD => RD,
          WR => WR,
          CS_ROM => CS_ROM,
          CS_RAM => CS_RAM,
          CS_UART => CS_UART,
          CS_VIA => CS_VIA,
          CSR_VDP => CSR_VDP,
          CSW_VDP => CSW_VDP,
  
          CS_OPL => CS_OPL,
			 RD_OPL => RD_OPL,
			 WR_OPL => WR_OPL
			 
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
		RW <= '1';
--		ROMOFF <= '1';
		
      wait for 100 ns;	
		RESET <= '1';
		
		wait for CLKIN_period/2;

      -- wait for CLKIN_period*10;

      -- insert stimulus here 
		-- hold reset state for 100 ns.
 
		-- Test RAM
		A <= "0000000000000000";
		wait for CLKIN_period/2;

		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_RAM		= '0' report "CS_RAM not selected" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CSR_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CSW_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CS_OPL		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
	
		wait for CLKIN_period*10;

		
		A <= "0000000111110000"; -- $01f0
		wait for CLKIN_period/2;

		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_RAM		= '0' report "CS_RAM not selected" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CSR_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CSW_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CS_OPL		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		
		wait for CLKIN_period*10;

		A <= "0000001010000000"; -- $0280
		wait for CLKIN_period/2;
		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_RAM		= '0' report "CS_LORAM not selected" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CSR_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CSW_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CS_OPL		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		
		wait for CLKIN_period*10;


		A <= "0000011111110000"; -- $07f0
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
		A <= "0000001000000000";
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

		A <= "0000001000010000";
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

		A <= "0000001000100000";
		RW <= '1';
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
		A	<= "0000001000100000";
		RW <= '0';
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

		A <= "0000001001000000";
		wait for CLKIN_period/2;

		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CSR_VDP		= '1' report "CS_VDP  selected but should not" severity error;
		assert CSW_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert CS_OPL		= '0' report "CS_IO not selected" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_RAM		= '1' report "CS_RAM selected but should not" severity error;
		
		wait for CLKIN_period*10;

		-- test CS_RAM, CS_ROM, ROMOFF
		-- read from $e000, ROMOFF = 0
		report "test CS_RAM, CS_ROM, ROMOFF";
		report "7. test CS_RAM, CS_ROM";

		RW			<= '1'; -- reading
		--ROMOFF 	<= '0'; -- ROM is on
		A 			<= "1110000000000000" ;-- $E000
		wait for CLKIN_period/2;
		assert CS_ROM	= '0' report "CS_ROM not selectedX" severity error;
		assert CS_RAM	= '1' report "CS_RAM selected but should notY" severity error;

		wait for CLKIN_period*10;

--		ROMOFF 	<= '1';
--		wait for CLKIN_period/2;
--		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
--		assert CS_RAM	= '0' report "CS_RAM not selected" severity error;

		wait for CLKIN_period*10;
	
		-- test CS_RAM, CS_ROM, ROMOFF
		-- write to $e000, ROMOFF = 0
		report "8. write to $e000";
		RW			<= '0'; -- writing
--		ROMOFF 	<= '0'; -- ROM is ON
		A 			<= "1110000000000000" ;-- $E000
		wait for CLKIN_period/2;
		assert CS_ROM		= '1' 	report "CS_ROM selected but should not" severity error;
		assert CS_RAM		= '0' 	report "CS_RAM not selected $E000" severity error;	

		wait for CLKIN_period*10;

		-- read from $f000, ROMOFF = 0
		RW			<= '1'; -- reading
		--ROMOFF 	<= '0'; -- ROM is on
		A 			<= "1111000000000000" ;-- $F000
--		wait for CLKIN_period/2;
--		assert CS_ROM		= '0' 	report "CS_ROM not selected" severity error;
--		assert CS_RAM		= '1' 	report "CS_RAM selected but should not" severity error;

--		wait for CLKIN_period*10;

--		ROMOFF 	<= '1';
--		wait for CLKIN_period/2;
--		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
--		assert CS_RAM	= '0' report "CS_RAM not selected" severity error;

--		wait for CLKIN_period*10;
	
		-- test CS_RAM, CS_ROM, ROMOFF
		-- write to $f000, ROMOFF = 0
		report "9. write to $f000";

		RW			<= '0'; -- writing
--		ROMOFF 	<= '0'; -- ROM is ON
		A 			<= "1111000000000000" ;-- $F000
		wait for CLKIN_period/2;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_RAM	= '0' report "CS_RAM not selected" severity error;	

	
		
		finish;
   end process;

END;
