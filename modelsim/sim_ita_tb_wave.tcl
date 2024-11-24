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
add wave -noupdate -expand -group {Masking Signals} -radix unsigned /ita_tb/dut/i_controller/mask_col_offset_q
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/i_softmax_top/i_softmax/max_o
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/i_softmax_top/i_softmax/exp_sum_d
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/i_softmax_top/i_softmax/exp_sum_q
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/i_softmax_top/i_softmax/disable_row
add wave -noupdate -expand -group {Masking Signals} -radix binary /ita_tb/dut/i_softmax_top/i_softmax/disable_col
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/i_controller/step_q
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned /ita_tb/dut/i_controller/mask_tile_x_pos_d
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned /ita_tb/dut/i_controller/mask_tile_x_pos_q
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned /ita_tb/dut/i_controller/mask_tile_y_pos_d
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned /ita_tb/dut/i_controller/mask_tile_y_pos_q
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned /ita_tb/dut/i_controller/mask_tile_x_q3
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned /ita_tb/dut/i_controller/mask_tile_y_q3
add wave -noupdate -expand -group {Masking Signals} -group {Mask Tile Pos} -radix unsigned /ita_tb/dut/i_controller/first_outer_dim
add wave -noupdate -expand -group {Masking Signals} -radix unsigned /ita_tb/dut/i_controller/count_q
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/i_controller/mask_d
add wave -noupdate -expand -group {Masking Signals} -radix unsigned /ita_tb/dut/i_controller/mask_pos_q
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/i_inp2_mux/clk_i
add wave -noupdate -expand -group {Masking Signals} -radix unsigned /ita_tb/dut/i_softmax_top/i_softmax/inp_stream_soft_o
add wave -noupdate -expand -group {Masking Signals} -radix unsigned /ita_tb/dut/i_softmax_top/i_softmax/count_soft_q1
add wave -noupdate -expand -group {Masking Signals} -radix unsigned /ita_tb/dut/i_softmax_top/i_softmax/count_soft_q2
add wave -noupdate -expand -group {Masking Signals} -radix hexadecimal /ita_tb/dut/i_softmax_top/i_softmax/calc_stream_soft_en_q
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/calc_en
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/calc_en_q1
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/calc_en_q2
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/calc_en_q3
add wave -noupdate -expand -group {Masking Signals} /ita_tb/dut/calc_en_q4
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
add wave -noupdate /ita_tb/dut/i_accumulator/oup_i
add wave -noupdate /ita_tb/dut/i_accumulator/result_d
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
