package comparator_type is

  constant comparator_array_size : natural := 3;
  subtype comparator_array is std_logic_vector(comparator_array_size-1 downto 0);

  constant comparator_eq    : comparator_array := "001";
  constant comparator_gr    : comparator_array := "010";
  constant comparator_lo    : comparator_array := "100";
  constant comparator_ge    : comparator_array := "011";
  constant comparator_le    : comparator_array := "101";
  constant comparator_ne    : comparator_array := "110";
  constant comparator_true  : comparator_array := "111";
  constant comparator_false : comparator_array := "000";
end package;
