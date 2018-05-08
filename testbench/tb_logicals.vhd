library ieee;
use ieee.std_logic_1164.all;

use work.logicals_types.all;

entity tb_logicals is
end entity;

architecture behavioral of tb_logicals is
  constant n : natural := 4;
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

  signal in_1, in_2, out_s : std_logic_vector(n-1 downto 0);
  signal logic             : logicals_array;
begin

  dut : logicals_n generic map (
    n => n
    ) port map (
      in_1  => in_1,
      in_2  => in_2,
      logic => logic,
      out_s => out_s
      );

  process
  begin

    in_1 <= "1100";
    in_2 <= "1010";

    logic <= logicals_and;
    wait for 100 ps;
    logic <= logicals_nand;
    wait for 100 ps;
    logic <= logicals_or;
    wait for 100 ps;
    logic <= logicals_nor;
    wait for 100 ps;
    logic <= logicals_xor;
    wait for 100 ps;
    logic <= logicals_xnor;
    wait for 100 ps;

    assert false report "testbench finished" severity failure;
  end process;

end architecture;
