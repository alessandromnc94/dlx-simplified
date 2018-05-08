library ieee;
use ieee.std_logic_1164.all;

use work.logicals_types.all;

entity logicals_n is
  generic (
    n : natural := 8
    );
  port (
    in_1  : in  std_logic_vector(n-1 downto 0);
    in_2  : in  std_logic_vector(n-1 downto 0);
    logic : in  logicals_array;
    out_s : out std_logic_vector(n-1 downto 0)
    );
end entity;

architecture structural of logicals_n is
  component logicals is
    port (
      in_1  : in  std_logic;
      in_2  : in  std_logic;
      logic : in  logicals_array;
      out_s : out std_logic
      );
  end component;

begin

  logicals_gen : for i in 0 to n-1 generate
    logicals_x : logicals port map (
      in_1  => in_1(i),
      in_2  => in_2(i),
      logic => logic,
      out_s => out_s(i)
      );
  end generate;

end architecture;
