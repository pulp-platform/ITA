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
    input requant_t  data_i,
    input logic signed [EMS-1:0] eps_mult_i,
    input logic signed [EMS-1:0] right_shift_i,
    input requant_t add_i,
    output requant_t data_o
  );

  localparam requant_t LOWER_BOUND = -2**(WI-1) + 1;

  requant_t data_clipped;
  logic signed [GELU_PRE_RQS_WIDTH-1:0] data_sign_ext, b_sign_ext;
  logic signed [GELU_PRE_RQS_WIDTH-1:0] poly_d, poly_sq;
  logic signed [GELU_PRE_RQS_WIDTH-1:0] erf_sgn, erf_abs, erf_clipped, erf_L;
  logic signed [GELU_PRE_RQS_WIDTH-1:0] gelu_erf, gelu_sum, gelu_out;
  logic signed [GELU_PRE_RQS_WIDTH+EMS-1:0] product;
  logic signed [GELU_PRE_RQS_WIDTH+EMS-1:0] shifted;
  logic signed [GELU_PRE_RQS_WIDTH+EMS-1:0] shifted_added;
  requant_t result;

  always_comb begin
    data_clipped = data_i < LOWER_BOUND ? LOWER_BOUND : data_i;
    data_sign_ext = {{GELU_PRE_RQS_WIDTH-WI{data_clipped[WI-1]}}, data_clipped};
    b_sign_ext = {{GELU_PRE_RQS_WIDTH-GELU_CONSTANTS_WIDTH{b_i[GELU_CONSTANTS_WIDTH-1]}}, b_i};

    erf_sgn = data_i < 0 ? -1 : 1;
    erf_abs = data_i < 0 ? -data_sign_ext : data_sign_ext;
    erf_clipped = erf_abs > -b_sign_ext ? -b_sign_ext : erf_abs;

    poly_d = erf_clipped + b_i;
    poly_sq = poly_d * poly_d;

    erf_L = poly_sq + c_i;

    gelu_erf = erf_sgn * erf_L;
    gelu_sum = gelu_erf + one_i;
    gelu_out = data_i * gelu_sum;

    product = signed'(gelu_out) * signed'(eps_mult_i);
    shifted = product >>> right_shift_i;

    // Perform rounding half away from zero
    if ( (right_shift_i > 0) & (product[right_shift_i-1]) ) begin
      shifted += 1;
    end
    shifted_added = shifted + (GELU_PRE_RQS_WIDTH+EMS)'(signed'(add_i));
    result = shifted_added[WI-1:0];

    // Check for saturation
    if (~shifted_added[GELU_PRE_RQS_WIDTH+EMS-1] & (|(shifted_added[GELU_PRE_RQS_WIDTH+EMS-2:WI-1]))) begin
      result = '1;
      result[WI-1] = 1'b0; // sat+
    end
    else if (shifted_added[GELU_PRE_RQS_WIDTH+EMS-1] & (|(~shifted_added[GELU_PRE_RQS_WIDTH+EMS-2:WI-1]))) begin
      result = '0;
      result[WI-1] = 1'b1; // sat-
    end
  end

  assign data_o = result;

endmodule
