library ieee;
use ieee.std_logic_1164.all;

entity p4_adder is
  generic (
    n          : natural := 32;
    carry_step : natural := 4
    );
  port (
    in_1      : in  std_logic_vector (n-1 downto 0);
    in_2      : in  std_logic_vector (n-1 downto 0);
    carry_in  : in  std_logic;
    sum       : out std_logic_vector (n-1 downto 0);
    carry_out : out std_logic
    );
end entity;

architecture structural of p4_adder is

  component p4_carries_generator is
    generic (
      n          : natural;
      carry_step : natural
      );
    port (
      in_1        : in  std_logic_vector (n-1 downto 0);
      in_2        : in  std_logic_vector (n-1 downto 0);
      carry_in    : in  std_logic;
      carries_out : out std_logic_vector (n/carry_step downto 0)
      );
  end component;

  component p4_sum_generator is
    generic (
      n          : natural;
      carry_step : natural
      );
    port (
      in_1       : in  std_logic_vector (n-1 downto 0);
      in_2       : in  std_logic_vector (n-1 downto 0);
      carries_in : in  std_logic_vector (n/carry_step downto 0);
      sum        : out std_logic_vector (n-1 downto 0)
      );
  end component;

  signal carries : std_logic_vector (n/carry_step downto 0);

begin

  carry_out <= carries(n/carry_step);

  cg : p4_carries_generator
    generic map (
      n          => n,
      carry_step => carry_step
      )
    port map (
      in_1        => in_1,
      in_2        => in_2,
      carry_in    => carry_in,
      carries_out => carries
      );

  sg : p4_sum_generator
    generic map (
      n          => n,
      carry_step => carry_step
      )
    port map (
      in_1       => in_1,
      in_2       => in_2,
      carries_in => carries,
      sum        => sum
      );

end architecture;
