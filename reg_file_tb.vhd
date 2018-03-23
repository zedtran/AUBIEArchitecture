LIBRARY work;
USE work.bv_arithmetic.ALL;
USE work.dlx_types.ALL;

entity reg_file_tb is
end reg_file_tb;

architecture test of reg_file_tb is
	signal clock_SIG         : bit := '0';
	signal readnotwrite_SIG  : bit := '0';
	signal reg_num_SIG   	 : register_index := "00000";
	signal data_in_SIG       : dlx_word := x"00000000";
	signal data_out_SIG      : dlx_word;
	
	component reg_file is
		generic ( prop_delay: time:= 15 ns );
		port (
			clock           : in  bit;
			readnotwrite    : in  bit;
			reg_number      : in register_index;
			data_in         : in dlx_word;
			data_out        : out dlx_word
		);
    	end component reg_file;
  
	-- Time interval between signal changes
	constant TIME_DELTA : time := 20 ns;
  
	-- Used for converting our bits to string format --
	type T_bit_map is array(bit) of character;
	constant C_BIT_MAP: T_bit_map := ('0', '1');

begin
	-- Instantiate Unit Under Test (UUT)
	reg_file_INST : reg_file
		port map (
			clock          => 	clock_SIG,
			readnotwrite   => 	readnotwrite_SIG,
			reg_number     => 	reg_num_SIG,
			data_in        => 	data_in_SIG,
			data_out       => 	data_out_SIG
		);

	  -- Test
	  process is
	  begin
	    -- clock = 0, readnotwrite = 0 --
	    -- register index 0
	    -- data_in: 0001 0001 0001 0001 0001 0001 0001 0001 --
	    clock_SIG         <= 	'0';
	    readnotwrite_SIG  <= 	'0';
	    reg_num_SIG       <= 	"00000";
	    data_in_SIG       <= 	x"11111111";
	    wait for TIME_DELTA;
	    assert (data_in_SIG = x"11111111" and data_out_SIG = x"00000000")
	    report "CASE 1: Unexpected signal change for data_in and/or data_out" severity failure;
	    
	    -- clock = 0, readnotwrite = 1 --
	    -- register index 1
	    -- data_in: 0010 0010 0010 0010 0010 1101 0010 0010
	    clock_SIG         <= 	'0';
	    readnotwrite_SIG  <= 	'1';
	    reg_num_SIG       <= 	"00001";
	    data_in_SIG       <= 	x"22222222";
	    wait for TIME_DELTA;
	    assert (data_in_SIG = x"22222222" and data_out_SIG = x"00000000") 
	    report "CASE 2: Unexpected signal change for data_in and/or data_out" severity failure;
	    
	    -- clock = 1, readnotwrite = 0 --
	    -- register index 2
	    -- data_in: 0011 0011 0011 0011 00011 0011 0011 0011
	    clock_SIG         <= 	'1';
	    readnotwrite_SIG  <= 	'0';
	    reg_num_SIG       <= 	"00010";
	    data_in_SIG       <= 	x"33333333";
	    wait for TIME_DELTA;
	    assert (data_in_SIG = x"33333333" and data_out_SIG = x"00000000") 
	    report "CASE 3: Unexpected signal change for data_in and/or data_out" severity failure;
	    
	    -- clock = 1, readnotwrite = 1 --
	    -- register index 3
	    -- data_in: 0100 0100 0100 0100 0100 0100 0100 0100
	    clock_SIG         <= 	'1';
	    readnotwrite_SIG  <= 	'1';
	    reg_num_SIG       <= 	"00011";
	    data_in_SIG       <= 	x"44444444";
	    wait for TIME_DELTA;
	    assert (data_in_SIG = x"44444444" and data_out_SIG = x"00000000") 
	    report "CASE 4: Unexpected signal change for data_in and/or data_out" severity failure;
	
	    wait; -- Auto Termination   
  	end process;
end test;