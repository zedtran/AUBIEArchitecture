LIBRARY work;
USE work.dlx_types.ALL;

-------------------------------------------------------------------
-- 	BEGIN Define ENTITY "dlx_register" 			 --
-- NOTE: We implement a 32-bit Datapath which uses 8 hex digits. --
-------------------------------------------------------------------
entity dlx_register is
	generic(prop_delay : Time := 5 ns);
	port(
	     in_val	: 	in dlx_word;
	     clock	: 	in bit;
	     out_val	: 	out dlx_word
	);
end entity dlx_register;

---------------------------------------------
-- BEGIN Defining ARCHITECTURE "dlx_register"  --
---------------------------------------------
architecture behavior of dlx_register is

begin
	dlx_reg_process: process(in_val, clock) is
	----------------------------------------------------------------------
	-- NOTE: Process accepts only input signals from our defined entity --
	----------------------------------------------------------------------
	begin
		-- Start process
		if (clock = '1') then
			out_val <= in_val after prop_delay;
		end if;
	end process dlx_reg_process;
end architecture behavior;
