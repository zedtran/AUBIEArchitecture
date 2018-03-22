LIBRARY work;
USE work.bv_arithmetic.ALL;
USE work.dlx_types.ALL;

-- BEGIN Define ENTITY "reg_file" --
entity reg_file is
	generic(
		prop_delay		: Time:= 15 ns
	);
	-- Signals
	port(	
		clock			: in bit;
		readnotwrite		: in bit;
		reg_number		: in register_index;		
		data_in 		: in dlx_word;  
		data_out		: out dlx_word
	);
end entity reg_file; -- END ENTITY
-- 32-bit Datapath -> 8 hex digits instead of 4 (shows as 0x signal in sim)
-- After write, then apply prop_delay (cannot delay variable assignments)


-- BEGIN Define ARCHITECTURE "reg_file" --
architecture behavior of reg_file is
		-- Variables (Storage for our single process)
		type reg_type is array (0 to 31) of dlx_word;
		variable registers	: reg_type;
begin
	-- Process takes input variables from our defined entity above --
	file_read_write: process(readnotwrite, clock, reg_number, data_in) is
	begin 
		-- Start process
		if (clock = '1') then
			if (readnotwrite = '0') then
				-- PERFORM "WRITE"
				registers(bv_to_integer(reg_number)) := data_in; 
				-- value needs to be something in array of variables (ignore prop_delay)
			else
				-- PERFORM "READ" (readnotwrite = '1')
				data_out <= registers(bv_to_integer(reg_number)) after prop_delay; 
				-- copy of variables into the input signal
			end if;
		end if;
	end process file_read_write;
end architecture behavior; 
