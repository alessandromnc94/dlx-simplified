library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.my_const.all;

entity register_file is
  generic (
    width_add  : integer := 5;
    width_data : integer := 64
    );
  port (
    clk     : in  std_logic;
    reset   : in  std_logic;
    enable  : in  std_logic;
    rd1     : in  std_logic;
    rd2     : in  std_logic;
    wr      : in  std_logic;
    add_wr  : in  std_logic_vector(width_add-1 downto 0);
    add_rd1 : in  std_logic_vector(width_add-1 downto 0);
    add_rd2 : in  std_logic_vector(width_add-1 downto 0);
    datain  : in  std_logic_vector(width_data-1 downto 0);
    out1    : out std_logic_vector(width_data-1 downto 0);
    out2    : out std_logic_vector(width_data-1 downto 0)
    );
end entity;

architecture behavioral of register_file is

  -- define type for registers array
  type reg_array is array(natural range <>) of std_logic_vector(width_data-1 downto 0);

  -- signal registers : reg_array(0 to 31) := (others => (others => '0'));
  signal registers : reg_array(0 to (2**width_add)-1) := (others => (others => '0'));

begin
  process (clk, reset)
    variable wr_index, rd1_index, rd2_index : integer := 0;
  begin
    if reset = reset_value then
      out1      <= (others => 'Z');
      out2      <= (others => 'Z');
      registers <= (others => (others => '0'));
    elsif rising_edge(clk) then
      wr_index  := conv_integer(unsigned(add_wr));
      rd1_index := conv_integer(unsigned(add_rd1));
      rd2_index := conv_integer(unsigned(add_rd2));
      if enable = '1' then
        if wr = '1' then
          -- report "The value of 'a' is " & integer'image(2**width_add);
          if wr_index /= 0 then
            registers(wr_index) <= datain;
          end if;
        end if;
        if rd1 = '1' then
          if rd1_index = 0 then
            out1 <= (others => '0');
          else
            out1 <= registers(rd1_index);
          end if;
        end if;
        if rd2 = '1' then
          if rd2_index = 0 then
            out2 <= (others => '0');
          else
            out2 <= registers(rd2_index);
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture;
