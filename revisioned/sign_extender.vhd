library ieee;
use ieee.std_logic_1164.all;

entity sign_extender is
  generic (
    n_in  : natural := 32;
    n_out : natural := 64
    );
  port (
    in_s  : in  std_logic_vector(n_in-1 downto 0);
    en    : in  std_logic;
    out_s : out std_logic_vector(n_out-1 downto 0)
    );
end entity;

architecture behavioral of sign_extender is
  signal extended_bit : std_logic;
begin
  extended_bit <= en and in_s(n_in-1);
  out_s        <= (n_out-1 downto n_in => extended_bit) & in_s;
end architecture;
