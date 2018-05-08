library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;

use work.logicals_types.all;
use work.alu_types.all;
use work.my_arith_functions.all;

entity alu is
  generic (
    n : natural := 32
    );
  port (
    in_1   : in  std_logic_vector(n-1 downto 0);
    in_2   : in  std_logic_vector(n-1 downto 0);
    op_sel : in  alu_array;
    -- outputs
    out_s  : out std_logic_vector(n-1 downto 0)
    );
end entity;

architecture behavioral of alu is
  component mux_n_2_1 is
    generic (
      n : natural
      );
    port (
      in_0  : in  std_logic_vector(n-1 downto 0);
      in_1  : in  std_logic_vector(n-1 downto 0);
      s     : in  std_logic;
      out_s : out std_logic_vector(n-1 downto 0)
      );
  end component;
  signal mux_in_2_select : std_logic_vector(n-1 downto 0) := (others => '0');

-- mux_n_6_1 for: output mux and comparator mux
  component mux_n_6_1 is
    generic (
      n : natural
      );
    port (
      in_0  : in  std_logic_vector(n-1 downto 0);
      in_1  : in  std_logic_vector(n-1 downto 0);
      in_2  : in  std_logic_vector(n-1 downto 0);
      in_3  : in  std_logic_vector(n-1 downto 0);
      in_4  : in  std_logic_vector(n-1 downto 0);
      in_5  : in  std_logic_vector(n-1 downto 0);
      s     : in  std_logic_vector(2 downto 0);
      out_s : out std_logic_vector(n-1 downto 0)
      );
  end component;
  signal out_mux_sel  : std_logic_vector(2 downto 0) := (others => '0');
  signal comp_mux_sel : std_logic_vector(2 downto 0) := (others => '0');

  component not_gate_n is
    generic (
      n : natural
      );
    port (
      in_s  : in  std_logic_vector(n-1 downto 0);
      out_s : out std_logic_vector(n-1 downto 0)
      );
  end component;
  signal not_in_2 : std_logic_vector(n-1 downto 0);

  component logicals_n is
    generic (
      n : natural
      );
    port (
      in_1  : in  std_logic_vector(n-1 downto 0);
      in_2  : in  std_logic_vector(n-1 downto 0);
      logic : in  logicals_array;
      out_s : out std_logic_vector(n-1 downto 0)
      );
  end component;
  signal logicals_mode : logicals_array := (others => '0');
  signal logicals_out  : std_logic_vector(n-1 downto 0);

  component booth_multiplier is
    generic (
      n : natural
      );
    port (
      in_1       : in  std_logic_vector(n-1 downto 0);
      in_2       : in  std_logic_vector(n-1 downto 0);
      signed_mul : in  std_logic;
      out_s      : out std_logic_vector(2*n-1 downto 0)
      );
  end component;
  signal mul_out    : std_logic_vector(n-1 downto 0);
  signal signed_mul : std_logic := '0';

  component p4_adder is
    generic (
      n          : natural;
      carry_step : natural
      );
    port (
      in_1      : in  std_logic_vector(n-1 downto 0);
      in_2      : in  std_logic_vector(n-1 downto 0);
      carry_in  : in  std_logic;
      sum       : out std_logic_vector(n-1 downto 0);
      carry_out : out std_logic
      );
  end component;
  signal addsub_out       : std_logic_vector(n-1 downto 0);
  signal addsub_carry_out : std_logic;
  signal addsub_sel_in    : std_logic := '0';

  component zero_comparator is
    generic (
      n : natural
      );
    port (
      in_s  : in  std_logic_vector(n-1 downto 0);
      out_s : out std_logic
      );
  end component;
  signal zero_comp_out : std_logic;

  component comparator is
    port (
      zero_out          : in  std_logic;
      carry_out         : in  std_logic;
      sign_out          : in  std_logic;
      signed_comparison : in  std_logic;
      eq_out            : out std_logic;
      gr_out            : out std_logic;
      lo_out            : out std_logic;
      ge_out            : out std_logic;
      le_out            : out std_logic;
      ne_out            : out std_logic
      );
  end component;

  -- insert shifter/rotator component declaration
  component shifter is
    generic (
      n : natural
      );
    port (
      base_vector    : in  std_logic_vector(n-1 downto 0);
      shift_by_value : in  std_logic_vector(n-1 downto 0);
      left_shift     : in  std_logic;
      arith_shift    : in  std_logic;
      out_s          : out std_logic_vector(n-1 downto 0)
      );
  end component;
  signal shift_out   : std_logic_vector(n-1 downto 0);
  signal left_shift  : std_logic := '0';
  signal arith_shift : std_logic := '0';
