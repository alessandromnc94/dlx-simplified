library ieee;
use ieee.std_logic_1164.all;

entity rca_n is
  generic (
    n : natural := 4
    );
  port (
    in_1      : in  std_logic_vector(n-1 downto 0);
    in_2      : in  std_logic_vector(n-1 downto 0);
    carry_in  : in  std_logic;
    sum       : out std_logic_vector(n-1 downto 0);
    carry_out : out std_logic
    );
end entity;

architecture structural of rca_n is

  component full_adder is
    port(
      in_1      : in  std_logic;
      in_2      : in  std_logic;
      carry_in  : in  std_logic;
      sum       : out std_logic;
      carry_out : out std_logic
      );
  end component;

  signal carries : std_logic_vector(n downto 0) := (others => '0');

begin
  carries(0) <= carry_in;
  carry_out  <= carries(n);

  full_adder_gen : for i in 0 to n-1 generate
    full_adder_x : full_adder port map (
      in_1      => in_1(i),
      in_2      => in_2(i),
      carry_in  => carries(i),
      sum       => sum(i),
      carry_out => carries(i+1)
      );
  end generate;

end architecture;
