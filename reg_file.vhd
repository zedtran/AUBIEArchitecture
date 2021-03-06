LIBRARY work;
USE work.bv_arithmetic.ALL;
USE work.dlx_types.ALL;

-------------------------------------------------------------------
-- 	BEGIN Define ENTITY "reg_file" 				 --
-- NOTE: We implement a 32-bit Datapath which uses 8 hex digits. --
-- 		 A 16-bit Datapath would utilize 4 hex digits	 --
-------------------------------------------------------------------
entity reg_file is
	generic(
		prop_delay		: Time := 15 ns
	);
	-- Signals
	port(
		clock			: in bit;
		readnotwrite	        : in bit;
		reg_number		: in register_index;
		data_in 		: in dlx_word;
		data_out		: out dlx_word
	);
end entity reg_file;


---------------------------------------------
-- BEGIN Defining ARCHITECTURE "reg_file"  --
---------------------------------------------
architecture behavior of reg_file is
		----------------------------------------------------------
		-- 	Type Define (Act as 'storage' for our process)  --
		-- reg_type: defines a data structure for		--
		--	         an array of 32-bit words 		--
		----------------------------------------------------------
		type reg_type is array (0 to 31) of dlx_word;
begin
	reg_file_process: process(readnotwrite, clock, reg_number, data_in) is
	----------------------------------------------------------------------
	-- NOTE: Process accepts only input signals from our defined entity --
	----------------------------------------------------------------------
		----------------------------------------------------------
		-- 	Variable (Act as 'storage' for our process)  	--
		-- registers: implements reg_type and initializes       --
		--	      registers we use for this process		--
		----------------------------------------------------------
		variable registers: reg_type;
	begin
		-- Start process
		if (clock = '1') then
			if (readnotwrite = '1') then
				---------------------------------------------------------------
				-- 	[Performing "READ" Operation (readnotwrite = '1')]   --
				-- Here, we simply ignore 'data_in' and copy value in 	     --
				-- registers at index --> reg_number to data_out port signal --
				---------------------------------------------------------------
				data_out <= registers(bv_to_integer(reg_number)) after prop_delay;
			else
				------------------------------------------------------
				-- 	[Performing "WRITE" Operation]		    --
				-- Value from 'data_in' is copied into registers at --
				-- register index --> 'reg_number'		    --
				------------------------------------------------------
				registers(bv_to_integer(reg_number)) := data_in;
				------------------------------------------------------
				-- NOTE: No prop_delay is applied because we don't  --
				--	want to delay variable assignments. 	    --
				------------------------------------------------------
			end if;
		end if;
	end process reg_file_process;
end architecture behavior;
