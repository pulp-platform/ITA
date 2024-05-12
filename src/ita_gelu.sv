// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

module ita_gelu
  import ita_package::*;
(
  input  logic           clk_i        ,
  input  logic           rst_ni       ,
  input logic signed [GELU_CONSTANTS_WIDTH-1:0] one_i,
  input logic signed [GELU_CONSTANTS_WIDTH-1:0] b_i,
  input logic signed [GELU_CONSTANTS_WIDTH-1:0] c_i,
  input logic signed [WI-1:0]  data_i,
  output logic signed [GELU_OUT_WIDTH-1:0] data_o
);

  logic signed [GELU_OUT_WIDTH-1:0] data_sign_ext, b_sign_ext;
  logic signed [GELU_OUT_WIDTH-1:0] poly_d, poly_sq;
  logic signed [GELU_OUT_WIDTH-1:0] erf_sgn, erf_abs, erf_clipped, erf_L;
  logic signed [GELU_OUT_WIDTH-1:0] gelu_erf, gelu_sum, gelu_out;

  always_comb begin
    data_sign_ext = {{GELU_OUT_WIDTH-WI{data_clipped[WI-1]}}, data_clipped};
    b_sign_ext = {{GELU_OUT_WIDTH-GELU_CONSTANTS_WIDTH{b_i[GELU_CONSTANTS_WIDTH-1]}}, b_i};
    erf_sgn = data_i < 0 ? -1 : 1;
    erf_abs = data_i < 0 ? -data_sign_ext : data_sign_ext;
    erf_clipped = erf_abs > -b_sign_ext ? -b_sign_ext : erf_abs;

    poly_d = erf_clipped + b_i;
    poly_sq = poly_d * poly_d;

    erf_L = poly_sq + c_i;
    
    gelu_erf = erf_sgn * erf_L;
    gelu_sum = gelu_erf + one_i;
    gelu_out = data_i * gelu_sum;
  end

  assign data_o = gelu_out;

endmodule
