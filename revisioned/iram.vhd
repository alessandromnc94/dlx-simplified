library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.my_const.all;

-- instruction memory for dlx
-- memory filled by a process which reads from a file
-- file name is "test.asm.mem"
entity iram is
  generic (
    ram_depth       : natural := 64;
    data_cell_width : natural := 8;
    addr_size       : natural := 32
    );
  port (
    rst  : in  std_logic                                        := '0';
    addr : in  std_logic_vector(addr_size - 1 downto 0)         := (others => '0');
    dout : out std_logic_vector(4*data_cell_width - 1 downto 0) := (others => '0')
    );

end entity;

architecture behavioral of iram is

  type ramtype is array (0 to ram_depth - 1) of std_logic_vector(data_cell_width-1 downto 0);  -- std_logic_vector(i_size - 1 downto 0);

  signal iram_mem : ramtype;
begin


  dout(4*data_cell_width-1 downto 3*data_cell_width) <= iram_mem(conv_integer(unsigned(addr)));
  dout(3*data_cell_width-1 downto 2*data_cell_width) <= iram_mem(conv_integer(unsigned(addr))+1);
  dout(2*data_cell_width-1 downto 1*data_cell_width) <= iram_mem(conv_integer(unsigned(addr))+2);
  dout(1*data_cell_width-1 downto 0)                 <= iram_mem(conv_integer(unsigned(addr))+3);

  -- purpose: this process is in charge of filling the instruction ram with the firmware
  -- type   : combinational
  -- inputs : rst
  -- outputs: iram_mem
  fill_mem_p : process (rst)
    file mem_fp         : text;
    variable file_line  : line;
    variable index_rst  : natural := 0;
    variable tmp_data_u : std_logic_vector(4*data_cell_width-1 downto 0);
  begin  -- process fill_mem_p
    if (rst = reset_value) then
      file_open(mem_fp, "D:/Workspace/Microelectronics/dlx-revision/simulation/modelsim/program.txt", read_mode);
      while (not endfile(mem_fp)) loop
        readline(mem_fp, file_line);
        hread(file_line, tmp_data_u);
        for i in 0 to 3 loop
          iram_mem(index_rst+3-i) <= tmp_data_u((i+1)*data_cell_width-1 downto i*data_cell_width);
        end loop;
        index_rst := index_rst + 4;
      end loop;
      if(index_rst < ram_depth) then
        iram_mem(index_rst to ram_depth-1) <= (others => (others => '0'));
      end if;
    end if;
  end process fill_mem_p;

end architecture;
