LIBRARY work;
USE work.bv_arithmetic.ALL;
USE work.dlx_types.ALL;

entity reg_file_tb is
end reg_file_tb;

architecture test of reg_file_tb is

	component reg_file is
		generic ( prop_delay: time := 15 ns );
		port (
			clock           : in  bit;
			readnotwrite    : in  bit;
			reg_number      : in register_index;
			data_in         : in dlx_word;
			data_out        : out dlx_word
		);
    	end component reg_file;

	-- Inputs --
	signal clock         : bit := '0';
	signal readnotwrite  : bit := '0';
	signal reg_number    : register_index := "00000";
	signal data_in       : dlx_word := x"00000000";
	
	-- Outputs --	
	signal data_out      : dlx_word;

	-- Time interval between signal changes
	constant TIME_DELTA 	: time := 20 ns;
  
	-- Used for converting a single binary bit to string format for assertion output --
	type T_bit_map is array(bit) of character;
	constant C_BIT_MAP: T_bit_map := ('0', '1');

	type reg_type is array (0 to 31) of dlx_word;


begin
	-- Instantiate Unit Under Test (UUT)
	uut: reg_file 
		port map (
			clock          => 	clock,
			readnotwrite   => 	readnotwrite,
			reg_number     => 	reg_number,
			data_in        => 	data_in,
			data_out       => 	data_out
		);
		
		-- Stimuli (Lines 52 - 61) --
		clock		 <= '1', '0' after 140 ns;
		readnotwrite 	 <= '0', '1' after 30 ns, '0' after 60 ns, '1' after 90 ns, '0' after 120 ns, '0' after 170 ns;
		
		--------------------------------------------------------------------------------------------------------------------------------	
		-- NOTE: For the purpose of showing data_out being modified during the simulation, we will use the same register index value. --
		-- 	 The below line denoted with (#) can be used if we want to show new register indeces being written to.		      --
		--------------------------------------------------------------------------------------------------------------------------------
		reg_number 	 <= "00000"; 
		-- (#) reg_number 	 <= "00000", "00000" after 30 ns, "00000" after 60 ns, "00000" after 90 ns, "00000" after 120 ns, "00000" after 170 ns;
		data_in		 <= x"11111111", x"22222222" after 30 ns, x"33333333" after 60 ns, x"44444444" after 90 ns, x"55555555" after 120 ns, x"00000000" after 170 ns;

	  -- Test
	  stimulus_process: process

	  begin
	    	-- Check UUT response --
		
		wait for 170 ns; -- Let all input signals propagate
	    wait; -- Terminate so we don't continue run -all   
  	  end process;
end test;