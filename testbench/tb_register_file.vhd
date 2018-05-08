library ieee;
use ieee.std_logic_1164.all;

entity tb_register_file is
end entity;

architecture testbench of tb_register_file is

  signal clk     : std_logic := '0';
  signal reset   : std_logic;
  signal enable  : std_logic;
  signal rd1     : std_logic;
  signal rd2     : std_logic;
  signal wr      : std_logic;
  signal add_wr  : std_logic_vector(4 downto 0);
  signal add_rd1 : std_logic_vector(4 downto 0);
  signal add_rd2 : std_logic_vector(4 downto 0);
  signal datain  : std_logic_vector(63 downto 0);
  signal out1    : std_logic_vector(63 downto 0);
  signal out2    : std_logic_vector(63 downto 0);

  component register_file
    port (
      clk     : in  std_logic;
      reset   : in  std_logic;
      enable  : in  std_logic;
      rd1     : in  std_logic;
      rd2     : in  std_logic;
      wr      : in  std_logic;
      add_wr  : in  std_logic_vector(4 downto 0);
      add_rd1 : in  std_logic_vector(4 downto 0);
      add_rd2 : in  std_logic_vector(4 downto 0);
      datain  : in  std_logic_vector(63 downto 0);
      out1    : out std_logic_vector(63 downto 0);
      out2    : out std_logic_vector(63 downto 0)
      );
  end component;

begin

  rg : register_file
    port map (clk, reset, enable, rd1, rd2, wr, add_wr, add_rd1, add_rd2, datain, out1, out2);
  reset   <= '1', '0'                         after 5 ns;
  enable  <= '0', '1'                         after 3 ns, '0' after 10 ns, '1' after 15 ns;
  wr      <= '0', '1'                         after 6 ns, '0' after 7 ns, '1' after 10 ns, '0' after 20 ns;
  rd1     <= '1', '0'                         after 5 ns, '1' after 13 ns, '0' after 20 ns;
  rd2     <= '0', '1'                         after 17 ns;
  add_wr  <= "10110", "01000"                 after 9 ns;
  add_rd1 <= "10110", "01000"                 after 9 ns;
  add_rd2 <= "11100", "01000"                 after 9 ns;
  datain  <= (others => '0'), (others => '1') after 8 ns;

  pclock : process(clk)
  begin
    clk <= not(clk) after 0.5 ns;
  end process;
end architecture;
