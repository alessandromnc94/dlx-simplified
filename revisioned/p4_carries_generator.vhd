library ieee;
use ieee.std_logic_1164.all;

entity p4_carries_generator is
  generic (
    n          : natural := 32;
    carry_step : natural := 4
    );
  port (
    in_1        : in  std_logic_vector (n-1 downto 0);
    in_2        : in  std_logic_vector (n-1 downto 0);
    carry_in    : in  std_logic;
    carries_out : out std_logic_vector (n/carry_step downto 0)
    );
end entity;

architecture structural of p4_carries_generator is

  component pg_network is
    generic (
      n : natural
      );
    port (
      in_1 : in  std_logic_vector (n-1 downto 0);
      in_2 : in  std_logic_vector (n-1 downto 0);
      pg   : out std_logic_vector (n-1 downto 0);
      g    : out std_logic_vector (n-1 downto 0)
      );
  end component;

  component p4_carries_logic_network is
    generic (
      n          : natural;
      carry_step : natural
      );
    port (
      pg          : in  std_logic_vector (n-1 downto 0);
      g           : in  std_logic_vector (n-1 downto 0);
      carry_in    : in  std_logic;
      carries_out : out std_logic_vector (n/carry_step downto 0)
      );
  end component;

  signal pg0_s, g0_s : std_logic_vector (n-1 downto 0);

begin

  pg_net : pg_network
    generic map (
      n => n
      )
    port map (
      in_1 => in_1,
      in_2 => in_2,
      pg   => pg0_s,
      g    => g0_s
      );

  cl_net : p4_carries_logic_network
    generic map (
      n          => n,
      carry_step => carry_step
      )
    port map (
      pg          => pg0_s,
      g           => g0_s,
      carry_in    => carry_in,
      carries_out => carries_out
      );
end architecture;
