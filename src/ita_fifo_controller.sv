// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51


module ita_fifo_controller
  import ita_package::*;
(
  input  logic         clk_i         ,
  input  logic         rst_ni        ,
  input  requant_oup_t requant_oup_i ,
  input  logic         requantizer_done       ,
  input  logic         fifo_full_i   ,
  output logic         push_to_fifo_o,
  output fifo_data_t   data_to_fifo_o
);

  logic requantizer_done_q, activation_done;

  always_comb begin
    push_to_fifo_o = 0;
    data_to_fifo_o = '0;
    if (&activation_done) begin
      push_to_fifo_o = 1;
      data_to_fifo_o = {>>WI{requant_oup_i}};
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      requantizer_done_q <= 0;
      activation_done <= 0;
    end else begin
      requantizer_done_q <= requantizer_done;
      activation_done <= requantizer_done_q;
    end
  end
 endmodule
