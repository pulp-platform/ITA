onerror {resume}
quietly WaveActivateNextPane {} 0
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
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/rst_ni
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/mode_i
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/eps_mult_i
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/right_shift_i
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/calc_en_i
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/calc_en_q_i
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/result_i
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/add_i
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/mult_signed
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/product
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/shifted_added
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/shifted_d
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/shifted_q
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/add_q1
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/add_q2
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/add_q3
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/add_q4
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/requant_oup_d
add wave -noupdate -expand -group Requantizer /ita_tb/dut/i_requantizer/requant_oup_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/clk_i
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/rst_ni
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/ctrl_i
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/inp_valid_i
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/inp_ready_o
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/weight_valid_i
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/weight_ready_o
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/bias_valid_i
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/bias_ready_o
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/oup_valid_i
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/oup_ready_i
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/pop_softmax_fifo_i
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/step_o
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/soft_addr_div_i
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/softmax_done_i
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/calc_en_o
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/first_inner_tile_o
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/last_inner_tile_o
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/tile_x_o
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/tile_y_o
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/inner_tile_o
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/requant_add_i
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/requant_add_o
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/inp_bias_i
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/inp_bias_pad_o
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/mask_o
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/busy_o
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/calc_en_q1_i
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/step_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/step_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/count_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/count_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/bias_count
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/mask_pos_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/mask_pos_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/mask_col_offset_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/mask_col_offset_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/mask_count_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/mask_count_q1
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/mask_count_q2
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/mask_count_q3
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/tile_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/tile_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/inner_tile_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/inner_tile_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/mask_tile_x_pos_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/mask_tile_x_pos_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/mask_tile_y_pos_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/mask_tile_y_pos_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/tile_x_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/tile_x_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/bias_tile_x_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/bias_tile_x_q1
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/bias_tile_x_q2
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/mask_tile_x_q3
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/tile_y_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/tile_y_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/bias_tile_y_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/bias_tile_y_q1
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/bias_tile_y_q2
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/mask_tile_y_q3
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/softmax_tile_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/softmax_tile_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/ongoing_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/ongoing_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/ongoing_soft_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/ongoing_soft_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/inp_bias
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/inp_bias_padded
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/last_time
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/mask_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/mask_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/inner_tile_dim
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/first_outer_dim
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/second_outer_dim
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/first_outer_dim_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/first_outer_dim_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/second_outer_dim_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/second_outer_dim_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/softmax_fifo
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/softmax_div
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/softmax_div_done_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/softmax_div_done_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/busy_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/busy_q
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/requant_add_d
add wave -noupdate -expand -group Controller /ita_tb/dut/i_controller/requant_add_q
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/clk_i
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/rst_ni
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/ctrl_i
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/step_i
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/calc_en_i
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/requant_oup_i
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/calc_stream_soft_en_i
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/soft_addr_div_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/softmax_done_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/pop_softmax_fifo_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/inp_i
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/inp_stream_soft_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/div_inp_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/div_valid_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/div_ready_i
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/div_valid_i
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/div_ready_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/div_oup_i
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/read_acc_en_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/read_acc_addr_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/read_acc_data_i
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/write_acc_en_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/write_acc_addr_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/write_acc_data_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/prev_max_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/max_i
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/max_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/read_max_en_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/read_max_addr_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/read_max_data_i
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/write_max_en_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/write_max_addr_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/write_max_data_o
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/tile_x_i
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/tile_y_i
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/inner_tile_i
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/mask_i
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/tile_d
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/tile_q1
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/tile_q2
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/tile_q3
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/tile_q4
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/count_d
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/count_q1
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/count_q2
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/count_q3
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/count_q4
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/inner_tile_q
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/tile_y_q
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/exp_sum_d
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/exp_sum_q
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/count_soft_d
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/count_soft_q1
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/count_soft_q2
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/count_soft_mask_q
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/count_div_d
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/count_div_q
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/addr_div_d
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/addr_div_q
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/div_read_d
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/div_read_q
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/div_write_d
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/div_write_q
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/max_d
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/max_q
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/shift_d
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/shift_q
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/shift_diff
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/shift_sum_d
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/shift_sum_q
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/max_diff
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/shift_inp
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/shift_inp_diff
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/calc_en_d
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/calc_en_q1
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/calc_en_q2
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/calc_en_q3
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/fifo_full
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/fifo_empty
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/push_to_fifo
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/pop_from_fifo
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/data_to_fifo
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/data_from_fifo
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/fifo_usage
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/disable_shift
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/disable_row
add wave -noupdate -expand -group {Softmax Controller} /ita_tb/dut/i_softmax_top/i_softmax/disable_col
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/clk_i
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/rst_ni
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/calc_en_i
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/calc_en_q_i
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/first_tile_i
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/first_tile_q_i
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/last_tile_i
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/last_tile_q_i
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/oup_i
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/inp_bias_i
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/result_o
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/read_en
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/read_addr
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/read_data
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/read_data_unused
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/write_en
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/write_addr
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/write_data
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/read_addr_d
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/read_addr_q
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/write_addr_d
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/write_addr_q
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/result_d
add wave -noupdate -group Accumulator /ita_tb/dut/i_accumulator/result_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3869000 ps} 1} {{Cursor 2} {5124600 ps} 1} {{Cursor 3} {5390600 ps} 1} {{Cursor 4} {5680600 ps} 1} {{Cursor 5} {5920600 ps} 1} {inp1_q {5901000 ps} 1} {{Cursor 7} {5899000 ps} 1} {{Cursor 8} {5897400 ps} 1} {{Cursor 9} {0 ps} 0} {Trace {5106220 ps} 0}
quietly wave cursor active 10
configure wave -namecolwidth 170
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {5088920 ps} {5143811 ps}
