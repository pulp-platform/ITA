// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

module ita_gelu
  import ita_package::*;
  (
    input logic clk_i,
    input logic rst_ni,
    input gelu_const_t one_i,
    input gelu_const_t b_i,
    input gelu_const_t c_i,
    input requant_t  data_i,
    output gelu_out_t data_o
  );

  logic erf_sgn_d, erf_sgn_q1;
  gelu_const_t one_q1, c_q1;
  gelu_const_t data_sign_ext, erf_abs, erf_clipped, poly_d;
  gelu_out_t erf_L_q1, gelu_erf_q1, gelu_sum_q1;
  gelu_out_t gelu_out_q1, gelu_out_q2;
  gelu_out_t poly_sq_d, poly_sq_q1;
  requant_t data_q1;

  always_comb begin
    // First pipeline stage
    data_sign_ext = {{GELU_CONSTANTS_WIDTH-WI{data_i[WI-1]}}, data_i};

    erf_sgn_d = data_i < 0;
    erf_abs = erf_sgn_d ? -data_sign_ext : data_sign_ext;
    erf_clipped = erf_abs > -b_i ? -b_i : erf_abs;

    poly_d = erf_clipped + b_i;
    poly_sq_d = poly_d * poly_d;

    // Second pipeline stage
    erf_L_q1 = poly_sq_q1 + c_q1;

    gelu_erf_q1 = erf_sgn_q1 ? -erf_L_q1 : erf_L_q1;
    gelu_sum_q1 = gelu_erf_q1 + one_q1;
    gelu_out_q1 = data_q1 * gelu_sum_q1;
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      one_q1 <= '0;
      c_q1 <= '0;
      data_q1 <= '0;
      erf_sgn_q1 <= '0;
      poly_sq_q1 <= '0;
      gelu_out_q2 <= '0;
    end else begin
      one_q1 <= one_i;
      c_q1 <= c_i;
      data_q1 <= data_i;
      erf_sgn_q1 <= erf_sgn_d;
      poly_sq_q1 <= poly_sq_d;
      gelu_out_q2 <= gelu_out_q1;
    end
  end

  assign data_o = gelu_out_q2;

endmodule
