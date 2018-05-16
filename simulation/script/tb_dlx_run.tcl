# vsim work.ENTITY
vsim work.tb_dlx
# add wave [-label LABEL] [-color STD_COLOR] [-RADIX] SIGNAL_ABSOLUTE_REFERENCE
# Insert your waves below

add wave -hexadecimal dut/*
wave sort ascending

run 10 ns
