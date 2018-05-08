library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity tb_booth_multiplier is
end entity;

architecture behavioral of tb_booth_multiplier is
  constant n : natural := 4;
  component booth_multiplier is
    generic (
      n : natural
      );
    port (
      in_1       : in  std_logic_vector(n-1 downto 0);
      in_2       : in  std_logic_vector(n-1 downto 0);
      signed_mul : in  std_logic;
      out_s      : out std_logic_vector(2*n-1 downto 0)
      );
  end component;

  signal in_1, in_2 : std_logic_vector(n-1 downto 0);
  signal signed_mul : std_logic;
  signal out_s      : std_logic_vector(2*n-1 downto 0);
begin


  dut : booth_multiplier generic map (
    n => n
    ) port map (
      in_1       => in_1,
      in_2       => in_2,
      signed_mul => signed_mul,
      out_s      => out_s
      );

  process
  begin
    for k in 0 to 1 loop
      if k = 0 then
        signed_mul <= '0';
      else
        signed_mul <= '1';
      end if;
      for i in -1 to 1 loop
        in_1 <= conv_std_logic_vector(i, n);
        for j in -1 to 1 loop
          in_2 <= conv_std_logic_vector(j, n);
          wait for 100 ps;
        end loop;
      end loop;
    end loop;
    assert false report "testbench finished" severity failure;
  end process;

end architecture;
