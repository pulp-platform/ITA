// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

module ita_activation
  import ita_package::*;
  (
    input logic clk_i,
    input logic rst_ni,
    input gelu_const_t one_i,
    input gelu_const_t b_i,
    input gelu_const_t c_i,
    input logic requant_mode,
    input requant_const_t requant_mult_i,
    input requant_const_t requant_shift_i,
    input requant_const_t requant_add_i,
    input activation_e activation_i,
    input requant_oup_t  data_i,
    output requant_oup_t data_o
  );

  requant_oup_t gelu_out, relu_out;

  generate
    for (genvar i = 0; i < N; i++) begin: relu_loop
      ita_relu i_relu (
        .data_i(data_i[i]),
        .data_o(relu_out[i])
      );
    end
  endgenerate

  generate
    for (genvar i = 0; i < N; i++) begin: gelu_loop
      ita_gelu i_gelu (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .one_i(one_i),
        .b_i(b_i),
        .c_i(c_i),
        .data_i(data_i[i]),
        .eps_mult_i(eps_mult_i),
        .right_shift_i(right_shift_i),
        .add_i(add_i),
        .data_o(gelu_out[i])
      );
    end
  endgenerate


  always_comb begin
    if (activation_i == IDENTITY) begin
      data_o = data_i;
    end else if (activation_i == RELU) begin
      data_o = relu_out;
    end else if (activation_i == GELU) begin
      data_o = gelu_out;
    end
  end

endmodule