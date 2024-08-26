// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// Author: Gamze Islamoglu <gislamoglu@iis.ee.ethz.ch>

import ita_hwpe_package::*;
import ita_package::M;
import ita_package::N;
import hwpe_stream_package::*;

module ita_hwpe_input_bias_fence #(
  parameter int unsigned ITA_INPUT_DW  = 32,
  parameter int unsigned ITA_BIAS_DW   = 32
) (
  // global signals
  input  logic                   clk_i,
  input  logic                   rst_ni,
  // local enable & clear
  input  logic                   clear_i,
  // test mode
  input  logic                   test_mode_i,
  // If bias is disabled
  input logic                    bias_disable_i,
  // Stream interfaces
  hwpe_stream_intf_stream.sink   input_i,
  hwpe_stream_intf_stream.sink   bias_i,
  hwpe_stream_intf_stream.source input_o,
  hwpe_stream_intf_stream.source bias_o
);

  // Fence input and bias streams to ensure that they arrive at the same time
  localparam int unsigned NB_STREAMS = 2;

  hwpe_stream_intf_stream #(
    .DATA_WIDTH ( ITA_INPUT_DW ) // assuming ITA_INPUT_DW > (ITA_BIAS_DW)
  ) split_streams [NB_STREAMS-1:0] (
    .clk ( clk_i )
  );

  hwpe_stream_intf_stream #(
    .DATA_WIDTH ( ITA_INPUT_DW )
  ) fenced_streams [NB_STREAMS-1:0] (
    .clk ( clk_i )
  );

  hwpe_stream_fence #(
    .NB_STREAMS ( NB_STREAMS   ),
    .DATA_WIDTH ( ITA_INPUT_DW )
  ) i_fence (
    .clk_i       ( clk_i          ),
    .rst_ni      ( rst_ni         ),
    .clear_i     ( clear_i        ),
    .test_mode_i ( test_mode_i    ),
    .push_i      ( split_streams  ),
    .pop_o       ( fenced_streams )
  );

  hwpe_stream_assign i_split_input_assign (.push_i (input_i), .pop_o (split_streams[0]));

  assign split_streams[1].valid = bias_disable_i ? 1'b1 : bias_i.valid;
  assign split_streams[1].data  = bias_disable_i ? '0 : bias_i.data;
  assign split_streams[1].strb  = bias_disable_i ? '0 : bias_i.strb;
  assign bias_i.ready = bias_disable_i ? 1'b0 : split_streams[1].ready;

  hwpe_stream_assign i_fenced_input_assign (.push_i (fenced_streams[0]), .pop_o (input_o));
  hwpe_stream_assign i_fenced_bias_assign (.push_i (fenced_streams[1]), .pop_o (bias_o));

endmodule : ita_hwpe_input_bias_fence