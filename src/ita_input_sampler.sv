// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51


module ita_input_sampler
  import ita_package::*;
(
  input  logic        clk_i       ,
  input  logic        rst_ni      ,
  input  logic        valid_i     ,
  input  logic        ready_i     ,
  input  inp_t        inp_i       ,
  input  bias_t       inp_bias_i  ,
  output inp_t        inp_o       ,
  output bias_t       inp_bias_o
);

  inp_t        inp_d, inp_q;
  bias_t       bias_d, bias_q;

  assign inp_o        = inp_q;
  assign inp_bias_o   = bias_q;

  always_comb begin
    inp_d    = inp_q;
    bias_d   = bias_q;
    if (valid_i && ready_i) begin
      inp_d    = inp_i;
      bias_d   = inp_bias_i;
    end
  end

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      inp_q    <= '0;
      bias_q   <= '0;
    end else begin
      inp_q    <= inp_d;
      bias_q   <= bias_d;
    end
  end

endmodule
