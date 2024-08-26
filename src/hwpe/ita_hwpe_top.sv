// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// Author: Gamze Islamoglu <gislamoglu@iis.ee.ethz.ch>

import ita_hwpe_package::*;
import hwpe_ctrl_package::*;
import hwpe_stream_package::*;

module ita_hwpe_top
(
  // global signals
  input  logic                                  clk_i,
  input  logic                                  rst_ni,
  input  logic                                  test_mode_i,
  // events
  output logic [N_CORES-1:0][REGFILE_N_EVT-1:0] evt_o,
  output logic                                  busy_o,
  // tcdm master ports
  hci_core_intf.initiator                       tcdm,
  // periph slave port
  hwpe_ctrl_intf_periph.slave                   periph
);

  logic enable, clear;
  ctrl_streamer_t  streamer_ctrl;
  flags_streamer_t streamer_flags;
  ctrl_engine_t    engine_ctrl;
  flags_engine_t   engine_flags;
  ctrl_stream_t    ctrl_stream;
  flags_fifo_t [1:0] flags_fifo;

  hwpe_stream_intf_stream #(
    .DATA_WIDTH(ITA_TCDM_DW)
  ) ita_input (
    .clk ( clk_i )
  );
  hwpe_stream_intf_stream #(
    .DATA_WIDTH(ITA_TCDM_DW)
  ) ita_weight (
    .clk ( clk_i )
  );
  hwpe_stream_intf_stream #(
    .DATA_WIDTH(ITA_TCDM_DW)
  ) ita_bias (
    .clk ( clk_i )
  );
  hwpe_stream_intf_stream #(
    .DATA_WIDTH(ITA_TCDM_DW)
  ) ita_output (
    .clk ( clk_i )
  );

  hwpe_stream_intf_stream #(
    .DATA_WIDTH(ITA_INPUT_DW)
  ) ita_engine_input (
    .clk ( clk_i )
  );
  hwpe_stream_intf_stream #(
    .DATA_WIDTH(ITA_WEIGHT_DW)
  ) ita_engine_weight (
    .clk ( clk_i )
  );
  hwpe_stream_intf_stream #(
    .DATA_WIDTH(ITA_BIAS_DW)
  ) ita_engine_bias (
    .clk ( clk_i )
  );
  hwpe_stream_intf_stream #(
    .DATA_WIDTH(ITA_OUTPUT_DW)
  ) ita_engine_output (
    .clk ( clk_i )
  );

  hwpe_stream_intf_stream #(
    .DATA_WIDTH(ITA_INPUT_DW)
  ) input_prefence (
    .clk ( clk_i )
  );
  hwpe_stream_intf_stream #(
    .DATA_WIDTH(ITA_BIAS_DW)
  ) bias_prefence (
    .clk ( clk_i )
  );

  ita_hwpe_engine i_engine (
    .clk_i            ( clk_i                    ),
    .rst_ni           ( rst_ni                   ),
    .test_mode_i      ( test_mode_i              ),
    .input_i          ( ita_engine_input.sink    ),
    .weight_i         ( ita_engine_weight.sink   ),
    .bias_i           ( ita_engine_bias.sink     ),
    .output_o         ( ita_engine_output.source ),
    .ctrl_i           ( engine_ctrl              ),
    .flags_o          ( engine_flags             )
  );

  ita_hwpe_input_buffer #(
    .INPUT_DATA_WIDTH  (ITA_TCDM_DW ),
    .OUTPUT_DATA_WIDTH (ITA_INPUT_DW)
  ) i_input_buffer (
    .clk_i  ( clk_i                 ),
    .rst_ni ( rst_ni                ),
    .data_i ( ita_input.sink        ),
    .data_o ( input_prefence.source )
  );

  ita_hwpe_input_buffer #(
    .INPUT_DATA_WIDTH  (ITA_TCDM_DW  ),
    .OUTPUT_DATA_WIDTH (ITA_WEIGHT_DW),
    .FIFO_DEPTH        (4)
  ) i_weight_buffer (
    .clk_i   ( clk_i                    ),
    .rst_ni  ( rst_ni                   ),
    .data_i  ( ita_weight.sink          ),
    .data_o  ( ita_engine_weight.source )
  );

  ita_hwpe_input_bias_buffer #(
    .INPUT_DATA_WIDTH  (ITA_TCDM_DW),
    .OUTPUT_DATA_WIDTH (ITA_BIAS_DW)
  ) i_bias_buffer (
    .clk_i      ( clk_i                      ),
    .rst_ni     ( rst_ni                     ),
    .bias_dir_i ( ctrl_stream.bias_direction ),
    .data_i     ( ita_bias.sink              ),
    .data_o     ( bias_prefence.source       )
  );

  ita_hwpe_output_buffer #(
    .INPUT_DATA_WIDTH  (ITA_OUTPUT_DW ),
    .OUTPUT_DATA_WIDTH (ITA_TCDM_DW   )
  ) i_output_buffer (
    .clk_i  ( clk_i                  ),
    .rst_ni ( rst_ni                 ),
    .data_i ( ita_engine_output.sink ),
    .data_o ( ita_output.source      )
  );

  ita_hwpe_streamer #(
    
  ) i_streamer (
    .clk_i            ( clk_i              ),
    .rst_ni           ( rst_ni             ),
    .test_mode_i      ( test_mode_i        ),
    .enable_i         ( enable             ),
    .clear_i          ( clear              ),
    .input_o          ( ita_input.source   ),
    .weight_o         ( ita_weight.source  ),
    .bias_o           ( ita_bias.source    ),
    .output_i         ( ita_output.sink    ),
    .tcdm_o           ( tcdm               ),
    .ctrl_i           ( streamer_ctrl      ),
    .flags_o          ( streamer_flags     ),
    .flags_fifo_o     ( flags_fifo         )
  );

  ita_hwpe_ctrl #(

  ) i_ctrl (
    .clk_i            ( clk_i          ),
    .rst_ni           ( rst_ni         ),
    .test_mode_i      ( test_mode_i    ),
    .evt_o            ( evt_o          ),
    .busy_o           ( busy_o         ),
    .clear_o          ( clear          ),
    .ctrl_streamer_o  ( streamer_ctrl  ),
    .flags_streamer_i ( streamer_flags ),
    .flags_fifo_i     ( flags_fifo     ),
    .ctrl_engine_o    ( engine_ctrl    ),
    .flags_engine_i   ( engine_flags   ),
    .ctrl_stream_o    ( ctrl_stream    ),
    .periph           ( periph         )
  );

  assign enable = 1'b1;

  ita_hwpe_input_bias_fence #(
    .ITA_INPUT_DW ( ITA_INPUT_DW ),
    .ITA_BIAS_DW  ( ITA_BIAS_DW  )
  ) i_input_bias_fence (
    .clk_i          ( clk_i                    ),
    .rst_ni         ( rst_ni                   ),
    .clear_i        ( clear                    ),
    .test_mode_i    ( test_mode_i              ),
    .bias_disable_i ( ctrl_stream.bias_disable ),
    .input_i        ( input_prefence.sink      ),
    .bias_i         ( bias_prefence.sink       ),
    .input_o        ( ita_engine_input.source  ),
    .bias_o         ( ita_engine_bias.source   )
  );

endmodule : ita_hwpe_top