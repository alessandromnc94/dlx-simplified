library ieee;
use ieee.std_logic_1164.all;

use work.alu_types.all;
use work.cu_hw_types.all;
use work.my_const.all;

entity dlx is
  port (
    rst : in std_logic;
    clk : in std_logic
    );
end entity;

architecture structural of dlx is

  component cu_hw is
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
  end component;

  component datapath is
    generic (
      imm_val_size  : natural := 16;
      j_val_size    : natural := 26;
      reg_addr_size : natural := 32;
      n_bit         : natural := 32
      );
    port (
      -- input
      instr      : in     std_logic_vector(n_bit-1 downto 0);  --current instruction from iram, feeds the ir
      lmdin      : in     std_logic_vector(n_bit-1 downto 0);  --lmd register data input
      clk        : in     std_logic;    --clock signal
      rst        : in     std_logic;    --general reset signal
      -- 1st stage
      pce        : in     std_logic;    --program counter enable
      npce       : in     std_logic;    --npc counter enable
      ire        : in     std_logic;    --instruction register enable
      -- 2nd stage
      --register file signals
      rfe        : in     std_logic;    --enable
      rfr1       : in     std_logic;    --read enable 1
      rfr2       : in     std_logic;    --read enable 2
      rfw        : in     std_logic;    --write enable
      --branch unit signals
      be         : in     std_logic;    --branch enable
      bnez       : in     std_logic;    --beqz/!bnez
      jr         : in     std_logic;    --jr/!nojr
      jmp        : in     std_logic;    --jmp/!nojmp
      --sign extender and registers signals
      see        : in     std_logic;    --sign extender enable
      ae         : in     std_logic;    --a register enable
      ben        : in     std_logic;    --b register enable
      ie         : in     std_logic;    --immediate register enable
      pre        : in     std_logic;    --pc pipeline reg enable
      aw1e       : in     std_logic;    --address write1 reg enable
      -- 3rd stage
      --alu signals
      alusel     : in     alu_array;    --alu operation selectors
      --muxes and registers signals
      m3s        : in     std_logic;    --mux 3 selector
      aoe        : in     std_logic;    --alu_out registes enable
      mee        : in     std_logic;    --me register enable
      mps        : in     std_logic;    --mux from pc selector
      mss        : in     std_logic;    --mux to sum 8 to pc selector
      aw2e       : in     std_logic;    --address write2 reg enable
      -- 4th stage
      r1e        : in     std_logic;    --register 1 enable
      msksel2    : in     std_logic;    --selector for load byte mask
      msksigned2 : in     std_logic;    -- mask is signed if enabled
      lmde       : in     std_logic;    --lmd register enable
      aw3e       : in     std_logic;    --address write3 reg enable
      -- 5th stage
      m5s        : in     std_logic;    --mux 5 selector
      mws        : in     std_logic;  --write addr mux selector(mux is physically in decode stage, but driven in wb stage)
      -- outputs
      pcout      : buffer std_logic_vector(n_bit-1 downto 0);  --program counter output per le dimensioni puoi cambiarlo, la iram puo' essere diversa dalla dram
      aluout     : buffer std_logic_vector(n_bit-1 downto 0);  --alu outpud data
      meout      : out    std_logic_vector(n_bit-1 downto 0)  --me register data out
      irout      : buffer std_logic_vector(n_bit-1 downto 0)   -- ir out for cu
      );
  end component;

  component iram is
    generic (
      ram_depth       : natural;
      data_cell_width : natural;
      addr_size       : natural
      );
    port (
      rst  : in  std_logic;
      addr : in  std_logic_vector(addr_size - 1 downto 0);
      dout : out std_logic_vector(4*data_cell_width - 1 downto 0)
      );

  end component;

  component dram is
    generic (
      ram_depth       : natural;
      data_cell_width : natural;
      addr_size       : natural
      );
    port (
      rst               : in  std_logic;
      addr_r            : in  std_logic_vector(addr_size - 1 downto 0);
      addr_w            : in  std_logic_vector(addr_size - 1 downto 0);
      read_enable       : in  std_logic;
      write_enable      : in  std_logic;
      write_single_cell : in  std_logic;
      din               : in  std_logic_vector(4*data_cell_width - 1 downto 0);
      dout              : out std_logic_vector(4*data_cell_width - 1 downto 0)
      );

  end component;
  
  signal reg_file_read_1    : std_logic;
  signal reg_file_read_2    : std_logic;
  signal reg_imm_en         : std_logic;
  signal imm_sign_ext_en    : std_logic;
  signal branch_en          : std_logic;
  signal branch_nez         : std_logic;
  signal jump_en            : std_logic;
  signal jr_en              : std_logic;
  signal jl_en              : std_logic;
  --signal forwarding_in_1_en : std_logic;
  --signal forwarding_in_2_en : std_logic;
  signal alu_op_sel         : alu_array;
  signal alu_pc_sel         : std_logic;
  signal alu_get_imm_in     : std_logic;
  signal alu_out_reg_en     : std_logic;
  signal b_bypass_en        : std_logic;
  signal add_w_pipe_2_en    : std_logic;
  signal alu_bypass_en      : std_logic;
  signal dram_read_en       : std_logic;
  signal dram_write_en      : std_logic;
  signal dram_write_byte    : std_logic;
  signal mask_2_signed      : std_logic;
  signal mask_2_en          : std_logic;
  signal add_w_pipe_3_en    : std_logic;
  signal mem_out_sel        : std_logic;
  signal reg_file_write     : std_logic;
  signal branch_taken       : std_logic;
  signal opcode             : opcode_array;
  signal func               : func_array;

  constant datapath_imm_val_size  : natural := 16;
  constant datapath_j_val_size    : natural := 26;
  constant datapath_reg_addr_size : natural := 32;
  constant datapath_n_bit         : natural := 32;
  signal pce             : std_logic;
  signal npce            : std_logic;
  signal rfe             : std_logic;
  signal ae              : std_logic;
  signal ben             : std_logic;
  signal ie              : std_logic;
  signal ire             : std_logic;
  signal pre             : std_logic;
  signal aw1e            : std_logic;
  signal lmde            : std_logic;
  signal datapath_m3s             : std_logic;
  signal mee             : std_logic;
  signal datapath_mps             : std_logic;
  signal datapath_mss             : std_logic;
  signal r1e             : std_logic;
  signal datapath_lmde            : std_logic;
  signal datapath_m4s             : std_logic;
  signal datapath_m5s             : std_logic;
  signal datapath_mws             : std_logic;
  signal pcout           : std_logic_vector(datapath_n_bit-1 downto 0);
  signal aluout          : std_logic_vector(datapath_n_bit-1 downto 0);
  signal meout           : std_logic_vector(datapath_n_bit-1 downto 0);
  
  constant iram_addr_size       : natural := 32;
  constant iram_depth           : natural := 1024*4;
  constant iram_data_cell_width : natural := 8;
  signal iram_addr              : std_logic_vector(iram_addr_size - 1 downto 0);
  signal iram_dout              : std_logic_vector(4*iram_data_cell_width - 1 downto 0);

  constant dram_addr_size       : natural := 32;
  constant dram_depth           : natural := 1024*4;
  constant dram_data_cell_width : natural := 8;
  signal dram_dout              : std_logic_vector(4*dram_data_cell_width - 1 downto 0);
  signal irout                  : std_logic_vector(datapath_n_bit-1 downto 0);

