## Generated SDC file "QFP.sdc"

## Copyright (C) 1991-2011 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 11.1 Build 259 01/25/2012 Service Pack 2 SJ Web Edition"

## DATE    "Tue Jul 01 23:52:29 2014"

##
## DEVICE  "EP4CE22F17C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 6.000 -waveform { 0.000 3.000 } [get_ports {clock_50}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************

set_multicycle_path -setup -end -from [get_registers {din[6] din[7] din[8] din[9] din[10] din[11] din[12] din[13] din[14] din[15] din[16] din[17] din[18] din[19] din[20] din[21] din[22] din[23] din[24] din[25] din[26] din[27] din[28] din[29] din[30] din[31] din[32] din[33] din[34] din[38] din[39] din[40] din[41] din[42] din[43] din[44] din[45] din[46] din[47] din[48] din[49] din[50] din[51] din[52] din[53] din[54] din[55] din[56] din[57] din[58] din[59] din[60] din[61] din[62] din[63] din[64] din[65] din[66]}] -to [get_registers {qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[0] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[1] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[2] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[3] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[4] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[5] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[6] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[7] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[8] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[9] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[10] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[11] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[12] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[13] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[14] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[15] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[16] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[17] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[18] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[19] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[20] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[21] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[22] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[23] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[24] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[25] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[26] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[27] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[28] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[29] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[30] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[31] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[32] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[33] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[34] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[35] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[36] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[37] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[38] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[39] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[40] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[41] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[42] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[43] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[44] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[45] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[46] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[47] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[48] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[49] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[50] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[51] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[52] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[53] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[54] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[55] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[56] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[57]}] 2
set_multicycle_path -hold -end -from [get_registers {din[6] din[7] din[8] din[9] din[10] din[11] din[12] din[13] din[14] din[15] din[16] din[17] din[18] din[19] din[20] din[21] din[22] din[23] din[24] din[25] din[26] din[27] din[28] din[29] din[30] din[31] din[32] din[33] din[34] din[38] din[39] din[40] din[41] din[42] din[43] din[44] din[45] din[46] din[47] din[48] din[49] din[50] din[51] din[52] din[53] din[54] din[55] din[56] din[57] din[58] din[59] din[60] din[61] din[62] din[63] din[64] din[65] din[66]}] -to [get_registers {qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[0] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[1] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[2] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[3] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[4] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[5] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[6] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[7] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[8] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[9] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[10] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[11] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[12] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[13] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[14] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[15] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[16] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[17] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[18] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[19] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[20] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[21] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[22] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[23] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[24] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[25] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[26] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[27] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[28] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[29] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[30] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[31] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[32] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[33] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[34] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[35] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[36] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[37] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[38] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[39] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[40] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[41] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[42] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[43] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[44] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[45] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[46] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[47] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[48] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[49] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[50] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[51] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[52] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[53] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[54] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[55] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[56] qfp_unit:qfp_unit_1|qfp32_mul:qfp32_mul_1|p2_result[57]}] 1
set_multicycle_path -setup -end -from [get_registers {din[6] din[7] din[8] din[9] din[10] din[11] din[12] din[13] din[14] din[15] din[16] din[17] din[18] din[19] din[20] din[21] din[22] din[23] din[24] din[25] din[26] din[27] din[28] din[29] din[30] din[31] din[32] din[33] din[34] din[35] din[36] din[37] din[38] din[39] din[40] din[41] din[42] din[43] din[44] din[45] din[46] din[47] din[48] din[49] din[50] din[51] din[52] din[53] din[54] din[55] din[56] din[57] din[58] din[59] din[60] din[61] din[62] din[63] din[64] din[65] din[66] din[67] din[68] din[69]}] -to [get_fanouts [get_registers *\|qfp32_divider*\|start_1d]] 2
set_multicycle_path -hold -end -from [get_registers {din[6] din[7] din[8] din[9] din[10] din[11] din[12] din[13] din[14] din[15] din[16] din[17] din[18] din[19] din[20] din[21] din[22] din[23] din[24] din[25] din[26] din[27] din[28] din[29] din[30] din[31] din[32] din[33] din[34] din[35] din[36] din[37] din[38] din[39] din[40] din[41] din[42] din[43] din[44] din[45] din[46] din[47] din[48] din[49] din[50] din[51] din[52] din[53] din[54] din[55] din[56] din[57] din[58] din[59] din[60] din[61] din[62] din[63] din[64] din[65] din[66] din[67] din[68] din[69]}] -to [get_fanouts [get_registers *\|qfp32_divider*\|start_1d]] 1
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

