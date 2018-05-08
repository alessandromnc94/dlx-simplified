library ieee;
use ieee.std_logic_1164.all;

entity half_adder is
  port (
    in_1      : in  std_logic;
    in_2      : in  std_logic;
    sum       : out std_logic;
    carry_out : out std_logic
    );
end entity;

architecture structural of half_adder is

  component xor_gate is
    port (
      in_1  : in  std_logic;
      in_2  : in  std_logic;
      out_s : out std_logic
      );
  end component;

  component and_gate is
    port (
      in_1  : in  std_logic;
      in_2  : in  std_logic;
      out_s : out std_logic
      );
  end component;

begin
  s_gate : xor_gate port map (
    in_1  => in_1,
    in_2  => in_2,
    out_s => sum
    );
  c_out_gate : and_gate port map (
    in_1  => in_1,
    in_2  => in_2,
    out_s => carry_out
    );
end architecture;
