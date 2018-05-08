library ieee;
use ieee.std_logic_1164.all;

entity not_gate is
  port (
    in_s  : in  std_logic;
    out_s : out std_logic
    );
end entity;

architecture behavioral of not_gate is
begin
  out_s <= not in_s;
end architecture;
