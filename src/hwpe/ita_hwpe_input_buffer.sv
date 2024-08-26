// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

import ita_package::*;

module ita_hwpe_input_buffer #(
  parameter int unsigned INPUT_DATA_WIDTH  = 32,
  parameter int unsigned OUTPUT_DATA_WIDTH = 32,
  parameter int unsigned FIFO_DEPTH = 8,
  parameter int unsigned LATCH_FIFO = 1,
  parameter int unsigned LATCH_FIFO_TEST_WRAP = 0
)
(
  input  logic                   clk_i ,
  input  logic                   rst_ni,
  hwpe_stream_intf_stream.sink   data_i,
  hwpe_stream_intf_stream.source data_o
);

  hwpe_stream_intf_stream #(
    .DATA_WIDTH(INPUT_DATA_WIDTH)
  ) data_fifo (
    .clk ( clk_i )
  );

  localparam int unsigned REUSE_FACTOR = INPUT_DATA_WIDTH / OUTPUT_DATA_WIDTH;

  logic [REUSE_FACTOR-1:0] reuse_cnt_d, reuse_cnt_q;

  always_comb begin
    // Default assignments
    reuse_cnt_d = reuse_cnt_q;

    data_o.data  = data_fifo.data[(reuse_cnt_q)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
    data_o.strb  = data_fifo.strb[(reuse_cnt_q)*OUTPUT_DATA_WIDTH/8+:OUTPUT_DATA_WIDTH/8];
    data_o.valid = data_fifo.valid;
    data_fifo.ready = (reuse_cnt_q == REUSE_FACTOR - 1) ? data_o.ready : 0;

    if(data_o.ready && data_fifo.valid) begin
      reuse_cnt_d = reuse_cnt_q + 1;
      if (reuse_cnt_q == REUSE_FACTOR - 1) begin
        reuse_cnt_d = 0;
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      reuse_cnt_q <= '0;
    end else begin
      reuse_cnt_q <= reuse_cnt_d;
    end
  end

  hwpe_stream_fifo #(
    .DATA_WIDTH (INPUT_DATA_WIDTH),
    .FIFO_DEPTH (8),
    .LATCH_FIFO (1),
    .LATCH_FIFO_TEST_WRAP (0)
  ) i_data_fifo (
    .clk_i (clk_i),
    .rst_ni(rst_ni),
    .clear_i(1'b0),
    .flags_o(),
    .push_i(data_i),
    .pop_o (data_fifo)
  );

endmodule
