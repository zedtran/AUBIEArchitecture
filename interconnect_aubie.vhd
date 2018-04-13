use work.bv_arithmetic.all; 
use work.dlx_types.all; 

-- interconnect of aubie cpu

entity aubie is
    port(aubie_clock: in bit);
end aubie; 

architecture struct of aubie is
	signal result_out,
		mem_out, 
		memaddr_in,
		ir_out,
		imm_out,
		addr_in,
		addr_out,
		pcplusone_out,
		pc_out,
		pc_in,
		regfile_in,
		regfile_out,
		alu_out,
		op1_out,
		op2_out : dlx_word;

	signal alu_func: alu_operation_code; 

	signal regfile_mux, memaddr_mux: threeway_muxcode;

	signal regfile_index: register_index; 
	
	signal addr_mux, pc_mux, 
		mem_clk, mem_readnotwrite, 
		ir_clk, imm_clk,
		addr_clk, pc_clk, regfile_clk, regfile_readnotwrite,
	        op1_clk, op2_clk, result_clk:  bit; 

	signal alu_error: error_code; 

begin -- structure of aubie 
	aubie_ctl: entity work.aubie_controller(behavior)
	  port map ( 
		ir_control => ir_out, 
		alu_out => alu_out,
		alu_error => alu_error,
		clock => aubie_clock,
		regfilein_mux => regfile_mux, 
		memaddr_mux => memaddr_mux,
		addr_mux => addr_mux, 
		pc_mux => pc_mux,
		alu_func => alu_func, 
		regfile_index => regfile_index,
		regfile_readnotwrite => regfile_readnotwrite, 
		regfile_clk => regfile_clk,
		mem_clk => mem_clk,
		mem_readnotwrite => mem_readnotwrite, 
		ir_clk => ir_clk, 
		imm_clk => imm_clk, 
		addr_clk => addr_clk, 
		pc_clk => pc_clk,
		op1_clk => op1_clk, 
		op2_clk => op2_clk, 
		result_clk => result_clk); 

	aubie_memory: entity work.memory(behavior) 
		port map (
			address => memaddr_in,
			readnotwrite => mem_readnotwrite,
			data_out => mem_out,
			data_in => result_out,
			clock => mem_clk);

	aubie_ir: entity work.dlx_register(behavior)
		port map (
			in_val => mem_out,
			clock => ir_clk,
			out_val => ir_out); 

	aubie_immed: entity work.dlx_register(behavior)
		port map (
			in_val => mem_out, 
			clock => imm_clk,
			out_val => imm_out);

	aubie_addr: entity work.dlx_register(behavior)
		port map (
			in_val => addr_in, 
			clock => addr_clk,
			out_val => addr_out);

	aubie_pc: entity work.dlx_register(behavior)
		port map (
			in_val => pc_in, 
			clock => pc_clk,
			out_val => pc_out);

	aubie_op1: entity work.dlx_register(behavior)
		port map (
			in_val => regfile_out, 
			clock => op1_clk,
			out_val => op1_out);

	aubie_op2: entity work.dlx_register(behavior)
		port map (
			in_val => regfile_out, 
			clock => op2_clk,
			out_val => op2_out);

	aubie_result: entity work.dlx_register(behavior)
		port map (
			in_val => alu_out, 
			clock => result_clk,
			out_val => result_out);

	aubie_regfile: entity work.reg_file(behavior)
		port map ( 
			data_in => regfile_in,
			readnotwrite => regfile_readnotwrite,
			clock => regfile_clk,
			reg_number => regfile_index,
			data_out => regfile_out);

	aubie_alu: entity work.alu(behavior)
		port map ( 
			operand1 => op1_out,
			operand2 => op2_out,
			operation => alu_func,
			result => alu_out, 
			error => alu_error); 

	aubie_addr_mux: entity work.mux(behavior) 
		port map ( 
			input_1 =>  mem_out,
			input_0 => regfile_out,
			which => addr_mux,
			output => addr_in); 

	aubie_pc_mux: entity work.mux(behavior) 
		port map ( 
			input_1 =>  addr_out,
			input_0 => pcplusone_out,
			which => pc_mux,
			output => pc_in); 

	aubie_memaddr_mux: entity work.threeway_mux(behavior) 
		port map ( 
			input_2 => regfile_out,
			input_1 =>  addr_out,
			input_0 => pc_out,
			which => memaddr_mux,
			output => memaddr_in); 

	aubie_regfilein_mux: entity work.threeway_mux(behavior) 
		port map ( 
			input_2 => imm_out,
			input_1 =>  mem_out,
			input_0 => result_out,
			which => regfile_mux,
			output => regfile_in); 

	aubie_pcpluspone: entity work.pcplusone(behavior)
		port map (
			input => pc_out,
			clock => pc_clk, -- this is just here to make it execute
			output => pcplusone_out); 

end struct;