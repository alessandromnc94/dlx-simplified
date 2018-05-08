library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity tb_p4_adder is
end entity;

architecture behavioral of tb_p4_adder is
  constant n : natural := 16;
  component p4_adder is
    generic (
      n : natural
      );
    port (
      in_1      : in  std_logic_vector (n-1 downto 0);
      in_2      : in  std_logic_vector (n-1 downto 0);
      carry_in  : in  std_logic;
      sum       : out std_logic_vector (n-1 downto 0);
      carry_out : out std_logic
      );
  end component;

  signal in_1, in_2, sum     : std_logic_vector(n-1 downto 0);
  signal carry_in, carry_out : std_logic;
  signal expected_sum        : std_logic_vector(n-1 downto 0);


begin

  dut : p4_adder generic map (
    n => n
    ) port map (
      in_1      => in_1,
      in_2      => in_2,
      carry_in  => carry_in,
      sum       => sum,
      carry_out => carry_out
      );

  process
  begin
    for c in 0 to 1 loop
      if c = 0 then
        carry_in <= '0';
      else
        carry_in <= '1';
      end if;
      for i in -2 to 2 loop
        in_1 <= conv_std_logic_vector(i, n);
        for j in -2 to 2 loop
          -- if c = 0 then
          --   expected_sum <= conv_std_logic_vector(i+j, n);
          --   in_2 <= conv_std_logic_vector(j, n);
          -- else
          --   in_2 <= not conv_std_logic_vector(j, n);
          --   expected_sum <= conv_std_logic_vector(i-j, n);
          -- end if;

          expected_sum <= conv_std_logic_vector(i+j+c, n);
          in_2         <= conv_std_logic_vector(j, n);
          wait for 100 ps;
        end loop;
      end loop;
    end loop;
    assert false report "testbench finished!" severity failure;
  end process;

end architecture;
