library ieee;
use ieee.std_logic_1164.all;

entity xnor_gate is
  port (
    in_1  : in  std_logic;
    in_2  : in  std_logic;
    out_s : out std_logic
    );
end entity;

architecture behavioral of xnor_gate is
begin
  out_s <= in_1 xnor in_2;
end architecture;
