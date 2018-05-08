library ieee;
use ieee.std_logic_1164.all;

entity nand_gate_n is
  generic (
    n : natural := 1
    );
  port (
    in_1  : in  std_logic_vector(n-1 downto 0);
    in_2  : in  std_logic_vector(n-1 downto 0);
    out_s : out std_logic_vector(n-1 downto 0)
    );
end entity;

architecture behavioral of nand_gate_n is
  signal tmp_out_s : std_logic;
begin
  out_s <= in_1 nand in_2;
end architecture;
