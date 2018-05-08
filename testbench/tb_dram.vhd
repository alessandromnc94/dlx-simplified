library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity tb_dram is
end entity;

architecture behavioral of tb_dram is

  component dram is
    generic (
      ram_depth  : natural := 64;
      data_width : natural := 8;
      addr_size  : natural := 32
      );
    port (
      rst               : in  std_logic;
      addr_r            : in  std_logic_vector(addr_size - 1 downto 0);
      addr_w            : in  std_logic_vector(addr_size - 1 downto 0);
      read_enable       : in  std_logic;
      write_enable      : in  std_logic;
      write_single_cell : in  std_logic;
      din               : in  std_logic_vector(4*data_width - 1 downto 0);
      dout              : out std_logic_vector(4*data_width - 1 downto 0)
      );

  end component;

  signal addr_r_s, addr_w_s                                        : std_logic_vector(5 downto 0)  := (others => '0');
  signal din_s, dout_s                                             : std_logic_vector(31 downto 0) := (others => '0');
  signal dout_0_s, dout_1_s, dout_2_s, dout_3_s                    : std_logic_vector(7 downto 0);
  signal rst_s, write_enable_s, write_single_cell_s, read_enable_s : std_logic                     := '0';
  signal clk                                                       : std_logic                     := '0';
  constant clk_period                                              : time                          := 10 ns;
begin
  dout_0_s <= dout_s(7 downto 0);
  dout_1_s <= dout_s(15 downto 8);
  dout_2_s <= dout_s(23 downto 16);
  dout_3_s <= dout_s(31 downto 24);
  clk      <= not clk after clk_period/2;
  dram_x : dram port map (
    rst               => rst_s,
    addr_r            => addr_r_s,
    addr_w            => addr_w_s,
    read_enable       => read_enable_s,
    write_enable      => write_enable_s,
    write_single_cell => write_single_cell_s,
    din               => din_s,
    dout              => dout_s
    );

  read_enable_s <= '1';
  addr_r_s      <= addr_w_s;
  process
  begin
    rst_s               <= '0';
    write_single_cell_s <= '1';
    write_enable_s      <= '0';
    din_s               <= (others => '0');
    addr_w_s            <= (others => '0');
    wait for clk_period;
    rst_s               <= '1';
    write_enable_s      <= '1';
    for i in 0 to 63 loop
      din_s    <= conv_std_logic_vector(i, din_s'length);
      addr_w_s <= conv_std_logic_vector(i, addr_w_s'length);
      wait for clk_period;
    end loop;
    write_enable_s <= '0';
    for i in 0 to 63 loop
      din_s    <= conv_std_logic_vector(i, din_s'length);
      addr_w_s <= conv_std_logic_vector(i, addr_w_s'length);
      wait for clk_period;
    end loop;
    assert false report "testbench finished" severity failure;
    wait;
  end process;
end architecture;
