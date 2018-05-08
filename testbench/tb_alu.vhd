library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;

use work.alu_types.all;

entity tb_alu is
end entity;

architecture behavioral of tb_alu is

  constant n : natural := 8;

  component alu is
    generic (
      n : natural
      );
    port (
      in_1   : in  std_logic_vector(n-1 downto 0);
      in_2   : in  std_logic_vector(n-1 downto 0);
      op_sel : in  alu_array;
      -- outputs
      out_s  : out std_logic_vector(n-1 downto 0)
      );
  end component;
  signal in_1, in_2, out_s, expected_out_s : std_logic_vector(n-1 downto 0) := (others => '1');
  signal op_sel                            : alu_array;
  signal operation                         : string(1 to 5)                 := "     ";
  signal correct                           : boolean;
begin

  correct <= expected_out_s = out_s;

  dut : alu generic map (
    n => n
    ) port map (
      in_1   => in_1,
      in_2   => in_2,
      op_sel => op_sel,
      out_s  => out_s
      );


  process
  begin

    for i in -2 to 2 loop
      in_1 <= conv_std_logic_vector(i, n);
      for j in -2 to 2 loop
        in_2   <= conv_std_logic_vector(j, n);
        op_sel <= alu_add;
        wait for 100 ps;
        op_sel <= alu_sub;
        wait for 100 ps;

        op_sel <= alu_and;
        wait for 100 ps;
        op_sel <= alu_or;
        wait for 100 ps;
        op_sel <= alu_xor;
        wait for 100 ps;
        op_sel <= alu_nand;
        wait for 100 ps;
        op_sel <= alu_nor;
        wait for 100 ps;
        op_sel <= alu_xnor;
        wait for 100 ps;

        op_sel <= alu_sll;
        wait for 100 ps;
        op_sel <= alu_srl;
        wait for 100 ps;
        op_sel <= alu_sra;
        wait for 100 ps;

        op_sel <= alu_rol;
        wait for 100 ps;
        op_sel <= alu_ror;
        wait for 100 ps;

        op_sel <= alu_mult;
        wait for 100 ps;
        op_sel <= alu_multu;
        wait for 100 ps;

        op_sel <= alu_seq;
        wait for 100 ps;
        op_sel <= alu_sne;
        wait for 100 ps;
        op_sel <= alu_sgtu;
        wait for 100 ps;
        op_sel <= alu_sgeu;
        wait for 100 ps;
        op_sel <= alu_sltu;
        wait for 100 ps;
        op_sel <= alu_sleu;
        wait for 100 ps;
        op_sel <= alu_sgt;
        wait for 100 ps;
        op_sel <= alu_sge;
        wait for 100 ps;
        op_sel <= alu_slt;
        wait for 100 ps;
        op_sel <= alu_sle;
        wait for 100 ps;


      end loop;
    end loop;
    assert false report "testbench terminated!!!" severity failure;

  end process;

  process(op_sel, in_1, in_2)
  begin
    case op_sel is
      when alu_add =>
        operation      <= "  add";
        expected_out_s <= unsigned(in_1) + unsigned(in_2);
      when alu_sub =>
        operation      <= "  sub";
        expected_out_s <= unsigned(in_1) - unsigned(in_2);
      when alu_and =>
        operation      <= "  and";
        expected_out_s <= in_1 and in_2;
      when alu_or =>
        operation      <= "   or";
        expected_out_s <= in_1 or in_2;
      when alu_xor =>
        operation      <= "  xor";
        expected_out_s <= in_1 xor in_2;
      when alu_nand =>
        operation      <= " nand";
        expected_out_s <= in_1 nand in_2;
      when alu_nor =>
        operation      <= "  nor";
        expected_out_s <= in_1 nor in_2;
      when alu_xnor =>
        operation      <= " xnor";
        expected_out_s <= in_1 xnor in_2;
      when alu_multu =>
        operation      <= "U mul";
        expected_out_s <= unsigned(in_1(n/2-1 downto 0)) * unsigned(in_2(n/2-1 downto 0));
      when alu_mult =>
        operation      <= "s mul";
        expected_out_s <= signed(in_1(n/2-1 downto 0)) * signed(in_2(n/2-1 downto 0));
      when alu_sll =>
        operation      <= "  sll";
        expected_out_s <= to_stdlogicvector(to_bitvector(in_1) sll conv_integer(unsigned(in_2)));
      when alu_srl =>
        operation      <= "  srl";
        expected_out_s <= to_stdlogicvector(to_bitvector(in_1) srl conv_integer(unsigned(in_2)));
      when alu_sra =>
        operation      <= "  sra";
        expected_out_s <= to_stdlogicvector(to_bitvector(in_1) sra conv_integer(unsigned(in_2)));
      when alu_rol =>
        operation      <= "  rol";
        expected_out_s <= to_stdlogicvector(to_bitvector(in_1) rol conv_integer(unsigned(in_2)));
      when alu_ror =>
        operation      <= "  ror";
        expected_out_s <= to_stdlogicvector(to_bitvector(in_1) ror conv_integer(unsigned(in_2)));
      when alu_seq =>
        operation                             <= "   eq";
        expected_out_s(n-1 downto 1)          <= (others => '0');
        if in_1 = in_2 then expected_out_s(0) <= '1';
        else expected_out_s(0)                <= '0';
        end if;
      when alu_sne =>
        operation                              <= "   ne";
        expected_out_s(n-1 downto 1)           <= (others => '0');
        if in_1 /= in_2 then expected_out_s(0) <= '1';
        else expected_out_s(0)                 <= '0';
        end if;
      when alu_sgtu =>
        operation                                                 <= "   gr";
        expected_out_s(n-1 downto 1)                              <= (others => '0');
        if unsigned(in_1) > unsigned(in_2) then expected_out_s(0) <= '1';
        else expected_out_s(0)                                    <= '0';
        end if;
      when alu_sgeu =>
        operation                                                  <= "    ge";
        expected_out_s(n-1 downto 1)                               <= (others => '0');
        if unsigned(in_1) >= unsigned(in_2) then expected_out_s(0) <= '1';
        else expected_out_s(0)                                     <= '0';
        end if;
      when alu_sltu =>
        operation                                                 <= "   lo";
        expected_out_s(n-1 downto 1)                              <= (others => '0');
        if unsigned(in_1) < unsigned(in_2) then expected_out_s(0) <= '1';
        else expected_out_s(0)                                    <= '0';
        end if;
      when alu_sleu =>
        operation                    <= "   le";
        expected_out_s(n-1 downto 1) <= (others => '0');
        if unsigned(in_1)            <= unsigned(in_2) then expected_out_s(0) <= '1';
        else expected_out_s(0)       <= '0';
        end if;
      when alu_sgt =>
        operation                                             <= "s  gr";
        expected_out_s(n-1 downto 1)                          <= (others => '0');
        if signed(in_1) > signed(in_2) then expected_out_s(0) <= '1';
        else expected_out_s(0)                                <= '0';
        end if;
      when alu_sge =>
        operation                                              <= "s  ge";
        expected_out_s(n-1 downto 1)                           <= (others => '0');
        if signed(in_1) >= signed(in_2) then expected_out_s(0) <= '1';
        else expected_out_s(0)                                 <= '0';
        end if;
      when alu_slt =>
        operation                                             <= "s  lo";
        expected_out_s(n-1 downto 1)                          <= (others => '0');
        if signed(in_1) < signed(in_2) then expected_out_s(0) <= '1';
        else expected_out_s(0)                                <= '0';
        end if;
      when alu_sle =>
        operation                    <= "s  le";
        expected_out_s(n-1 downto 1) <= (others => '0');
        if signed(in_1)              <= signed(in_2) then expected_out_s(0) <= '1';
        else expected_out_s(0)       <= '0';
        end if;
      when others =>
        operation <= " null";
    end case;
  end process;
end architecture;