-- insert rotator component declaration (re-used left_shift to reduce signals)
  component rotator is
    generic (
      n : natural
      );
    port (
      base_vector     : in  std_logic_vector(n-1 downto 0);
      rotate_by_value : in  std_logic_vector(n-1 downto 0);
      left_rotation   : in  std_logic;
      out_s           : out std_logic_vector(n-1 downto 0)
      );
  end component;
  signal rotate_out : std_logic_vector(n-1 downto 0);

  signal zero_out          : std_logic;
  signal comp_mode         : std_logic_vector(2 downto 0)   := (others => '0');
  signal signed_comparison : std_logic                      := '0';
  signal comp_eq_out       : std_logic_vector(0 downto 0);
  signal comp_gr_out       : std_logic_vector(0 downto 0);
  signal comp_lo_out       : std_logic_vector(0 downto 0);
  signal comp_ge_out       : std_logic_vector(0 downto 0);
  signal comp_le_out       : std_logic_vector(0 downto 0);
  signal comp_ne_out       : std_logic_vector(0 downto 0);
  signal comp_mux_out      : std_logic_vector(n-1 downto 0) := (others => '0');
  constant comp_eq_sel     : std_logic_vector(2 downto 0)   := "000";
  constant comp_ne_sel     : std_logic_vector(2 downto 0)   := "001";
  constant comp_gr_sel     : std_logic_vector(2 downto 0)   := "010";
  constant comp_ge_sel     : std_logic_vector(2 downto 0)   := "011";
  constant comp_lo_sel     : std_logic_vector(2 downto 0)   := "100";
  constant comp_le_sel     : std_logic_vector(2 downto 0)   := "101";

  constant out_adder_value_sel    : std_logic_vector(2 downto 0) := "000";
  constant out_logicals_value_sel : std_logic_vector(2 downto 0) := "001";
  constant out_comp_value_sel     : std_logic_vector(2 downto 0) := "010";
  constant out_mul_value_sel      : std_logic_vector(2 downto 0) := "011";
  constant out_shift_value_sel    : std_logic_vector(2 downto 0) := "100";
  constant out_rotate_value_sel   : std_logic_vector(2 downto 0) := "101";

  signal comparator_eq_out  : std_logic;
  signal comparator_gr_out  : std_logic;
  signal comparator_lo_out  : std_logic;
  signal comparator_ge_out  : std_logic;
  signal comparator_le_out  : std_logic;
  signal comparator_ne_out  : std_logic;
  signal comparator_mux_out : std_logic_vector(n-1 downto 0) := (others => '0');

begin

-- negated version od in_2 is used for sub operation
  not_in_2_gate : not_gate_n generic map (
    n => n
    ) port map (
      in_s  => in_2,
      out_s => not_in_2
      );

-- this mux select the input for p4_adder: s = 0 means in_2 (adding) else not in_2 (subtracting)
  mux_in_2_select_comp : mux_n_2_1 generic map (
    n => n
    ) port map (
      in_0  => in_2,
      in_1  => not_in_2,
      s     => addsub_sel_in,
      out_s => mux_in_2_select
      );

