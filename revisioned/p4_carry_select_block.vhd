library ieee;
use ieee.std_logic_1164.all;

entity p4_carry_select_block is
  generic (
    n : natural := 8
    );
  port (
    in_1      : in  std_logic_vector (n-1 downto 0);
    in_2      : in  std_logic_vector (n-1 downto 0);
    carry_sel : in  std_logic;
    sum       : out std_logic_vector (n-1 downto 0)
    );
end entity;

architecture structural of p4_carry_select_block is

  component rca_n is
    generic (
      n : natural
      );
    port (
      in_1      : in  std_logic_vector (n-1 downto 0);
      in_2      : in  std_logic_vector (n-1 downto 0);
      carry_in  : in  std_logic;
      sum       : out std_logic_vector (n-1 downto 0);
      carry_out : out std_logic
      );
  end component;

  component mux_n_2_1 is
    generic (
      n : natural
      );
    port (
      in_0  : in  std_logic_vector (n-1 downto 0);
      in_1  : in  std_logic_vector (n-1 downto 0);
      s     : in  std_logic;
      out_s : out std_logic_vector (n-1 downto 0)
      );
  end component;

  signal sum_0, sum_1 : std_logic_vector (n-1 downto 0);
begin
  rca_0 : rca_n
    generic map (
      n => n
      )
    port map (
      in_1      => in_1,
      in_2      => in_2,
      carry_in  => '0',
      sum       => sum_0,
      carry_out => open
      );

  rca_1 : rca_n
    generic map (
      n => n
      )
    port map (
      in_1      => in_1,
      in_2      => in_2,
      carry_in  => '1',
      sum       => sum_1,
      carry_out => open
      );

  mux : mux_n_2_1
    generic map (
      n => n
      )
    port map (
      in_0  => sum_0,
      in_1  => sum_1,
      s     => carry_sel,
      out_s => sum
      );
end architecture;
