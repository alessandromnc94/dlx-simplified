library ieee;
use ieee.std_logic_1164.all;

entity tb_comparator is
end entity;

architecture behavioral of tb_comparator is
  component comparator is
    port (
      zero_out          : in  std_logic;
      carry_out         : in  std_logic;
      signed_comparison : in  std_logic;
      eq_out            : out std_logic;
      gr_out            : out std_logic;
      lo_out            : out std_logic;
      ge_out            : out std_logic;
      le_out            : out std_logic;
      ne_out            : out std_logic
      );
  end component;

  signal zero_out          : std_logic;
  signal carry_out         : std_logic;
  signal signed_comparison : std_logic;
  signal eq_out            : std_logic_vector(0 downto 0);
  signal gr_out            : std_logic_vector(0 downto 0);
  signal lo_out            : std_logic_vector(0 downto 0);
  signal ge_out            : std_logic_vector(0 downto 0);
  signal le_out            : std_logic_vector(0 downto 0);
  signal ne_out            : std_logic_vector(0 downto 0);

begin


  dut : comparator port map (
    zero_out          => zero_out,
    carry_out         => carry_out,
    signed_comparison => signed_comparison,
    eq_out            => eq_out (0),
    gr_out            => gr_out (0),
    lo_out            => lo_out (0),
    ge_out            => ge_out (0),
    le_out            => le_out (0),
    ne_out            => ne_out (0)
    );

  process
  begin
    zero_out          <= '0';
    carry_out         <= '0';
    signed_comparison <= '0';
    wait for 1 ns;
    zero_out          <= '1';
    carry_out         <= '0';
    signed_comparison <= '0';
    wait for 1 ns;
    zero_out          <= '0';
    carry_out         <= '1';
    signed_comparison <= '0';
    wait for 1 ns;
    zero_out          <= '1';
    carry_out         <= '1';
    signed_comparison <= '0';
    wait for 1 ns;
    zero_out          <= '0';
    carry_out         <= '0';
    signed_comparison <= '1';
    wait for 1 ns;
    zero_out          <= '1';
    carry_out         <= '0';
    signed_comparison <= '1';
    wait for 1 ns;
    zero_out          <= '0';
    carry_out         <= '1';
    signed_comparison <= '1';
    wait for 1 ns;
    zero_out          <= '1';
    carry_out         <= '1';
    signed_comparison <= '1';
    wait for 1 ns;
    assert false report "testbench finished!" severity failure;
  end process;
end architecture;
