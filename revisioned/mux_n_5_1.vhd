library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity mux_n_5_1 is
  generic (
    n : natural := 1                           -- number of bits for inputs
    );
  port (
    in_0  : in  std_logic_vector(n-1 downto 0);
    in_1  : in  std_logic_vector(n-1 downto 0);
    in_2  : in  std_logic_vector(n-1 downto 0);
    in_3  : in  std_logic_vector(n-1 downto 0);
    in_4  : in  std_logic_vector(n-1 downto 0);
    s     : in  std_logic_vector(2 downto 0);  -- selector
    out_s : out std_logic_vector(n-1 downto 0)
    );
end entity;

architecture behavioral of mux_n_5_1 is
begin
  process (in_0, in_1, in_2, in_3, in_4, s)
  begin
    case conv_integer(s) is
      when 0      => out_s <= in_0;
      when 1      => out_s <= in_1;
      when 2      => out_s <= in_2;
      when 3      => out_s <= in_3;
      when 4      => out_s <= in_4;
      when others => out_s <= (others => 'Z');
    end case;
  end process;
end architecture;
