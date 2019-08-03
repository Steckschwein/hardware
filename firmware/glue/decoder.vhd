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
		A			 : in std_logic_vector (15 downto 0);	-- Address bus 
		AO			 : out std_logic_vector(18 downto 13);   -- extended address bus AO13-AO18
		
		-- data bus
		D			 : inout std_logic_vector (7 downto 0); -- data bus lower 4 bits
		
		-- control signals
		RESET     : in std_logic;  	-- reset line
		RW        : in std_logic;  	-- RW pin of 6502
		RDY		 : out std_logic; 	-- RDY signal for generating wait states
		RD			 : out std_logic; 	-- read access
		WR			 : out std_logic; 	-- write access
		
		-- chip select for memory
		CS_ROM    : out std_logic; 	-- CS signal for ROM at $e000-$ffff 
		CS_RAM  	 : out std_logic; 	-- CS for ram 
		
		-- chip select for peripherals
		CS_UART   : out std_logic;  	
		CS_VIA    : out std_logic;  	
		CSR_VDP   : out std_logic;  -- VDP read
		CSW_VDP   : out std_logic;  -- VDP write
		CS_OPL    : out std_logic;  	-- OPL2		
		CS_IO01	 : out std_logic;   -- generic IO01
		CS_IO02	 : out std_logic;   -- generic IO01
		CS_IO03	 : out std_logic;   -- generic IO01
		
		RD_OPL	 : out std_logic;
		WR_OPL	 : out std_logic
		
	);

end;

Architecture decoder_arch of decoder is
	signal clk: std_logic;
	signal rdyclk: STD_LOGIC;
	signal romoff: std_logic;
	signal rom_bank: std_logic_vector(1 downto 0);
	signal AO_sig : std_logic_vector(18 downto 13);   -- extended address bus AO13-AO18

	signal cs_rom_sig: std_logic;
	signal cs_ram_sig: std_logic;

	signal cs_uart_sig: std_logic;
	signal cs_via_sig: std_logic;
	signal cs_vdp_sig: std_logic;

	signal csr_vdp_sig: std_logic;
	signal csw_vdp_sig: std_logic;
	signal cs_opl_sig: std_logic;
	signal cs_io01_sig: std_logic;
	signal cs_io02_sig: std_logic;
	
	signal d_out: std_logic_vector(7 downto 0);
	signal d_in:  std_logic_vector(7 downto 0);
	
	signal reg_select: std_logic;
	signal reg_addr: std_logic;
	signal is_read: std_logic;
	signal rdy_sig: std_logic;
begin
	-- inputs
	clk		<= CLKIN;
	d_in 		<= D;	

	-- bidirectional
	-- make data bus output tristate when not a qualified read
	D 			<= d_out when (is_read='1') else (others => 'Z');
	
	-- outputs
	PHI2OUT 	<= clk;
	RD 		<= RW nand clk;
	WR 		<= not RW nand clk;
	RD_OPL	<= not RW;
	WR_OPL	<= RW;
	RDY		<= rdy_sig;
	AO			<= AO_sig;
		
	cs_uart 		<= cs_uart_sig;
	cs_via  		<= cs_via_sig;
	csr_vdp 		<= csr_vdp_sig;
	csw_vdp 		<= csw_vdp_sig;
	cs_opl  		<= cs_opl_sig;
	CS_ROM  		<= cs_rom_sig;
	cs_ram  		<= cs_ram_sig;

	cs_io01		<= cs_io01_sig;
	cs_io02		<= cs_io02_sig;
	
	
	-- helpers
	-- qualified read?
	is_read 		<= reg_select and clk and rw;
	
	-- internal register selected ($0230 - $023f)
	reg_select  	<= '1' when (A(15 downto 4) = "000000100011") else '0';						-- $0230
	
	reg_addr 		<= A(0);
	
	-- cpu register section
	-- cpu read
	cpu_read: process (is_read, reg_addr, ROMOFF, rom_bank)
	begin
		if (is_read = '1') then 
			case reg_addr is
				when '0' =>        -- read latch
					D_out(0)	<= ROMOFF;
					D_out(1) <= rom_bank(0);
					D_out(2) <= rom_bank(1);
					D_out(3)	<= '0';
					D_out(4)	<= '0';
					D_out(5)	<= '0';
					D_out(6)	<= '0';
					D_out(7)	<= '0';

				when others => 
				  D_out <= (others => '0');
			end case;
		else
			D_out <= (others => '0');
		end if;
	end process;

	-- cpu write 
	cpu_write: process(reset, reg_select, reg_addr, clk, RW, D_in)
	begin
		if (reset = '0') then
			romoff 		<= '0';
			rom_bank 	<= "00";
			AO_sig(18)	<= '0'; -- A18
			AO_sig(17) 	<= '0'; -- A17
			AO_sig(16) 	<= '0'; -- A16
		elsif (falling_edge(clk) and reg_select='1' and RW='0') then
			case reg_addr is
				when '0' =>         
					romoff <= D_in(0);
					rom_bank(0) <= D_in(1);
					rom_bank(1) <= D_in(2);				 
					AO_sig(16) 	<= D_in(3); -- A16
					AO_sig(17) 	<= D_in(4); -- A17
					AO_sig(18)	<= D_in(5); -- A18
				when others =>
			end case;
		end if;
	end process;
	
--	frequency_divider: process (RESET, CLKIN) begin
--	  if (RESET = '0') then
--			clk <= '0';
--		elsif rising_edge(CLKIN) then
--			clk <= not(clk);
--	  end if;
--	end process;


 
	-- wait state generator
	rdygen: process(RESET, clk, rdyclk)
	begin
		if (RESET = '0') then
			rdyclk <= '0';
		elsif rising_edge(clk) then
			rdyclk <= not rdyclk;
		end if;
	end process;
	
	
	rdy_sig			<= '0' when (rdyclk = '1' and (CS_ROM_sig = '0' or CS_OPL_sig = '0' or CSR_VDP_sig = '0' or CSW_VDP_sig = '0') ) else 'Z';
	
	-- io area decoding
	
	CS_UART_sig    <= '0' when (A(15 downto 4) = "000000100000") else '1'; 						-- $0200		
	CS_VIA_sig     <= '0' when (A(15 downto 4) = "000000100001") else '1'; 						-- $0210
	
	CSR_VDP_sig		<= '0' when (A(15 downto 4) = "000000100010") and (RW = '1') else '1'; 	-- $0220	
	CSW_VDP_sig		<= '0' when (A(15 downto 4) = "000000100010") and (RW = '0') else '1'; 	-- $0220	
	CS_OPL_sig		<= '0' when (A(15 downto 4) = "000000100100") else '1';  					-- $0240
	cs_io01_sig 	<= '0' when (A(15 downto 4) = "000000100101") else '1'; 						-- $0250
	cs_io02_sig 	<= '0' when (A(15 downto 4) = "000000100110") else '1';						-- $0260


	cs_rom_sig	  	<= '0' when (ROMOFF = '0') and (RW = '1') and (A(15 downto 13) = "111") else '1';
	cs_ram_sig		<= '0' when (
							not(A(15 downto 7) = "000000100") -- io area $0200 - $027f
							and cs_rom_sig='1'
						) else '1';
						
	ao_sig(13) 		<= rom_bank(0) when cs_rom_sig = '0' else A(13);
	ao_sig(14) 		<= rom_bank(1) when cs_rom_sig = '0' else A(14);
	
	ao_sig(15) 		<= A(15);
	
	

End decoder_arch;
