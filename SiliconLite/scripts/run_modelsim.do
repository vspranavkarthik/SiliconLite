transcript on
if {[file exists work]} {vdel -lib work -all}
vlib work
vlog rtl/siliconlite_cpu.v tb/tb_siliconlite_cpu.v
vsim work.tb_siliconlite_cpu
run -all
quit -f