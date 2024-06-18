// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

module ita_gelu
  import ita_package::*;
  (
    input gelu_const_t one_i,
    input gelu_const_t b_i,
    input gelu_const_t c_i,
    input requant_t  data_i,
    output gelu_out_t data_o
  );

  logic erf_sgn;
  gelu_const_t data_sign_ext, erf_abs, erf_clipped, poly_d;
  gelu_out_t erf_L, poly_sq, gelu_erf, gelu_sum, gelu_out;

  always_comb begin
    data_sign_ext = {{GELU_CONSTANTS_WIDTH-WI{data_i[WI-1]}}, data_i};

    erf_sgn = data_i < 0;
    erf_abs = erf_sgn ? -data_sign_ext : data_sign_ext;
    erf_clipped = erf_abs > -b_i ? -b_i : erf_abs;

    poly_d = erf_clipped + b_i;
    poly_sq = poly_d * poly_d;

    erf_L = poly_sq + c_i;

    gelu_erf = erf_sgn ? -erf_L : erf_L;
    gelu_sum = gelu_erf + one_i;
    gelu_out = data_i * gelu_sum;
  end

  assign data_o = gelu_out;

endmodule
