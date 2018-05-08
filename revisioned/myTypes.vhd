library ieee;
use ieee.std_logic_1164.all;

package mytypes is

  constant addrsize : natural := 32;
  subtype addregtype is std_logic_vector(addrsize-1 downto 0);

  constant regsize : natural := 32;
  subtype regtype is std_logic_vector(regsize-1 downto 0);

  constant zero : addregtype := (others => '0');

end package;
