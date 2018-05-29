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
    out_mux : out std_logic_vector(1 downto 0)   := (others => '0');
    dout1   : out std_logic_vector(m-1 downto 0) := (others => 'Z');  -- data to be forwarded
    dout2   : out std_logic_vector(m-1 downto 0) := (others => 'Z')
    );
end entity;


architecture behavioral of forwarding_unit is
  constant zero         : std_logic_vector(n-1 downto 0) := (others => '0');
  constant not_selected : std_logic_vector(m-1 downto 0) := (others => 'Z');
begin


  process(clk)
  begin

    if rising_edge(clk) then

      if alue = '1' and aluar /= zero and aluar = arf1 then
        out_mux(0) <= '1';
        dout1      <= alud;
      elsif exe = '1' and exear /= zero and exear = arf1 then
        out_mux(0) <= '1';
        dout1      <= exed;
      elsif meme = '1' and memar /= zero and exear = arf1 then
        out_mux(0) <= '1';
        dout1      <= memd;
      else
        dout1      <= not_selected;
        out_mux(0) <= '0';
      end if;


      if alue = '1' and aluar /= zero and aluar = arf2 then
        out_mux(1) <= '1';
        dout2      <= alud;
      elsif exe = '1' and exear /= zero and exear = arf2 then
        out_mux(1) <= '1';
        dout2      <= exed;
      elsif meme = '1' and memar /= zero and exear = arf2 then
        out_mux(1) <= '1';
        dout2      <= memd;
      else
        dout2      <= not_selected;
        out_mux(1) <= '0';
      end if;

    end if;

  end process;

end architecture;
