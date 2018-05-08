library ieee;
use ieee.std_logic_1164.all;

entity or_gate_n is
  generic (
    n : natural := 1
    );
  port (
    in_1  : in  std_logic_vector(n-1 downto 0);
    in_2  : in  std_logic_vector(n-1 downto 0);
    out_s : out std_logic_vector(n-1 downto 0)
    );
end entity;

architecture structural of or_gate_n is
  component or_gate is
    port (
      in_1  : in  std_logic;
      in_2  : in  std_logic;
      out_s : out std_logic
      );
  end component;

begin
  gate_gen : for i in 0 to n-1 generate
    or_gate_x : or_gate port map (
      in_1  => in_1(i),
      in_2  => in_2(i),
      out_s => out_s(i)
      );
  end generate;
end architecture;
