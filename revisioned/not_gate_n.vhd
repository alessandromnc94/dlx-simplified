library ieee;
use ieee.std_logic_1164.all;

entity not_gate_n is
  generic (
    n : natural := 1
    );
  port (
    in_s  : in  std_logic_vector(n-1 downto 0);
    out_s : out std_logic_vector(n-1 downto 0)
    );
end entity;

architecture structural of not_gate_n is
  component not_gate is
    port (
      in_s  : in  std_logic;
      out_s : out std_logic
      );
  end component;

begin
  gate_gen : for i in 0 to n-1 generate
    not_gate_x : not_gate port map (
      in_s  => in_s(i),
      out_s => out_s(i)
      );
  end generate;
end architecture;
