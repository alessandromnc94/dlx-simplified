library ieee;
use ieee.std_logic_1164.all;

entity pg_block is
  port (
    pg_l   : in  std_logic;
    g_l    : in  std_logic;
    pg_r   : in  std_logic;
    g_r    : in  std_logic;
    pg_out : out std_logic;
    g_out  : out std_logic
    );
end entity;

architecture structural of pg_block is
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

  signal and_out : std_logic := '0';
begin
  pg_and_gate : and_gate port map (
    in_1  => pg_l,
    in_2  => pg_r,
    out_s => pg_out
    );
  g_and_gate : and_gate port map (
    in_1  => pg_l,
    in_2  => g_r,
    out_s => and_out
    );
  g_or_gate : or_gate port map (
    in_1  => g_l,
    in_2  => and_out,
    out_s => g_out
    );
end architecture;
