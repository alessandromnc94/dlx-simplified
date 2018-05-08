library ieee;
use ieee.std_logic_1164.all;

entity mask is
  generic (
    n : natural := 32
    );
  port (
    a           : in  std_logic_vector(n-1 downto 0);
    sel         : in  std_logic;
    sign_extend : in  std_logic;
    b           : out std_logic_vector(n-1 downto 0)
    );
end entity;

architecture structural of mask is

  component and_gate is
    port (
      in_1  : in  std_logic;
      in_2  : in  std_logic;
      out_s : out std_logic
      );
  end component;

  component or_gate_n is
    generic (
      n : natural := 1
      );
    port (
      in_1  : in  std_logic_vector(n-1 downto 0);
      in_2  : in  std_logic_vector(n-1 downto 0);
      out_s : out std_logic_vector(n-1 downto 0)
      );
  end component;

  component not_gate is
    port (
      in_s  : in  std_logic;
      out_s : out std_logic
      );
  end component;

  signal a1, a2, a3 : std_logic_vector(n-1 downto 0);
  signal nsel       : std_logic;

begin

  not1 : not_gate port map(sel, nsel);

  and1 : for i in 0 to n-1 generate
    and1_x : and_gate port map(nsel, a(i), a1(i));
    and2_x : and_gate port map(sel, a(i), a2(i));
    and3_x : and_gate port map(a2(i), sign_extend, a3(i));
  end generate;

  or1 : or_gate_n generic map(n => n)
    port map(a1, a3, b);

end architecture;
