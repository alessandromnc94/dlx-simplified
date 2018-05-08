library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.my_arith_functions.all;

entity register_file_win is
  generic (
    width_data         : natural := 64;
    n_global_registers : natural := 8;
    n_local_registers  : natural := 8;
    windows            : natural := 8);
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
end entity;

architecture behavioral of register_file_win is
  -- define constants
  -- offset_cwp is used to shift pointers swp and cwp
  constant offset_cwp            : natural := 2 * n_local_registers;
  -- n_window_registers contains the number of registers (except global) of a window (in + local + out)
  constant n_window_registers    : natural := 3 * n_local_registers;
  -- width_add contains the number of bits to address registers in a window (global + in + local + out )
  constant width_add             : natural := log2int(n_window_registers + n_global_registers);
  -- total_registers contains the number of all registers (except global)
  constant n_total_win_registers : natural := windows * offset_cwp;

  -- define type for registers array
  type reg_array is (natural range <>) of std_logic_vector(width_data-1 downto 0);

  -- define signals
  -- 'global_registers' is the collection of global registers
  signal global_registers        : reg_array(0 to n_global_registers-1)    := (others => (others => '0'));
  -- 'win_registers' is the collection of in, local (and out) registers
  signal win_registers           : reg_array(0 to n_total_win_registers-1) := (others => (others => '0'));
  -- 'swp' and 'cwp' contains the address of the 1st register of stored window and current window
  signal cwp, swp                : natural                                 := 0;
  -- 'in_spilling' and 'in_filling' are signals used to check which operation is in execution.
  -- they are needed because 'spill' and 'fill' outputs can be only modified but not checked in 'if' conditions
  signal in_spilling, in_filling : std_logic                               := '0';
  -- 'rf_cycles' contains how many times cycles are started.
  -- it is used to check if at the least one window is stored in memory
  signal rf_cycles               : natural                                 := 0;
  -- 'memory_cnt' is an offset used during filling and spilling operation
  signal memory_cnt              : natural                                 := 0;

begin

  spill <= in_spilling;
  fill  <= in_filling;

  process (clk)
  begin
    if rising_edge(clk) then
      -- reset operation is synchronous
      if reset = '1' then
        win_registers    <= (others => (others => '0'));
        global_registers <= (others => (others => '0'));
        out1             <= (others => 'Z');
        out2             <= (others => 'Z');
        cwp              <= 0;
        swp              <= 0;
        in_spilling      <= '0';
        in_filling       <= '0';
        to_memory_data   <= (others => 'Z');
        rf_cycles        <= 0;
      elsif enable = '1' then
        if in_spilling = '1' then
          -- continue the spill operation if the number of stored registers is lower than the number of registers in e local in a windows
          -- else terminate it
          if memory_cnt < offset_cwp then
            to_memory_data <= win_registers(getregpointer(swp, memory_cnt, windows, n_local_registers));
            memory_cnt     <= memory_cnt + 1;
          else
            in_spilling <= '0';
            -- if swp is 0
            -- increase rf_cycles
            -- (new cycle started)
            if swp = 0 then
              rf_cycles <= rf_cycles + 1;
            end if;
            -- change pointers values
            swp <= getregpointer(swp, offset_cwp, windows, n_local_registers);
            cwp <= getregpointer(cwp, offset_cwp, windows, n_local_registers);
          end if;
        elsif in_filling = '1' then
          -- like before but starting from the top
          if memory_cnt > 0 then
            win_registers(getregpointer(swp, memory_cnt-1-offset_cwp, windows, n_local_registers)) <= from_memory_data;
            memory_cnt                                                                             <= memory_cnt - 1;
          else
            in_filling <= '0';
            -- if swp = offset_cwp
            -- decrease rf_cycles
            -- (a cycle is completed)
            if swp = offset_cwp then
              rf_cycles <= rf_cycles - 1;
            end if;
            -- change pointers values
            swp <= getregpointer(swp, -offset_cwp, windows, n_local_registers);
            cwp <= getregpointer(cwp, -offset_cwp, windows, n_local_registers);
          end if;
        -- call sub-routine
        elsif sub_call = '1' then
          -- the next condition checks if the next window is the last available
          -- thus if cwp+2*(offset_cwp) is equal to swp do a spill
          -- else increase cwp by offset_cwp
          if getregpointer(cwp, 2*offset_cwp, windows, n_local_registers) = swp then
            in_spilling <= '1';
            memory_cnt  <= 0;
          else
            cwp <= getregpointer(cwp, offset_cwp, windows, n_local_registers);
          end if;
        -- ret sub-routine
        elsif sub_ret = '1' then
          -- the next condition checks if it is possible do a ret
          -- checking how many times t-he swp has to change its value from offset_cwp (poiter to the 2nd window)
          -- to 0 (pointer to the 1st window).
          -- if it is greater than 0 a ret is possible
          -- else report a warning to console
          if rf_cycles > 0 then
            -- if cwp = swp a fill operation must be executed
            -- else decrease cwp by offset_cwp
            if cwp = swp then
              in_filling <= '1';
              -- memory_cnt <= n_window_registers;
              memory_cnt <= offset_cwp;
            else
              cwp <= getregpointer(cwp, -offset_cwp, windows, n_local_registers);
            end if;
          else
            report "no ret routine: no window to return!" severity warning;
          end if;
        else
          -- write operation
          if wr = '1' then
            -- if 'add_wr' is lower than 'n_global_registers' read global register
            if conv_integer(add_wr) < n_global_registers then
              -- global registers
              global_registers(conv_integer(add_wr)) <= datain;
            -- else read a register of the window
            else
              -- window registers (in, local, out)
              win_registers(getregpointer(cwp, conv_integer(add_wr)-n_global_registers, windows, n_local_registers)) <= datain;
            end if;
          end if;
          -- read from out1 operation
          if rd1 = '1' then
            -- as before
            if conv_integer(add_rd1) < n_global_registers then
              -- global registers
              out1 <= global_registers(conv_integer(add_rd1));
            else
              -- window registers (in, local, out)
              out1 <= win_registers(getregpointer(cwp, conv_integer(add_rd1)-n_global_registers, windows, n_local_registers));
            end if;
          end if;
          -- read from out2 operation
          if rd2 = '1' then
            -- as before
            if conv_integer(add_rd2) < n_global_registers then
              -- global registers
              out2 <= global_registers(conv_integer(add_rd2));
            else
              -- window registers (in, local, out)
              out2 <= win_registers(getregpointer(cwp, conv_integer(add_rd2)-n_global_registers, windows, n_local_registers));
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture;
