library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

Entity chuck is
   Port (
      -- system clock
      CLKIN       : in std_logic;
      CPU_phi2    : out std_logic;

      -- address bus
      CPU_a          : in std_logic_vector (15 downto 0);   -- Address bus
      EXT_a          : out std_logic_vector(18 downto 14);   -- extended address bus EXT_a14-EXT_a18

      -- data bus
      CPU_d          : inout std_logic_vector (7 downto 0);

      -- control signals
      RESET    : in std_logic;     -- reset line
      CPU_rw   : in std_logic;     -- RW pin of 6502
      CPU_rdy  : out std_logic;    -- RDY signal for generating wait states
      OE       : out std_logic;    -- read access
      WE       : out std_logic;    -- write access
      R			: out std_logic;	  -- CPU read w/o phi2
      W			: out std_logic;	  -- CPU write w/o phi2

      -- chip select for memory
      CS_ROM    : out std_logic;    -- CS signal for ROM at $e000-$ffff
      CS_RAM    : out std_logic;    -- CS for ram

      -- chip select for peripherals
      CS_UART   : out std_logic;
      CS_VIA    : out std_logic;
      CSR_VDP   : out std_logic;  -- VDP read
      CSW_VDP   : out std_logic;  -- VDP write
      CS_OPL    : out std_logic;  -- OPL2

      -- chip select for expansion ports
      CS_SLOT0	 : out std_logic;
      CS_SLOT1	 : out std_logic;

      -- chip select for data bus buffer
      CS_BUFFER : out std_logic  -- Data bus transceiver enable
   );

end;

Architecture chuck_arch of chuck is

   -- define bank table type array of 6 bit vectors
   type t_banktable is array (0 to 3) of std_logic_vector(5 downto 0);
   signal INT_banktable : t_banktable;

   signal clk: std_logic;

   signal clk_div: std_logic_vector(2 downto 0);
   signal rdy_en: boolean;

   signal d_out: std_logic_vector(7 downto 0);
   signal d_in: std_logic_vector(7 downto 0);

   signal reg_select: std_logic;
   signal io_select: std_logic;
   signal reg_addr: std_logic_vector(1 downto 0);
   signal reg_read: std_logic;

   signal read_sig: std_logic;
   signal write_sig: std_logic;
   signal reset_sig: std_logic;

   signal sig_cs_rom: std_logic;
   signal sig_csr_vdp: std_logic;
	signal sig_csw_vdp: std_logic;
   signal sig_cs_vdp: std_logic;
   signal sig_cs_opl: std_logic;
	signal sig_cs_via: std_logic;
	signal sig_cs_uart: std_logic;
	signal sig_cs_slot0: std_logic;
	signal sig_cs_slot1: std_logic;


	signal sig_cs_buffer: std_logic;

