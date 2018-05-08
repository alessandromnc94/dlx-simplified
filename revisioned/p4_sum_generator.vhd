library ieee;
use ieee.std_logic_1164.all;

entity p4_sum_generator is

  generic (
    n          : natural := 32;
    carry_step : natural := 4
    );
  port (
    in_1       : in  std_logic_vector (n-1 downto 0);
    in_2       : in  std_logic_vector (n-1 downto 0);
    carries_in : in  std_logic_vector (n/carry_step downto 0);
    sum        : out std_logic_vector (n-1 downto 0)
    );

end entity;

architecture structural of p4_sum_generator is

  component p4_carry_select_block is
    generic (
      n : natural
      );
    port (
      in_1      : in  std_logic_vector (n-1 downto 0);
      in_2      : in  std_logic_vector (n-1 downto 0);
      carry_sel : in  std_logic;
      sum       : out std_logic_vector (n-1 downto 0)
      );
  end component;
begin

  csb_gen : for i in 0 to n/carry_step-1 generate
    csbx : p4_carry_select_block
      generic map (
        n => carry_step
        )
      port map (
        in_1      => in_1((i+1)*carry_step-1 downto (i)*carry_step),
        in_2      => in_2((i+1)*carry_step-1 downto (i)*carry_step),
        carry_sel => carries_in(i),
        sum       => sum((i+1)*carry_step-1 downto (i)*carry_step)
        );
  end generate;

end architecture;
