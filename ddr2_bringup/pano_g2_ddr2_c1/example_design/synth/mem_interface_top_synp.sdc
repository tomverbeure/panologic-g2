# Synplicity, Inc. constraint file
# Written on Mon Jun 27 15:50:39 2005

define_attribute          {v:work.example_top} syn_hier {hard}
define_attribute          {v:work.infrastructure} syn_hier {hard}
define_attribute          {v:work.memc_tb_top} syn_hier {hard}
define_attribute          {v:work.memc_wrapper} syn_hier {hard}
define_attribute          {v:work.iodrp_controller} syn_hier {hard}
define_attribute          {v:work.iodrp_mcb_controller} syn_hier {hard}
define_attribute          {v:work.mcb_raw_wrapper} syn_hier {hard}
define_attribute          {v:work.mcb_soft_calibration} syn_hier {hard}
define_attribute          {v:work.mcb_soft_calibration_top} syn_hier {hard}
define_attribute          {v:work.mcb_ui_top} syn_hier {hard}
define_attribute          {v:work.afifo} syn_hier {hard}
define_attribute          {v:work.cmd_gen} syn_hier {hard}
define_attribute          {v:work.cmd_prbs_gen} syn_hier {hard}
define_attribute          {v:work.data_prbs_gen} syn_hier {hard}
define_attribute          {v:work.init_mem_pattern_ctr} syn_hier {hard}
define_attribute          {v:work.mcb_flow_control} syn_hier {hard}
define_attribute          {v:work.mcb_traffic_gen} syn_hier {hard}
define_attribute          {v:work.rd_data_gen} syn_hier {hard}
define_attribute          {v:work.read_data_path} syn_hier {hard}
define_attribute          {v:work.read_posted_fifo} syn_hier {hard}
define_attribute          {v:work.sp6_data_gen} syn_hier {hard}
define_attribute          {v:work.tg_status} syn_hier {hard}
define_attribute          {v:work.v6_data_gen} syn_hier {hard}
define_attribute          {v:work.wr_data_gen} syn_hier {hard}
define_attribute          {v:work.write_data_path} syn_hier {hard}

# clock Constraints
define_clock -disable -name {memc1_infrastructure_inst} -period 8000 -clockgroup default_clkgroup_1
define_clock          -name {memc1_infrastructure_inst.SYS_CLK_INST} -period 8000 -clockgroup default_clkgroup_2
define_clock -disable -name {memc1_infrastructure_inst.u_pll_adv} -period 8000 -clockgroup default_clkgroup_3




