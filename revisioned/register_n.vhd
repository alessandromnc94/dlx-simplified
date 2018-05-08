library ieee;
use ieee.std_logic_1164.all;

entity register_n is
  generic (
    n : natural := 8
    );
  port (
    din  : in  std_logic_vector(n-1 downto 0);
    clk  : in  std_logic;
    rst  : in  std_logic;
    set  : in  std_logic;
    en   : in  std_logic;
    dout : out std_logic_vector(n-1 downto 0)
    );
end entity;

architecture structural of register_n is

  component dff is
    port (
      d   : in  std_logic;
      clk : in  std_logic;
      rst : in  std_logic;
      set : in  std_logic;
      en  : in  std_logic;
      q   : out std_logic
      );
  end component;

begin

  dff_generation : for i in 0 to n-1 generate
    dffx : dff
      port map (
        d   => din(i),
        clk => clk,
        rst => rst,
        set => set,
        en  => en,
        q   => dout(i)
        );
  end generate;
end architecture;
