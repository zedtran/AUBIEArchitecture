
use work.bv_arithmetic.all; 
use work.dlx_types.all; 

entity aubie_controller is
	port(ir_control: in dlx_word;
	     alu_out: in dlx_word; 
	     alu_error: in error_code; 
	     clock: in bit; 
	     regfilein_mux: out threeway_muxcode; 
	     memaddr_mux: out threeway_muxcode; 
	     addr_mux: out bit; 
	     pc_mux: out bit; 
	     alu_func: out alu_operation_code; 
	     regfile_index: out register_index;
	     regfile_readnotwrite: out bit; 
	     regfile_clk: out bit;   
	     mem_clk: out bit;
	     mem_readnotwrite: out bit;  
	     ir_clk: out bit; 
	     imm_clk: out bit; 
	     addr_clk: out bit;  
             pc_clk: out bit; 
	     op1_clk: out bit; 
	     op2_clk: out bit; 
	     result_clk: out bit
	     ); 
end aubie_controller; 

architecture behavior of aubie_controller is
begin
	behav: process(clock) is 
		type state_type is range 1 to 20; 
		variable state: state_type := 1; 
		variable opcode: byte; 
		variable destination,operand1,operand2 : register_index; 

	begin
		if clock'event and clock = '1' then
		   opcode := ir_control(31 downto 24);
		   destination := ir_control(23 downto 19);
		   operand1 := ir_control(18 downto 14);
		   operand2 := ir_control(13 downto 9); 
		   case state is
			when 1 => -- fetch the instruction, for all types
				-- your code goes here
				state := 2; 
			when 2 =>  
				
				-- figure out which instruction
			 	if opcode(7 downto 4) = "0000" then -- ALU op
					state := 3; 
				elsif opcode = X"20" then  -- STO 
				elsif opcode = X"30" or opcode = X"31" then -- LD or LDI
					state := 7;
				elsif opcode = X"22" then -- STOR
				elsif opcode = X"32" then -- LDR
				elsif opcode = X"40" or opcode = X"41" then -- JMP or JZ
				elsif opcode = X"10" then -- NOOP
				else -- error
				end if; 
			when 3 => 
				-- ALU op:  load op1 register from the regfile
				-- your code here 
				state := 4; 
			when 4 => 
				-- ALU op: load op2 registear from the regfile 
				-- your code here
         	state := 5; 
			when 5 => 
				-- ALU op:  perform ALU operation
				-- your code here
            state := 6; 
			when 6 => 
				-- ALU op: write back ALU operation
				-- your code here
            state := 1; 
			when 7 => 
				-- LD or LDI: get the addr or immediate word
			   -- your code here 
				state := 8; 
			when 8 => 
				-- LD or LDI
				-- your code here
        		state := 1; 
			when others => null; 
		   end case; 
		elsif clock'event and clock = '0' then
			-- reset all the register clocks
		   -- your code here				
		end if; 
	end process behav;
end behavior;	