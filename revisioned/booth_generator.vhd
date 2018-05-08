library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

use work.booth_generator_types.all;

entity booth_generator is
  generic(
    n_in  : natural := 16;
    n_out : natural := 3*16
    );
  port(
    in_s    : in  std_logic_vector(n_in-1 downto 0);
    pos_out : out std_logic_vector(n_out-1 downto 0);
    neg_out : out std_logic_vector(n_out-1 downto 0)
    );
end entity;

architecture behavioral of booth_generator is
  signal compl_2_in_s : std_logic_vector(n_in -1 downto 0);
begin
  compl_2_in_s <= '1'+not(in_s);

  pos_out(n_out-2*n_in-1 downto 0) <= (others => '0');
  neg_out(n_out-2*n_in-1 downto 0) <= (others => '0');

  pos_out(n_out-n_in-1 downto n_out-2*n_in) <= in_s;
  neg_out(n_out-n_in-1 downto n_out-2*n_in) <= compl_2_in_s;

  pos_out(n_out-1 downto n_out-n_in) <= (others => in_s(n_in-1));
  neg_out(n_out-1 downto n_out-n_in) <= (others => compl_2_in_s(n_in-1));
end architecture;
