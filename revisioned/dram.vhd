library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.my_const.all;

-- data memory for dlx
-- memory initial status: all '0's
entity dram is
  generic (
    ram_depth       : natural := 64;
    data_cell_width : natural := 8;
    addr_size       : natural := 6
    );
  port (
    rst               : in  std_logic;
    addr_r            : in  std_logic_vector(addr_size - 1 downto 0);
    addr_w            : in  std_logic_vector(addr_size - 1 downto 0);
    read_enable       : in  std_logic;
    write_enable      : in  std_logic;
    write_single_cell : in  std_logic;
    din               : in  std_logic_vector(4*data_cell_width - 1 downto 0);
    dout              : out std_logic_vector(4*data_cell_width - 1 downto 0)
    );

end entity;

architecture behavioral of dram is

  type ramtype is array (0 to ram_depth - 1) of std_logic_vector(data_cell_width-1 downto 0);  -- std_logic_vector(i_size - 1 downto 0);

  signal dram_mem : ramtype;

begin


  process(addr_r, read_enable, rst)
    variable index : natural := 0;
  begin
    if(rst = reset_value) then
      for i in 0 to 3 loop
        dout((i+1)*data_cell_width-1 downto i*data_cell_width) <= (others => '0');
      end loop;
    elsif(read_enable = '1') then
      index := conv_integer(unsigned(addr_r));
      for i in 0 to 3 loop
        if(index+i < ram_depth) then
          dout((i+1)*data_cell_width-1 downto i*data_cell_width) <= dram_mem(index+i);
        else
          dout((i+1)*data_cell_width-1 downto i*data_cell_width) <= (others => '0');
        end if;
      end loop;
    end if;
  end process;


  process (addr_w, din, write_enable, write_single_cell, rst)
    variable index : natural := 0;
  begin
    index := conv_integer(unsigned(addr_w));

    if (rst = reset_value) then
      dram_mem <= (others => (others => '0'));
    elsif (write_enable = '1') then
      if(write_single_cell = '1') then
        dram_mem(index) <= din(data_cell_width-1 downto 0);
      else
        for i in 0 to 3 loop
          dram_mem(index+3-i) <= din((i+1)*data_cell_width-1 downto i*data_cell_width);
        end loop;
      end if;
    end if;
  end process;

end architecture;
