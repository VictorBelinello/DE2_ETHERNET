-- TOP LEVEL
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity de2_net is
  port (
    CLOCK_50 : in STD_LOGIC;
		
    KEY : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		
    DRAM_CLK, DRAM_CKE                            : OUT STD_LOGIC;
    DRAM_ADDR                                     : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    DRAM_BA_0, DRAM_BA_1                          : BUFFER STD_LOGIC;
    DRAM_CS_N, DRAM_CAS_N, DRAM_RAS_N, DRAM_WE_N  : OUT STD_LOGIC;
    DRAM_DQ                                       : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    DRAM_UDQM, DRAM_LDQM                          : BUFFER STD_LOGIC;
	
		ENET_CLK    : out std_logic;
		ENET_CMD    : out std_logic;
		ENET_CS_N   : out std_logic;
		ENET_INT    : in std_logic;
		ENET_RD_N   : out std_logic;
		ENET_WR_N   : out std_logic;
		ENET_RST_N  : out std_logic;
    ENET_DATA   : inout std_logic_vector(15 downto 0);

    FL_DQ     : inout std_logic_vector(7 downto 0);
    FL_ADDR   : out std_logic_vector(21 downto 0);
    FL_RST_N  : out std_logic_vector(0 downto 0);
    FL_WE_N   : out std_logic_vector(0 downto 0);
    FL_OE_N   : out std_logic_vector(0 downto 0);
    FL_CE_N   : out std_logic_vector(0 downto 0)		
  );
end entity de2_net;

architecture rtl of de2_net is
  component system is
    port (
        clk_clk          : in    STD_LOGIC := 'X';             -- clk
				reset_n_reset_n  : in    std_logic := 'X';             -- reset_n
				
        sdram_wire_addr  : out   STD_LOGIC_VECTOR(11 downto 0);                    -- addr
        sdram_wire_ba    : out   STD_LOGIC_VECTOR(1 downto 0);                     -- ba
        sdram_wire_cas_n : out   STD_LOGIC;                                        -- cas_n
        sdram_wire_cke   : out   STD_LOGIC;                                        -- cke
        sdram_wire_cs_n  : out   STD_LOGIC;                                        -- cs_n
        sdram_wire_dq    : inout STD_LOGIC_VECTOR(15 downto 0) := (others => 'X'); -- dq
        sdram_wire_dqm   : out   STD_LOGIC_VECTOR(1 downto 0);                     -- dqm
        sdram_wire_ras_n : out   STD_LOGIC;                                        -- ras_n
        sdram_wire_we_n  : out   STD_LOGIC;                                        -- we_n
        
				dm9000a_iOSC_50                       : in    std_logic := 'X';             -- iOSC_50
        dm9000a_ENET_DATA                     : inout std_logic_vector(15 downto 0) := (others => 'X'); -- ENET_DATA
        dm9000a_ENET_CMD                      : out   std_logic;                                        -- ENET_CMD
        dm9000a_ENET_RD_N                     : out   std_logic;                                        -- ENET_RD_N
        dm9000a_ENET_WR_N                     : out   std_logic;                                        -- ENET_WR_N
        dm9000a_ENET_CS_N                     : out   std_logic;                                        -- ENET_CS_N
        dm9000a_ENET_RST_N                    : out   std_logic;                                        -- ENET_RST_N
        dm9000a_ENET_CLK                      : out   std_logic;                                        -- ENET_CLK
        dm9000a_ENET_INT                      : in    std_logic := 'X';                                 -- ENET_INT
        
        bridge_cfi_flash_tcm_address_out      : out   std_logic_vector(21 downto 0);                    -- cfi_flash_tcm_address_out
        bridge_cfi_flash_tcm_read_n_out       : out   std_logic_vector(0 downto 0);                     -- cfi_flash_tcm_read_n_out
        bridge_cfi_flash_tcm_write_n_out      : out   std_logic_vector(0 downto 0);                     -- cfi_flash_tcm_write_n_out
        bridge_cfi_flash_tcm_data_out         : inout std_logic_vector(7 downto 0)  := (others => 'X'); -- cfi_flash_tcm_data_out
        bridge_cfi_flash_tcm_chipselect_n_out : out   std_logic_vector(0 downto 0) 
    );
  end component system;
	
	component Reset_Delay is
		port(
			iCLK : in STD_LOGIC;
			iRST : in STD_LOGIC;
			oRESET : out STD_LOGIC
		);
	end component Reset_Delay;
	
	component pll is
		port(
			inclk0		: IN STD_LOGIC;
			c0		: OUT STD_LOGIC;
			c1		: OUT STD_LOGIC 
		);
	end component pll;
	

  SIGNAL DRAM_DQM : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL DRAM_BA : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL CPU_RESET : STD_LOGIC;
	SIGNAL CPU_CLK : STD_LOGIC;

