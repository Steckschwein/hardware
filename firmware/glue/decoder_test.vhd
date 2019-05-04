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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY decoder_test IS
END decoder_test;
 
ARCHITECTURE behavior OF decoder_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT decoder
    PORT(
         CLKIN : IN  std_logic;
         PHI2OUT : OUT  std_logic;
         A : IN  std_logic_vector(11 downto 0);
         RW : IN  std_logic;
         ROMOFF : IN  std_logic;
         RDY : INOUT  std_logic;
         RD : OUT  std_logic;
         WR : OUT  std_logic;
         CS_ROM : INOUT  std_logic;
         CS_LORAM : OUT  std_logic;
         CS_HIRAM : OUT  std_logic;
         CS_UART : INOUT  std_logic;
         CS_VIA : OUT  std_logic;
         CS_VDP : INOUT  std_logic;
         MEMCTL : OUT  std_logic;
         CS_IO : INOUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLKIN : std_logic := '0';
   signal A : std_logic_vector(11 downto 0) := (others => '0');
   signal RW : std_logic := '0';
   signal ROMOFF : std_logic := '0';

	--BiDirs
   signal RDY : std_logic;
   signal CS_ROM : std_logic;
   signal CS_UART : std_logic;
   signal CS_VDP : std_logic;
   signal CS_IO : std_logic;

 	--Outputs
   signal PHI2OUT : std_logic;
   signal RD : std_logic;
   signal WR : std_logic;
   signal CS_LORAM : std_logic;
   signal CS_HIRAM : std_logic;
   signal CS_VIA : std_logic;
   signal MEMCTL : std_logic;

   -- Clock period definitions
   constant CLKIN_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: decoder PORT MAP (
          CLKIN => CLKIN,
          PHI2OUT => PHI2OUT,
          A => A,
          RW => RW,
          ROMOFF => ROMOFF,
          RDY => RDY,
          RD => RD,
          WR => WR,
          CS_ROM => CS_ROM,
          CS_LORAM => CS_LORAM,
          CS_HIRAM => CS_HIRAM,
          CS_UART => CS_UART,
          CS_VIA => CS_VIA,
          CS_VDP => CS_VDP,
          MEMCTL => MEMCTL,
          CS_IO => CS_IO
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
      wait for 100 ns;	

      wait for CLKIN_period*10;

      -- insert stimulus here 
		-- hold reset state for 100 ns.
 
		-- Test LORAM
		A <= "000000000000";
		wait for CLKIN_period/2;

		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_LORAM	= '0' report "CS_LORAM not selected" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CS_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert MEMCTL		= '1' report "MEMCTL selected but should not" severity error;
		assert CS_IO		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_HIRAM	= '1' report "CS_HIRAM selected but should not" severity error;

		A <= "000000011111"; -- $01f0
		wait for 10 ns;
		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_LORAM	= '0' report "CS_LORAM not selected" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CS_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert MEMCTL		= '1' report "MEMCTL selected but should not" severity error;
		assert CS_IO		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_HIRAM	= '1' report "CS_HIRAM selected but should not" severity error;

		A <= "000000101000"; -- $0280
		wait for 10 ns;
		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_LORAM	= '0' report "CS_LORAM not selected" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CS_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert MEMCTL		= '1' report "MEMCTL selected but should not" severity error;
		assert CS_IO		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_HIRAM	= '1' report "CS_HIRAM selected but should not" severity error;

		A <= "000001111111"; -- $07f0
		wait for 10 ns;
		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_LORAM	= '0' report "CS_LORAM not selected" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CS_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert MEMCTL		= '1' report "MEMCTL selected but should not" severity error;
		assert CS_IO		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_HIRAM	= '1' report "CS_HIRAM selected but should not" severity error;


		-- Test IO area	
		-- Select UART ($0200)
		A <= "000000100000";
		wait for 10 ns;
		assert CS_UART	 	= '0' report "UART not selected" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CS_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert MEMCTL		= '1' report "MEMCTL selected but should not" severity error;
		assert CS_IO		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_HIRAM	= '1' report "CS_HIRAM selected but should not" severity error;
		assert CS_LORAM	= '1' report "CS_LORAM selected but should not" severity error;

		wait for CLKIN_period*10;
		
		-- select VIA ($0210)
		A <= "000000100001";
		wait for 10 ns;

		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_VIA		= '0' report "CS_VIA not selected" severity error;
		assert CS_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert MEMCTL		= '1' report "MEMCTL selected but should not" severity error;
		assert CS_IO		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_HIRAM	= '1' report "CS_HIRAM selected but should not" severity error;
		assert CS_LORAM	= '1' report "CS_LORAM selected but should not" severity error;
		
		wait for CLKIN_period*10;
		
		-- select VDP ($0220)
		A <= "000000100010";
		wait for 10 ns;

		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CS_VDP		= '0' report "CS_VDP not selected" severity error;
		assert MEMCTL		= '1' report "MEMCTL selected but should not" severity error;
		assert CS_IO		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_HIRAM	= '1' report "CS_HIRAM selected but should not" severity error;
		assert CS_LORAM	= '1' report "CS_LORAM selected but should not" severity error;

		wait for CLKIN_period*10;
		
		-- select MEMCTL ($0230)
		A <= "000000100011";
		wait for 10 ns;

		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CS_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert MEMCTL		= '0' report "MEMCTL not selected" severity error;
		assert CS_IO		= '1' report "CS_IO selected but should not" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_HIRAM	= '1' report "CS_HIRAM selected but should not" severity error;
		assert CS_LORAM	= '1' report "CS_LORAM selected but should not" severity error;
	
		wait for CLKIN_period*10;
		
		-- select CS_IO ($0240)
		A <= "000000100100";
		wait for 10 ns;

		assert CS_UART	 	= '1' report "UART selected but should not" severity error;
		assert CS_VIA		= '1' report "CS_VIA selected but should not" severity error;
		assert CS_VDP		= '1' report "CS_VDP selected but should not" severity error;
		assert MEMCTL		= '1' report "MEMCTL selected but should not" severity error;
		assert CS_IO		= '0' report "CS_IO not selected" severity error;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_HIRAM	= '1' report "CS_HIRAM selected but should not" severity error;
		assert CS_LORAM	= '1' report "CS_LORAM selected but should not" severity error;

		-- test CS_HIRAM, CS_ROM, ROMOFF
		ROMOFF 	<= '0';
		A 			<= "111000000000" ;-- $E000
		wait for 10 ns;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_HIRAM	= '0' report "CS_HIRAM not selected" severity error;

		ROMOFF 	<= '1';
		wait for 10 ns;
		assert CS_ROM		= '0' report "CS_ROM not selected " severity error;
		assert CS_HIRAM	= '1' report "CS_HIRAM selected but should not" severity error;
		
		-- test CS_HIRAM, CS_ROM, ROMOFF
		ROMOFF 	<= '0';
		A 			<= "111100000000" ;-- $F000
		wait for 10 ns;
		assert CS_ROM		= '1' report "CS_ROM selected but should not" severity error;
		assert CS_HIRAM	= '0' report "CS_HIRAM not selected" severity error;

		ROMOFF 	<= '1';
		wait for 10 ns;
		assert CS_ROM		= '0' report "CS_ROM not selected " severity error;
		assert CS_HIRAM	= '1' report "CS_HIRAM selected but should not" severity error;

    
    

      wait;
   end process;

END;
