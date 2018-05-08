library ieee;
use ieee.std_logic_1164.all;

entity dff is
  port (
    d   : in  std_logic;
    clk : in  std_logic;
    rst : in  std_logic;
    set : in  std_logic;
    en  : in  std_logic;
    q   : out std_logic
    );
end entity;

architecture behavioral of dff is
begin

  process (clk, rst, set)
  begin
-- asynchronous set and reset
    if rst = '1' or set = '1' then
      -- if rst and set are equal to '1'
      -- forbidden input
      if rst = set then
        q <= 'X';
      elsif rst = '1' then
        q <= '0';
      else
        q <= '1';
      end if;
    elsif rising_edge(clk) and en = '1' then
      q <= d;
    end if;
  end process;
end architecture;
