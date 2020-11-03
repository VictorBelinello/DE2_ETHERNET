-- TOP LEVEL
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity de2_net is
  port (
    CLOCK_50 : in STD_LOGIC;
		
    KEY : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		
    DRAM_CLK, DRAM_CKE : OUT STD_LOGIC;
    DRAM_ADDR : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    DRAM_BA_0, DRAM_BA_1 : BUFFER STD_LOGIC;
    DRAM_CS_N, DRAM_CAS_N, DRAM_RAS_N, DRAM_WE_N : OUT STD_LOGIC;
    DRAM_DQ : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    DRAM_UDQM, DRAM_LDQM : BUFFER STD_LOGIC;
	
		ENET_CLK : out std_logic;
		ENET_CMD : out std_logic;
		ENET_CS_N : out std_logic;
		ENET_INT : in std_logic;
		ENET_RD_N : out std_logic;
		ENET_WR_N : out std_logic;
		ENET_RST_N : out std_logic;
		ENET_DATA : inout std_logic_vector(15 downto 0)
		
  );
end entity de2_net;

architecture rtl of de2_net is
  component system is
    port (
        clk_clk          : in    STD_LOGIC                     := 'X';             -- clk
				
        reset_reset_n    : in    STD_LOGIC                     := 'X';             -- reset_n
				
        sdram_wire_addr  : out   STD_LOGIC_VECTOR(11 downto 0);                    -- addr
        sdram_wire_ba    : out   STD_LOGIC_VECTOR(1 downto 0);                     -- ba
        sdram_wire_cas_n : out   STD_LOGIC;                                        -- cas_n
        sdram_wire_cke   : out   STD_LOGIC;                                        -- cke
        sdram_wire_cs_n  : out   STD_LOGIC;                                        -- cs_n
        sdram_wire_dq    : inout STD_LOGIC_VECTOR(15 downto 0) := (others => 'X'); -- dq
        sdram_wire_dqm   : out   STD_LOGIC_VECTOR(1 downto 0);                     -- dqm
        sdram_wire_ras_n : out   STD_LOGIC;                                        -- ras_n
        sdram_wire_we_n  : out   STD_LOGIC;                                        -- we_n
				
				sdram_clk_clk    : out   std_logic;                                        -- clk
        enet_clk_clk     : out   std_logic;                                        -- clk
				
				dm9000a_DATA     : inout std_logic_vector(15 downto 0) := (others => 'X'); -- DATA
				dm9000a_CMD      : out   std_logic;                                        -- CMD
				dm9000a_RD_N     : out   std_logic;                                        -- RD_N
				dm9000a_WR_N     : out   std_logic;                                        -- WR_N
				dm9000a_CS_N     : out   std_logic;                                        -- CS_N
				dm9000a_RST_N    : out   std_logic;                                        -- RST_N
				dm9000a_INT      : in    std_logic                     := 'X'              -- INT
    );
  end component system;

  SIGNAL DRAM_DQM : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL DRAM_BA : STD_LOGIC_VECTOR(1 DOWNTO 0);

begin

  DRAM_BA_0 <= DRAM_BA(0);
  DRAM_BA_1 <= DRAM_BA(1);
  DRAM_LDQM <= DRAM_DQM(0);
  DRAM_UDQM <= DRAM_DQM(1);

  NiosII : component system
    port map (
        clk_clk          => CLOCK_50,          --        clk.clk
        reset_reset_n    => KEY(0),    --      reset.reset_n
				
        sdram_wire_addr  => DRAM_ADDR,  -- sdram_wire.addr
        sdram_wire_ba    => DRAM_BA,    --           .ba
        sdram_wire_cas_n => DRAM_CAS_N, --           .cas_n
        sdram_wire_cke   => DRAM_CKE,   --           .cke
        sdram_wire_cs_n  => DRAM_CS_N,  --           .cs_n
        sdram_wire_dq    => DRAM_DQ,    --           .dq
        sdram_wire_dqm   => DRAM_DQM,   --           .dqm
        sdram_wire_ras_n => DRAM_RAS_N, --           .ras_n
        sdram_wire_we_n  => DRAM_WE_N,   --           .we_n
				sdram_clk_clk    => DRAM_CLK,    --  sdram_clk.clk
				
        enet_clk_clk     => ENET_CLK,     --   enet_clk.clk
				dm9000a_DATA     => ENET_DATA,                 --               dm9000a.DATA
				dm9000a_CMD      => ENET_CMD,                  --                      .CMD
				dm9000a_RD_N     => ENET_RD_N,                 --                      .RD_N
				dm9000a_WR_N     => ENET_WR_N,                 --                      .WR_N
				dm9000a_CS_N     => ENET_CS_N,                 --                      .CS_N
				dm9000a_RST_N    => ENET_RST_N,                --                      .RST_N
				dm9000a_INT      => ENET_INT                   --                      .INT
    );

end architecture rtl;