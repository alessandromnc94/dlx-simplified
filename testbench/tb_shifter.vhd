library ieee;
use ieee.std_logic_1164.all;

entity tb_shifter is
end entity;

architecture behavioral of tb_shifter is
  constant n : natural := 8;
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

  signal base_vector, shift_by_value, out_s : std_logic_vector(n-1 downto 0);
  signal left_shift, arith_shift            : std_logic;

begin

  dut : shifter generic map (
    n => n
    ) port map (
      base_vector    => base_vector,
      shift_by_value => shift_by_value,
      left_shift     => left_shift,
      arith_shift    => arith_shift,
      out_s          => out_s
      );

  process
  begin

    base_vector                 <= (n-1 downto 0 => '0');
    base_vector(2)              <= '1';
    shift_by_value              <= (n-1 downto 2 => '0') & "01";
    left_shift                  <= '1';
    arith_shift                 <= '0';
    wait for 1 ns;
    left_shift                  <= '0';
    wait for 1 ns;
    arith_shift                 <= '1';
    wait for 1 ns;
    base_vector(n-1 downto n-2) <= "11";
    left_shift                  <= '1';
    arith_shift                 <= '0';
    wait for 1 ns;
    left_shift                  <= '0';
    wait for 1 ns;
    arith_shift                 <= '1';
    wait for 1 ns;
    assert false report "testbench finished!" severity failure;
  end process;

end architecture;
