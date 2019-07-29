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
		AO			 : inout std_logic_vector(18 downto 13);   -- extended address bus AO13-AO18
		
		-- data bus
		D			 : inout std_logic_vector (7 downto 0); -- data bus lower 4 bits
		
		-- control signals
		RESET     : in std_logic;  	-- reset line
		RW        : in std_logic;  	-- RW pin of 6502
		RDY		 : inout std_logic; 	-- RDY signal for generating wait states
		RD			 : out std_logic; 	-- read access
		WR			 : out std_logic; 	-- write access
		
		RD_OPL	 : out std_logic;
		WR_OPL	 : out std_logic;
		
		-- chip select for memory
		CS_ROM    : out std_logic; 	-- CS signal for ROM at $e000-$ffff 
		CS_RAM  	 : out std_logic; 	-- CS for ram 
		
		-- chip select for peripherals
		CS_UART   : out std_logic;  	
		CS_VIA    : out std_logic;  	
		CSR_VDP   : inout std_logic;  -- VDP read
		CSW_VDP   : inout std_logic;  -- VDP write
		CS_OPL    : inout std_logic  	-- OPL2		
	);

end;

Architecture decoder_arch of decoder is
	signal clk: std_logic;
	signal rdyclk: STD_LOGIC;
	signal romoff: std_logic;
	signal rom_bank: std_logic_vector(1 downto 0);
	signal cs_rom_sig: std_logic;
	signal reg_select: std_logic;
	
begin
	
--	frequency_divider: process (RESET, CLKIN) begin
--	  if (RESET = '0') then
--			clk <= '0';
--		elsif rising_edge(CLKIN) then
--			clk <= not(clk);
--	  end if;
--	end process;
	clk		<= CLKIN;
   PHI2OUT 	<= clk;
	RD 		<= RW nand clk;
	WR 		<= not RW nand clk;



	
	rdygen: process(RESET, clk, rdyclk)
	begin
		if (RESET = '0') then
			rdyclk <= '0';
		elsif rising_edge(clk) then
			rdyclk <= not rdyclk;
		end if;
		--sigrdy <= ((not rdyclk) and (not CS_ROM or not CS_IO or not CS_VDP));
	end process;
	
	
	RDY				<= '0' when (rdyclk = '1' and (CS_ROM_sig = '0' or CS_OPL = '0' or CSR_VDP = '0' or CSW_VDP = '0') ) else 'Z';
	

	cs_rom_sig	  	<= '0' when (ROMOFF = '0') and (RW = '1') and (A(15 downto 13) = "111") else '1';
	CS_ROM 			<= cs_rom_sig;
	CS_RAM   		<= '1' when (((A(15) = '1')	or A(14 downto 7) = "00000100") 
									or	(A(15) = '1' and A(13) = '0'))
									or (((A(15 downto 14) = "10"))
									or ((RW = '0') and (A(15 downto 12) = "111"))			-- Writes to $e000-$ffff go to the RAM						
									or ((ROMOFF = '1') and (RW = '1') and (A(15 downto 13) = "111")))	-- Reads to $e000-$ffff go to the ROM or to RAM when ROMOFF is low								 
								
								else '0';
							


	CS_UART    	<= '0' when (A(15 downto 4) = "000000100000") else '1'; 	-- $0200		
	CS_VIA     	<= '0' when (A(15 downto 4) = "000000100001") else '1'; 	-- $0210
	CSR_VDP		<= '0' when (A(15 downto 4) = "000000100010") and (RW = '1') else '1'; 	-- $0220	
	CSW_VDP		<= '0' when (A(15 downto 4) = "000000100010") and (RW = '0') else '1'; 	-- $0220	
	reg_select  <= '1' when (A(15 downto 4) = "000000100011") else '0';	-- $0230
	CS_OPL		<= '0' when (A(15 downto 4) = "000000100100") else '1';  -- $0240
							  
	RD_OPL		<= '0' when RW='1' else '1';
	WR_OPL		<= '0' when RW='0' else '1';
	--							or (A = "000000100101") 				-- $0250
	--							or (A = "000000100110") 				-- $0260
	--							or (A = "000000100111") 				-- $0270
	
--	AO(15) <= A(15);	
--	AO(14) <= A(14);
--	AO(13) <= A(13);

-- cpu register section
    -- cpu read
    cpu_read: process (RW, reg_select, A(0), ROMOFF, rom_bank)
    begin
        if RW = '1' and reg_select = '1' then 
            case A(0) is
                when '0' =>        -- read latch
                    D(0) <= ROMOFF;
						  D(1) <= rom_bank(0);
						  D(2) <= rom_bank(1);
						  D(3)	<= '0';
						  D(4)	<= '0';
						  D(5)	<= '0';
						  D(6)	<= '0';
						  D(7)	<= '0';
						
					 when '1' =>        -- read latch
                	  D(0)   <= AO(13);
						  D(1)   <= AO(14);
						  D(2)   <= AO(15);
						  D(3)   <= AO(16);
						  D(4)   <= AO(17);
						  D(5)   <= AO(18);
						  D(6)	<= '0';
						  D(7)	<= '0';
						  
                when others => 
                    D <= (others => '0');
            end case;
        else
            D <= (others => '0');
        end if;
    end process;

    -- cpu write 
    cpu_write: process(reset, reg_select, A(0), clk, RW, D)
    begin
        if (reset = '0') then
            romoff <= '0';
				rom_bank <= "00";
				AO(18) <= '0'; -- A18
				AO(17) <= '0';  -- A17
				AO(16) <= '0';  -- A16
				AO(15) <= '0';	
				AO(14) <= '0';
				AO(13) <= '0';
		elsif (falling_edge(clk) and reg_select='1' and RW='0') then
            case A(0) is
                when '0' =>         
                    romoff <= D(0);
						  rom_bank(0) <= D(1);
						  rom_bank(1) <= D(2);
					 when '1' =>         
                    AO(13) <= D(0);
						  AO(14) <= D(1);
						  AO(15) <= D(2);
						  AO(16) <= D(3);
						  AO(17) <= D(4);
						  AO(18) <= D(5);
						 
                when others =>
            end case;
        end if;
    end process;


End decoder_arch;
