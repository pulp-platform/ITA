# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

add wave -noupdate /ita_tb/dut/i_inp1_mux/clk_i
add wave -noupdate /ita_tb/dut/i_inp1_mux/rst_ni
add wave -noupdate /ita_tb/dut/i_inp1_mux/inp_i
add wave -noupdate /ita_tb/dut/i_inp1_mux/inp1_o
add wave -noupdate /ita_tb/dut/i_inp2_mux/clk_i
add wave -noupdate /ita_tb/dut/i_inp2_mux/rst_ni
add wave -noupdate /ita_tb/dut/i_inp2_mux/weight_i
add wave -noupdate /ita_tb/dut/i_inp2_mux/inp2_o
add wave -noupdate /ita_tb/dut/i_controller/ctrl_i
add wave -noupdate /ita_tb/dut/oup_o
add wave -noupdate /ita_tb/dut/inp1_q
add wave -noupdate /ita_tb/dut/inp2_q
add wave -noupdate -expand -group {Masking Signals} -radix unsigned /ita_tb/dut/i_controller/count_d
add wave -noupdate -expand -group {Masking Signals} -radix unsigned /ita_tb/dut/i_controller/bias_count
add wave -noupdate -expand -group {Masking Signals} -radix unsigned /ita_tb/dut/i_controller/mask_count_q1
add wave -noupdate -expand -group {Masking Signals} -radix unsigned /ita_tb/dut/i_controller/mask_count_q2
add wave -noupdate -expand -group {Masking Signals} -radix unsigned /ita_tb/dut/i_controller/mask_count_q3
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/i_softmax_top/i_softmax/max_o
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/i_softmax_top/i_softmax/exp_sum_d
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/i_softmax_top/i_softmax/exp_sum_q
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/i_softmax_top/i_softmax/disable_row
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned /ita_tb/dut/i_controller/mask_tile_x_pos_d
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned /ita_tb/dut/i_controller/mask_tile_x_pos_q
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned /ita_tb/dut/i_controller/mask_tile_y_pos_d
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned /ita_tb/dut/i_controller/mask_tile_y_pos_q
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned /ita_tb/dut/i_controller/mask_tile_x_q3
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned /ita_tb/dut/i_controller/mask_tile_y_q3
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned /ita_tb/dut/i_controller/first_outer_dim
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/i_inp2_mux/clk_i
add wave -noupdate -expand -group {Masking Signals} -radix unsigned /ita_tb/dut/i_controller/count_q
add wave -noupdate -expand -group {Masking Signals} -radix binary /ita_tb/dut/i_controller/mask_d
add wave -noupdate -expand -group {Masking Signals} -radix binary /ita_tb/dut/mask
add wave -noupdate -expand -group {Masking Signals} -radix binary /ita_tb/dut/mask_q1
add wave -noupdate -expand -group {Masking Signals} -radix binary /ita_tb/dut/mask_q2
add wave -noupdate -expand -group {Masking Signals} -radix binary /ita_tb/dut/mask_q3
add wave -noupdate -expand -group {Masking Signals} -radix binary /ita_tb/dut/mask_q4
add wave -noupdate -expand -group {Masking Signals} -radix binary /ita_tb/dut/mask_q5
add wave -noupdate -expand -group {Masking Signals} -radix binary /ita_tb/dut/mask_q6
add wave -noupdate -expand -group {Masking Signals} -radix binary /ita_tb/dut/i_softmax_top/i_softmax/mask_i
add wave -noupdate -expand -group {Masking Signals} -radix decimal /ita_tb/dut/i_softmax_top/i_softmax/max_o
add wave -noupdate -expand -group {Masking Signals} -radix decimal /ita_tb/dut/i_softmax_top/i_softmax/max_i
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/i_requantizer/requant_oup_o
add wave -noupdate -expand -group {Masking Signals} -radix decimal /ita_tb/dut/i_softmax_top/i_softmax/requant_oup_q
add wave -noupdate -expand -group {Masking Signals} -radix decimal /ita_tb/dut/i_softmax_top/i_softmax/prev_max_o
add wave -noupdate -expand -group {Masking Signals} -radix decimal -childformat {{{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[15]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[14]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[13]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[12]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[11]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[10]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[9]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[8]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[7]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[6]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[5]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[4]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[3]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[2]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[1]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[0]} -radix decimal}} -subitemconfig {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[15]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[14]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[13]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[12]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[11]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[10]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[9]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[8]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[7]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[6]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[5]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[4]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[3]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[2]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[1]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[0]} {-height 16 -radix decimal}} /ita_tb/dut/i_softmax_top/i_softmax/shift_diff
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/i_softmax_top/i_softmax/disable_shift
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/i_softmax_top/i_softmax/calc_en_d
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/i_softmax_top/i_softmax/calc_en_q1
add wave -noupdate -expand -group {Masking Signals} -radix unsigned /ita_tb/dut/i_controller/mask_pos_q
add wave -noupdate -expand -group {Masking Signals} -radix unsigned /ita_tb/dut/i_controller/mask_col_offset_q
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/calc_en_q5
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/calc_en_q6
add wave -noupdate /ita_tb/dut/calc_en_q7
add wave -noupdate /ita_tb/dut/calc_en_q8
add wave -noupdate /ita_tb/dut/calc_en_q9
add wave -noupdate /ita_tb/dut/calc_en_q10
add wave -noupdate -group Requant /ita_tb/dut/i_controller/requant_add_i
add wave -noupdate -group Requant /ita_tb/dut/i_controller/requant_add_o
add wave -noupdate -group Bias /ita_tb/dut/inp_bias
add wave -noupdate -group Bias /ita_tb/dut/inp_bias_padded
add wave -noupdate -group Bias /ita_tb/dut/inp_bias_q1
add wave -noupdate -group Bias /ita_tb/dut/inp_bias_q2
add wave -noupdate /ita_tb/dut/calc_en_q4
add wave -noupdate -radix unsigned /ita_tb/dut/i_softmax_top/i_softmax/count_soft_q1
add wave -noupdate -radix unsigned /ita_tb/dut/i_softmax_top/i_softmax/count_soft_mask_q
add wave -noupdate /ita_tb/dut/i_softmax_top/i_softmax/calc_stream_soft_en_q
add wave -noupdate -radix unsigned /ita_tb/dut/i_softmax_top/i_softmax/count_soft_q2
add wave -noupdate -radix binary -childformat {{{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[63]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[62]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[61]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[60]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[59]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[58]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[57]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[56]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[55]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[54]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[53]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[52]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[51]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[50]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[49]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[48]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[47]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[46]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[45]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[44]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[43]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[42]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[41]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[40]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[39]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[38]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[37]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[36]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[35]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[34]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[33]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[32]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[31]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[30]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[29]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[28]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[27]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[26]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[25]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[24]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[23]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[22]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[21]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[20]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[19]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[18]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[17]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[16]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[15]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[14]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[13]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[12]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[11]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[10]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[9]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[8]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[7]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[6]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[5]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[4]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[3]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[2]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[1]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[0]} -radix binary}} -subitemconfig {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[63]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[62]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[61]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[60]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[59]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[58]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[57]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[56]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[55]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[54]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[53]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[52]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[51]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[50]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[49]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[48]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[47]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[46]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[45]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[44]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[43]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[42]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[41]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[40]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[39]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[38]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[37]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[36]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[35]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[34]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[33]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[32]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[31]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[30]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[29]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[28]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[27]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[26]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[25]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[24]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[23]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[22]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[21]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[20]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[19]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[18]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[17]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[16]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[15]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[14]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[13]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[12]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[11]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[10]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[9]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[8]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[7]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[6]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[5]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[4]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[3]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[2]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[1]} {-radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[0]} {-radix binary}} /ita_tb/dut/i_softmax_top/i_softmax/disable_col
add wave -noupdate /ita_tb/dut/i_inp2_mux/clk_i
add wave -noupdate /ita_tb/dut/i_controller/step_q
add wave -noupdate -expand -group {In Softmax} /ita_tb/dut/i_softmax_top/i_softmax/step_i
add wave -noupdate -expand -group {In Softmax} /ita_tb/dut/i_softmax_top/i_softmax/calc_en_i
add wave -noupdate -expand -group {In Softmax} /ita_tb/dut/i_softmax_top/i_softmax/calc_en_d
add wave -noupdate -expand -group {In Softmax} /ita_tb/dut/i_softmax_top/i_softmax/calc_en_q1
add wave -noupdate -expand -group {In Softmax} /ita_tb/dut/i_softmax_top/i_softmax/calc_en_q2
add wave -noupdate -expand -group {In Softmax} /ita_tb/dut/i_softmax_top/i_softmax/calc_en_q3
add wave -noupdate -expand -group {In Softmax} /ita_tb/dut/i_softmax_top/i_softmax/mask_i
add wave -noupdate -expand -group {In Softmax} /ita_tb/dut/i_softmax_top/i_softmax/max_i
add wave -noupdate -expand -group {In Softmax} /ita_tb/dut/i_softmax_top/i_softmax/max_o
add wave -noupdate -expand -group {In Softmax} /ita_tb/dut/i_softmax_top/i_softmax/count_d
add wave -noupdate -expand -group {In Softmax} /ita_tb/dut/i_softmax_top/i_softmax/count_q1
add wave -noupdate -expand -group {In Softmax} /ita_tb/dut/i_softmax_top/i_softmax/count_q2
add wave -noupdate -expand -group {In Softmax} /ita_tb/dut/i_softmax_top/i_softmax/count_q3
add wave -noupdate -expand -group {In Softmax} /ita_tb/dut/i_softmax_top/i_softmax/count_q4
add wave -noupdate /ita_tb/dut/calc_en
add wave -noupdate /ita_tb/dut/calc_en_q1
add wave -noupdate /ita_tb/dut/calc_en_q2
add wave -noupdate /ita_tb/dut/calc_en_q3
add wave -noupdate /ita_tb/dut/calc_en_q4
add wave -noupdate /ita_tb/dut/calc_en_q5
add wave -noupdate /ita_tb/dut/calc_en_q6
add wave -noupdate /ita_tb/dut/calc_en_q7
add wave -noupdate /ita_tb/dut/calc_en_q8
add wave -noupdate /ita_tb/dut/calc_en_q9
add wave -noupdate /ita_tb/dut/calc_en_q10
add wave -noupdate /ita_tb/dut/i_softmax_top/i_softmax/calc_stream_soft_en_i
add wave -noupdate -radix hexadecimal /ita_tb/dut/i_softmax_top/i_softmax/calc_stream_soft_en_q
add wave -noupdate /ita_tb/dut/i_requantizer/clk_i
add wave -noupdate -radix binary /ita_tb/dut/i_softmax_top/i_softmax/disable_col
add wave -noupdate /ita_tb/dut/i_inp1_mux/inp_i
add wave -noupdate /ita_tb/dut/inp
add wave -noupdate -radix unsigned /ita_tb/dut/i_softmax_top/i_softmax/inp_stream_soft_o
add wave -noupdate -radix decimal /ita_tb/dut/inp1
add wave -noupdate -radix decimal /ita_tb/dut/inp1_q
add wave -noupdate -radix decimal /ita_tb/dut/i_accumulator/oup_i
add wave -noupdate /ita_tb/dut/i_accumulator/result_d
add wave -noupdate /ita_tb/dut/i_accumulator/result_o
add wave -noupdate /ita_tb/dut/i_activation/data_i
add wave -noupdate /ita_tb/dut/i_activation/data_q1
add wave -noupdate /ita_tb/dut/i_activation/data_q2
add wave -noupdate /ita_tb/dut/i_activation/data_q3
add wave -noupdate /ita_tb/dut/i_activation/data_q4
add wave -noupdate /ita_tb/dut/i_activation/data_o
add wave -noupdate /ita_tb/dut/i_fifo/data_i
add wave -noupdate /ita_tb/dut/i_fifo/data_o
add wave -noupdate /ita_tb/dut/oup_o
add wave -noupdate -group Requantizer /ita_tb/dut/i_requantizer/*
add wave -expand -group Controller /ita_tb/dut/i_controller/*
add wave -group {Softmax Controller} ita_tb/dut/i_softmax_top/i_softmax/*
add wave -group {Accumulator} ita_tb/dut/i_accumulator/*