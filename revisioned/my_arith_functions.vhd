library ieee;
use ieee.math_real.all;

package my_arith_functions is
  function log2int (
    n : natural
    )
    return natural;
  function log2int_own (
    n : natural
    )
    return natural;
end package;

package body my_arith_functions is
  function log2int (
    n : natural
    ) return natural is
  begin
    return integer(ceil(log2(real(n))));

  end function;

  function log2int_own (
    n : natural
    )
    return natural is
    variable tmp : natural := n;
    variable ret : natural := 0;
  begin
    while tmp > 0 loop
      tmp := tmp/2;
      ret := ret + 1;
    end loop;
    return ret;
  end function;
end package body;
