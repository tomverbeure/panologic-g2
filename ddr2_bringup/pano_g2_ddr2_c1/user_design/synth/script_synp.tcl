project -new 
add_file -verilog "../rtl/infrastructure.v"
add_file -verilog "../rtl/memc_wrapper.v"
add_file -verilog "../rtl/pano_g2_ddr2_c1.v"
add_file -verilog "../rtl/mcb_controller/iodrp_controller.v"
add_file -verilog "../rtl/mcb_controller/iodrp_mcb_controller.v"
add_file -verilog "../rtl/mcb_controller/mcb_raw_wrapper.v"
add_file -verilog "../rtl/mcb_controller/mcb_soft_calibration.v"
add_file -verilog "../rtl/mcb_controller/mcb_soft_calibration_top.v"
add_file -verilog "../rtl/mcb_controller/mcb_ui_top.v"
add_file -constraint "../synth/mem_interface_top_synp.sdc"
impl -add rev_1
set_option -technology spartan6
set_option -part xc6slx150
set_option -package fgg484
set_option -speed_grade -2
set_option -default_enum_encoding default
#AXI_ENABLE synp definition is not required for user_design
set_option -symbolic_fsm_compiler 1
set_option -resource_sharing 0
set_option -use_fsm_explorer 0
set_option -top_module "pano_g2_ddr2_c1"
set_option -frequency 125
set_option -fanout_limit 1000
set_option -disable_io_insertion 0
set_option -pipe 1
set_option -fixgatedclocks 0
set_option -retiming 0
set_option -modular 0
set_option -update_models_cp 0
set_option -verification_mode 0
set_option -write_verilog 0
set_option -write_vhdl 0
set_option -write_apr_constraint 0
project -result_file "../synth/rev_1/pano_g2_ddr2_c1.edf"
set_option -vlog_std v2001
set_option -auto_constrain_io 0
impl -active "../synth/rev_1"
project -run
project -save

