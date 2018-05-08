library ieee;
use ieee.std_logic_1164.all;

entity booth_encoder is
  generic(
    n : natural := 8
    );
  port(
    in_s  : in  std_logic_vector(n-1 downto 0);
    out_s : out std_logic_vector(3*((n/2) + n mod 2) - 1 downto 0)
    );
end entity;

architecture structural of booth_encoder is
  component booth_encoder_block is
    port(
      in_s  : in  std_logic_vector(2 downto 0);
      out_s : out std_logic_vector(2 downto 0)
      );
  end component;

  constant n_encoders_block : natural                                       := n/2 + n mod 2;
  signal in_s_tmp           : std_logic_vector(2*n_encoders_block downto 0) := (others => '0');
begin
  in_s_tmp(n downto 1) <= in_s;

  blck_gen : for i in 0 to n_encoders_block-1 generate
    blck_x : booth_encoder_block port map (
      in_s  => in_s_tmp(2*i+2 downto 2*i),
      out_s => out_s(3*i+2 downto 3*i)
      );
  end generate;

end architecture;
