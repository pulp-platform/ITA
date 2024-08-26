// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51


module ita_inp2_mux
  import ita_package::*;
(
  input  logic         clk_i         ,
  input  logic         rst_ni        ,
  input  logic         calc_en_i     ,
  input  weight_t      weight_i  ,
  output weight_t      inp2_o
);

  always_comb begin
    inp2_o = '0;

    if (calc_en_i) begin
      inp2_o = weight_i;
    end
  end

 endmodule