-- booth multiplier
  booth_multiplier_comp : booth_multiplier generic map (
    n => n/2
    ) port map (
      in_1       => in_1(n/2-1 downto 0),
      in_2       => in_2(n/2-1 downto 0),
      signed_mul => signed_mul,
      out_s      => mul_out
      );

-- this adder is used for adding or subtracting two values (addsub_sel_in select the operation)
  p4_adder_comp : p4_adder generic map (
    n          => n,
    carry_step => 4
    ) port map (
      in_1      => in_1,
      in_2      => mux_in_2_select,
      carry_in  => addsub_sel_in,
      sum       => addsub_out,
      carry_out => addsub_carry_out
      );

-- this component does the logic operation between inputs
  logicals_comp : logicals_n generic map (
    n => n
    ) port map (
      in_1  => in_1,
      in_2  => in_2,
      logic => logicals_mode,
      out_s => logicals_out
      );

  -- this zero_comparator is used for the comparator
  adder_out_zero_comp : zero_comparator generic map (
    n => n-1
    ) port map (
      in_s  => addsub_out(n-2 downto 0),
      out_s => zero_comp_out
      );

  -- this comparator compares the carry out from adder and the zero_out from zero_comparator
  -- which kind comparison is choosen externally
  comparator_comp : comparator port map (
    zero_out          => zero_comp_out,
    carry_out         => addsub_carry_out,
    sign_out          => addsub_out(n-1),
    signed_comparison => signed_comparison,
    eq_out            => comp_eq_out(0),
    gr_out            => comp_gr_out(0),
    lo_out            => comp_lo_out(0),
    ge_out            => comp_ge_out(0),
    le_out            => comp_le_out(0),
    ne_out            => comp_ne_out(0)
    );

-- shifter
  shifter_comp : shifter generic map (
    n => n
    ) port map (
      base_vector    => in_1,
      shift_by_value => in_2,
      left_shift     => left_shift,
      arith_shift    => arith_shift,
      out_s          => shift_out
      );
-- rotator
  rotator_comp : rotator generic map (
    n => n
    ) port map (
      base_vector     => in_1,
      rotate_by_value => in_2,
      left_rotation   => left_shift,
      out_s           => rotate_out
      );
-- insert: comparator_mux (6 inputs -> 1 outputs (1 bit))
  comp_mux : mux_n_6_1 generic map (
    n => 1
    ) port map (
      in_0  => comp_eq_out,
      in_1  => comp_ne_out,
      in_2  => comp_gr_out,
      in_3  => comp_ge_out,
      in_4  => comp_lo_out,
      in_5  => comp_le_out,
      s     => comp_mux_sel,
      out_s => comp_mux_out(0 downto 0)
      );
-- output_mux
  out_mux : mux_n_6_1 generic map (
    n => n
    ) port map (
      in_0  => addsub_out,
      in_1  => logicals_out,
      in_2  => comp_mux_out,
      in_3  => mul_out,
      in_4  => shift_out,
      in_5  => rotate_out,
      s     => out_mux_sel,
      out_s => out_s
      );
