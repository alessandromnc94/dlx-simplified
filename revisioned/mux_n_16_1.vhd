library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity mux_n_16_1 is
  generic (
    n : natural := 1                           -- number of bits for inputs
    );
  port (
    in_0  : in  std_logic_vector(n-1 downto 0);
    in_1  : in  std_logic_vector(n-1 downto 0);
    in_2  : in  std_logic_vector(n-1 downto 0);
    in_3  : in  std_logic_vector(n-1 downto 0);
    in_4  : in  std_logic_vector(n-1 downto 0);
    in_5  : in  std_logic_vector(n-1 downto 0);
    in_6  : in  std_logic_vector(n-1 downto 0);
    in_7  : in  std_logic_vector(n-1 downto 0);
    in_8  : in  std_logic_vector(n-1 downto 0);
    in_9  : in  std_logic_vector(n-1 downto 0);
    in_10 : in  std_logic_vector(n-1 downto 0);
    in_11 : in  std_logic_vector(n-1 downto 0);
    in_12 : in  std_logic_vector(n-1 downto 0);
    in_13 : in  std_logic_vector(n-1 downto 0);
    in_14 : in  std_logic_vector(n-1 downto 0);
    in_15 : in  std_logic_vector(n-1 downto 0);
    s     : in  std_logic_vector(2 downto 0);  -- selector
    out_s : out std_logic_vector(n-1 downto 0)
    );
end entity;

architecture behavioral of mux_n_16_1 is
begin
  process (all)
  begin
    case conv_integer(s) is
      when 0      => out_s <= in_0;
      when 1      => out_s <= in_1;
      when 2      => out_s <= in_2;
      when 3      => out_s <= in_3;
      when 4      => out_s <= in_4;
      when 5      => out_s <= in_5;
      when 6      => out_s <= in_6;
      when 7      => out_s <= in_7;
      when 8      => out_s <= in_8;
      when 9      => out_s <= in_9;
      when 10     => out_s <= in_10;
      when 11     => out_s <= in_11;
      when 12     => out_s <= in_12;
      when 13     => out_s <= in_13;
      when 14     => out_s <= in_14;
      when 15     => out_s <= in_15;
      when others => null;
    end case;
  end process;
end architecture;
