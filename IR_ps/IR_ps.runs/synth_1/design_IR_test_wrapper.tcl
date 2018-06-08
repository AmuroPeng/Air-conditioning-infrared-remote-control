# 
# Synthesis run script generated by Vivado
# 

debug::add_scope template.lib 1
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7z020clg400-1

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir D:/5Project/PYNQ/Air-conditioning-infrared-remote-control/IR_ps/IR_ps.cache/wt [current_project]
set_property parent.project_path D:/5Project/PYNQ/Air-conditioning-infrared-remote-control/IR_ps/IR_ps.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_repo_paths {
  d:/5project/pynq/air-conditioning-infrared-remote-control/ip_repo_ir/ir_1.0
  d:/5Project/PYNQ/Air-conditioning-infrared-remote-control/ip_repo_IR
} [current_project]
add_files D:/5Project/PYNQ/Air-conditioning-infrared-remote-control/IR_ps/IR_ps.srcs/sources_1/bd/design_IR_test/design_IR_test.bd
set_property used_in_implementation false [get_files -all d:/5Project/PYNQ/Air-conditioning-infrared-remote-control/IR_ps/IR_ps.srcs/sources_1/bd/design_IR_test/ip/design_IR_test_processing_system7_0_0/design_IR_test_processing_system7_0_0.xdc]
set_property used_in_implementation false [get_files -all d:/5Project/PYNQ/Air-conditioning-infrared-remote-control/IR_ps/IR_ps.srcs/sources_1/bd/design_IR_test/ip/design_IR_test_rst_processing_system7_0_100M_0/design_IR_test_rst_processing_system7_0_100M_0_board.xdc]
set_property used_in_implementation false [get_files -all d:/5Project/PYNQ/Air-conditioning-infrared-remote-control/IR_ps/IR_ps.srcs/sources_1/bd/design_IR_test/ip/design_IR_test_rst_processing_system7_0_100M_0/design_IR_test_rst_processing_system7_0_100M_0.xdc]
set_property used_in_implementation false [get_files -all d:/5Project/PYNQ/Air-conditioning-infrared-remote-control/IR_ps/IR_ps.srcs/sources_1/bd/design_IR_test/ip/design_IR_test_rst_processing_system7_0_100M_0/design_IR_test_rst_processing_system7_0_100M_0_ooc.xdc]
set_property used_in_implementation false [get_files -all d:/5Project/PYNQ/Air-conditioning-infrared-remote-control/IR_ps/IR_ps.srcs/sources_1/bd/design_IR_test/ip/design_IR_test_auto_pc_0/design_IR_test_auto_pc_0_ooc.xdc]
set_property used_in_implementation false [get_files -all D:/5Project/PYNQ/Air-conditioning-infrared-remote-control/IR_ps/IR_ps.srcs/sources_1/bd/design_IR_test/design_IR_test_ooc.xdc]
set_property is_locked true [get_files D:/5Project/PYNQ/Air-conditioning-infrared-remote-control/IR_ps/IR_ps.srcs/sources_1/bd/design_IR_test/design_IR_test.bd]

read_verilog -library xil_defaultlib D:/5Project/PYNQ/Air-conditioning-infrared-remote-control/IR_ps/IR_ps.srcs/sources_1/bd/design_IR_test/hdl/design_IR_test_wrapper.v
read_xdc D:/5Project/PYNQ/Air-conditioning-infrared-remote-control/IR_ps/IR_ps.srcs/constrs_1/new/111.xdc
set_property used_in_implementation false [get_files D:/5Project/PYNQ/Air-conditioning-infrared-remote-control/IR_ps/IR_ps.srcs/constrs_1/new/111.xdc]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
synth_design -top design_IR_test_wrapper -part xc7z020clg400-1
write_checkpoint -noxdef design_IR_test_wrapper.dcp
catch { report_utilization -file design_IR_test_wrapper_utilization_synth.rpt -pb design_IR_test_wrapper_utilization_synth.pb }