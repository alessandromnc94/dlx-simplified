library ieee;
use ieee.std_logic_1164.all;

entity pg_network is
  generic (
    n : natural := 8
    );
  port (
    in_1 : in  std_logic_vector (n-1 downto 0);
    in_2 : in  std_logic_vector (n-1 downto 0);
    pg   : out std_logic_vector (n-1 downto 0);
    g    : out std_logic_vector (n-1 downto 0)
    );
end entity;

architecture structural of pg_network is
  component pg_network_block is
    port (
      in_1 : in  std_logic;
      in_2 : in  std_logic;
      pg   : out std_logic;
      g    : out std_logic
      );
  end component;
begin

  pg_block_gen : for i in 0 to n-1 generate
    pg_blockx : pg_network_block
      port map (
        in_1 => in_1(i),
        in_2 => in_2(i),
        pg   => pg(i),
        g    => g(i)
        );
  end generate;
end architecture;
