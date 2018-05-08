library ieee;
use ieee.std_logic_1164.all;

entity booth_encoder_block is

  port(
    in_s  : in  std_logic_vector(2 downto 0);
    out_s : out std_logic_vector(2 downto 0)
    );

end entity;

architecture structural of booth_encoder_block is

  component and_gate_single_n is
    generic (
      n : natural
      );
    port (
      in_s  : in  std_logic_vector(n-1 downto 0);
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

  component not_gate_n is
    generic (
      n : natural
      );
    port (
      in_s  : in  std_logic_vector(n-1 downto 0);
      out_s : out std_logic_vector(n-1 downto 0)
      );
  end component;

  signal not_in_s                               : std_logic_vector(2 downto 0);
  signal and_gate_3_2_in, and_gate_3_1_b_in     : std_logic_vector(2 downto 0);
  signal and_gate_3_1_b_out, and_gate_2_1_a_out : std_logic;
  signal out_s_tmp                              : std_logic_vector(2 downto 0);

begin

  out_s <= out_s_tmp;

  not_in_s_gate : not_gate_n generic map (
    n => 3
    ) port map (
      in_s  => in_s,
      out_s => not_in_s
      );

  -- out_s(0) <= in_s(1) xor in_s(0)
  xor_gate_2_0 : xor_gate port map (
    in_1  => in_s(0),
    in_2  => in_s(1),
    out_s => out_s_tmp(0)
    );

  -- out_s(1) <= (in_s(2) and (in_s(1) xor in_s(0))) or (not(in_s(2)) and in_s(1) and in_s(0)) == (in_s(2) xor out_s(0)) or  or (not(in_s(2)) and in_s(1) and in_s(0))
  and_gate_2_1_a : and_gate port map (
    in_1  => in_s(2),
    in_2  => out_s_tmp(0),
    out_s => and_gate_2_1_a_out
    );
  and_gate_3_1_b_in <= not_in_s(2) & in_s(1) & in_s(0);
  and_gate_3_1_b : and_gate_single_n generic map (
    n => 3
    ) port map (
      in_s  => and_gate_3_1_b_in,
      out_s => and_gate_3_1_b_out
      );
  or_gate_2_1 : or_gate port map (
    in_1  => and_gate_3_1_b_out,
    in_2  => and_gate_2_1_a_out,
    out_s => out_s_tmp(1)
    );

  -- out_s(2) <= in_s(2) and not(in_s(1)) and not(in_s(0))
  and_gate_3_2_in <= in_s(2) & not_in_s(1) & not_in_s(0);
  and_gate_3_2 : and_gate_single_n generic map (
    n => 3
    ) port map (
      in_s  => and_gate_3_2_in,
      out_s => out_s_tmp(2)
      );

end architecture;
