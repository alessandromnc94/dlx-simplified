-- cose da fare:
-- + inserire segnali aggiunti
-- + estendere case per la alu

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.alu_types.all;
use work.cu_hw_types.all;
-- use work.cu_hw_functions.all;
use work.my_const.all;

entity cu_hw is
  port (
    -- decode   
    reg_file_read_1 : out std_logic;
    reg_file_read_2 : out std_logic;
    reg_imm_en      : out std_logic;
    imm_sign_ext_en : out std_logic;
    write_in_r31_en : out std_logic;
-- execute      
    branch_en       : out std_logic;
    branch_nez      : out std_logic;
    jump_en         : out std_logic;
    jr_en           : out std_logic;
    jl_en           : out std_logic;
    alu_pc_sel      : out std_logic;
    alu_get_imm_in  : out std_logic;
    alu_out_reg_en  : out std_logic;
    b_bypass_en     : out std_logic;
    add_w_pipe_2_en : out std_logic;
-- mem
    dram_read_en    : out std_logic;
    dram_write_en   : out std_logic;
    dram_write_byte : out std_logic;
    mask_2_signed   : out std_logic;
    mask_2_en       : out std_logic;
    add_w_pipe_3_en : out std_logic;
-- wb   
    mem_out_sel     : out std_logic;
    reg_file_write  : out std_logic :

    -- inputs
    branch_taken : in std_logic;
    opcode       : in opcode_array;
    func         : in func_array;
    clk          : in std_logic;
    rst          : in std_logic
    );
end entity;

-- architectures

-- behavioral architecture
architecture behavioral of cu_hw is

  -- lut for control word
  signal cw_mem : cw_mem_matrix := (
    rtype_add   => "11000000000010110000111",
    itype_addi  => "10100000000110110000111",
    rtype_addu  => "11000000000010110000111",
    itype_addui => "10110000000110110000111",
    rtype_and   => "11000000000010110000111",
    itype_andi  => "10100000000110110000111",
    beqz        => "10100100000100010000010",
    bnez        => "10100110000100010000010",
    j           => "00100001000100010000010",
    jal         => "00101001011110110000111",
    jalr        => "10001001111010110000111",
    jr          => "10000001100000010000010",
    lb          => "10100000000110100011101",
    lbu         => "10100000000110100001101",
    lw          => "10100000000110100000101",
    rtype_mult  => "11000000000010110000111",
    rtype_multu => "11000000000010110000111",
    nop         => cw_nop,
    rtype_or    => "11000000000010110000111",
    itype_ori   => "10100000000110110000111",
    sb          => "11100000000111011100010",
    rtype_seq   => "11000000000010110000111",
    itype_seqi  => "10100000000110110000111",
    rtype_sge   => "11000000000010110000111",
    itype_sgei  => "10100000000110110000111",
    rtype_sgeu  => "11000000000010110000111",
    itype_sgeui => "10110000000110110000111",
    rtype_sgt   => "11000000000010110000111",
    itype_sgti  => "10100000000110110000111",
    rtype_sgtu  => "11000000000010110000111",
    itype_sgtui => "10110000000110110000111",
    rtype_sle   => "11000000000010110000111",
    itype_slei  => "10100000000110110000111",
    rtype_sleu  => "11000000000010110000111",
    itype_sleui => "10110000000110110000111",
    rtype_sll   => "11000000000010110000111",
    itype_slli  => "10100000000110110000111",
    rtype_slt   => "11000000000010110000111",
    itype_slti  => "10100000000110110000111",
    rtype_sltu  => "11000000000010110000111",
    itype_sltui => "10110000000110110000111",
    rtype_sne   => "11000000000010110000111",
    itype_snei  => "10100000000110110000111",
    rtype_sra   => "11000000000010110000111",
    itype_srai  => "10100000000110110000111",
    rtype_srl   => "11000000000010110000111",
    itype_srli  => "10100000000110110000111",
    rtype_sub   => "11000000000010110000111",
    itype_subi  => "10100000000110110000111",
    rtype_subu  => "11000000000010110000111",
    itype_subui => "10110000000110110000111",
    sw          => "11100000000111011000010",
    rtype_xor   => "11000000000010110000111",
    itype_xori  => "10100000000110110000111",
    others      => cw_nop               -- instructions not defined
    );
  -- control word from lut
  signal cw               : cw_array                                    := (others => '0');
  -- split cw in stages
  constant cw1_array_size : natural                                     := cw_array_size;
  signal cw1              : cw_array                                    := (others => '0');
  constant cw2_array_size : natural                                     := cw1_array_size;
  signal cw2              : std_logic_vector(cw2_array_size-1 downto 0) := (others => '0');
  constant cw3_array_size : natural                                     := cw2_array_size-5;
  signal cw3              : std_logic_vector(cw3_array_size-1 downto 0) := (others => '0');
  constant cw4_array_size : natural                                     := cw3_array_size-10;
  signal cw4              : std_logic_vector(cw4_array_size-1 downto 0) := (others => '0');
  constant cw5_array_size : natural                                     := cw4_array_size-6;
  signal cw5              : std_logic_vector(cw5_array_size-1 downto 0) := (others => '0');
  -- delay alu control word
  signal alu1, alu2, alu3 : alu_array                                   := (others => '0');
  -- signals to manage cw words
  signal alu              : alu_array                                   := (others => '0');  -- alu code from func

