library ieee;
use ieee.std_logic_1164.all;

entity tb_rotator is
end entity;

architecture behavioral of tb_rotator is
  constant n : natural := 4;
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

  signal base_vector, rotate_by_value, out_s : std_logic_vector(n-1 downto 0);
  signal left_rotation                       : std_logic;

begin

  dut : rotator generic map (
    n => n
    ) port map (
      base_vector     => base_vector,
      rotate_by_value => rotate_by_value,
      left_rotation   => left_rotation,
      out_s           => out_s
      );

  process
  begin

    base_vector                 <= (n-1 downto 0 => '0');
    base_vector(2)              <= '1';
    rotate_by_value             <= (n-1 downto 2 => '0') & "11";
    left_rotation               <= '1';
    wait for 1 ns;
    left_rotation               <= '0';
    wait for 1 ns;
    base_vector(n-1 downto n-2) <= "11";
    left_rotation               <= '1';
    wait for 1 ns;
    left_rotation               <= '0';
    wait for 1 ns;
    assert false report "testbench finished!" severity failure;
  end process;

end architecture;
