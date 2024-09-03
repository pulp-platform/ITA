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

  requant_oup_t data_q1, data_q2;
  activation_e activation_q1, activation_q2;
  gelu_out_t [N-1:0] gelu_out;
  requant_oup_t gelu_out_requant;
  requant_oup_t relu_out;

  ita_requantizer i_requantizer (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .mode_i(requant_mode),
    .eps_mult_i(requant_mult_i),
    .right_shift_i(requant_shift_i),
    .add_i({N{requant_add_i}}),
    .calc_en_i(1'b1),
    .calc_en_q_i(1'b1),
    .result_i(gelu_out),
    .requant_oup_o(gelu_out_requant)
  );

  generate
    for (genvar i = 0; i < N; i++) begin: relu_loop
      ita_relu i_relu (
        .data_i(data_q2[i]),
        .data_o(relu_out[i])
      );
    end
  endgenerate

  generate
    for (genvar i = 0; i < N; i++) begin: gelu_loop
      ita_gelu i_gelu (
        .one_i(one_i),
        .b_i(b_i),
        .c_i(c_i),
        .data_i(data_i[i]),
        .data_o(gelu_out[i])
      );
    end
  endgenerate


  always_comb begin
    if (activation_q2 == IDENTITY) begin
      data_o = data_q2;
    end else if (activation_q2 == RELU) begin
      data_o = relu_out;
    end else if (activation_q2 == GELU) begin
      data_o = gelu_out_requant;
    end
  end

  // Delay data for IDENTITY and RELU activations which are not requantized
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      data_q1 <= '0;
      data_q2 <= '0;
      activation_q1 <= IDENTITY;
      activation_q2 <= IDENTITY;
    end else begin
      data_q1 <= data_i;
      data_q2 <= data_q1;
      activation_q1 <= activation_i;
      activation_q2 <= activation_q1;
    end
  end
endmodule