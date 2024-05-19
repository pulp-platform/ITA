// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51


module ita_fifo_controller
  import ita_package::*;
(
  input  logic         clk_i         ,
  input  logic         rst_ni        ,
  input  requant_oup_t requant_oup_i ,
  input  logic         preactivation_requantizer_done_i       ,
  input  logic         fifo_full_i   ,
  input activation_e activation_i,
  output logic         push_to_fifo_o,
  output fifo_data_t   data_to_fifo_o
);

  logic is_activation_requantized, is_activation_done;
  logic preactivation_requantizer_done_q, postactivation_requantizer_done_q;

  assign is_activation_requantized = activation_i === GELU;
  assign is_activation_done =  (is_activation_requantized && postactivation_requantizer_done_q) || (!is_activation_requantized && preactivation_requantizer_done_i);

  always_comb begin
    push_to_fifo_o = 0;
    data_to_fifo_o = '0;
    if (is_activation_done) begin
      push_to_fifo_o = 1;
      data_to_fifo_o = {>>WI{requant_oup_i}};
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      preactivation_requantizer_done_q <= 0;
      postactivation_requantizer_done_q <= 0;
    end else begin
      preactivation_requantizer_done_q <= preactivation_requantizer_done_i;
      postactivation_requantizer_done_q <= preactivation_requantizer_done_q;
    end
  end
 endmodule
