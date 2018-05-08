library ieee;
use ieee.std_logic_1164.all;

entity nand_gate is
  port (
    in_1  : in  std_logic;
    in_2  : in  std_logic;
    out_s : out std_logic
    );
end entity;

architecture behavioral of nand_gate is
begin
  out_s <= in_1 nand in_2;
end architecture;
