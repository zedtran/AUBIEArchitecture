restart -f
add wave -position insertpoint \
sim:/aubie/aubie_clock \
sim:/aubie/aubie_ctl/behav/state \
sim:/aubie/aubie_ctl/ir_control \
sim:/aubie/aubie_ctl/behav/opcode \
sim:/aubie/aubie_ctl/behav/destination \
sim:/aubie/aubie_ctl/behav/operand1 \
sim:/aubie/aubie_ctl/behav/operand2 \
sim:/aubie/aubie_regfile/reg_file_process/registers \
sim:/aubie/mem_out \
sim:/aubie/memaddr_in \
sim:/aubie/regfile_index \
sim:/aubie/addr_in \
sim:/aubie/addr_out \
sim:/aubie/ir_out \
sim:/aubie/pc_out \
sim:/aubie/pc_in \
sim:/aubie/regfile_in \
sim:/aubie/regfile_out \
sim:/aubie/memaddr_mux \
sim:/aubie/mem_clk \
sim:/aubie/mem_readnotwrite \
sim:/aubie/ir_clk \
sim:/aubie/pc_clk \
sim:/aubie/regfile_clk \
sim:/aubie/regfile_readnotwrite
force -freeze sim:/aubie/aubie_clock 1 0, 0 {50 ns} -r 100


run 1000 ns