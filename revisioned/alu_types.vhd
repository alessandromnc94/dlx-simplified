library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

package alu_types is

  constant alu_array_size : natural := 5;
  subtype alu_array is std_logic_vector(alu_array_size-1 downto 0);

  constant alu_add   : alu_array := conv_std_logic_vector(0, alu_array_size);
  constant alu_sub   : alu_array := conv_std_logic_vector(1, alu_array_size);
  constant alu_and   : alu_array := conv_std_logic_vector(2, alu_array_size);
  constant alu_nand  : alu_array := conv_std_logic_vector(3, alu_array_size);
  constant alu_or    : alu_array := conv_std_logic_vector(4, alu_array_size);
  constant alu_nor   : alu_array := conv_std_logic_vector(5, alu_array_size);
  constant alu_xor   : alu_array := conv_std_logic_vector(6, alu_array_size);
  constant alu_xnor  : alu_array := conv_std_logic_vector(7, alu_array_size);
  constant alu_sll   : alu_array := conv_std_logic_vector(8, alu_array_size);
  constant alu_srl   : alu_array := conv_std_logic_vector(9, alu_array_size);
  constant alu_sla   : alu_array := conv_std_logic_vector(10, alu_array_size);
  constant alu_sra   : alu_array := conv_std_logic_vector(11, alu_array_size);
  constant alu_rol   : alu_array := conv_std_logic_vector(12, alu_array_size);
  constant alu_ror   : alu_array := conv_std_logic_vector(13, alu_array_size);
  constant alu_seq   : alu_array := conv_std_logic_vector(14, alu_array_size);
  constant alu_sgtu  : alu_array := conv_std_logic_vector(15, alu_array_size);
  constant alu_sltu  : alu_array := conv_std_logic_vector(16, alu_array_size);
  constant alu_sgeu  : alu_array := conv_std_logic_vector(17, alu_array_size);
  constant alu_sleu  : alu_array := conv_std_logic_vector(18, alu_array_size);
  constant alu_sne   : alu_array := conv_std_logic_vector(19, alu_array_size);
  constant alu_sze   : alu_array := conv_std_logic_vector(20, alu_array_size);
  constant alu_sgt   : alu_array := conv_std_logic_vector(21, alu_array_size);
  constant alu_slt   : alu_array := conv_std_logic_vector(22, alu_array_size);
  constant alu_sge   : alu_array := conv_std_logic_vector(23, alu_array_size);
  constant alu_sle   : alu_array := conv_std_logic_vector(24, alu_array_size);
  constant alu_multu : alu_array := conv_std_logic_vector(25, alu_array_size);
  constant alu_mult  : alu_array := conv_std_logic_vector(26, alu_array_size);

  constant alu_nop : alu_array := alu_add;
end package;