begin
  
  -- stuck signals
  pce  <= '1';
  npce <= '1';
  rfe  <= '1';
  ae   <= '1';
  ben  <= '1';
  ie   <= '1';
  ire  <= '1';
  pre  <= '1';
  aw1e <= '1';
  mee  <= '1';
  -- mss  <= '1';
  r1e  <= '1';
  lmde <= '1';

  datapath0 : datapath generic map (
    imm_val_size  => datapath_imm_val_size,
    j_val_size    => datapath_j_val_size,
    reg_addr_size => datapath_reg_addr_size,
    n_bit         => datapath_n_bit
    ) port map (
      instr      => iram_dout,
      lmdin      => dram_dout,
      clk        => clk,
      rst        => rst,
      pce        => pce,
      npce       => npce,
      ire        => reg_imm_en,
      rfe        => rfe,
      rfr1       => reg_file_read_1,
      rfr2       => reg_file_read_2,
      rfw        => reg_file_write,
      be         => branch_en,
      bnez       => branch_nez,
      jr         => jr_en,
      jmp        => jump_en,
      see        => imm_sign_ext_en,
      ae         => ae,
      ben        => ben,
      ie         => ie,
      pre        => pre,
      aw1e       => aw1e,
      alusel     => alu_op_sel,
      m3s        => alu_get_imm_in,
      aoe        => alu_out_reg_en,
      mee        => mee,
      mps        => jl_en,
      mss        => datapath_mss, --????
      aw2e       => add_w_pipe_2_en,
      r1e        => r1e,
      msksel2    => mask_2_en,
      msksigned2 => mask_2_signed,
      lmde       => lmde,
      aw3e       => add_w_pipe_3_en,
      m5s        => mem_out_sel,
      mws        => alu_bypass_en,
      pcout      => pcout,
      aluout     => aluout,
      meout      => meout,
      irout      => irout
      );

  cu_hw0 : cu_hw port map (
    reg_file_read_1    => reg_file_read_1,
    reg_file_read_2    => reg_file_read_2,
    reg_imm_en         => reg_imm_en,
    imm_sign_ext_en    => imm_sign_ext_en,
    branch_en          => branch_en,
    branch_nez         => branch_nez,
    jump_en            => jump_en,
    jr_en              => jr_en,
    jl_en              => jl_en,
    forwarding_in_1_en => open,
    forwarding_in_2_en => open,
    alu_op_sel         => alu_op_sel,
    alu_pc_sel         => alu_pc_sel,
    alu_get_imm_in     => alu_get_imm_in,
    alu_out_reg_en     => alu_out_reg_en,
    b_bypass_en        => b_bypass_en,
    add_w_pipe_2_en    => add_w_pipe_2_en,
    alu_bypass_en      => alu_bypass_en,
    dram_read_en       => dram_read_en,
    dram_write_en      => dram_write_en,
    dram_write_byte    => dram_write_byte,
    mask_2_signed      => mask_2_signed,
    mask_2_en          => mask_2_en,
    add_w_pipe_3_en    => add_w_pipe_3_en,
    mem_out_sel        => mem_out_sel,
    reg_file_write     => reg_file_write,
    branch_taken       => branch_taken, --????
    opcode             => irout(n_bit-1 downto n_bit-opcode_size),
    func               => irout(func_size-1 downto 0),
    clk                => clk,
    rst                => rst
    );

  iram0 : iram generic map (
    ram_depth       => iram_depth,
    data_cell_width => iram_data_cell_width,
    addr_size       => iram_addr_size
    ) port map (
      rst  => rst,
      addr => pcout,
      dout => iram_dout
      );

  dram0 : dram generic map (
    ram_depth       => dram_depth,
    data_cell_width => dram_data_cell_width,
    addr_size       => dram_addr_size
    ) port map (
      rst               => rst,
      addr_r            => aluout,
      addr_w            => aluout,
      read_enable       => dram_read_en,
      write_enable      => dram_write_en,
      write_single_cell => dram_write_byte,
      din               => meout,
      dout              => dram_dout
      );

end architecture;
