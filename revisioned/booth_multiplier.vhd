library ieee;
use ieee.std_logic_1164.all;

use work.booth_generator_types.all;

entity booth_multiplier is
  generic (
    n : natural := 8
    );
  port (
    in_1       : in  std_logic_vector(n-1 downto 0);
    in_2       : in  std_logic_vector(n-1 downto 0);
    signed_mul : in  std_logic;
    out_s      : out std_logic_vector(2*n-1 downto 0)
    );
end entity;

architecture structural of booth_multiplier is

  component booth_encoder is
    generic(
      n : natural
      );
    port(
      in_s  : in  std_logic_vector(n-1 downto 0);
      out_s : out std_logic_vector(3*((n/2) + n mod 2) - 1 downto 0)
      );
  end component;

  component booth_generator is
    generic(
      n_in  : natural;
      n_out : natural
      );
    port(
      in_s    : in  std_logic_vector(n_in-1 downto 0);
      pos_out : out std_logic_vector(n_out-1 downto 0);
      neg_out : out std_logic_vector(n_out-1 downto 0)
      );
  end component;

-- in_0 : 0
-- in_1 : 1 X k
-- in_2 : -1 X k
-- in_3 : 2 X k
-- in_4 : -2 X k
  component mux_n_5_1 is
    generic (
      n : natural
      );
    port (
      in_0  : in  std_logic_vector(n-1 downto 0);
      in_1  : in  std_logic_vector(n-1 downto 0);
      in_2  : in  std_logic_vector(n-1 downto 0);
      in_3  : in  std_logic_vector(n-1 downto 0);
      in_4  : in  std_logic_vector(n-1 downto 0);
      s     : in  std_logic_vector(2 downto 0);  -- selector
      out_s : out std_logic_vector(n-1 downto 0)
      );
  end component;

  component rca_n is
    generic (
      n : natural
      );
    port (
      in_1      : in  std_logic_vector(n-1 downto 0);
      in_2      : in  std_logic_vector(n-1 downto 0);
      carry_in  : in  std_logic;
      sum       : out std_logic_vector(n-1 downto 0);
      carry_out : out std_logic
      );
  end component;

  constant n_prime : natural := n+2;

  constant n_level   : natural := n_prime/2 + n_prime mod 2;
  constant n_shifted : natural := 3*n_prime;

  type signal_matrix is array(0 to n_level-1) of std_logic_vector(2*n_prime-1 downto 0);
  signal encoder_out                      : std_logic_vector(3*n_level-1 downto 0);
  signal gen_pos_out, gen_neg_out         : std_logic_vector(n_shifted-1 downto 0);
  signal mux_out_matrix, adder_out_matrix : signal_matrix;

  signal in_1_bis, in_2_bis               : std_logic_vector(n_prime-1 downto 0);
  signal sign_extender_1, sign_extender_2 : std_logic;
begin
  sign_extender_1 <= in_1(n-1) and signed_mul;
  sign_extender_2 <= in_2(n-1) and signed_mul;
  in_1_bis        <= sign_extender_1 & sign_extender_1 & in_1;
  in_2_bis        <= sign_extender_2 & sign_extender_2 & in_2;

  booth_encoder_comp : booth_encoder generic map (
    n => n_prime
    ) port map (
      in_s  => in_2_bis,
      out_s => encoder_out
      );

  booth_generator_comp : booth_generator generic map (
    n_in  => n_prime,
    n_out => n_shifted
    ) port map (
      in_s    => in_1_bis,
      pos_out => gen_pos_out,
      neg_out => gen_neg_out
      );

  muxes_gen : for i in 0 to n_level-1 generate
    mux_x : mux_n_5_1 generic map (
      n => 2*n_prime
      ) port map (
        in_0  => (others => '0'),       -- 0
        in_1  => gen_pos_out(n_shifted-2*i-1 downto n_shifted-2*i-2*n_prime),  -- 1x(2^(i+1))
        in_2  => gen_pos_out(n_shifted-2*i-2 downto n_shifted-2*i-1-2*n_prime),  -- 2x(2^(i+1))
        in_3  => gen_neg_out(n_shifted-2*i-1 downto n_shifted-2*i-2*n_prime),  -- -1x(2^(i+1))
        in_4  => gen_neg_out(n_shifted-2*i-2 downto n_shifted-2*i-1-2*n_prime),  -- -2x(2^(i+1))
        s     => encoder_out(i*3+2 downto i*3),
        out_s => mux_out_matrix(i)
        );
  end generate;

  adders_gen : for i in 1 to n_level-1 generate
    adder_0_gen : if i = 1 generate
      adder_0 : rca_n generic map (
        n => 2*n_prime
        ) port map (
          in_1      => mux_out_matrix(1),
          in_2      => mux_out_matrix(0),
          carry_in  => '0',
          sum       => adder_out_matrix(1),
          carry_out => open
          );
    end generate;
    adder_x_gen : if i > 1 generate
      adder_x : rca_n generic map (
        n => 2*n_prime
        ) port map (
          in_1      => mux_out_matrix(i),
          in_2      => adder_out_matrix(i-1),
          carry_in  => '0',
          sum       => adder_out_matrix(i),
          carry_out => open
          );
    end generate;
  end generate;

  out_s <= adder_out_matrix(n_level-1)(2*n-1 downto 0);

end architecture;