begin
   -- inputs
   --clk         <= CLKIN;

   reset_sig   <= not RESET;

   CPU_phi2    <= clk;

   read_sig    <= CPU_rw NAND clk;
   write_sig   <= (NOT CPU_rw) NAND clk;
   R				<= CPU_rw;
   W				<= NOT CPU_rw;

   -- helpers

   rdy_en      <= false; -- (sig_cs_rom or sig_csw_vdp or sig_csr_vdp or sig_cs_opl) = '1';

   -- $0200 - $027x
   io_select   <= '1' when CPU_a(15 downto 7) = "000000100" else '0';

   -- register address denoted by address bit 0,1
   reg_addr    <= CPU_a(1 downto 0);

   -- internal register selected ($0230 - $023f)
   reg_select  <= '1' when io_select = '1' and CPU_a(6 downto 4) = "011" else '0';

   -- qualified register read?
   reg_read <= reg_select AND CPU_rw AND clk;

   d_in <= CPU_d when (reg_select AND NOT(CPU_rw)) = '1' else
            (others => '0');

   -- outputs
   -- make data bus output tristate when not a qualified read
   CPU_d <= d_out when (reg_select AND CPU_rw) = '1' else
            (others => 'Z');

   -- cpu register section
   -- cpu read from CPLD register
   cpu_read: process (reg_read, reg_addr, INT_banktable, d_out)
   begin
      if (reg_read = '1') then
         d_out(7)          <= INT_banktable(conv_integer(reg_addr))(5);
         d_out(6 downto 5) <= "00";
         d_out(4 downto 0) <= INT_banktable(conv_integer(reg_addr))(4 downto 0);
      end if;
   end process;

   -- cpu write to CPLD register
   cpu_write: process(reset_sig, clk, reg_select, reg_addr, CPU_rw, d_in)
   begin
      if (reset_sig = '1') then
         INT_banktable(0) <= "000000"; -- Bank $00
         INT_banktable(1) <= "000001"; -- Bank $01
         INT_banktable(2) <= "100000"; -- Bank $80 (ROM)
         INT_banktable(3) <= "100001"; -- Bank $81 (ROM)
      elsif (falling_edge(clk) and CPU_rw = '0' and reg_select = '1') then
         INT_banktable(conv_integer(reg_addr))(4 downto 0) <= d_in(4 downto 0);
         INT_banktable(conv_integer(reg_addr))(5) <= d_in(7);
      end if;
   end process;

   --clock divider
   process_genclk: process(CLKIN, reset_sig)
   begin
      if (reset_sig = '1') then
         clk_div <= "000";
      elsif (rising_edge(CLKIN)) then
         clk_div <= clk_div + 1;
      end if;
   end process;

	clk <= clk_div(2) AND '1';

   -- wait state generator
   --process(clk, clk_div, rdy_en)
   --begin
   --   if(rdy_en) then
    --     if (rising_edge(clk)) then
   --         clk_div <= clk_div + '1';
   --      end if;
   --   else
   --      clk_div <= (others => '0');
   --   end if;
   --end process;

   -- io area decoding
   --   $0200 - $020f
   sig_cs_uart   <= '1' when io_select = '1' and CPU_a(6 downto 4) = "000" else '0';

   --   $0210 - $021f
   sig_cs_via     <= '1' when io_select = '1' and CPU_a(6 downto 4) = "001" else '0';

   --   $0220 - $022f
   sig_cs_vdp      <= '1' when io_select = '1' and CPU_a(6 downto 4) = "010" else '0';
   sig_csr_vdp     <= '1' when sig_cs_vdp = '1' and CPU_rw = '1' else '0';
   sig_csw_vdp     <= '1' when (conv_integer(clk_div) >= 1 and conv_integer(clk_div) <= 6)
                               and sig_cs_vdp = '1' and CPU_rw = '0' else '0';

   --   $0240 - $024f
   sig_cs_opl     <= '1' when io_select = '1' and CPU_a(6 downto 4) = "100" else '0';

   --   $0250 - $025f expansion slot 0
	sig_cs_slot0     <= '1' when io_select = '1' and CPU_a(6 downto 4) = "101" else '0';
	--   $0260 - $026f expansion slot 1
	sig_cs_slot1     <= '1' when io_select = '1' and CPU_a(6 downto 4) = "110" else '0';


	sig_cs_buffer 	<= '1' when
                           sig_cs_vdp = '1'
                           or sig_cs_opl = '1'
									or sig_cs_uart = '1'
									or sig_cs_slot0 = '1'
									or sig_cs_slot1 = '1'
								else '0';

   -- extended address bus
   EXT_a(18 downto 14) <= INT_banktable(conv_integer(CPU_a(15 downto 14)))(4 downto 0);

   sig_cs_rom  <= INT_banktable(conv_integer(CPU_a(15 downto 14)))(5) AND NOT io_select;

   CS_RAM      <= INT_banktable(conv_integer(CPU_a(15 downto 14)))(5) OR io_select;
   CS_ROM      <= NOT(sig_cs_rom);
   CSR_VDP     <= NOT(sig_csr_vdp);
   CSW_VDP     <= NOT(sig_csw_vdp);

   CS_OPL      <= NOT(sig_cs_opl);
   CS_VIA		<= NOT(sig_cs_via);
   CS_UART		<= NOT(sig_cs_uart);
	CS_SLOT0		<= NOT(sig_cs_slot0);
	CS_SLOT1		<= NOT(sig_cs_slot1);

   CS_BUFFER   <= NOT(sig_cs_buffer);


   CPU_rdy     <= 'Z'; --'0' when (clk_div <= 4 and rdy_en) else 'Z';

   OE          <= read_sig;
   WE          <= write_sig;

End chuck_arch;