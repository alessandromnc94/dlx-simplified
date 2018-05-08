library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity tb_register_file_win is
  generic (
    width_data         : natural := 4;
    n_global_registers : natural := 1;
    n_local_registers  : natural := 1;
    windows            : natural := 4
    );
end entity;

architecture testbench of tb_register_file_win is
  constant clk_period : time := 1 ns;

  component register_file_win is
    generic (
      width_data         : natural := 64;
      n_global_registers : natural := 8;
      n_local_registers  : natural := 8;
      windows            : natural := 4
      );
    port (
      clk              : in  std_logic;
      reset            : in  std_logic;
      enable           : in  std_logic;
      rd1              : in  std_logic;
      rd2              : in  std_logic;
      wr               : in  std_logic;
      add_wr           : in  std_logic_vector(log2int(3*n_local_registers+n_global_registers)-1 downto 0);
      add_rd1          : in  std_logic_vector(log2int(3*n_local_registers+n_global_registers)-1 downto 0);
      add_rd2          : in  std_logic_vector(log2int(3*n_local_registers+n_global_registers)-1 downto 0);
      datain           : in  std_logic_vector(width_data-1 downto 0);
      out1             : out std_logic_vector(width_data-1 downto 0);
      out2             : out std_logic_vector(width_data-1 downto 0);
      sub_call         : in  std_logic;
      sub_ret          : in  std_logic;
      spill            : out std_logic;
      fill             : out std_logic;
      to_memory_data   : out std_logic_vector(width_data-1 downto 0);
      from_memory_data : in  std_logic_vector(width_data-1 downto 0)
      );
  end component;

  signal clk              : std_logic                                                                    := '0';
  signal reset            : std_logic                                                                    := '0';
  signal enable           : std_logic                                                                    := '0';
  signal rd1              : std_logic                                                                    := '0';
  signal rd2              : std_logic                                                                    := '0';
  signal wr               : std_logic                                                                    := '0';
  signal add_wr           : std_logic_vector(log2int(3*n_local_registers+n_global_registers)-1 downto 0) := (others => '0');
  signal add_rd1          : std_logic_vector(log2int(3*n_local_registers+n_global_registers)-1 downto 0) := (others => '0');
  signal add_rd2          : std_logic_vector(log2int(3*n_local_registers+n_global_registers)-1 downto 0) := (others => '0');
  signal datain           : std_logic_vector(width_data-1 downto 0)                                      := (others => '0');
  signal out1             : std_logic_vector(width_data-1 downto 0)                                      := (others => '0');
  signal out2             : std_logic_vector(width_data-1 downto 0)                                      := (others => '0');
  signal sub_call         : std_logic                                                                    := '0';
  signal sub_ret          : std_logic                                                                    := '0';
  signal spill            : std_logic                                                                    := '0';
  signal fill             : std_logic                                                                    := '0';
  signal to_memory_data   : std_logic_vector(width_data-1 downto 0)                                      := (others => '0');
  signal from_memory_data : std_logic_vector(width_data-1 downto 0)                                      := (others => '0');

  -- signals for testbench
  signal windows_in_memory : natural := 0;
  signal windows_in_rf     : natural := 1;

  -- signal added only for show the clk_period during simulation
  signal clk_period_s : time := clk_period;
