library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.alu_types.all;

package cu_hw_types is

-- control unit std_logic_vector sizes
  constant opcode_size   : natural := 6;   -- opcode field size
  constant func_size     : natural := 11;  -- func field size 
  constant cw_array_size : natural := 25;  -- cw size

-- change the values of the instructions coding as you want, depending also on the type of control unit choosen
  subtype cw_array is std_logic_vector(cw_array_size-1 downto 0);
  type cw_mem_matrix is array (natural range 0 to 2**opcode_size-1) of cw_array;
  subtype opcode_array is std_logic_vector(opcode_size-1 downto 0);
  subtype func_array is std_logic_vector(func_size-1 downto 0);

-- define the control word for nop instruction
  constant cw_nop : cw_array := (others => '0');

-- r-type instruction -> opcode field
  constant rtype       : natural := 16#00#;  -- for any register-to-register operation
-- r-type instruction -> func field
--
  constant rtype_sll   : natural := 16#04#;
  constant rtype_srl   : natural := 16#06#;
  constant rtype_sra   : natural := 16#07#;
  constant rtype_add   : natural := 16#20#;
  constant rtype_addu  : natural := 16#21#;
  constant rtype_sub   : natural := 16#22#;
  constant rtype_subu  : natural := 16#23#;
  constant rtype_and   : natural := 16#24#;
  constant rtype_or    : natural := 16#25#;
  constant rtype_xor   : natural := 16#26#;
  constant rtype_seq   : natural := 16#28#;
  constant rtype_sne   : natural := 16#29#;
  constant rtype_slt   : natural := 16#2a#;
  constant rtype_sgt   : natural := 16#2b#;
  constant rtype_sle   : natural := 16#2c#;
  constant rtype_sge   : natural := 16#2d#;
  constant rtype_sltu  : natural := 16#3a#;
  constant rtype_sgtu  : natural := 16#3b#;
  constant rtype_sleu  : natural := 16#3c#;
  constant rtype_sgeu  : natural := 16#3d#;
  -- modified instruction list
  constant rtype_mult  : natural := 16#3e#;
  constant rtype_multu : natural := 16#3f#;
-- i-type instruction -> opcode field
  constant nop         : natural := 16#15#;
  constant itype_addi  : natural := 16#08#;
  constant itype_addui : natural := 16#09#;
  constant itype_subui : natural := 16#0a#;
  constant itype_subi  : natural := 16#0b#;
  constant itype_andi  : natural := 16#0c#;
  constant itype_ori   : natural := 16#0d#;
  constant itype_xori  : natural := 16#0e#;
  constant itype_slli  : natural := 16#14#;
  constant itype_srli  : natural := 16#16#;
  constant itype_srai  : natural := 16#17#;
  constant itype_seqi  : natural := 16#18#;
  constant itype_snei  : natural := 16#19#;
  constant itype_sgti  : natural := 16#1a#;
  constant itype_sgtui : natural := 16#1b#;
  constant itype_sgei  : natural := 16#1c#;
  constant itype_sgeui : natural := 16#1d#;
  constant itype_slti  : natural := 16#3a#;
  constant itype_sltui : natural := 16#3b#;
  constant itype_slei  : natural := 16#3c#;
  constant itype_sleui : natural := 16#3d#;
-- jump instruction -> opcode field
  constant j           : natural := 16#02#;
  constant jal         : natural := 16#03#;
  constant jr          : natural := 16#12#;
  constant jalr        : natural := 16#13#;
-- branch instruction -> opcode field
  constant beqz        : natural := 16#04#;
  constant bnez        : natural := 16#05#;
-- load instruction -> opcode field
  constant lhi         : natural := 16#0f#;
  constant lb          : natural := 16#20#;
  constant lw          : natural := 16#23#;
  constant lbu         : natural := 16#24#;
  constant lhu         : natural := 16#25#;
-- store instruction -> opcode field
  constant sb          : natural := 16#28#;
  constant sw          : natural := 16#2b#;

end package;