--

  process(op_sel)
  begin
    case conv_integer(unsigned(op_sel)) is
      when conv_integer(unsigned(alu_add)) =>
        addsub_sel_in <= '0';
        out_mux_sel   <= out_adder_value_sel;
      when conv_integer(unsigned(alu_sub)) =>
        addsub_sel_in <= '1';
        out_mux_sel   <= out_adder_value_sel;
      when conv_integer(unsigned(alu_and)) =>
        logicals_mode <= logicals_and;
        out_mux_sel   <= out_logicals_value_sel;
      when conv_integer(unsigned(alu_or)) =>
        logicals_mode <= logicals_or;
        out_mux_sel   <= out_logicals_value_sel;
      when conv_integer(unsigned(alu_xor)) =>
        logicals_mode <= logicals_xor;
        out_mux_sel   <= out_logicals_value_sel;
      when conv_integer(unsigned(alu_nand)) =>
        logicals_mode <= logicals_nand;
        out_mux_sel   <= out_logicals_value_sel;
      when conv_integer(unsigned(alu_nor)) =>
        logicals_mode <= logicals_nor;
        out_mux_sel   <= out_logicals_value_sel;
      when conv_integer(unsigned(alu_xnor)) =>
        logicals_mode <= logicals_xnor;
        out_mux_sel   <= out_logicals_value_sel;
      when conv_integer(unsigned(alu_mult)) =>
        out_mux_sel <= out_mul_value_sel;
        signed_mul  <= '1';
      when conv_integer(unsigned(alu_multu)) =>
        out_mux_sel <= out_mul_value_sel;
        signed_mul  <= '0';
      when conv_integer(unsigned(alu_sll)) =>
        left_shift  <= '1';
        arith_shift <= '0';
        out_mux_sel <= out_shift_value_sel;
      when conv_integer(unsigned(alu_srl)) =>
        left_shift  <= '0';
        arith_shift <= '0';
        out_mux_sel <= out_shift_value_sel;
      when conv_integer(unsigned(alu_sra)) =>
        left_shift  <= '0';
        arith_shift <= '1';
        out_mux_sel <= out_shift_value_sel;
      when conv_integer(unsigned(alu_rol)) =>
        left_shift  <= '1';
        out_mux_sel <= out_rotate_value_sel;
      when conv_integer(unsigned(alu_ror)) =>
        left_shift  <= '0';
        out_mux_sel <= out_rotate_value_sel;
      when conv_integer(unsigned(alu_seq)) =>
        addsub_sel_in     <= '1';
        signed_comparison <= '0';
        comp_mux_sel      <= comp_eq_sel;
        out_mux_sel       <= out_comp_value_sel;
      when conv_integer(unsigned(alu_sne)) =>
        addsub_sel_in     <= '1';
        signed_comparison <= '0';
        comp_mux_sel      <= comp_ne_sel;
        out_mux_sel       <= out_comp_value_sel;
      when conv_integer(unsigned(alu_sgtu)) =>
        addsub_sel_in     <= '1';
        signed_comparison <= '0';
        comp_mux_sel      <= comp_gr_sel;
        out_mux_sel       <= out_comp_value_sel;
      when conv_integer(unsigned(alu_sgeu)) =>
        addsub_sel_in     <= '1';
        signed_comparison <= '0';
        comp_mux_sel      <= comp_ge_sel;
        out_mux_sel       <= out_comp_value_sel;
      when conv_integer(unsigned(alu_sltu)) =>
        addsub_sel_in     <= '1';
        signed_comparison <= '0';
        comp_mux_sel      <= comp_lo_sel;
        out_mux_sel       <= out_comp_value_sel;
      when conv_integer(unsigned(alu_sleu)) =>
        addsub_sel_in     <= '1';
        signed_comparison <= '0';
        comp_mux_sel      <= comp_le_sel;
        out_mux_sel       <= out_comp_value_sel;
      when conv_integer(unsigned(alu_sgt)) =>
        addsub_sel_in     <= '1';
        signed_comparison <= '1';
        comp_mux_sel      <= comp_gr_sel;
        out_mux_sel       <= out_comp_value_sel;
      when conv_integer(unsigned(alu_sge)) =>
        addsub_sel_in     <= '1';
        signed_comparison <= '1';
        comp_mux_sel      <= comp_ge_sel;
        out_mux_sel       <= out_comp_value_sel;
      when conv_integer(unsigned(alu_slt)) =>
        addsub_sel_in     <= '1';
        signed_comparison <= '1';
        comp_mux_sel      <= comp_lo_sel;
        out_mux_sel       <= out_comp_value_sel;
      when conv_integer(unsigned(alu_sle)) =>
        addsub_sel_in     <= '1';
        signed_comparison <= '1';
        comp_mux_sel      <= comp_le_sel;
        out_mux_sel       <= out_comp_value_sel;
      when others => null;
    end case;
  end process;

end architecture;
