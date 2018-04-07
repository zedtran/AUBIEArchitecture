add wave -position insertpoint  \
sim:/alu/operand1 \
sim:/alu/operand2 \
sim:/alu/operation \
sim:/alu/result \
sim:/alu/error


force -freeze sim:/alu/operand1 32'h00AAAAAA 0
force -freeze sim:/alu/operand2 32'h00111111 0
force -freeze sim:/alu/operation 4'h0 0
run 50 ns

force -freeze sim:/alu/operand1 32'hFFFFFFFF 0
force -freeze sim:/alu/operand2 32'h00000001 0
force -freeze sim:/alu/operation 4'h0 0
run 50 ns

force -freeze sim:/alu/operand1 32'hFFFFFFFF 0
force -freeze sim:/alu/operand2 32'h11111111 0
force -freeze sim:/alu/operation 4'h1 0
run 50 ns

force -freeze sim:/alu/operand1 32'h00000001 0
force -freeze sim:/alu/operand2 32'h00000010 0
force -freeze sim:/alu/operation 4'h1 0
run 50 ns

force -freeze sim:/alu/operand1 32'hFFFFFFF9 0
force -freeze sim:/alu/operand2 32'h00000007 0
force -freeze sim:/alu/operation 4'h2 0
run 50 ns

force -freeze sim:/alu/operand1 32'h7FFFFFFF 0
force -freeze sim:/alu/operand2 32'h00000001 0
force -freeze sim:/alu/operation 4'h2 0
run 50 ns

force -freeze sim:/alu/operand1 32'h80000000 0
force -freeze sim:/alu/operand2 32'h80000000 0
force -freeze sim:/alu/operation 4'h2 0
run 50 ns

force -freeze sim:/alu/operand1 32'h03333333 0
force -freeze sim:/alu/operand2 32'h02222222 0
force -freeze sim:/alu/operation 4'h3 0
run 50 ns

force -freeze sim:/alu/operand1 32'h7FFFFFFF 0
force -freeze sim:/alu/operand2 32'h80000000 0
force -freeze sim:/alu/operation 4'h3 0
run 50 ns

force -freeze sim:/alu/operand1 32'h80000000 0
force -freeze sim:/alu/operand2 32'h7FFFFFFF 0
force -freeze sim:/alu/operation 4'h3 0
run 50 ns

force -freeze sim:/alu/operand1 32'h00000100 0
force -freeze sim:/alu/operand2 32'h00000100 0
force -freeze sim:/alu/operation 4'h4 0
run 50 ns

force -freeze sim:/alu/operand1 32'h80000000 0
force -freeze sim:/alu/operand2 32'h80000001 0
force -freeze sim:/alu/operation 4'h4 0
run 50 ns

force -freeze sim:/alu/operand1 32'h80000000 0
force -freeze sim:/alu/operand2 32'h7FFFFFFE 0
force -freeze sim:/alu/operation 4'h4 0
run 50 ns

force -freeze sim:/alu/operand1 32'h00000064 0
force -freeze sim:/alu/operand2 32'h00000002 0
force -freeze sim:/alu/operation 4'h5 0
run 50 ns

force -freeze sim:/alu/operand1 32'h80000000 0
force -freeze sim:/alu/operand2 32'hFFFFFFFF 0
force -freeze sim:/alu/operation 4'h5 0
run 50 ns

force -freeze sim:/alu/operand1 32'h0FFFFFFF 0
force -freeze sim:/alu/operand2 32'h00000000 0
force -freeze sim:/alu/operation 4'h5 0
run 50 ns

force -freeze sim:/alu/operand1 32'h11111111 0
force -freeze sim:/alu/operand2 32'h11111111 0
force -freeze sim:/alu/operation 4'h6 0
run 50 ns

force -freeze sim:/alu/operand1 32'h00000000 0
force -freeze sim:/alu/operand2 32'h11111111 0
force -freeze sim:/alu/operation 4'h6 0
run 50 ns

force -freeze sim:/alu/operand1 32'hAAAAAAAA 0
force -freeze sim:/alu/operand2 32'h55555555 0
force -freeze sim:/alu/operation 4'h7 0
run 50 ns

force -freeze sim:/alu/operand1 32'hFFFFFFFF 0
force -freeze sim:/alu/operand2 32'h55555555 0
force -freeze sim:/alu/operation 4'h7 0
run 50 ns

force -freeze sim:/alu/operand1 32'h11111111 0
force -freeze sim:/alu/operand2 32'h11111111 0
force -freeze sim:/alu/operation 4'h8 0
run 50 ns

force -freeze sim:/alu/operand1 32'h00000000 0
force -freeze sim:/alu/operand2 32'h11111111 0
force -freeze sim:/alu/operation 4'h8 0
run 50 ns

force -freeze sim:/alu/operand1 32'hAAAAAAAA 0
force -freeze sim:/alu/operand2 32'h55555555 0
force -freeze sim:/alu/operation 4'h9 0
run 50 ns

force -freeze sim:/alu/operand1 32'hFFFFFFFF 0
force -freeze sim:/alu/operand2 32'h55555555 0
force -freeze sim:/alu/operation 4'h9 0
run 50 ns

force -freeze sim:/alu/operand1 32'h00000001 0
force -freeze sim:/alu/operand2 32'h00000000 0
force -freeze sim:/alu/operation 4'hA 0
run 50 ns

force -freeze sim:/alu/operand1 32'h00000000 0
force -freeze sim:/alu/operand2 32'h00000000 0
force -freeze sim:/alu/operation 4'hA 0
run 50 ns

force -freeze sim:/alu/operand1 32'h00000000 0
force -freeze sim:/alu/operand2 32'h00000000 0
force -freeze sim:/alu/operation 4'hB 0
run 50 ns

force -freeze sim:/alu/operand1 32'hFFFFFFFF 0
force -freeze sim:/alu/operand2 32'h00000000 0
force -freeze sim:/alu/operation 4'hB 0
run 50 ns