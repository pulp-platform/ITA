# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

add wave -noupdate -divider TB
add wave -noupdate -group Parameters /ita_hwpe_tb/ITA_REG_OFFSET
add wave -noupdate -group Parameters /ita_hwpe_tb/PROB_STALL
add wave -noupdate -group Parameters /ita_hwpe_tb/MEMORY_SIZE
add wave -noupdate -group Parameters -radix unsigned /ita_hwpe_tb/MP
add wave -noupdate -group Parameters -radix unsigned /ita_hwpe_tb/N_PE
add wave -noupdate -group Parameters -radix unsigned /ita_hwpe_tb/M_TILE_LEN
add wave -noupdate -group Parameters -radix unsigned /ita_hwpe_tb/SEQUENCE_LEN
add wave -noupdate -group Parameters -radix unsigned /ita_hwpe_tb/PROJECTION_SPACE
add wave -noupdate -group Parameters -radix unsigned /ita_hwpe_tb/EMBEDDING_SIZE
add wave -noupdate -group Parameters -radix unsigned /ita_hwpe_tb/N_TILES_SEQUENCE_DIM
add wave -noupdate -group Parameters -radix unsigned /ita_hwpe_tb/N_TILES_EMBEDDING_DIM
add wave -noupdate -group Parameters -radix unsigned /ita_hwpe_tb/N_ELEMENTS_PER_TILE
add wave -noupdate -group Parameters -radix unsigned /ita_hwpe_tb/N_TILES_OUTER_X
add wave -noupdate -group Parameters -radix unsigned /ita_hwpe_tb/N_TILES_OUTER_Y
add wave -noupdate -group Parameters -radix unsigned /ita_hwpe_tb/N_TILES_INNER_DIM
add wave -noupdate -group Parameters /ita_hwpe_tb/BASE_PTR
add wave -noupdate -group Parameters /ita_hwpe_tb/BASE_PTR_INPUT
add wave -noupdate -group Parameters /ita_hwpe_tb/BASE_PTR_WEIGHT0
add wave -noupdate -group Parameters /ita_hwpe_tb/BASE_PTR_WEIGHT1
add wave -noupdate -group Parameters /ita_hwpe_tb/BASE_PTR_BIAS
add wave -noupdate -group Parameters /ita_hwpe_tb/BASE_PTR_OUTPUT
add wave -noupdate -group Signals /ita_hwpe_tb/simdir
add wave -noupdate -group Signals /ita_hwpe_tb/clk
add wave -noupdate -group Signals /ita_hwpe_tb/rst_n
add wave -noupdate -group Signals /ita_hwpe_tb/evt
add wave -noupdate -group Signals /ita_hwpe_tb/busy
add wave -noupdate -group {Peripheral Interface} /ita_hwpe_tb/periph/r_id
add wave -noupdate -group {Peripheral Interface} /ita_hwpe_tb/periph/r_valid
add wave -noupdate -group {Peripheral Interface} /ita_hwpe_tb/periph/r_data
add wave -noupdate -group {Peripheral Interface} /ita_hwpe_tb/periph/id
add wave -noupdate -group {Peripheral Interface} /ita_hwpe_tb/periph/data
add wave -noupdate -group {Peripheral Interface} /ita_hwpe_tb/periph/be
add wave -noupdate -group {Peripheral Interface} /ita_hwpe_tb/periph/wen
add wave -noupdate -group {Peripheral Interface} /ita_hwpe_tb/periph/add
add wave -noupdate -group {Peripheral Interface} /ita_hwpe_tb/periph/gnt
add wave -noupdate -group {Peripheral Interface} /ita_hwpe_tb/periph/req
add wave -noupdate -group {Peripheral Interface} /ita_hwpe_tb/periph/clk
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/clk
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/req
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/gnt
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/r_valid
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/r_ready
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/add
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/wen
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/data
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/be
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/user
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/id
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/r_data
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/r_user
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/r_id
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/r_opc
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/ecc
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/r_ecc
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/ereq
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/egnt
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/r_evalid
add wave -noupdate -group {TCDM Interface} /ita_hwpe_tb/dut/tcdm/r_eready
add wave -noupdate -divider {ITA Top}
add wave -noupdate -group {ITA Input} /ita_hwpe_tb/dut/i_ita/ita_input/clk
add wave -noupdate -group {ITA Input} /ita_hwpe_tb/dut/i_ita/ita_input/valid
add wave -noupdate -group {ITA Input} /ita_hwpe_tb/dut/i_ita/ita_input/ready
add wave -noupdate -group {ITA Input} /ita_hwpe_tb/dut/i_ita/ita_input/data
add wave -noupdate -group {ITA Input} /ita_hwpe_tb/dut/i_ita/ita_input/strb
add wave -noupdate -group {ITA Weight} /ita_hwpe_tb/dut/i_ita/ita_weight/clk
add wave -noupdate -group {ITA Weight} /ita_hwpe_tb/dut/i_ita/ita_weight/valid
add wave -noupdate -group {ITA Weight} /ita_hwpe_tb/dut/i_ita/ita_weight/ready
add wave -noupdate -group {ITA Weight} /ita_hwpe_tb/dut/i_ita/ita_weight/data
add wave -noupdate -group {ITA Weight} /ita_hwpe_tb/dut/i_ita/ita_weight/strb
add wave -noupdate -group {ITA Bias} /ita_hwpe_tb/dut/i_ita/ita_bias/clk
add wave -noupdate -group {ITA Bias} /ita_hwpe_tb/dut/i_ita/ita_bias/valid
add wave -noupdate -group {ITA Bias} /ita_hwpe_tb/dut/i_ita/ita_bias/ready
add wave -noupdate -group {ITA Bias} /ita_hwpe_tb/dut/i_ita/ita_bias/data
add wave -noupdate -group {ITA Bias} /ita_hwpe_tb/dut/i_ita/ita_bias/strb
add wave -noupdate -group {ITA Output} /ita_hwpe_tb/dut/i_ita/ita_output/clk
add wave -noupdate -group {ITA Output} /ita_hwpe_tb/dut/i_ita/ita_output/valid
add wave -noupdate -group {ITA Output} /ita_hwpe_tb/dut/i_ita/ita_output/ready
add wave -noupdate -group {ITA Output} /ita_hwpe_tb/dut/i_ita/ita_output/data
add wave -noupdate -group {ITA Output} /ita_hwpe_tb/dut/i_ita/ita_output/strb
add wave -noupdate -divider ITA
add wave -noupdate -group {ITA I/O} /ita_hwpe_tb/dut/i_ita/i_engine/clk_i
add wave -noupdate -group {ITA I/O} /ita_hwpe_tb/dut/i_ita/i_engine/rst_ni
add wave -noupdate -group {ITA I/O} /ita_hwpe_tb/dut/i_ita/i_engine/ctrl_i
add wave -noupdate -group {ITA I/O} /ita_hwpe_tb/dut/i_ita/i_engine/flags_o
add wave -noupdate -group {ITA I/O} /ita_hwpe_tb/dut/i_ita/i_engine/i_ita/inp_valid_i
add wave -noupdate -group {ITA I/O} /ita_hwpe_tb/dut/i_ita/i_engine/i_ita/inp_ready_o
add wave -noupdate -group {ITA I/O} /ita_hwpe_tb/dut/i_ita/i_engine/i_ita/inp_weight_valid_i
add wave -noupdate -group {ITA I/O} /ita_hwpe_tb/dut/i_ita/i_engine/i_ita/inp_weight_ready_o
add wave -noupdate -group {ITA I/O} /ita_hwpe_tb/dut/i_ita/i_engine/i_ita/inp_bias_valid_i
add wave -noupdate -group {ITA I/O} /ita_hwpe_tb/dut/i_ita/i_engine/i_ita/inp_bias_ready_o
add wave -noupdate -group {ITA I/O} /ita_hwpe_tb/dut/i_ita/i_engine/i_ita/valid_o
add wave -noupdate -group {ITA I/O} /ita_hwpe_tb/dut/i_ita/i_engine/i_ita/ready_i
add wave -noupdate -group {ITA I/O} /ita_hwpe_tb/dut/i_ita/i_engine/i_ita/inp_i
add wave -noupdate -group {ITA I/O} /ita_hwpe_tb/dut/i_ita/i_engine/i_ita/inp_weight_i
add wave -noupdate -group {ITA I/O} /ita_hwpe_tb/dut/i_ita/i_engine/i_ita/inp_bias_i
add wave -noupdate -group {ITA I/O} /ita_hwpe_tb/dut/i_ita/i_engine/i_ita/oup_o
add wave -noupdate -group {ITA Controller} /ita_hwpe_tb/dut/i_ita/i_engine/i_ita/i_controller/*
add wave -noupdate -group {ITA Softmax} /ita_hwpe_tb/dut/i_ita/i_engine/i_ita/i_softmax_top/i_softmax/*
add wave -noupdate /ita_hwpe_tb/dut/i_ita/i_engine/i_ita/step
add wave -noupdate -divider Streamer
add wave -noupdate -group {Streamer I/O} /ita_hwpe_tb/dut/i_ita/i_streamer/clk_i
add wave -noupdate -group {Streamer I/O} /ita_hwpe_tb/dut/i_ita/i_streamer/rst_ni
add wave -noupdate -group {Streamer I/O} /ita_hwpe_tb/dut/i_ita/i_streamer/enable_i
add wave -noupdate -group {Streamer I/O} /ita_hwpe_tb/dut/i_ita/i_streamer/clear_i
add wave -noupdate -group {Streamer I/O} /ita_hwpe_tb/dut/i_ita/i_streamer/ctrl_i
add wave -noupdate -group {Streamer I/O} /ita_hwpe_tb/dut/i_ita/i_streamer/flags_o
add wave -noupdate -divider {Top Controller}
add wave -noupdate /ita_hwpe_tb/dut/i_ita/i_ctrl/TOT_LEN
add wave -noupdate -group {Top Controller I/O} /ita_hwpe_tb/dut/i_ita/i_ctrl/clk_i
add wave -noupdate -group {Top Controller I/O} /ita_hwpe_tb/dut/i_ita/i_ctrl/rst_ni
add wave -noupdate -group {Top Controller I/O} /ita_hwpe_tb/dut/i_ita/i_ctrl/clear_o
add wave -noupdate -group {Top Controller I/O} /ita_hwpe_tb/dut/i_ita/i_ctrl/evt_o
add wave -noupdate -group {Top Controller I/O} /ita_hwpe_tb/dut/i_ita/i_ctrl/busy_o
add wave -noupdate -group {Top Controller I/O} /ita_hwpe_tb/dut/i_ita/i_ctrl/ctrl_streamer_o
add wave -noupdate -group {Top Controller I/O} /ita_hwpe_tb/dut/i_ita/i_ctrl/flags_streamer_i
add wave -noupdate -group {Top Controller I/O} /ita_hwpe_tb/dut/i_ita/i_ctrl/ctrl_engine_o
add wave -noupdate -group {Top Controller I/O} /ita_hwpe_tb/dut/i_ita/i_ctrl/flags_engine_i
add wave -noupdate -group {Top Controller Signals} /ita_hwpe_tb/dut/i_ita/i_ctrl/slave_ctrl
add wave -noupdate -group {Top Controller Signals} /ita_hwpe_tb/dut/i_ita/i_ctrl/slave_flags
add wave -noupdate -group {Top Controller Signals} /ita_hwpe_tb/dut/i_ita/i_ctrl/reg_file
add wave -noupdate -group {Top Controller Signals} /ita_hwpe_tb/dut/i_ita/i_ctrl/input_addr
add wave -noupdate -group {Top Controller Signals} /ita_hwpe_tb/dut/i_ita/i_ctrl/weight_addr
add wave -noupdate -group {Top Controller Signals} /ita_hwpe_tb/dut/i_ita/i_ctrl/bias_addr
add wave -noupdate -group {Top Controller Signals} /ita_hwpe_tb/dut/i_ita/i_ctrl/output_addr
add wave -noupdate -group {Top Controller Signals} /ita_hwpe_tb/dut/i_ita/i_ctrl/state_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 4} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 161
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
