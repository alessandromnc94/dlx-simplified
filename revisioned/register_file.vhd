library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity register_file is
  generic (
    width_add  : natural := 5;
    width_data : natural := 64
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

  signal registers : reg_array(0 to 2**width_add-1) := (others => (others => '0'));

begin
  process (clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        out1      <= (others => 'Z');
        out2      <= (others => 'Z');
        registers <= (others => (others => '0'));
      elsif enable = '1' then
        if wr = '1' then
          if conv_integer(add_wr) /= 0 then
            registers(conv_integer(add_wr)) <= datain;
          end if;
        end if;
        if rd1 = '1' then
          if conv_integer(add_rd1) = 0 then
            out1 <= (others => '0');
          else
            out1 <= registers(conv_integer(add_rd1));
          end if;
        end if;
        if rd2 = '1' then
          if conv_integer(add_rd2) = 0 then
            out2 <= (others => '0');
          else
            out2 <= registers(conv_integer(add_rd2));
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture;
