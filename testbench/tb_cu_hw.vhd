library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.cu_hw_types.all;

-- wrong testbench

entity tb_cu_hw is
end entity;

architecture test of tb_cu_hw is
  component cu_hw is
    port (
      -- first pipe stage outputs
      en1     : out std_logic;  -- enables the register file and the pipeline registers
      rf1     : out std_logic;  -- enables the read port 1 of the register file
      rf2     : out std_logic;  -- enables the read port 2 of the register file
      -- second pipe stage outputs
      en2     : out std_logic;          -- enables the pipe registers
      s1      : out std_logic;  -- input selection of the first multiplexer
      s2      : out std_logic;  -- input selection of the second multiplexer
      -- alu1   : out std_logic;           -- alu control bit
      -- alu2   : out std_logic;           -- alu control bit
      alu_out : out alu_array;          -- alu control bits
      -- third pipe stage outputs
      en3     : out std_logic;  -- enables the memory and the pipeline registers
      rm      : out std_logic;          -- enables the read-out of the memory
      wm      : out std_logic;          -- enables the write-in of the memory
      wf1     : out std_logic;  -- enables the write port of the register file
      s3      : out std_logic;          -- input selection of the multiplexer
      -- inputs
      opcode  : in  opcode_array;
      func    : in  func_array;
      clk     : in  std_logic;          -- clock
      rst     : in  std_logic           -- reset:active-low
      );                                -- register file write enable
  end component;

  constant clk_period     : time      := 4 ns;
  constant test_nop_delay : time      := 0 * clk_period;
  signal clk_period_s     : time      := clk_period;
  signal clk_t, rst_t     : std_logic := '0';
  signal opc_t            : opcode_array;
  signal func_t           : func_array;

  signal en1_t, rf1_t, rf2_t               : std_logic;
  signal en2_t, s1_t, s2_t, alu1_t, alu2_t : std_logic;
  signal alu_out_t                         : alu_array;
  signal en3_t, rm_t, wm_t, wf1_t, s3_t    : std_logic;

  signal opname : string(1 to 14);  --used only to indicate during simulation current

begin
  clk_t <= not clk_t after clk_period/2;

  dut : cu_hw port map(
    en1 => en1_t,
    rf1 => rf1_t,
    rf2 => rf2_t,
    en2 => en2_t,
    s1  => s1_t,
    s2  => s2_t,
    alu_out_t,
    en3_t,
    rm_t,
    wm_t,
    wf1_t,
    s3_t,
    opc_t,
    func_t,
    clk_t,
    rst_t);

  test_proc : process
  begin
    opc_t  <= (others => '0');
    func_t <= (others => '0');
    rst_t  <= '0';
    wait for clk_period;

    rst_t  <= '1';
    opc_t  <= rtype;
    func_t <= rtype_add;
    wait for clk_period;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for test_nop_delay;

    opc_t  <= rtype;
    func_t <= rtype_sub;
    wait for clk_period;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for test_nop_delay;

    opc_t  <= rtype;
    func_t <= rtype_and_op;
    wait for clk_period;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for test_nop_delay;

    opc_t  <= rtype;
    func_t <= rtype_or_op;
    wait for clk_period;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for test_nop_delay;

    func_t <= (others => '0');
    opc_t  <= itype_addin1;
    wait for clk_period;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for test_nop_delay;

    opc_t <= itype_subin1;
    wait for clk_period;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for test_nop_delay;

    opc_t <= itype_andin1_op;
    wait for clk_period;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for test_nop_delay;

    opc_t <= itype_orin1_op;
    wait for clk_period;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for test_nop_delay;

    opc_t <= itype_addi2;
    wait for clk_period;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for test_nop_delay;

    opc_t <= itype_subi2;
    wait for clk_period;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for test_nop_delay;

    opc_t <= itype_andi2_op;
    wait for clk_period;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for test_nop_delay;

    opc_t <= itype_ori2_op;
    wait for clk_period;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for test_nop_delay;

    opc_t <= itype_mov;
    wait for clk_period;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for test_nop_delay;

    opc_t <= itype_s_reg1;
    wait for clk_period;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for test_nop_delay;

    --opc_t <= itype_s_mem1;
    --wait for clk_period;

    -- opc_t <= nop;
    -- func_t <= (others => '0');
    -- wait for test_nop_delay;

    opc_t <= itype_l_mem1;
    wait for clk_period;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for test_nop_delay;

    opc_t <= itype_s_reg2;
    wait for clk_period;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for test_nop_delay;

    opc_t <= itype_s_mem2;
    wait for clk_period;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for test_nop_delay;

    opc_t <= itype_l_mem2;
    wait for clk_period;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for test_nop_delay;

    opc_t  <= nop;
    func_t <= (others => '0');
    wait for 3 * clk_period;

    assert false report "testbench finished" severity failure;
    wait;

  end process;

  print : process(opc_t, func_t)
  begin
    case opc_t is
      when rtype =>
        case func_t is
          when rtype_add    => opname <= "     rtype_add";
          when rtype_sub    => opname <= "     rtype_sub";
          when rtype_and_op => opname <= "  rtype_and_op";
          when rtype_or_op  => opname <= "   rtype_or_op";
          when others       => opname <= "         nop";
        end case;
      when itype_addin1    => opname <= "   itype_addin1";
      when itype_subin1    => opname <= "   itype_subin1";
      when itype_andin1_op => opname <= "itype_andin1_op";
      when itype_orin1_op  => opname <= " itype_orin1_op";
      when itype_addi2     => opname <= "   itype_addi2";
      when itype_subi2     => opname <= "   itype_subi2";
      when itype_andi2_op  => opname <= "itype_andi2_op";
      when itype_ori2_op   => opname <= " itype_ori2_op";
      when itype_mov       => opname <= "     itype_mov";
      when itype_s_reg1    => opname <= "  itype_s_reg1";
      -- when itype_s_mem1        => opname <= "  itype_s_mem1";
      when itype_l_mem1    => opname <= "  itype_l_mem1";
      when itype_s_reg2    => opname <= "  itype_s_reg2";
      when itype_s_mem2    => opname <= "  itype_s_mem2";
      when itype_l_mem2    => opname <= "  itype_l_mem2";
      when others          => opname <= "            nop";
    end case;
  end process;
end architecture;
