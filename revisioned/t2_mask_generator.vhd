library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity t2_mask_generator is
  generic (
    n           : natural := 32;
    mask_offset : natural := 3
    );
  port (
    base_vector : in  std_logic_vector(n-1 downto 0);
    left_shift  : in  std_logic;
    arith_shift : in  std_logic;
    out_s       : out std_logic_vector(3*n+2**(mask_offset+1)-1 downto 0)
    );
end entity;

architecture structural of t2_mask_generator is
  signal left_shift_mask, right_shift_mask : std_logic_vector(2*n+2**mask_offset-1 downto 0);

  component and_gate is
    port (
      in_1  : in  std_logic;
      in_2  : in  std_logic;
      out_s : out std_logic
      );
  end component;
  component mux_n_2_1 is
    generic (
      n : natural
      );
    port (
      in_0  : std_logic_vector(n-1 downto 0);
      in_1  : std_logic_vector(n-1 downto 0);
      s     : std_logic;
      out_s : std_logic_vector(n-1 downto 0)
      );
  end component;

  signal extended_bit         : std_logic;
  signal out_mux_1, out_mux_2 : std_logic_vector(n-1 downto 0);
begin

  extended_bit_and_gate : and_gate port map (
    in_1  => base_vector(n-1),
    in_2  => arith_shift,
    out_s => extended_bit
    );

  out_mux : mux_n_2_1 generic map (
    n => 2*n+2**mask_offset
    ) port map (
      in_0  => right_shift_mask,
      in_1  => left_shift_mask,
      s     => left_shift,
      out_s => out_s
      );

  left_shift_mask(n+2**mask_offset-1 downto 0)                 <= (others => '0');
  left_shift_mask(2*n+2**mask_offset-1 downto n+2*mask_offset) <= base_vector;
  right_shift_mask(n-1 downto 0)                               <= base_vector;
  right_shift_mask(2*n+2**mask_offset-1 downto n)              <= (others => extended_bit);

end architecture;
