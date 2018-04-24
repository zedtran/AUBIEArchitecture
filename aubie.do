restart -f
add wave -position insertpoint \
sim:/aubie/aubie_clock \
sim:/aubie/aubie_ctl/behav/current_state \
sim:/aubie/aubie_ctl/behav/next_state \
sim:/aubie/ir_clk \
sim:/aubie/aubie_ctl/ir_control \
sim:/aubie/aubie_ctl/behav/opcode \
sim:/aubie/aubie_ctl/behav/destination \
sim:/aubie/aubie_ctl/behav/operand1 \
sim:/aubie/aubie_ctl/behav/operand2 \
sim:/aubie/mem_clk \
sim:/aubie/memaddr_mux \
sim:/aubie/memaddr_in \
sim:/aubie/mem_readnotwrite \
sim:/aubie/mem_out \
sim:/aubie/aubie_memory/mem_behav/data_memory \
sim:/aubie/addr_clk \
sim:/aubie/addr_in \
sim:/aubie/addr_out \
sim:/aubie/pc_clk \
sim:/aubie/pc_mux \
sim:/aubie/pc_in \
sim:/aubie/pc_out \
sim:/aubie/regfile_clk \
sim:/aubie/aubie_regfile/reg_file_process/registers \
sim:/aubie/regfile_index \
sim:/aubie/regfile_readnotwrite \
sim:/aubie/regfile_in \
sim:/aubie/regfile_out 
force -freeze sim:/aubie/aubie_clock 0 0, 1 {50 ns} -r 100

run 4000 ns