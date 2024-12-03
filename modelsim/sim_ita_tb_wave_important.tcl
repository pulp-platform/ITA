onerror {resume}
quietly set dataset_list [list vsim sim]
if {[catch {datasetcheck $dataset_list}]} {abort}
quietly WaveActivateNextPane {} 0
add wave -noupdate sim:/ita_tb/dut/i_inp1_mux/clk_i
add wave -noupdate sim:/ita_tb/dut/i_inp1_mux/rst_ni
add wave -noupdate sim:/ita_tb/dut/i_inp1_mux/inp_i
add wave -noupdate sim:/ita_tb/dut/i_inp1_mux/inp1_o
add wave -noupdate sim:/ita_tb/dut/i_inp2_mux/clk_i
add wave -noupdate sim:/ita_tb/dut/i_inp2_mux/rst_ni
add wave -noupdate sim:/ita_tb/dut/i_inp2_mux/weight_i
add wave -noupdate sim:/ita_tb/dut/i_inp2_mux/inp2_o
add wave -noupdate sim:/ita_tb/dut/i_controller/ctrl_i
add wave -noupdate sim:/ita_tb/dut/oup_o
add wave -noupdate sim:/ita_tb/dut/inp1_q
add wave -noupdate sim:/ita_tb/dut/inp2_q
add wave -noupdate -expand -group {Masking Signals} -radix unsigned sim:/ita_tb/dut/i_controller/count_d
add wave -noupdate -expand -group {Masking Signals} -radix unsigned sim:/ita_tb/dut/i_controller/bias_count
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_softmax_top/i_softmax/max_o
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_softmax_top/i_softmax/disable_row
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned sim:/ita_tb/dut/i_controller/mask_tile_x_pos_d
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned sim:/ita_tb/dut/i_controller/mask_tile_x_pos_q
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned sim:/ita_tb/dut/i_controller/mask_tile_y_pos_d
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned sim:/ita_tb/dut/i_controller/mask_tile_y_pos_q
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned sim:/ita_tb/dut/i_controller/first_outer_dim
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/last_inner_tile_q6
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_controller/calc_en_o
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/calc_en_q1
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/calc_en_q2
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/calc_en_q3
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/calc_en_q4
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/calc_en_q5
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/calc_en_q6
add wave -noupdate -expand -group {Masking Signals} -expand -group {In Softmax Module} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_en_d
add wave -noupdate -expand -group {Masking Signals} -radix decimal sim:/ita_tb/dut/i_softmax_top/i_softmax/max_o
add wave -noupdate -expand -group {Masking Signals} -radix decimal sim:/ita_tb/dut/i_softmax_top/i_softmax/max_i
add wave -noupdate -expand -group {Masking Signals} -radix decimal vsim:/ita_tb/dut/i_softmax_top/i_softmax/max_i
add wave -noupdate -expand -group {Masking Signals} -radix decimal sim:/ita_tb/dut/i_requantizer/requant_oup_o
add wave -noupdate -expand -group {Masking Signals} -radix decimal sim:/ita_tb/dut/i_softmax_top/i_softmax/requant_oup_q
add wave -noupdate -expand -group {Masking Signals} -radix decimal sim:/ita_tb/dut/i_softmax_top/i_softmax/prev_max_o
add wave -noupdate -expand -group {Masking Signals} -radix decimal -childformat {{{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[15]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[14]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[13]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[12]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[11]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[10]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[9]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[8]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[7]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[6]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[5]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[4]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[3]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[2]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[1]} -radix decimal} {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[0]} -radix decimal}} -subitemconfig {{/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[15]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[14]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[13]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[12]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[11]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[10]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[9]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[8]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[7]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[6]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[5]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[4]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[3]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[2]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[1]} {-height 16 -radix decimal} {/ita_tb/dut/i_softmax_top/i_softmax/shift_diff[0]} {-height 16 -radix decimal}} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_diff
add wave -noupdate -expand -group {Masking Signals} -radix decimal vsim:/ita_tb/dut/i_softmax_top/i_softmax/shift_diff
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_softmax_top/i_softmax/disable_shift
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_controller/step_q
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_stream_soft_en_q
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_inp2_mux/clk_i
add wave -noupdate -expand -group {Masking Signals} -radix unsigned sim:/ita_tb/dut/i_controller/count_q
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_en_q1
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_en_q2
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_en_q3
add wave -noupdate -expand -group {Masking Signals} -radix binary sim:/ita_tb/dut/i_controller/mask_d
add wave -noupdate -expand -group {Masking Signals} -radix binary sim:/ita_tb/dut/mask
add wave -noupdate -expand -group {Masking Signals} -radix binary sim:/ita_tb/dut/mask_q1
add wave -noupdate -expand -group {Masking Signals} -radix binary sim:/ita_tb/dut/mask_q2
add wave -noupdate -expand -group {Masking Signals} -radix binary sim:/ita_tb/dut/mask_q3
add wave -noupdate -expand -group {Masking Signals} -radix binary sim:/ita_tb/dut/mask_q4
add wave -noupdate -expand -group {Masking Signals} -radix binary sim:/ita_tb/dut/mask_q5
add wave -noupdate -expand -group {Masking Signals} -radix binary sim:/ita_tb/dut/mask_q6
add wave -noupdate -expand -group {Masking Signals} -radix binary sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_i
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_softmax_top/i_softmax/max_i
add wave -noupdate -expand -group {Masking Signals} vsim:/ita_tb/dut/i_softmax_top/i_softmax/max_i
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_d
add wave -noupdate -expand -group {Masking Signals} vsim:/ita_tb/dut/i_softmax_top/i_softmax/shift_d
add wave -noupdate -expand -group {Masking Signals} -radix unsigned sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_q
add wave -noupdate -expand -group {Masking Signals} vsim:/ita_tb/dut/i_softmax_top/i_softmax/shift_q
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_sum_d
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_sum_q
add wave -noupdate -expand -group {Masking Signals} vsim:/ita_tb/dut/i_softmax_top/i_softmax/shift_sum_d
add wave -noupdate -expand -group {Masking Signals} vsim:/ita_tb/dut/i_softmax_top/i_softmax/shift_sum_q
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_softmax_top/i_softmax/read_max_en_o
add wave -noupdate -expand -group {Masking Signals} -radix unsigned sim:/ita_tb/dut/i_softmax_top/i_softmax/read_max_addr_o
add wave -noupdate -expand -group {Masking Signals} -radix decimal sim:/ita_tb/dut/i_softmax_top/i_softmax/read_max_data_i
add wave -noupdate -expand -group {Masking Signals} vsim:/ita_tb/dut/i_softmax_top/i_softmax/read_max_en_o
add wave -noupdate -expand -group {Masking Signals} -radix unsigned vsim:/ita_tb/dut/i_softmax_top/i_softmax/read_max_addr_o
add wave -noupdate -expand -group {Masking Signals} -radix decimal vsim:/ita_tb/dut/i_softmax_top/i_softmax/read_max_data_i
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_softmax_top/i_softmax/read_acc_data_i
add wave -noupdate -expand -group {Masking Signals} vsim:/ita_tb/dut/i_softmax_top/i_softmax/read_acc_data_i
add wave -noupdate -expand -group {Masking Signals} -expand sim:/ita_tb/dut/i_softmax_top/i_softmax/read_acc_en_o
add wave -noupdate -expand -group {Masking Signals} -expand vsim:/ita_tb/dut/i_softmax_top/i_softmax/read_acc_en_o
add wave -noupdate -expand -group {Masking Signals} -radix unsigned sim:/ita_tb/dut/i_softmax_top/i_softmax/read_acc_addr_o
add wave -noupdate -expand -group {Masking Signals} -radix unsigned vsim:/ita_tb/dut/i_softmax_top/i_softmax/read_acc_addr_o
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_softmax_top/i_softmax/write_acc_en_o
add wave -noupdate -expand -group {Masking Signals} vsim:/ita_tb/dut/i_softmax_top/i_softmax/write_acc_en_o
add wave -noupdate -expand -group {Masking Signals} -radix unsigned sim:/ita_tb/dut/i_softmax_top/i_softmax/write_acc_addr_o
add wave -noupdate -expand -group {Masking Signals} -radix unsigned vsim:/ita_tb/dut/i_softmax_top/i_softmax/write_acc_addr_o
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_softmax_top/i_softmax/write_acc_data_o
add wave -noupdate -expand -group {Masking Signals} vsim:/ita_tb/dut/i_softmax_top/i_softmax/write_acc_data_o
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_softmax_top/i_softmax/exp_sum_d
add wave -noupdate -expand -group {Masking Signals} vsim:/ita_tb/dut/i_softmax_top/i_softmax/exp_sum_d
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_softmax_top/i_softmax/exp_sum_q
add wave -noupdate -expand -group {Masking Signals} vsim:/ita_tb/dut/i_softmax_top/i_softmax/exp_sum_q
add wave -noupdate -expand -group {Masking Signals} sim:/ita_tb/dut/i_softmax_top/i_softmax/step_i
add wave -noupdate -expand -group {Masking Signals} vsim:/ita_tb/dut/i_softmax_top/i_softmax/step_i
add wave -noupdate -expand -group {Masking Signals} -radix unsigned sim:/ita_tb/dut/i_softmax_top/i_softmax/count_d
add wave -noupdate -expand -group {Masking Signals} -radix unsigned vsim:/ita_tb/dut/i_softmax_top/i_softmax/count_d
add wave -noupdate -expand -group {Masking Signals} -radix unsigned sim:/ita_tb/dut/i_softmax_top/i_softmax/count_q1
add wave -noupdate -expand -group {Masking Signals} -radix unsigned vsim:/ita_tb/dut/i_softmax_top/i_softmax/count_q1
add wave -noupdate -expand -group {Masking Signals} -radix unsigned sim:/ita_tb/dut/i_softmax_top/i_softmax/count_q2
add wave -noupdate -expand -group {Masking Signals} -radix unsigned vsim:/ita_tb/dut/i_softmax_top/i_softmax/count_q2
add wave -noupdate -expand -group {Masking Signals} -radix unsigned sim:/ita_tb/dut/i_softmax_top/i_softmax/count_q3
add wave -noupdate -expand -group {Masking Signals} -radix unsigned vsim:/ita_tb/dut/i_softmax_top/i_softmax/count_q3
add wave -noupdate -expand -group {Masking Signals} -radix unsigned sim:/ita_tb/dut/i_softmax_top/i_softmax/count_q4
add wave -noupdate -expand -group {Masking Signals} -radix unsigned vsim:/ita_tb/dut/i_softmax_top/i_softmax/count_q4
add wave -noupdate -expand -group {Masking Signals} -radix unsigned sim:/ita_tb/dut/i_controller/mask_pos_d
add wave -noupdate -expand -group {Masking Signals} -radix unsigned sim:/ita_tb/dut/i_controller/mask_pos_q
add wave -noupdate -expand -group {Masking Signals} -radix unsigned sim:/ita_tb/dut/i_controller/mask_col_offset_q
add wave -noupdate -radix unsigned sim:/ita_tb/dut/i_controller/mask_tile_x_pos_d
add wave -noupdate -radix unsigned sim:/ita_tb/dut/i_controller/mask_tile_x_pos_q
add wave -noupdate -radix unsigned sim:/ita_tb/dut/i_controller/mask_tile_y_pos_d
add wave -noupdate -radix unsigned sim:/ita_tb/dut/i_controller/mask_tile_y_pos_q
add wave -noupdate -radix unsigned sim:/ita_tb/dut/i_controller/tile_x_d
add wave -noupdate -radix unsigned sim:/ita_tb/dut/i_controller/tile_x_q
add wave -noupdate -radix unsigned sim:/ita_tb/dut/i_controller/tile_y_d
add wave -noupdate -radix unsigned sim:/ita_tb/dut/i_controller/tile_y_q
add wave -noupdate sim:/ita_tb/dut/calc_en_q5
add wave -noupdate sim:/ita_tb/dut/calc_en_q6
add wave -noupdate sim:/ita_tb/dut/calc_en_q7
add wave -noupdate sim:/ita_tb/dut/calc_en_q8
add wave -noupdate sim:/ita_tb/dut/calc_en_q9
add wave -noupdate sim:/ita_tb/dut/calc_en_q10
add wave -noupdate -group Requant sim:/ita_tb/dut/i_controller/requant_add_i
add wave -noupdate -group Requant sim:/ita_tb/dut/i_controller/requant_add_o
add wave -noupdate -group Bias sim:/ita_tb/dut/inp_bias
add wave -noupdate -group Bias sim:/ita_tb/dut/inp_bias_padded
add wave -noupdate -group Bias sim:/ita_tb/dut/inp_bias_q1
add wave -noupdate -group Bias sim:/ita_tb/dut/inp_bias_q2
add wave -noupdate sim:/ita_tb/dut/calc_en_q4
add wave -noupdate -radix unsigned sim:/ita_tb/dut/i_softmax_top/i_softmax/count_soft_q1
add wave -noupdate sim:/ita_tb/dut/i_softmax_top/i_softmax/inner_tile_i
add wave -noupdate sim:/ita_tb/dut/i_softmax_top/i_softmax/inner_tile_q
add wave -noupdate -radix unsigned sim:/ita_tb/dut/i_softmax_top/i_softmax/count_soft_q2
add wave -noupdate -radix binary -childformat {{{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[63]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[62]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[61]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[60]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[59]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[58]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[57]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[56]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[55]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[54]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[53]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[52]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[51]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[50]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[49]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[48]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[47]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[46]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[45]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[44]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[43]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[42]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[41]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[40]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[39]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[38]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[37]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[36]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[35]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[34]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[33]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[32]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[31]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[30]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[29]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[28]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[27]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[26]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[25]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[24]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[23]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[22]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[21]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[20]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[19]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[18]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[17]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[16]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[15]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[14]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[13]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[12]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[11]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[10]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[9]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[8]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[7]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[6]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[5]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[4]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[3]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[2]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[1]} -radix binary} {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[0]} -radix binary}} -subitemconfig {{/ita_tb/dut/i_softmax_top/i_softmax/disable_col[63]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[62]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[61]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[60]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[59]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[58]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[57]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[56]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[55]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[54]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[53]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[52]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[51]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[50]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[49]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[48]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[47]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[46]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[45]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[44]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[43]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[42]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[41]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[40]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[39]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[38]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[37]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[36]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[35]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[34]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[33]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[32]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[31]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[30]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[29]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[28]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[27]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[26]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[25]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[24]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[23]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[22]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[21]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[20]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[19]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[18]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[17]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[16]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[15]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[14]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[13]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[12]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[11]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[10]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[9]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[8]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[7]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[6]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[5]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[4]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[3]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[2]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[1]} {-height 16 -radix binary} {/ita_tb/dut/i_softmax_top/i_softmax/disable_col[0]} {-height 16 -radix binary}} sim:/ita_tb/dut/i_softmax_top/i_softmax/disable_col
add wave -noupdate sim:/ita_tb/dut/i_inp2_mux/clk_i
add wave -noupdate -expand -group {In Softmax} sim:/ita_tb/dut/i_softmax_top/i_softmax/step_i
add wave -noupdate -expand -group {In Softmax} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_en_i
add wave -noupdate -expand -group {In Softmax} sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_i
add wave -noupdate -expand -group {In Softmax} sim:/ita_tb/dut/i_softmax_top/i_softmax/max_i
add wave -noupdate -expand -group {In Softmax} sim:/ita_tb/dut/i_softmax_top/i_softmax/max_o
add wave -noupdate sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_stream_soft_en_i
add wave -noupdate -radix hexadecimal sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_stream_soft_en_q
add wave -noupdate sim:/ita_tb/dut/i_requantizer/clk_i
add wave -noupdate -radix unsigned sim:/ita_tb/dut/i_softmax_top/i_softmax/count_soft_q1
add wave -noupdate -radix unsigned sim:/ita_tb/dut/i_softmax_top/i_softmax/count_soft_mask_q
add wave -noupdate sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_tile_x_d
add wave -noupdate sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_tile_x_q
add wave -noupdate sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_tile_y_d
add wave -noupdate sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_tile_y_q
add wave -noupdate sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_tile_d
add wave -noupdate sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_tile_q
add wave -noupdate -radix binary sim:/ita_tb/dut/i_softmax_top/i_softmax/disable_col
add wave -noupdate sim:/ita_tb/dut/i_activation/data_q3
add wave -noupdate -radix decimal sim:/ita_tb/dut/inp_i
add wave -noupdate -expand -group {All in one Phase} -radix decimal -childformat {{{/ita_tb/dut/inp[63]} -radix decimal} {{/ita_tb/dut/inp[62]} -radix decimal} {{/ita_tb/dut/inp[61]} -radix decimal} {{/ita_tb/dut/inp[60]} -radix decimal} {{/ita_tb/dut/inp[59]} -radix decimal} {{/ita_tb/dut/inp[58]} -radix decimal} {{/ita_tb/dut/inp[57]} -radix decimal} {{/ita_tb/dut/inp[56]} -radix decimal} {{/ita_tb/dut/inp[55]} -radix decimal} {{/ita_tb/dut/inp[54]} -radix decimal} {{/ita_tb/dut/inp[53]} -radix decimal} {{/ita_tb/dut/inp[52]} -radix decimal} {{/ita_tb/dut/inp[51]} -radix decimal} {{/ita_tb/dut/inp[50]} -radix decimal} {{/ita_tb/dut/inp[49]} -radix decimal} {{/ita_tb/dut/inp[48]} -radix decimal} {{/ita_tb/dut/inp[47]} -radix decimal} {{/ita_tb/dut/inp[46]} -radix decimal} {{/ita_tb/dut/inp[45]} -radix decimal} {{/ita_tb/dut/inp[44]} -radix decimal} {{/ita_tb/dut/inp[43]} -radix decimal} {{/ita_tb/dut/inp[42]} -radix decimal} {{/ita_tb/dut/inp[41]} -radix decimal} {{/ita_tb/dut/inp[40]} -radix decimal} {{/ita_tb/dut/inp[39]} -radix decimal} {{/ita_tb/dut/inp[38]} -radix decimal} {{/ita_tb/dut/inp[37]} -radix decimal} {{/ita_tb/dut/inp[36]} -radix decimal} {{/ita_tb/dut/inp[35]} -radix decimal} {{/ita_tb/dut/inp[34]} -radix decimal} {{/ita_tb/dut/inp[33]} -radix decimal} {{/ita_tb/dut/inp[32]} -radix decimal} {{/ita_tb/dut/inp[31]} -radix decimal} {{/ita_tb/dut/inp[30]} -radix decimal} {{/ita_tb/dut/inp[29]} -radix decimal} {{/ita_tb/dut/inp[28]} -radix decimal} {{/ita_tb/dut/inp[27]} -radix decimal} {{/ita_tb/dut/inp[26]} -radix decimal} {{/ita_tb/dut/inp[25]} -radix decimal} {{/ita_tb/dut/inp[24]} -radix decimal} {{/ita_tb/dut/inp[23]} -radix decimal} {{/ita_tb/dut/inp[22]} -radix decimal} {{/ita_tb/dut/inp[21]} -radix decimal} {{/ita_tb/dut/inp[20]} -radix decimal} {{/ita_tb/dut/inp[19]} -radix decimal} {{/ita_tb/dut/inp[18]} -radix decimal} {{/ita_tb/dut/inp[17]} -radix decimal} {{/ita_tb/dut/inp[16]} -radix decimal} {{/ita_tb/dut/inp[15]} -radix decimal} {{/ita_tb/dut/inp[14]} -radix decimal} {{/ita_tb/dut/inp[13]} -radix decimal} {{/ita_tb/dut/inp[12]} -radix decimal} {{/ita_tb/dut/inp[11]} -radix decimal} {{/ita_tb/dut/inp[10]} -radix decimal} {{/ita_tb/dut/inp[9]} -radix decimal} {{/ita_tb/dut/inp[8]} -radix decimal} {{/ita_tb/dut/inp[7]} -radix decimal} {{/ita_tb/dut/inp[6]} -radix decimal} {{/ita_tb/dut/inp[5]} -radix decimal} {{/ita_tb/dut/inp[4]} -radix decimal} {{/ita_tb/dut/inp[3]} -radix decimal} {{/ita_tb/dut/inp[2]} -radix decimal} {{/ita_tb/dut/inp[1]} -radix decimal} {{/ita_tb/dut/inp[0]} -radix decimal}} -subitemconfig {{/ita_tb/dut/inp[63]} {-height 16 -radix decimal} {/ita_tb/dut/inp[62]} {-height 16 -radix decimal} {/ita_tb/dut/inp[61]} {-height 16 -radix decimal} {/ita_tb/dut/inp[60]} {-height 16 -radix decimal} {/ita_tb/dut/inp[59]} {-height 16 -radix decimal} {/ita_tb/dut/inp[58]} {-height 16 -radix decimal} {/ita_tb/dut/inp[57]} {-height 16 -radix decimal} {/ita_tb/dut/inp[56]} {-height 16 -radix decimal} {/ita_tb/dut/inp[55]} {-height 16 -radix decimal} {/ita_tb/dut/inp[54]} {-height 16 -radix decimal} {/ita_tb/dut/inp[53]} {-height 16 -radix decimal} {/ita_tb/dut/inp[52]} {-height 16 -radix decimal} {/ita_tb/dut/inp[51]} {-height 16 -radix decimal} {/ita_tb/dut/inp[50]} {-height 16 -radix decimal} {/ita_tb/dut/inp[49]} {-height 16 -radix decimal} {/ita_tb/dut/inp[48]} {-height 16 -radix decimal} {/ita_tb/dut/inp[47]} {-height 16 -radix decimal} {/ita_tb/dut/inp[46]} {-height 16 -radix decimal} {/ita_tb/dut/inp[45]} {-height 16 -radix decimal} {/ita_tb/dut/inp[44]} {-height 16 -radix decimal} {/ita_tb/dut/inp[43]} {-height 16 -radix decimal} {/ita_tb/dut/inp[42]} {-height 16 -radix decimal} {/ita_tb/dut/inp[41]} {-height 16 -radix decimal} {/ita_tb/dut/inp[40]} {-height 16 -radix decimal} {/ita_tb/dut/inp[39]} {-height 16 -radix decimal} {/ita_tb/dut/inp[38]} {-height 16 -radix decimal} {/ita_tb/dut/inp[37]} {-height 16 -radix decimal} {/ita_tb/dut/inp[36]} {-height 16 -radix decimal} {/ita_tb/dut/inp[35]} {-height 16 -radix decimal} {/ita_tb/dut/inp[34]} {-height 16 -radix decimal} {/ita_tb/dut/inp[33]} {-height 16 -radix decimal} {/ita_tb/dut/inp[32]} {-height 16 -radix decimal} {/ita_tb/dut/inp[31]} {-height 16 -radix decimal} {/ita_tb/dut/inp[30]} {-height 16 -radix decimal} {/ita_tb/dut/inp[29]} {-height 16 -radix decimal} {/ita_tb/dut/inp[28]} {-height 16 -radix decimal} {/ita_tb/dut/inp[27]} {-height 16 -radix decimal} {/ita_tb/dut/inp[26]} {-height 16 -radix decimal} {/ita_tb/dut/inp[25]} {-height 16 -radix decimal} {/ita_tb/dut/inp[24]} {-height 16 -radix decimal} {/ita_tb/dut/inp[23]} {-height 16 -radix decimal} {/ita_tb/dut/inp[22]} {-height 16 -radix decimal} {/ita_tb/dut/inp[21]} {-height 16 -radix decimal} {/ita_tb/dut/inp[20]} {-height 16 -radix decimal} {/ita_tb/dut/inp[19]} {-height 16 -radix decimal} {/ita_tb/dut/inp[18]} {-height 16 -radix decimal} {/ita_tb/dut/inp[17]} {-height 16 -radix decimal} {/ita_tb/dut/inp[16]} {-height 16 -radix decimal} {/ita_tb/dut/inp[15]} {-height 16 -radix decimal} {/ita_tb/dut/inp[14]} {-height 16 -radix decimal} {/ita_tb/dut/inp[13]} {-height 16 -radix decimal} {/ita_tb/dut/inp[12]} {-height 16 -radix decimal} {/ita_tb/dut/inp[11]} {-height 16 -radix decimal} {/ita_tb/dut/inp[10]} {-height 16 -radix decimal} {/ita_tb/dut/inp[9]} {-height 16 -radix decimal} {/ita_tb/dut/inp[8]} {-height 16 -radix decimal} {/ita_tb/dut/inp[7]} {-height 16 -radix decimal} {/ita_tb/dut/inp[6]} {-height 16 -radix decimal} {/ita_tb/dut/inp[5]} {-height 16 -radix decimal} {/ita_tb/dut/inp[4]} {-height 16 -radix decimal} {/ita_tb/dut/inp[3]} {-height 16 -radix decimal} {/ita_tb/dut/inp[2]} {-height 16 -radix decimal} {/ita_tb/dut/inp[1]} {-height 16 -radix decimal} {/ita_tb/dut/inp[0]} {-height 16 -radix decimal}} sim:/ita_tb/dut/inp
add wave -noupdate -expand -group {All in one Phase} -radix unsigned sim:/ita_tb/dut/i_softmax_top/i_softmax/inp_stream_soft_o
add wave -noupdate -expand -group {All in one Phase} -radix decimal sim:/ita_tb/dut/inp1
add wave -noupdate -radix unsigned sim:/ita_tb/dut/inp1_q
add wave -noupdate -radix decimal sim:/ita_tb/dut/i_accumulator/oup_i
add wave -noupdate -radix decimal -childformat {{{/ita_tb/dut/i_accumulator/result_d[15]} -radix decimal} {{/ita_tb/dut/i_accumulator/result_d[14]} -radix decimal} {{/ita_tb/dut/i_accumulator/result_d[13]} -radix decimal} {{/ita_tb/dut/i_accumulator/result_d[12]} -radix decimal} {{/ita_tb/dut/i_accumulator/result_d[11]} -radix decimal} {{/ita_tb/dut/i_accumulator/result_d[10]} -radix decimal} {{/ita_tb/dut/i_accumulator/result_d[9]} -radix decimal} {{/ita_tb/dut/i_accumulator/result_d[8]} -radix decimal} {{/ita_tb/dut/i_accumulator/result_d[7]} -radix decimal} {{/ita_tb/dut/i_accumulator/result_d[6]} -radix decimal} {{/ita_tb/dut/i_accumulator/result_d[5]} -radix decimal} {{/ita_tb/dut/i_accumulator/result_d[4]} -radix decimal} {{/ita_tb/dut/i_accumulator/result_d[3]} -radix decimal} {{/ita_tb/dut/i_accumulator/result_d[2]} -radix decimal} {{/ita_tb/dut/i_accumulator/result_d[1]} -radix decimal} {{/ita_tb/dut/i_accumulator/result_d[0]} -radix decimal}} -subitemconfig {{/ita_tb/dut/i_accumulator/result_d[15]} {-height 16 -radix decimal} {/ita_tb/dut/i_accumulator/result_d[14]} {-height 16 -radix decimal} {/ita_tb/dut/i_accumulator/result_d[13]} {-height 16 -radix decimal} {/ita_tb/dut/i_accumulator/result_d[12]} {-height 16 -radix decimal} {/ita_tb/dut/i_accumulator/result_d[11]} {-height 16 -radix decimal} {/ita_tb/dut/i_accumulator/result_d[10]} {-height 16 -radix decimal} {/ita_tb/dut/i_accumulator/result_d[9]} {-height 16 -radix decimal} {/ita_tb/dut/i_accumulator/result_d[8]} {-height 16 -radix decimal} {/ita_tb/dut/i_accumulator/result_d[7]} {-height 16 -radix decimal} {/ita_tb/dut/i_accumulator/result_d[6]} {-height 16 -radix decimal} {/ita_tb/dut/i_accumulator/result_d[5]} {-height 16 -radix decimal} {/ita_tb/dut/i_accumulator/result_d[4]} {-height 16 -radix decimal} {/ita_tb/dut/i_accumulator/result_d[3]} {-height 16 -radix decimal} {/ita_tb/dut/i_accumulator/result_d[2]} {-height 16 -radix decimal} {/ita_tb/dut/i_accumulator/result_d[1]} {-height 16 -radix decimal} {/ita_tb/dut/i_accumulator/result_d[0]} {-height 16 -radix decimal}} sim:/ita_tb/dut/i_accumulator/result_d
add wave -noupdate -radix decimal sim:/ita_tb/dut/i_accumulator/result_o
add wave -noupdate -radix hexadecimal -childformat {{{/ita_tb/dut/i_activation/data_i[15]} -radix decimal} {{/ita_tb/dut/i_activation/data_i[14]} -radix decimal} {{/ita_tb/dut/i_activation/data_i[13]} -radix decimal} {{/ita_tb/dut/i_activation/data_i[12]} -radix decimal} {{/ita_tb/dut/i_activation/data_i[11]} -radix decimal} {{/ita_tb/dut/i_activation/data_i[10]} -radix decimal} {{/ita_tb/dut/i_activation/data_i[9]} -radix decimal} {{/ita_tb/dut/i_activation/data_i[8]} -radix decimal} {{/ita_tb/dut/i_activation/data_i[7]} -radix decimal} {{/ita_tb/dut/i_activation/data_i[6]} -radix decimal} {{/ita_tb/dut/i_activation/data_i[5]} -radix decimal} {{/ita_tb/dut/i_activation/data_i[4]} -radix decimal} {{/ita_tb/dut/i_activation/data_i[3]} -radix decimal} {{/ita_tb/dut/i_activation/data_i[2]} -radix decimal} {{/ita_tb/dut/i_activation/data_i[1]} -radix decimal} {{/ita_tb/dut/i_activation/data_i[0]} -radix decimal}} -subitemconfig {{/ita_tb/dut/i_activation/data_i[15]} {-height 16 -radix decimal} {/ita_tb/dut/i_activation/data_i[14]} {-height 16 -radix decimal} {/ita_tb/dut/i_activation/data_i[13]} {-height 16 -radix decimal} {/ita_tb/dut/i_activation/data_i[12]} {-height 16 -radix decimal} {/ita_tb/dut/i_activation/data_i[11]} {-height 16 -radix decimal} {/ita_tb/dut/i_activation/data_i[10]} {-height 16 -radix decimal} {/ita_tb/dut/i_activation/data_i[9]} {-height 16 -radix decimal} {/ita_tb/dut/i_activation/data_i[8]} {-height 16 -radix decimal} {/ita_tb/dut/i_activation/data_i[7]} {-height 16 -radix decimal} {/ita_tb/dut/i_activation/data_i[6]} {-height 16 -radix decimal} {/ita_tb/dut/i_activation/data_i[5]} {-height 16 -radix decimal} {/ita_tb/dut/i_activation/data_i[4]} {-height 16 -radix decimal} {/ita_tb/dut/i_activation/data_i[3]} {-height 16 -radix decimal} {/ita_tb/dut/i_activation/data_i[2]} {-height 16 -radix decimal} {/ita_tb/dut/i_activation/data_i[1]} {-height 16 -radix decimal} {/ita_tb/dut/i_activation/data_i[0]} {-height 16 -radix decimal}} sim:/ita_tb/dut/i_activation/data_i
add wave -noupdate sim:/ita_tb/dut/i_activation/data_q1
add wave -noupdate sim:/ita_tb/dut/i_activation/data_q2
add wave -noupdate sim:/ita_tb/dut/i_activation/data_q3
add wave -noupdate sim:/ita_tb/dut/i_activation/data_q4
add wave -noupdate sim:/ita_tb/dut/i_activation/data_o
add wave -noupdate sim:/ita_tb/dut/i_fifo/data_i
add wave -noupdate sim:/ita_tb/dut/i_fifo/data_o
add wave -noupdate sim:/ita_tb/dut/oup_o
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/clk_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/rst_ni
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/mode_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/eps_mult_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/right_shift_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/calc_en_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/calc_en_q_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/result_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/add_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/requant_oup_o
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/mult_signed
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/product
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/shifted_added
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/shifted_d
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/shifted_q
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/add_q1
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/add_q2
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/add_q3
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/add_q4
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/requant_oup_d
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/requant_oup_q
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/clk_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/rst_ni
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/mode_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/eps_mult_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/right_shift_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/calc_en_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/calc_en_q_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/result_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/add_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/requant_oup_o
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/mult_signed
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/product
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/shifted_added
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/shifted_d
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/shifted_q
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/add_q1
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/add_q2
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/add_q3
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/add_q4
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/requant_oup_d
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/requant_oup_q
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/clk_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/rst_ni
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/mode_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/eps_mult_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/right_shift_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/calc_en_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/calc_en_q_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/result_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/add_i
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/requant_oup_o
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/mult_signed
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/product
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/shifted_added
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/shifted_d
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/shifted_q
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/add_q1
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/add_q2
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/add_q3
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/add_q4
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/requant_oup_d
add wave -noupdate -group Requantizer sim:/ita_tb/dut/i_requantizer/requant_oup_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/clk_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/rst_ni
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/ctrl_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inp_valid_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inp_ready_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/weight_valid_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/weight_ready_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_valid_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_ready_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/oup_valid_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/oup_ready_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/pop_softmax_fifo_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/step_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/soft_addr_div_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_done_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/calc_en_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/first_inner_tile_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/last_inner_tile_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_x_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_y_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inner_tile_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/requant_add_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/requant_add_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inp_bias_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inp_bias_pad_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/busy_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/calc_en_q1_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/step_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/step_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/count_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/count_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_count
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_pos_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_pos_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_col_offset_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_col_offset_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inner_tile_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inner_tile_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_tile_x_pos_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_tile_x_pos_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_tile_y_pos_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_tile_y_pos_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_x_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_x_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_tile_x_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_tile_x_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_y_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_y_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_tile_y_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_tile_y_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_tile_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_tile_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/ongoing_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/ongoing_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/ongoing_soft_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/ongoing_soft_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inp_bias
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inp_bias_padded
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/last_time
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inner_tile_dim
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/first_outer_dim
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/second_outer_dim
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/first_outer_dim_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/first_outer_dim_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/second_outer_dim_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/second_outer_dim_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_fifo
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_div
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_div_done_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_div_done_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/busy_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/busy_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/requant_add_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/requant_add_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/clk_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/rst_ni
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/ctrl_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inp_valid_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inp_ready_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/weight_valid_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/weight_ready_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_valid_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_ready_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/oup_valid_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/oup_ready_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/pop_softmax_fifo_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/step_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/soft_addr_div_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_done_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/calc_en_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/first_inner_tile_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/last_inner_tile_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_x_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_y_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inner_tile_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/requant_add_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/requant_add_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inp_bias_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inp_bias_pad_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/busy_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/calc_en_q1_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/step_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/step_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/count_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/count_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_count
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_pos_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_pos_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_col_offset_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_col_offset_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inner_tile_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inner_tile_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_tile_x_pos_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_tile_x_pos_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_tile_y_pos_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_tile_y_pos_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_x_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_x_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_tile_x_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_tile_x_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_y_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_y_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_tile_y_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_tile_y_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_tile_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_tile_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/ongoing_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/ongoing_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/ongoing_soft_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/ongoing_soft_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inp_bias
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inp_bias_padded
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/last_time
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inner_tile_dim
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/first_outer_dim
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/second_outer_dim
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/first_outer_dim_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/first_outer_dim_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/second_outer_dim_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/second_outer_dim_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_fifo
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_div
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_div_done_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_div_done_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/busy_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/busy_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/requant_add_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/requant_add_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/clk_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/rst_ni
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/ctrl_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inp_valid_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inp_ready_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/weight_valid_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/weight_ready_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_valid_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_ready_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/oup_valid_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/oup_ready_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/pop_softmax_fifo_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/step_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/soft_addr_div_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_done_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/calc_en_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/first_inner_tile_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/last_inner_tile_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_x_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_y_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inner_tile_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/requant_add_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/requant_add_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inp_bias_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inp_bias_pad_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/busy_o
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/calc_en_q1_i
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/step_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/step_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/count_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/count_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_count
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_pos_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_pos_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_col_offset_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_col_offset_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inner_tile_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inner_tile_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_tile_x_pos_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_tile_x_pos_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_tile_y_pos_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_tile_y_pos_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_x_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_x_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_tile_x_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_tile_x_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_y_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/tile_y_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_tile_y_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/bias_tile_y_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_tile_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_tile_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/ongoing_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/ongoing_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/ongoing_soft_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/ongoing_soft_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inp_bias
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inp_bias_padded
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/last_time
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/mask_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/inner_tile_dim
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/first_outer_dim
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/second_outer_dim
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/first_outer_dim_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/first_outer_dim_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/second_outer_dim_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/second_outer_dim_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_fifo
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_div
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_div_done_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/softmax_div_done_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/busy_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/busy_q
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/requant_add_d
add wave -noupdate -expand -group Controller sim:/ita_tb/dut/i_controller/requant_add_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/clk_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/rst_ni
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/ctrl_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_en_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/requant_oup_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_stream_soft_en_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/soft_addr_div_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/softmax_done_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/pop_softmax_fifo_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/inp_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/inp_stream_soft_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_inp_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_valid_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_ready_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_valid_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_ready_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_oup_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/prev_max_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/max_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/read_max_en_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/read_max_addr_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/read_max_data_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/write_max_en_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/write_max_addr_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/write_max_data_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_x_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_y_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/inner_tile_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_q1
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_q2
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_q3
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_q4
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/inner_tile_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_y_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/exp_sum_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/exp_sum_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_soft_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_soft_q1
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_soft_q2
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_soft_mask_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_div_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_div_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/addr_div_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/addr_div_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_read_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_read_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_write_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_write_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/requant_oup_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/max_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/max_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_diff
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/max_diff
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_inp
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_inp_diff
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_stream_soft_en_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_en_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_en_q1
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/fifo_full
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/fifo_empty
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/push_to_fifo
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/pop_from_fifo
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/data_to_fifo
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/data_from_fifo
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/fifo_usage
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/disable_shift
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/disable_row
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/disable_col
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/clk_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/rst_ni
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/ctrl_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/step_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_en_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/requant_oup_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_stream_soft_en_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/soft_addr_div_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/softmax_done_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/pop_softmax_fifo_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/inp_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/inp_stream_soft_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_inp_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_valid_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_ready_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_valid_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_ready_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_oup_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/read_acc_en_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/read_acc_addr_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/read_acc_data_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/write_acc_en_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/write_acc_addr_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/write_acc_data_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/prev_max_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/max_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/max_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/write_max_en_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/write_max_addr_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/write_max_data_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_x_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_y_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/inner_tile_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_q1
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_q2
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_q3
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_q4
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_q1
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_q2
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_q3
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_q4
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/inner_tile_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_x_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_y_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_tile_x_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_tile_x_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_tile_y_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_tile_y_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_tile_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_tile_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/exp_sum_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/exp_sum_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_soft_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_soft_q1
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_soft_q2
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_soft_mask_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_div_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_div_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/addr_div_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/addr_div_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_read_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_read_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_write_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_write_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/requant_oup_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/max_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/max_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_diff
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_sum_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_sum_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/max_diff
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_inp
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_inp_diff
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_stream_soft_en_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_en_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_en_q1
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_en_q2
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_en_q3
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/fifo_full
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/fifo_empty
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/push_to_fifo
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/pop_from_fifo
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/data_to_fifo
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/data_from_fifo
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/fifo_usage
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/disable_shift
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/disable_row
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/disable_col
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/clk_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/rst_ni
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/ctrl_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/step_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_en_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/requant_oup_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_stream_soft_en_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/soft_addr_div_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/softmax_done_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/pop_softmax_fifo_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/inp_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/inp_stream_soft_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_inp_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_valid_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_ready_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_valid_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_ready_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_oup_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/read_acc_en_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/read_acc_addr_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/read_acc_data_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/write_acc_en_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/write_acc_addr_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/write_acc_data_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/prev_max_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/max_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/max_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/read_max_en_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/read_max_addr_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/read_max_data_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/write_max_en_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/write_max_addr_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/write_max_data_o
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_x_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_y_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/inner_tile_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_i
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_q1
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_q2
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_q3
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_q4
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_q1
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_q2
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_q3
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_q4
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/inner_tile_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_x_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/tile_y_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_tile_x_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_tile_x_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_tile_y_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_tile_y_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_tile_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/mask_tile_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/exp_sum_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/exp_sum_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_soft_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_soft_q1
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_soft_q2
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_soft_mask_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_div_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/count_div_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/addr_div_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/addr_div_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_read_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_read_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_write_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/div_write_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/requant_oup_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/max_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/max_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_diff
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_sum_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_sum_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/max_diff
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_inp
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/shift_inp_diff
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_stream_soft_en_q
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_en_d
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_en_q1
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_en_q2
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/calc_en_q3
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/fifo_full
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/fifo_empty
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/push_to_fifo
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/pop_from_fifo
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/data_to_fifo
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/data_from_fifo
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/fifo_usage
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/disable_shift
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/disable_row
add wave -noupdate -expand -group {Softmax Controller} sim:/ita_tb/dut/i_softmax_top/i_softmax/disable_col
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/clk_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/rst_ni
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/calc_en_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/calc_en_q_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/first_tile_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/first_tile_q_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/last_tile_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/last_tile_q_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/oup_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/inp_bias_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/result_o
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/read_en
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/read_addr
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/read_data
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/read_data_unused
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/write_en
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/write_addr
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/write_data
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/read_addr_d
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/read_addr_q
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/write_addr_d
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/write_addr_q
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/result_d
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/result_q
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/clk_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/rst_ni
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/calc_en_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/calc_en_q_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/first_tile_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/first_tile_q_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/last_tile_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/last_tile_q_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/oup_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/inp_bias_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/result_o
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/read_en
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/read_addr
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/read_data
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/read_data_unused
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/write_en
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/write_addr
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/write_data
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/read_addr_d
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/read_addr_q
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/write_addr_d
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/write_addr_q
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/result_d
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/result_q
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/clk_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/rst_ni
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/calc_en_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/calc_en_q_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/first_tile_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/first_tile_q_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/last_tile_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/last_tile_q_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/oup_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/inp_bias_i
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/result_o
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/read_en
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/read_addr
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/read_data
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/read_data_unused
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/write_en
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/write_addr
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/write_data
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/read_addr_d
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/read_addr_q
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/write_addr_d
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/write_addr_q
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/result_d
add wave -noupdate -group Accumulator sim:/ita_tb/dut/i_accumulator/result_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5124600 ps} 1} {{Cursor 2} {5097000 ps} 1} {63 {3866973 ps} 1} {127 {4124941 ps} 1} {191 {4374986 ps} 1} {255 {4820989 ps} 1} {{Cursor 7} {4818977 ps} 0}
quietly wave cursor active 7
configure wave -namecolwidth 189
configure wave -valuecolwidth 165
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
WaveRestoreZoom {4810718 ps} {4831365 ps}




