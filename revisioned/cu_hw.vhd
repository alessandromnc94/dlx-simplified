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

entity cu_hw is
  port (
    -- cw
    -- first pipe stage outputs: fetch
    -- pc_en              : out std_logic;
    -- npc_en             : out std_logic;
    -- ir_en              : out std_logic;
    --
    -- second pipe stage outputs: decode
    -- reg_file_en        : out std_logic;
    reg_file_read_1    : out std_logic;  -- enable read from out_1 & store in reg a
    reg_file_read_2    : out std_logic;  -- same as before for out 2 & reg b
    reg_imm_en         : out std_logic;  -- load data from immediate
    imm_sign_ext_en    : out std_logic;
    branch_en          : out std_logic;
    branch_nez         : out std_logic;
    jump_en            : out std_logic;
    jr_en              : out std_logic;  -- enable also pc_delay and store_in_r_31
    jl_en              : out std_logic;
    -- check
    forwarding_in_1_en : out std_logic;  -- enable forwarding 1
    forwarding_in_2_en : out std_logic;  -- enable forwarding 2
    --
    -- third pipe stage outputs: execute
    -- alu selector
    alu_op_sel         : out alu_array;
    -- cw_mem signals
    alu_pc_sel         : out std_logic;  -- put pc on alu in_1 && "+8" on alu in_2 
    alu_get_imm_in     : out std_logic;
    alu_out_reg_en     : out std_logic;
    b_bypass_en        : out std_logic;
    add_w_pipe_2_en    : out std_logic;
    --
    -- fourth pipe stage outputs: memory
    -- cw_mem signals
    alu_bypass_en      : out std_logic;
    dram_read_en       : out std_logic;
    dram_write_en      : out std_logic;
    dram_write_byte    : out std_logic;
    mask_2_signed      : out std_logic;
    mask_2_en          : out std_logic;
    add_w_pipe_3_en    : out std_logic;
    --
    -- fifth pipe stage outputs: write back
    -- cw
    mem_out_sel        : out std_logic;
    reg_file_write     : out std_logic;
    -- inputs
    branch_taken       : in  std_logic;
    opcode             : in  opcode_array;
    func               : in  func_array;
    clk                : in  std_logic;
    rst                : in  std_logic
    );
end entity;

-- architectures

-- behavioral architecture
architecture behavioral of cu_hw is

  -- lut for control word
  signal cw_mem : cw_mem_matrix := (
    nop         => cw_nop,
    rtype       => "1100000001100011100000101",
    itype_addi  => "1010000001001011100000101",
    itype_addui => "1011000001001011100000101",
    itype_andi  => "1010000001001011100000101",
    beqz        => "1010100001000000000000000",
    bnez        => "1010110001000000000000000",
    j           => "0011001000000000000000000",
    jal         => "0011001011010001100000101",
    jalr        => "1010001111010001100000101",
    jr          => "1010001101000000000000000",
    lb          => "1011000001101011010011111",
    lbu         => "1010000001101011010001111",
    lw          => "1011000001001011010010111",
    itype_ori   => "1010000001001011100000101",
    sb          => "1111000001101110001100000",
    itype_seqi  => "1011000001001011100000101",
    itype_sgei  => "1011000001001011100000101",
    itype_sgeui => "1010000001001011100000101",
    itype_sgti  => "1011000001001011100000101",
    itype_sgtui => "1010000001001011100000101",
    itype_slei  => "1011000001001011100000101",
    itype_sleui => "1010000001001011100000101",
    itype_slli  => "1010000001101011100000101",
    itype_slti  => "1011000001001011100000101",
    itype_sltui => "1010000001001011100000101",
    itype_snei  => "1011000001001011100000101",
    itype_srai  => "1010000001101011100000101",
    itype_srli  => "1010000001101011100000101",
    itype_subi  => "1011000001001011100000101",
    itype_subui => "1010000001001011100000101",
    sw          => "1111000001101110001000000",
    itype_xori  => "1010000001001011100000101",
    others      => cw_nop               -- instructions not defined
    );
  -- control word from lut
  signal cw               : cw_array                                    := (others => '0');
  -- split cw in stages
  constant cw1_array_size : natural                                     := cw_array_size;
  signal cw1              : cw_array                                    := (others => '0');
  constant cw2_array_size : natural                                     := cw1_array_size;
  signal cw2              : std_logic_vector(cw2_array_size-1 downto 0) := (others => '0');
  constant cw3_array_size : natural                                     := cw2_array_size-11;
  signal cw3              : std_logic_vector(cw3_array_size-1 downto 0) := (others => '0');
  constant cw4_array_size : natural                                     := cw3_array_size-5;
  signal cw4              : std_logic_vector(cw4_array_size-1 downto 0) := (others => '0');
  constant cw5_array_size : natural                                     := cw4_array_size-7;
  signal cw5              : std_logic_vector(cw5_array_size-1 downto 0) := (others => '0');
  -- delay alu control word
  signal alu1, alu2, alu3 : alu_array                                   := (others => '0');
  -- signals to manage cw words
  signal alu              : alu_array                                   := (others => '0');  -- alu code from func

begin
  -- get output from luts
  cw <= cw_mem(conv_integer(unsigned(opcode)));

-- todo
  -- first pipe stage outputs
  -- empty ?
  -- second pipe stage outputs
  reg_file_read_1    <= cw2(cw2_array_size-1);
  reg_file_read_2    <= cw2(cw2_array_size-2);
  reg_imm_en         <= cw2(cw2_array_size-3);
  imm_sign_ext_en    <= cw2(cw2_array_size-4);
  branch_en          <= cw2(cw2_array_size-5);
  branch_nez         <= cw2(cw2_array_size-6);
  jump_en            <= cw2(cw2_array_size-7);
  jr_en              <= cw2(cw2_array_size-8);
  jl_en              <= cw2(cw2_array_size-9);
  forwarding_in_1_en <= cw2(cw2_array_size-10);
  forwarding_in_2_en <= cw2(cw2_array_size-11);
  -- third pipe stage outputs
  alu_op_sel         <= alu3;
  --
  alu_pc_sel         <= cw3(cw3_array_size-1);
  alu_get_imm_in     <= cw3(cw3_array_size-2);
  alu_out_reg_en     <= cw3(cw3_array_size-3);
  b_bypass_en        <= cw3(cw3_array_size-4);
  add_w_pipe_2_en    <= cw3(cw3_array_size-5);
  -- fourth pipe stage outputs
  alu_bypass_en      <= cw4(cw4_array_size-1);
  dram_read_en       <= cw4(cw4_array_size-2);
  dram_write_en      <= cw4(cw4_array_size-3);
  dram_write_byte    <= cw4(cw4_array_size-4);
  mask_2_signed      <= cw4(cw4_array_size-5);
  mask_2_en          <= cw4(cw4_array_size-6);
  add_w_pipe_3_en    <= cw4(cw4_array_size-7);
  -- fifth pipe stage outputs
  mem_out_sel        <= cw5(cw5_array_size-1);
  reg_file_write     <= cw5(cw5_array_size-2);
  -- process to pipeline control words
  cw_pipe : process (clk, rst)
  begin
    if rst = reset_value then                   -- asynchronous reset (active low)
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
