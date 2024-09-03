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
    input requant_mode_e requant_mode_i,
    input requant_const_t requant_mult_i,
    input requant_const_t requant_shift_i,
    input requant_t requant_add_i,
    input activation_e activation_i,
    input logic calc_en_i,
    input logic calc_en_q_i,
    input requant_oup_t  data_i,
    output requant_oup_t data_o
  );

  requant_oup_t data_q1, data_q2;
  activation_e activation_q1, activation_q2;
  oup_t gelu_out, relu_out_sign_ext, requant_in;
  requant_oup_t relu_out, requant_out;

  ita_requantizer i_requantizer (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .mode_i(requant_mode_i),
    .eps_mult_i(requant_mult_i),
    .right_shift_i(requant_shift_i),
    .add_i({N{requant_add_i}}),
    .calc_en_i(calc_en_i),
    .calc_en_q_i(calc_en_q_i),
    .result_i(requant_in),
    .requant_oup_o(requant_out)
  );

  generate
    for (genvar i = 0; i < N; i++) begin: relu_instances
      ita_relu i_relu (
        .data_i(data_q2[i]),
        .data_o(relu_out[i])
      );
      assign relu_out_sign_ext[i] = {{(WO-WI){relu_out[i][WI-1]}}, relu_out[i]};
    end
  endgenerate

  generate
    for (genvar i = 0; i < N; i++) begin: gelu_instances
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
    case (activation_i)
      GELU: begin
        requant_in = gelu_out;
      end
      RELU: begin
        requant_in = relu_out_sign_ext;
      end
      default: begin
        requant_in = '0;
      end
    endcase
  end


  always_comb begin
    case (activation_q2)
      GELU, RELU: begin
        data_o = requant_out;
      end
      default: begin
        data_o = data_q2;
      end
    endcase
  end

  always_ff @(posedge clk_i) begin
    if (rst_ni == 0) begin
      activation_q1 <= IDENTITY;
      activation_q2 <= IDENTITY;
      data_q1 <= '0;
      data_q2 <= '0;
    end else begin
      activation_q1 <= activation_i;
      activation_q2 <= activation_q1;
      data_q1 <= data_i;
      data_q2 <= data_q1;
    end
  end
endmodule