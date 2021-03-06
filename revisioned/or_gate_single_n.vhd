library ieee;
use ieee.std_logic_1164.all;

entity or_gate_single_n is
  generic (
    n : natural := 3
    );
  port (
    in_s  : in  std_logic_vector(n-1 downto 0);
    out_s : out std_logic
    );
end entity;

architecture behavioral of or_gate_single_n is

  signal tmp_out_s : std_logic_vector(n-1 downto 0);
begin
  tmp_out_s(0) <= i(0);
  or_gates_gen : for i in 1 to n-1 generate
    tmp_out_s(i) <= tmp_out_s(i-1) or in_s(i);
  end generate;

  out_s <= tmp_out_s(n-1);

--  it works only with vhdl 2008
--  out_s <= or i;
end architecture;