begin

  FL_RST_N(0) <= '1';
  
  DRAM_BA_0 <= DRAM_BA(0);
  DRAM_BA_1 <= DRAM_BA(1);
  DRAM_LDQM <= DRAM_DQM(0);
  DRAM_UDQM <= DRAM_DQM(1);

	delay1 : component Reset_Delay
		port map(
			iCLK => CLOCK_50,
			iRST => KEY(0),
			oRESET => CPU_RESET
		);
		
	pll_inst : component pll
		port map(
			inclk0 => CLOCK_50,
			c0 => CPU_CLK,
			c1 => DRAM_CLK
		);

  NiosII : component system
    port map (
        clk_clk          => CPU_CLK,          --        clk.clk
				reset_n_reset_n  => CPU_RESET,
				
        sdram_wire_addr  => DRAM_ADDR,  -- sdram_wire.addr
        sdram_wire_ba    => DRAM_BA,    --           .ba
        sdram_wire_cas_n => DRAM_CAS_N, --           .cas_n
        sdram_wire_cke   => DRAM_CKE,   --           .cke
        sdram_wire_cs_n  => DRAM_CS_N,  --           .cs_n
        sdram_wire_dq    => DRAM_DQ,    --           .dq
        sdram_wire_dqm   => DRAM_DQM,   --           .dqm
        sdram_wire_ras_n => DRAM_RAS_N, --           .ras_n
        sdram_wire_we_n  => DRAM_WE_N,   --           .we_n
				
        dm9000a_iOSC_50       => CLOCK_50,
				dm9000a_ENET_DATA     => ENET_DATA,                 --               dm9000a.DATA
        dm9000a_ENET_CLK      => ENET_CLK,
				dm9000a_ENET_CMD      => ENET_CMD,                  --                      .CMD
				dm9000a_ENET_RD_N     => ENET_RD_N,                 --                      .RD_N
				dm9000a_ENET_WR_N     => ENET_WR_N,                 --                      .WR_N
				dm9000a_ENET_CS_N     => ENET_CS_N,                 --                      .CS_N
				dm9000a_ENET_RST_N    => ENET_RST_N,                --                      .RST_N
        dm9000a_ENET_INT      => ENET_INT,                   --                      .INT
        
        bridge_cfi_flash_tcm_chipselect_n_out => FL_CE_N,  --                        .cfi_flash_0_tcm_chipselect_n_out
        bridge_cfi_flash_tcm_address_out      => FL_ADDR,      -- tristate_conduit_bridge.cfi_flash_0_tcm_address_out
        bridge_cfi_flash_tcm_data_out         => FL_DQ,         --                        .cfi_flash_0_tcm_data_out
        bridge_cfi_flash_tcm_read_n_out       => FL_OE_N,       --                        .cfi_flash_0_tcm_read_n_out
        bridge_cfi_flash_tcm_write_n_out      => FL_WE_N      --                        .cfi_flash_0_tcm_write_n_out
    );

end architecture rtl;