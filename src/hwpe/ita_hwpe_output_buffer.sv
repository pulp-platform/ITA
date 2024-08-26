// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

import ita_package::*;

module ita_hwpe_output_buffer #(
  parameter int unsigned INPUT_DATA_WIDTH  = 32,
  parameter int unsigned OUTPUT_DATA_WIDTH = 32,
  parameter int unsigned FIFO_DEPTH = 8,
  parameter int unsigned LATCH_FIFO = 1,
  parameter int unsigned LATCH_FIFO_TEST_WRAP = 0
)
(
  input  logic                   clk_i  ,
  input  logic                   rst_ni ,
  hwpe_stream_intf_stream.sink   data_i,
  hwpe_stream_intf_stream.source data_o
);

  hwpe_stream_intf_stream #(
    .DATA_WIDTH(OUTPUT_DATA_WIDTH)
  ) data_fifo (
    .clk ( clk_i )
  );

  localparam int unsigned REUSE_FACTOR = 2; // TODO: Make this a parameter

  logic [REUSE_FACTOR-1:0] reuse_cnt_d, reuse_cnt_q;
  logic [OUTPUT_DATA_WIDTH-1:0] data_d, data_q;
  logic [OUTPUT_DATA_WIDTH/8-1:0] data_strb_d, data_strb_q;

  always_comb begin
    // Default assignments
    reuse_cnt_d = reuse_cnt_q;
    data_d = data_q;
    data_strb_d = data_strb_q;
    data_fifo.data = '0;
    data_fifo.strb = '0;   
    
    data_fifo.valid = (reuse_cnt_q == REUSE_FACTOR - 1) ? data_i.valid : 0;
    data_i.ready = data_fifo.ready;

    if(data_i.valid) begin
      data_d[(reuse_cnt_q)*OUTPUT_DATA_WIDTH/REUSE_FACTOR+:INPUT_DATA_WIDTH] = data_i.data;
      data_strb_d[(reuse_cnt_q)*OUTPUT_DATA_WIDTH/REUSE_FACTOR/8+:INPUT_DATA_WIDTH/8] = data_i.strb;
      data_fifo.data = data_d;
      data_fifo.strb = data_strb_d;      
      if (data_fifo.ready) begin
        reuse_cnt_d = reuse_cnt_q + 1;
        if (reuse_cnt_q == REUSE_FACTOR - 1) begin
          reuse_cnt_d = 0;
          data_d = 0;
          data_strb_d = 0;
        end
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      reuse_cnt_q <= '0;
      data_q <= '0;
      data_strb_q <= '0;
    end else begin
      reuse_cnt_q <= reuse_cnt_d;
      data_q <= data_d;
      data_strb_q <= data_strb_d;
    end
  end

  hwpe_stream_fifo #(
    .DATA_WIDTH (OUTPUT_DATA_WIDTH),
    .FIFO_DEPTH (8),
    .LATCH_FIFO (1),
    .LATCH_FIFO_TEST_WRAP (0)
  ) i_data_fifo (
    .clk_i (clk_i),
    .rst_ni(rst_ni),
    .clear_i(1'b0),
    .flags_o(),
    .push_i(data_fifo),
    .pop_o (data_o)
  );

endmodule