begin
  -- clock signal
  clk              <= not clk after clk_period/2;
  -- 'from_memory_data' is always the # of windows in rf
  from_memory_data <= conv_std_logic_vector(windows_in_rf, from_memory_data'length);

  dut : register_file_win
    generic map (
      n_global_registers => n_global_registers,
      n_local_registers  => n_local_registers,
      width_data         => width_data,
      windows            => windows
      )
    port map (
      clk              => clk,
      reset            => reset,
      enable           => enable,
      rd1              => rd1,
      rd2              => rd2,
      wr               => wr,
      add_wr           => add_wr,
      add_rd1          => add_rd1,
      add_rd2          => add_rd2,
      datain           => datain,
      out1             => out1,
      out2             => out2,
      sub_call         => sub_call,
      sub_ret          => sub_ret,
      spill            => spill,
      fill             => fill,
      to_memory_data   => to_memory_data,
      from_memory_data => from_memory_data
      );

  process(spill, fill, reset)
  begin
    if reset = '1' then
      windows_in_memory <= 0;
    elsif rising_edge(spill) then
      windows_in_memory <= windows_in_memory + 1;
    elsif rising_edge(fill) then
      windows_in_memory <= windows_in_memory - 1;
    end if;
  end process;

  process (sub_ret, sub_call, reset) is
  begin
    if reset = '1' then
      windows_in_rf <= 1;
    elsif rising_edge(sub_call) then
      windows_in_rf <= windows_in_rf + 1;
    elsif rising_edge(sub_ret) then
      if windows_in_rf > 1 then
        windows_in_rf <= windows_in_rf - 1;
      else
        report "no window in rf!!!" severity warning;
      end if;
    end if;
  end process;

  process
  begin
    -- reset the register file
    report "reset the register file in order to write on globals registers (the value of register is its address)" severity note;
    reset  <= '1';
    wait until falling_edge(clk);
    wait for 5 * clk_period;
    -- enable 
    reset  <= '0';
    enable <= '1';
    -- outputs are setted to high impedence
    wait for 5 * clk_period;
    -- write in all global registers their indexes starting from 1
    wr     <= '1';
    for i in 0 to n_global_registers-1 loop
      add_wr <= conv_std_logic_vector(i, add_wr'length);
      datain <= conv_std_logic_vector(i, datain'length);
      wait for clk_period;
    end loop;

    report "write on the first window registers (the value of register is its address in the section preceded by 3 bits: '001' is for in registers, '010' is for local and '100' is for out)" severity failure;
    wait until falling_edge(clk);
    wait for 5 * clk_period;
    reset <= '1';
    wait for clk_period;
    reset <= '0';
    wait for clk_period;
    -- test writing on first window
    for i in 0 to n_local_registers-1 loop
      datain <= "001" & conv_std_logic_vector(i, datain'length-3);
      add_wr <= conv_std_logic_vector(n_global_registers+i, add_wr'length);
      wait for clk_period;
      datain <= "010" & conv_std_logic_vector(i, datain'length-3);
      add_wr <= conv_std_logic_vector(n_global_registers+n_local_registers+i, add_wr'length);
      wait for clk_period;
      datain <= "100" & conv_std_logic_vector(i, datain'length-3);
      add_wr <= conv_std_logic_vector(n_global_registers+2*n_local_registers+i, add_wr'length);
      wait for clk_period;
    end loop;
    wr     <= '0';
    wait for clk_period;
    report "reset register file to test call and ret subroutine: registers in a window contains its number" severity failure;
    wait for 1 us;
    wait until falling_edge(clk);
    reset  <= '1';
    datain <= (others => '0');
    wait for clk_period;
    reset  <= '0';
    wait for clk_period;

    -- test call routine 'windows'+1 times
    -- 2 spills done
    for i in 0 to windows + 1 loop
      datain <= conv_std_logic_vector(windows_in_rf, datain'length);
      wait for clk_period;
      -- set registers as # of window
      wr     <= '1';
      for k in 0 to n_global_registers + 3 * n_local_registers -1 loop
        add_wr <= conv_std_logic_vector(n_global_registers+k, add_wr'length);
        wait for clk_period;
      end loop;
      wr       <= '0';
      wait for clk_period;
      sub_call <= '1';
      wait for clk_period;
      sub_call <= '0';
      wait for clk_period;
      if spill = '1' then
        wait until spill = '0';
        wait for clk_period;
      end if;
      wait for 5 * clk_period;
    end loop;
    wait for 5 * clk_period;

    -- test ret routine 3 times
    -- no fills done
    for i in 0 to 2 loop
      sub_ret <= '1';
      wait for clk_period;
      sub_ret <= '0';
      wait for clk_period;
      if fill = '1' then
        wait until fill = '0';
        wait for clk_period;
      end if;
    end loop;

    wait for 10 * clk_period;

    -- test ret routine all windows
    -- 2 fills done
    while windows_in_memory > 0 loop
      sub_ret <= '1';
      wait for clk_period;
      sub_ret <= '0';
      wait for clk_period;
      if fill = '1' then
        wait until fill = '0';
        wait for clk_period;
      end if;
      wait for 5 * clk_period;
    end loop;
    report "testbench finished" severity failure;
    wait;
  end process;
end architecture;
