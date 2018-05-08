library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity rotator is
  generic (
    n : natural := 8
    );
  port (
    base_vector     : in  std_logic_vector(n-1 downto 0);
    rotate_by_value : in  std_logic_vector(n-1 downto 0);
    left_rotation   : in  std_logic;
    out_s           : out std_logic_vector(n-1 downto 0)
    );
end entity;

architecture behavioral of rotator is
  signal out_s_tmp, base_vector_casted : bit_vector(n-1 downto 0);
  signal rotate_by_value_casted        : natural;
begin
  base_vector_casted     <= to_bitvector(base_vector);
  rotate_by_value_casted <= conv_integer(rotate_by_value);
  out_s                  <= to_stdlogicvector(out_s_tmp);
  out_s_tmp              <= base_vector_casted rol rotate_by_value_casted when left_rotation = '1' else
               base_vector_casted ror rotate_by_value_casted;

end architecture;
