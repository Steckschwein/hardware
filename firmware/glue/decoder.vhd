library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

Entity decoder is
	Port (
		-- system clock
		CLKIN		 : in std_logic;
		PHI2OUT	 : out std_logic;
		
		-- address bus
		A			 : in std_logic_vector (11 downto 0);	-- Address bus upper 12 std_logics
		
		-- data bus
--		D			 : inout std_logic_vector (3 downto 0); -- data bus lower 4 bits
		
		-- control signals
		RESET     : in std_logic;  -- reset line
		RW        : in std_logic;  -- RW pin of 6502
		ROMOFF    : in std_logic;  -- switch off rom from address space, make underlying RAM readable
		RDY		 : inout std_logic; -- RDY signal for generating wait states
		RD			 : out std_logic; -- read access
		WR			 : out std_logic; -- write access
		
		-- chip select for memory
		CS_ROM    : inout std_logic; -- CS signal for ROM at $e000-$ffff 
		CS_LORAM  : out std_logic; -- CS for ram between  $0000-$7fff
		CS_HIRAM  : out std_logic; -- CS for ram between  $8000-$cfff

		-- chip select for peripherals
		CS_UART   : inout std_logic;  -- 6551 ACIA   at $d000 ?!?
		CS_VIA    : out std_logic;  -- 6522 VIA    at $d100
		CS_VDP    : inout std_logic;  -- VDP 
		MEMCTL    : out std_logic;  -- MEMCTL, control latch at $0230
		CS_IO   	 : inout std_logic  -- 4xIO at $240-$27f
	);

end;

Architecture decoder_arch of decoder is
	signal clk: std_logic;
	signal rdyclk: STD_LOGIC;
begin
	
	frequency_divider: process (RESET, CLKIN) begin
	  if (RESET = '0') then
			clk <= '0';
		elsif rising_edge(CLKIN) then
			clk <= not(clk);
	  end if;
	end process;
   PHI2OUT <= clk;
	RD 			<= RW nand clk;
	WR 			<= not RW nand clk;

	
	rdygen: process(RESET, clk, rdyclk)
	begin
		if (RESET = '0') then
			rdyclk <= '0';
		elsif rising_edge(clk) then
			rdyclk <= not rdyclk;
		end if;
		--sigrdy <= ((not rdyclk) and (not CS_ROM or not CS_IO or not CS_VDP));
	end process;
	RDY			<= '0' when (rdyclk = '1' and (CS_ROM = '0' or CS_IO = '0' or CS_VDP = '0') ) else 'Z';
	--RDY <= rdyclk;
	
--decoder: process(A, RW, ROMOFF)
--begin
	CS_ROM	  	<= '0' when (ROMOFF = '0') and (RW = '1') and (A(11 downto 9) = "111") else '1';
	CS_LORAM   	<= '1' when (A(11) = '1')
								or (A(10) = '0' 
								and A(9) = '0' 
								and A(8) = '0' 
								and A(7) = '0' 
								and A(6) = '0'
								and A(5) = '1'
								and A(4) = '0'
								and A(3) = '0')
								else '0';
								
								--or (A = "-00000100---") else '0';	

	--CS_HIRAM   	<= '0' when (A = "1-0---------")
	--							or --((A(11 downto 10) = "10"))
	--								(A = "10----------")
	--							or ((RW = '0') and (A = "111---------"))			-- Writes to $e000-$ffff go to the RAM
	--							--or ((RW = '0') and (A(11 downto 9) = "111"))			-- Writes to $e000-$ffff go to the RAM						
	--							or ((ROMOFF = '1') and (RW = '1') and (A(11 downto 9) = "111"))	-- Reads to $e000-$ffff go to the ROM or to RAM when ROMOFF is low
	--						 else '1';	

	CS_HIRAM   	<= '0' when (A(11) = '1' and A(9) = '0')
								or ((A(11 downto 10) = "10"))
								or ((RW = '0') and (A(11 downto 9) = "111"))			-- Writes to $e000-$ffff go to the RAM						
								or ((ROMOFF = '1') and (RW = '1') and (A(11 downto 9) = "111"))	-- Reads to $e000-$ffff go to the ROM or to RAM when ROMOFF is low
							 else '1';	


	CS_UART    	<= '0' when (A = "000000100000") else '1'; 	-- $0200		
	CS_VIA     	<= '0' when (A = "000000100001") else '1'; 	-- $0210
	CS_VDP		<= '0' when (A = "000000100010") else '1'; 	-- $0220	
	MEMCTL		<= '0' when (A = "000000100011") else '1'; 	-- $0230
	CS_IO			<= '0' when (A = "000000100100") 				-- $0240 
								or (A = "000000100101") 				-- $0250
								or (A = "000000100110") 				-- $0260
								or (A = "000000100111") 				-- $0270
							 else '1'; 



End decoder_arch;
