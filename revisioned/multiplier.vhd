library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;

entity multiplier is
  generic (
    n : natural := 16
    );
  port (
    in_1  : in  std_logic_vector(n-1 downto 0);
    in_2  : in  std_logic_vector(n-1 downto 0);
    out_s : out std_logic_vector(2*n-1 downto 0)
    );
end entity;

architecture behavioral of multiplier is

begin
  out_s <= in_1 * in_2;
end architecture;
