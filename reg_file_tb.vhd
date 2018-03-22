LIBRARY work;
USE work.bv_arithmetic.ALL;
USE work.dlx_types.ALL;

entity reg_file_tb is
end reg_file_tb;

architecture behave of reg_file_tb is
  signal clock          : bit := '0';
  signal readnotwrite   : bit := '0';
  signal reg_number     : bit_vector(4 down to 0) := "00000";
  signal data_in        : bit_vector(31 down to 0) := x"00000000";
  signal data_out       : bit_vector(31 down to 0);

  component reg_file is
    port (
      clock_in           : in  bit;
      readnotwrite_in    : in  bit;
      reg_number_in      : in bit_vector(4 down to 0);
      data_in_in         : in bit_vector(31 down to 0);
      data_out_out       : out bit_vector(31 down to 0)
    );
  end component reg_file;

begin

  reg_file_INST : reg_file
    port map (
      clock_in          => clock,
      readnotwrite_in   => readnotwrite,
      reg_number_in     => reg_number,
      data_in_in        => data_in,
      data_out_out      => data_out
      );

  process is
  begin
    clock         <= '0';
    readnotwrite  <= '0';
    reg_number    <= "00001";
    data_in       <= x"FFFFFFFF";
    wait for 20 ns;
    clock         <= '0';
    readnotwrite  <= '1';
    reg_number    <= "00001";
    data_in       <= x"FFFFFFFF";
    wait for 20 ns;
    clock         <= '1';
    readnotwrite  <= '0';
    reg_number    <= "00001";
    data_in       <= x"FFFFFFFF";
    wait for 20 ns;
    clock         <= '1';
    readnotwrite  <= '1';
    reg_number    <= "00001";
    data_in       <= x"FFFFFFFF";
    wait for 20 ns;
  end process;

end behave;
