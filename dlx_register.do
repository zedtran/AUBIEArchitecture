add wave -position insertpoint  \
sim:/dlx_register/in_val  \
sim:/dlx_register/clock  \
sim:/dlx_register/out_val  \


force -freeze sim:/dlx_register/in_val 32'hFFFFFFFF 0
force -freeze sim:/dlx_register/in_val 32'h00000000 50
force -freeze sim:/dlx_register/clock 1 0, 0 {50 ns} -r 100
run 100 ns

