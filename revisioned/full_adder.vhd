library ieee;
use ieee.std_logic_1164.all;

entity full_adder is
  port (
    in_1      : in  std_logic;
    in_2      : in  std_logic;
    carry_in  : in  std_logic;
    sum       : out std_logic;
    carry_out : out std_logic
    );
end entity;

architecture structural of full_adder is

  component xor_gate is
    port (
      in_1  : in  std_logic;
      in_2  : in  std_logic;
      out_s : out std_logic
      );
  end component;

  component or_gate is
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

  signal in_2_xor_carry_in, in_2_and_carry_in, in_1_and_in_2_xor_carry_in : std_logic := '0';

begin
  in_2_xor_carry_in_gate : xor_gate port map (
    in_1  => in_2,
    in_2  => carry_in,
    out_s => in_2_xor_carry_in
    );
  sum_xor_gate : xor_gate port map(
    in_1  => in_1,
    in_2  => in_2_xor_carry_in,
    out_s => sum
    );
  in_1_and_in_2_xor_carry_in_gate : and_gate port map (
    in_1  => in_1,
    in_2  => in_2_xor_carry_in,
    out_s => in_1_and_in_2_xor_carry_in
    );
  in_2_and_carry_in_gate : and_gate port map (
    in_1  => in_2,
    in_2  => carry_in,
    out_s => in_2_and_carry_in
    );
  carry_out_or_gate : or_gate port map (
    in_1  => in_1_and_in_2_xor_carry_in,
    in_2  => in_2_and_carry_in,
    out_s => carry_out
    );
end architecture;
