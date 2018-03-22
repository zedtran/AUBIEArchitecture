LIBRARY work;
USE work.bv_arithmetic.ALL;
USE work.dlx_types.ALL;

-- BEGIN Define ENTITY "reg_file" --
entity reg_file is
	generic(
		prop_delay		: Time:= 15 ns
	);
	port(
		readnotwrite, clock	: in bit;
		reg_number		: in register_index		
		data_in 		: in dlx_word;  
		data_out		: out dlx_word;
	);
end entity reg_file; -- END ENTITY


-- BEGIN Define ARCHITECTURE "reg_file" --
architecture behavior of reg_file is
		type reg_type is array (0 to 31) of dlx_word;
		variable registers	: reg_type
begin
	file_read_write: process(readnotwrite, clock, reg_number, data_in, data_out) is
	begin 
	
		-- ADD CODE HERE
	
	end process file_read_write;
end architecture behavior; 






--entity cnotGate is 
--	generic(prop_delay: Time:= 10 ns);
--	port(a_in, b_in: in bit; 
--		cnot_out: out bit);
--end entity cnotGate;
--
--architecture behaviour1 of cnotGate is 
--begin
--	cnotProcess: process(a_in, b_in) is
--	
--	begin
--		if a_in = '1' then
--			if b_in = '1' then 
--				-- 1 and 1 = 0 --
--				cnot_out <= '0' after prop_delay;
--			else  
--				-- 1 and 0 = 1 --
--				cnot_out <= '1' after prop_delay;
--		end if;
--		else
--			if b_in = '1' then 
--				-- 0 and 1 = 1 --
--				cnot_out <= '1' after prop_delay;
--			else
--				--0 and 0 = 0 --
--				cnot_out <= '0' after prop_delay;
--			end if;
--		end if;
--	end process cnotProcess;
--end architecture behaviour1;