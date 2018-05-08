library ieee;
use ieee.std_logic_1164.all;

entity forwarding_unit is
  generic(
    n : natural := 32;                  --address length
    m : natural := 32                   --data length
    );
  port (
    arf1    : in  std_logic_vector(n-1 downto 0);  --addresses of regisers for the current operation 
    arf2    : in  std_logic_vector(n-1 downto 0);
    aluar   : in  std_logic_vector(n-1 downto 0);  --address of reg in output to the alu 
    exear   : in  std_logic_vector(n-1 downto 0);  --adrress of reg in execute stage
    memar   : in  std_logic_vector(n-1 downto 0);  --adrress of reg in memory stage
    alue    : in  std_logic;
    exe     : in  std_logic;
    meme    : in  std_logic;
    alud    : in  std_logic_vector(m-1 downto 0);  -- data coming from output of alu
    exed    : in  std_logic_vector(m-1 downto 0);  -- data coming from execute stage
    memd    : in  std_logic_vector(m-1 downto 0);  -- data coming from memory stage
    clk     : in  std_logic;
    out_mux : out std_logic_vector(1 downto 0);
    dout1   : out std_logic_vector(m-1 downto 0);  -- data to be forwarded
    dout2   : out std_logic_vector(m-1 downto 0)
    );
end entity;


architecture behavioral of forwarding_unit is

  type addrarray is array(0 to 2) of std_logic_vector(n-1 downto 0);
  type datarray is array(0 to 2) of std_logic_vector(m-1 downto 0);

  signal ar, arf : addrarray;
  signal data_in : datarray;
  signal enarray : std_logic_vector(0 to 2);

  constant zero : std_logic_vector(n-1 downto 0) := (others => '0');

begin

  process(clk)

    variable data_out : datarray;

  begin

    ar(0) <= aluar;
    ar(1) <= exear;
    ar(2) <= memar;

    arf(0) <= arf1;
    arf(1) <= arf2;

    data_in(0) <= alud;
    data_in(1) <= exed;
    data_in(2) <= memd;

    enarray(0) <= alue;
    enarray(1) <= exe;
    enarray(2) <= meme;

    if(rising_edge(clk)) then
      out_mux(0) <= '0';                  --set both the muxes at normal flow
      out_mux(1) <= '0';
      for i in 0 to 2 loop
        for j in 0 to 1 loop
          if(arf(j) /= zero) then
            if(arf(j) = ar(i) and enarray(i) = '1') then
              out_mux(j)  <= '1';         --set desired mux at forwarding mode
              data_out(j) := data_in(i);  --forward corresponding data
            end if;
          end if;
        end loop;
      end loop;
      dout1 <= data_out(0);
      dout2 <= data_out(1);
    end if;

  end process;

end architecture;
