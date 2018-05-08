library ieee;
use ieee.std_logic_1164.all;

entity comparator is
  port (
    zero_out          : in  std_logic;
    carry_out         : in  std_logic;
    sign_out          : in  std_logic;
    signed_comparison : in  std_logic;
    eq_out            : out std_logic;
    gr_out            : out std_logic;
    lo_out            : out std_logic;
    ge_out            : out std_logic;
    le_out            : out std_logic;
    ne_out            : out std_logic
    );
end entity;

architecture behavioral of comparator is
  signal c_out, z_out : std_logic;

begin
-- unsigned comparison needs the value of carry_out
-- signed comparison needs the negate value of carry_out
  -- c_out  <= signed_comparison xor carry_out;
  c_out <= carry_out when signed_comparison = '0' else not sign_out;
  z_out <= not sign_out and zero_out;

  eq_out <= z_out;
  ne_out <= not z_out;
  ge_out <= c_out;
  -- ge_out <= c_out or zero_out;
  lo_out <= (not c_out);
  -- lo_out <= (not c_out) and (not zero_out);
  gr_out <= ((not z_out) and c_out);
  le_out <= ((not c_out) or z_out);

end architecture;
