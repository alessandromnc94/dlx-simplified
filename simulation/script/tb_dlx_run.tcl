# vsim work.ENTITY
vsim work.tb_dlx
# add wave [-label LABEL] [-color STD_COLOR] [-RADIX] SIGNAL_ABSOLUTE_REFERENCE
# Insert your waves below

add wave -hexadecimal -group DLX dut/*
add wave -hexadecimal -group DATAPATH dut/datapath0/*
add wave -hexadecimal -group CU_HW dut/cu_hw0/*
add wave -hexadecimal -group FORWARDING dut/datapath0/forwinst/*
add wave -hexadecimal -group ALU dut/datapath0/aluinst/*
# add wave -group DLX dut/*
# add wave -group DATAPATH dut/datapath0/*
# add wave -group FORWARDING dut/datapath0/forwinst/*
# add wave -hexadecimal dut/*
# add wave -hexadecimal dut/datapath0/*
# add wave -hexadecimal dut/datapath0/forwinst/*

wave sort fa

run 50 ns
