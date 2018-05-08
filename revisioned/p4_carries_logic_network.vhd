library ieee;
use ieee.std_logic_1164.all;

use work.my_arith_functions.all;
use work.p4_carries_logic_network_types.all;
use work.p4_carries_logic_network_functions.all;

entity p4_carries_logic_network is
  generic (
    n          : natural := 32;
    carry_step : natural := 4
    );

  port (
    pg          : in  std_logic_vector (n-1 downto 0);
    g           : in  std_logic_vector (n-1 downto 0);
    carry_in    : in  std_logic;
    carries_out : out std_logic_vector (n/carry_step downto 0)
    );
end entity;

architecture structural of p4_carries_logic_network is
  constant n_bit_log2 : natural    := log2int(n);
  type charvector is array (n downto 0) of character;
  type charmatrix is array (0 to n_bit_log2) of charvector;
  signal matrix_char  : charmatrix := (others => (others => 'X'));



  component g_block is
    port (
      pg_l  : in  std_logic;
      g_l   : in  std_logic;
      g_r   : in  std_logic;
      g_out : out std_logic
      );
  end component;

  component pg_block is
    port (
      pg_l   : in  std_logic;
      g_l    : in  std_logic;
      pg_r   : in  std_logic;
      g_r    : in  std_logic;
      pg_out : out std_logic;
      g_out  : out std_logic
      );
  end component;

  constant n_log2          : natural := log2int(n);
  constant carry_step_log2 : natural := log2int(carry_step);

  type signalvector is array (0 to n_log2) of std_logic_vector (n downto 0);

  signal pg_matrix : signalvector;
  signal g_matrix  : signalvector;

begin

  carries_out(0) <= carry_in;

  carries_out_gen : for blck in 1 to bintable_blocks(n, carry_step) generate
    carries_out(blck) <= g_matrix(n_log2)(bintable_left(carry_step, blck));
  end generate;

  g_block_0 : g_block
    port map (
      pg_l  => pg(0),
      g_l   => g(0),
      g_r   => carry_in,
      g_out => g_matrix(0)(1)
      );
  pg_matrix(0)(1)   <= pg(0);
  matrix_char(0)(1) <= 'g';

  pg_lev_0 : for blck in 2 to n generate
    pg_matrix(0)(blck)   <= pg(blck-1);
    g_matrix(0)(blck)    <= g(blck-1);
    matrix_char(0)(blck) <= 'p';

  end generate;

  bintree : for level in 1 to carry_step_log2 generate
    bintree_blcks : for blck in 1 to bintree_blocks(n, level) generate
      bintree_g_block : if bintree_is_g(blck) generate
        g_block_x : g_block
          port map (
            pg_l  => pg_matrix(level-1)(bintree_left(level, blck)),
            g_l   => g_matrix(level-1)(bintree_left(level, blck)),
            g_r   => g_matrix(level-1)(bintree_right(level, blck)),
            g_out => g_matrix(level)(bintree_left(level, blck))
            );
        matrix_char(level)(bintree_left(level, blck)) <= 'g';
      end generate;
      bintree_pg_block : if not bintree_is_g(blck) generate
        pg_block_x : pg_block
          port map (
            pg_l   => pg_matrix(level-1)(bintree_left(level, blck)),
            g_l    => g_matrix(level-1)(bintree_left(level, blck)),
            pg_r   => pg_matrix(level-1)(bintree_right(level, blck)),
            g_r    => g_matrix(level-1)(bintree_right(level, blck)),
            pg_out => pg_matrix(level)(bintree_left(level, blck)),
            g_out  => g_matrix(level)(bintree_left(level, blck))
            );
        matrix_char(level)(bintree_left(level, blck)) <= 'p';

      end generate;
    end generate;
  end generate;

  bintable : for level in carry_step_log2+1 to n_log2 generate
    bintable_blcks : for blck in 1 to bintable_blocks(n, carry_step) generate
      bintable_valid_blck : if bintable_valid_block(level, blck, carry_step) generate
        bintable_g_block : if bintable_is_g(level, blck, carry_step) generate
          g_block_x : g_block
            port map (
              pg_l  => pg_matrix(level-1)(bintable_left(carry_step, blck)),
              g_l   => g_matrix(level-1)(bintable_left(carry_step, blck)),
              g_r   => g_matrix(level-1)(bintable_right(carry_step, level, blck)),
              g_out => g_matrix(level)(bintable_left(carry_step, blck))
              );
          matrix_char(level)(bintable_left(carry_step, blck)) <= 'g';
        end generate;
        bintable_pg_block : if not bintable_is_g(level, blck, carry_step) generate
          pg_block_x : pg_block
            port map (
              pg_l   => pg_matrix(level-1)(bintable_left(carry_step, blck)),
              g_l    => g_matrix(level-1)(bintable_left(carry_step, blck)),
              pg_r   => pg_matrix(level-1)(bintable_right(carry_step, level, blck)),
              g_r    => g_matrix(level-1)(bintable_right(carry_step, level, blck)),
              pg_out => pg_matrix(level)(bintable_left(carry_step, blck)),
              g_out  => g_matrix(level)(bintable_left(carry_step, blck))
              );
          matrix_char(level)(bintable_left(carry_step, blck)) <= 'p';
        end generate;
      end generate;
      bintable_redirect : if not bintable_valid_block(level, blck, carry_step) generate
        pg_matrix(level)(bintable_left(carry_step, blck))   <= pg_matrix(level-1)(bintable_left(carry_step, blck));
        g_matrix(level)(bintable_left(carry_step, blck))    <= g_matrix(level-1)(bintable_left(carry_step, blck));
        matrix_char(level)(bintable_left(carry_step, blck)) <= '|';
      end generate;
    end generate;
  end generate;
end architecture;
