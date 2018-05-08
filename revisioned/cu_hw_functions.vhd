library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_textio.all;

use work.cu_hw_types.all;

package cu_hw_functions is
-- function to initialize cw_mem using a file (cw_input.txt)
  function initialize_cw_mem return cw_mem_matrix;
end package;

package body cu_hw_functions is
-- function to initialize cw_mem using a file (cw_input.txt)
  function initialize_cw_mem return cw_mem_matrix is
    file file_in                    : text;
    variable line_in                : line;
    variable cw_mem_ret             : cw_mem_matrix := (others => (others => '0'));
    variable index_start, index_end : natural;
    variable line_format            : character;
    variable content                : cw_mem_array;
  begin
    file_open(file_in, "cw_input.txt", read_mode);
    while not endfile(file_in) loop
      readline(file_in, line_in);
      line_format := line_in.all(1);
      case line_format is
        when 'r' | 'r' =>
          read(line_in, line_format);
          read(line_in, index_start);
          read(line_in, index_end);
          read(line_in, content);
          cw_mem_ret(index_start to index_end) := (index_start to index_end => content);
        when 's' | 's' =>
          read(line_in, line_format);
          read(line_in, index_start);
          read(line_in, content);
          cw_mem_ret(index_start) := content;
        when '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' =>
          read(line_in, index_start);
          read(line_in, content);
          cw_mem_ret(index_start) := content;
        when '#'    => null;
        when others => report "invalid line... line is skipped\n" & line_in.all severity warning;
      end case;
    end loop;
    return cw_mem_ret;
  end function;
end package body;