begin
  -- get output from luts
  cw <= cw_mem(conv_integer(unsigned(opcode)));


  -- decode     
  reg_file_read_1 <= cw(cwx_array_size-1);
  reg_file_read_2 <= cw(cwx_array_size-2);
  reg_imm_en      <= cw(cwx_array_size-3);
  imm_sign_ext_en <= cw(cwx_array_size-4);
  write_in_r31_en <= cw(cwx_array_size-5);
-- execute      
  branch_en       <= cw(cwx_array_size-1);
  branch_nez      <= cw(cwx_array_size-2);
  jump_en         <= cw(cwx_array_size-3);
  jr_en           <= cw(cwx_array_size-4);
  jl_en           <= cw(cwx_array_size-5);
  alu_pc_sel      <= cw(cwx_array_size-6);
  alu_get_imm_in  <= cw(cwx_array_size-7);
  alu_out_reg_en  <= cw(cwx_array_size-8);
  b_bypass_en     <= cw(cwx_array_size-9);
  add_w_pipe_2_en <= cw(cwx_array_size-10);
-- mem
  dram_read_en    <= cw(cwx_array_size-1);
  dram_write_en   <= cw(cwx_array_size-2);
  dram_write_byte <= cw(cwx_array_size-3);
  mask_2_signed   <= cw(cwx_array_size-4);
  mask_2_en       <= cw(cwx_array_size-5);
  add_w_pipe_3_en <= cw(cwx_array_size-6);
-- wb   
  mem_out_sel     <= cw(cwx_array_size-1);
  reg_file_write  <= cw(cwx_array_size-2);
  -- process to pipeline control words
  cw_pipe : process (clk, rst)
  begin
    if rst = reset_value then           -- asynchronous reset (active low)
      cw1  <= (others => '0');
      cw2  <= (others => '0');
      cw3  <= (others => '0');
      cw4  <= (others => '0');
      cw5  <= (others => '0');
      alu1 <= (others => '0');
      alu2 <= (others => '0');
      alu3 <= (others => '0');
    elsif rising_edge(clk) then         -- rising clock edge
      if branch_taken = '0' then
        cw1  <= cw;
        alu1 <= alu;
        cw2  <= cw1(cw2_array_size-1 downto 0);
        alu2 <= alu1;
      else
        alu1 <= alu_nop;
        cw1  <= cw_nop;
        alu2 <= alu_nop;
        cw2  <= cw_nop(cw2_array_size-1 downto 0);
      -- alu3 <= alu_nop;
      -- cw3  <= cw_nop(cw3_array_size-1 downto 0);
      end if;
      cw3  <= cw2(cw3_array_size-1 downto 0);
      alu3 <= alu2;
      cw4  <= cw3(cw4_array_size-1 downto 0);
      cw5  <= cw4(cw5_array_size-1 downto 0);
    end if;
  end process;

-- process to get alu control word
  alu_get_code : process (opcode, func)
  begin
    case conv_integer(unsigned(opcode)) is
      when rtype =>
        case conv_integer(unsigned(func)) is
          when rtype_add | rtype_addu => alu <= alu_add;
          when rtype_sub | rtype_subu => alu <= alu_sub;
          when rtype_sll              => alu <= alu_sll;
          when rtype_srl              => alu <= alu_srl;
          when rtype_sra              => alu <= alu_sra;
          when rtype_slt              => alu <= alu_slt;
          when rtype_sltu             => alu <= alu_sltu;
          when rtype_sle              => alu <= alu_sle;
          when rtype_sleu             => alu <= alu_sleu;
          when rtype_sgt              => alu <= alu_sgt;
          when rtype_sgtu             => alu <= alu_sgtu;
          when rtype_sge              => alu <= alu_sge;
          when rtype_sgeu             => alu <= alu_sgeu;
          when rtype_sne              => alu <= alu_sne;
          when rtype_seq              => alu <= alu_seq;
          when rtype_and              => alu <= alu_and;
          when rtype_or               => alu <= alu_or;
          when rtype_xor              => alu <= alu_xor;
          when rtype_mult             => alu <= alu_mult;
          when rtype_multu            => alu <= alu_multu;
          when others                 => alu <= alu_nop;
        end case;
      -- itype
      when itype_addi | itype_addui => alu <= alu_add;
      when itype_subi | itype_subui => alu <= alu_sub;
      --     when itype_muli               => alu <= alu_mul;
      when itype_slli               => alu <= alu_sll;
      when itype_srli               => alu <= alu_srl;
      when itype_srai               => alu <= alu_sra;
      when itype_slti               => alu <= alu_slt;
      when itype_sltui              => alu <= alu_sltu;
      when itype_slei               => alu <= alu_sle;
      when itype_sleui              => alu <= alu_sleu;
      when itype_sgti               => alu <= alu_sgt;
      when itype_sgtui              => alu <= alu_sgtu;
      when itype_sgei               => alu <= alu_sge;
      when itype_sgeui              => alu <= alu_sgeu;
      when itype_snei               => alu <= alu_sne;
      when itype_seqi               => alu <= alu_seq;
      when itype_andi               => alu <= alu_and;
      when itype_ori                => alu <= alu_or;
      when itype_xori               => alu <= alu_xor;
      -- jump
      when j | jr                   => alu <= alu_nop;
      when jal | jalr               => alu <= alu_nop;
      -- branch
      when beqz                     => alu <= alu_nop;
      when bnez                     => alu <= alu_nop;
      -- store
      when sb | sw                  => alu <= alu_add;
      -- load
      when lb | lbu                 => alu <= alu_add;
      -- when lhi | lhu                => alu <= alu_add;
      when lw                       => alu <= alu_add;
      when others                   => alu <= alu_nop;
    end case;
  end process;
end architecture;
