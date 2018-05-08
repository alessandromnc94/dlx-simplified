library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity shifter is
  generic (
    n : natural := 8
    );
  port (
    base_vector    : in  std_logic_vector(n-1 downto 0);
    shift_by_value : in  std_logic_vector(n-1 downto 0);
    left_shift     : in  std_logic;
    arith_shift    : in  std_logic;
    out_s          : out std_logic_vector(n-1 downto 0)
    );
end entity;

architecture behavioral of shifter is
  signal out_s_tmp, base_vector_casted : bit_vector(n-1 downto 0);
  signal shift_by_value_casted         : natural;
begin
  base_vector_casted    <= to_bitvector(base_vector);
  shift_by_value_casted <= conv_integer(shift_by_value);
  out_s                 <= to_stdlogicvector(out_s_tmp);
  out_s_tmp             <= base_vector_casted sll shift_by_value_casted when left_shift = '1' else
               base_vector_casted srl shift_by_value_casted when arith_shift = '0' else
               base_vector_casted sra shift_by_value_casted;

end architecture;
