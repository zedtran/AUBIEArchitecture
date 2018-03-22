LIBRARY work;
USE work.bv_arithmetic.ALL;
USE work.dlx_types.ALL;

-- BEGIN Define ENTITY "reg_file" --
ENTITY reg_file IS
	GENERIC(
		prop_delay		: Time:= 15 ns
	);
	-- Signals
	PORT(	
		clock			: in bit;
		readnotwrite		: in bit;
		reg_number		: in register_index;		
		data_in 		: in dlx_word;  
		data_out		: out dlx_word
	);
END ENTITY reg_file; -- END ENTITY
-- 32-bit Datapath -> 8 hex digits instead of 4 (shows as 0x signal in sim)


-- BEGIN Define ARCHITECTURE "reg_file" --
ARCHITECTURE behavior OF reg_file IS
		-- Variables (Storage for our single process)
		TYPE reg_type IS array (0 to 31) OF dlx_word;
		VARIABLE registers	: reg_type;
BEGIN
	-- Process takes input variables from our defined entity above --
	file_read_write: PROCESS(readnotwrite, clock, reg_number, data_in) IS
	BEGIN 
		-- Start process
		IF (clock = '1') THEN
			if (readnotwrite = '0') THEN
				-- PERFORM "WRITE"
				registers(bv_to_integer(reg_number)) := data_in; 
					-- No prop_delay is applied because we don't want to delay variable assignments.
					-- PROF Comments: "One might argue it takes time to save the value and if you read the value less 
					-- than 15ns (prop_delay) after writing it you should get the old value, this is hard to model
					-- so we won't delay "write".
			ELSE
				-- PERFORM "READ" (readnotwrite = '1')
				data_out <= registers(bv_to_integer(reg_number)) AFTER prop_delay; 
					-- copy of variables into the input signal
			END IF;
		END IF;
	END PROCESS file_read_write;
END ARCHITECTURE behavior; 
