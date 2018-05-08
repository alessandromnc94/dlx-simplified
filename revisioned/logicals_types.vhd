library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

package logicals_types is
  constant logicals_array_size : natural := 4;
  subtype logicals_array is std_logic_vector(logicals_array_size-1 downto 0);

  constant logicals_and  : logicals_array := "1000";
  constant logicals_nand : logicals_array := "0111";
  constant logicals_or   : logicals_array := "1110";
  constant logicals_nor  : logicals_array := "0001";
  constant logicals_xor  : logicals_array := "0110";
  constant logicals_xnor : logicals_array := "1001";

end package;
