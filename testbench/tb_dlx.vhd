library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.cu_hw_types.all;
use work.my_const.all;


entity tb_dlx is
end entity;

architecture test of tb_dlx is
  component dlx is
    port (
      clk : in std_logic;               -- clock
      rst : in std_logic                -- reset:active-low
      );                                -- register file write enable
  end component;


  signal clk_t : std_logic := '0';
  signal rst_t : std_logic := reset_value;

begin
  clk_t <= not clk_t after 1 ns;
  rst_t <= not reset_value after 2 ns;
  dut : dlx port map(
    clk_t,
    rst_t);
end architecture;
