library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.my_arith_functions.all;

entity t2_mask_selector is
  generic (
    n           : natural := 32;
    mask_offset : natural := 3
    );
  port (
    base_vector    : in  std_logic_vector(n-1 downto 0);
    shift_by_value : in  std_logic_vector(n-1 downto 3);
    left_shift     : in  std_logic;
    arith_shift    : in  std_logic;
    out_s          : out std_logic_vector(n+2**mask_offset-1 downto 0)
    );
end entity;

architecture structural of t2_mask_selector is
  component t2_mask_generator is
    generic (
      n           : natural;
      mask_offset : natural
      );
    port (
      base_vector : in  std_logic_vector(n-1 downto 0);
      arith_shift : in  std_logic;
      out_s       : out std_logic_vector(3*n+2**(1+mask_offset)-1 downto 0)
      );
  end component;

  signal mask_gen_out : std_logic_vector(2*n+2**mask_offset-1 downto 0);
  type mask_array is array (-(2**mask_offset-1) to 2**mask_offset-1) of std_logic_vector(n+2**mask_offset-1);
  signal mask_xx      : mask_array;

begin

  masks_redirect : for i in 0 to 2**mask_offset-1 generate
    mask_xx(i) <= mask_gen_out(2*n+(1-i)*2**mask_offset-1 downto 2*n-i*2**mask_offset);  -- 
  end generate;


end architecture;
