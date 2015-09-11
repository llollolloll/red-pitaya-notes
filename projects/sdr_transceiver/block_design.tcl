# Create processing_system7
cell xilinx.com:ip:processing_system7:5.5 ps_0 {
  PCW_IMPORT_BOARD_PRESET cfg/red_pitaya.xml
} {
  M_AXI_GP0_ACLK ps_0/FCLK_CLK0
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {
  make_external {FIXED_IO, DDR}
  Master Disable
  Slave Disable
} [get_bd_cells ps_0]

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset:5.0 rst_0

# Create util_ds_buf
cell xilinx.com:ip:util_ds_buf:2.1 buf_0 {
  C_SIZE 2
  C_BUF_TYPE IBUFDS
} {
  IBUF_DS_P daisy_p_i
  IBUF_DS_N daisy_n_i
}

# Create util_ds_buf
cell xilinx.com:ip:util_ds_buf:2.1 buf_1 {
  C_SIZE 2
  C_BUF_TYPE OBUFDS
} {
  OBUF_DS_P daisy_p_o
  OBUF_DS_N daisy_n_o
}

# Create axis_red_pitaya_adc
cell pavel-demin:user:axis_red_pitaya_adc:1.0 adc_0 {} {
  adc_clk_p adc_clk_p_i
  adc_clk_n adc_clk_n_i
  adc_dat_a adc_dat_a_i
  adc_dat_b adc_dat_b_i
  adc_csn adc_csn_o
}

# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary:12.0 cntr_0 {
  Output_Width 32
} {
  CLK adc_0/adc_clk
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_0 {
  DIN_WIDTH 32 DIN_FROM 26 DIN_TO 26 DOUT_WIDTH 1
} {
  Din cntr_0/Q
  Dout led_o
}

# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_0

# Create axis_clock_converter
cell xilinx.com:ip:axis_clock_converter:1.1 fifo_0 {} {
  S_AXIS adc_0/M_AXIS
  s_axis_aclk adc_0/adc_clk
  s_axis_aresetn const_0/dout
  m_axis_aclk ps_0/FCLK_CLK0
  m_axis_aresetn rst_0/peripheral_aresetn
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster:1.1 bcast_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 2
  M00_TDATA_REMAP {tdata[15:0]}
  M01_TDATA_REMAP {tdata[31:16]}
} {
  S_AXIS fifo_0/M_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

module trx_0 {
  source projects/sdr_transceiver/trx.tcl
} {
  rx_0/mult_0/S_AXIS_A bcast_0/M00_AXIS
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins trx_0/cfg_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg0]
set_property OFFSET 0x40000000 [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg0]

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins trx_0/sts_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg0]
set_property OFFSET 0x40001000 [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg0]

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins trx_0/rx_reader_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_rx_reader_0_reg0]
set_property OFFSET 0x40002000 [get_bd_addr_segs ps_0/Data/SEG_rx_reader_0_reg0]

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins trx_0/tx_writer_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_tx_writer_0_reg0]
set_property OFFSET 0x40003000 [get_bd_addr_segs ps_0/Data/SEG_tx_writer_0_reg0]

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 out_slice_0 {
  DIN_WIDTH 160 DIN_FROM 23 DIN_TO 16 DOUT_WIDTH 8
} {
  Din trx_0/cfg_0/cfg_data
}

# Delete input/output port
delete_bd_objs [get_bd_ports exp_n_io]

# Create output port
create_bd_port -dir O -from 7 -to 0 exp_n_io

# Connect output port
connect_bd_net [get_bd_pins out_slice_0/Dout] [get_bd_pins exp_n_io]


module trx_1 {
  source projects/sdr_transceiver/trx.tcl
} {
  rx_0/mult_0/S_AXIS_A bcast_0/M01_AXIS
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins trx_1/cfg_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg01]
set_property OFFSET 0x40010000 [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg01]

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins trx_1/sts_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg01]
set_property OFFSET 0x40011000 [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg01]

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins trx_1/rx_reader_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_rx_reader_0_reg01]
set_property OFFSET 0x40012000 [get_bd_addr_segs ps_0/Data/SEG_rx_reader_0_reg01]

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins trx_1/tx_writer_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_tx_writer_0_reg01]
set_property OFFSET 0x40013000 [get_bd_addr_segs ps_0/Data/SEG_tx_writer_0_reg01]

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 out_slice_1 {
  DIN_WIDTH 160 DIN_FROM 31 DIN_TO 24 DOUT_WIDTH 8
} {
  Din trx_1/cfg_0/cfg_data
}

# Delete input/output port
delete_bd_objs [get_bd_ports exp_p_io]

# Create output port
create_bd_port -dir O -from 7 -to 0 exp_p_io

# Connect output port
connect_bd_net [get_bd_pins out_slice_1/Dout] [get_bd_pins exp_p_io]

# Create clk_wiz
cell xilinx.com:ip:clk_wiz:5.1 pll_0 {
  PRIMITIVE PLL
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 125.0
  CLKOUT1_USED true
  CLKOUT2_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 125.0
  CLKOUT2_REQUESTED_OUT_FREQ 250.0
} {
  clk_in1 adc_0/adc_clk
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner:1.1 comb_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 2
} {
  S00_AXIS trx_0/tx_0/mult_0/M_AXIS_DOUT
  S01_AXIS trx_1/tx_0/mult_0/M_AXIS_DOUT
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create axis_clock_converter
cell xilinx.com:ip:axis_clock_converter:1.1 fifo_1 {} {
  S_AXIS comb_0/M_AXIS
  s_axis_aclk ps_0/FCLK_CLK0
  s_axis_aresetn rst_0/peripheral_aresetn
  m_axis_aclk pll_0/clk_out1
  m_axis_aresetn const_0/dout
}

# Create axis_red_pitaya_dac
cell pavel-demin:user:axis_red_pitaya_dac:1.0 dac_0 {} {
  aclk pll_0/clk_out1
  ddr_clk pll_0/clk_out2
  locked pll_0/locked
  S_AXIS fifo_1/M_AXIS
  dac_clk dac_clk_o
  dac_rst dac_rst_o
  dac_sel dac_sel_o
  dac_wrt dac_wrt_o
  dac_dat dac_dat_o
}

