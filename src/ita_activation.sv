// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

module ita_activation
  import ita_package::*;
  (
    input logic clk_i,
    input logic rst_ni,
    input gelu_const_t b_i,
    input gelu_const_t c_i,
    input requant_mode_e requant_mode_i,
    input requant_const_t requant_mult_i,
    input requant_const_t requant_shift_i,
    input requant_t requant_add_i,
    input activation_e activation_i,
    input activation_e activation_q2_i,
    input logic calc_en_i,
    input logic calc_en_q_i,
    input requant_oup_t  data_i,
    output requant_oup_t data_o
  );

  requant_oup_t data_q1, data_q2, data_q3, data_q4;
  activation_e activation_q3, activation_q4;
  oup_t gelu_out, requant_in;
  requant_oup_t relu_out, requant_out;
  logic calc_en_q2, calc_en_q3;

  ita_requantizer i_requantizer (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .mode_i(requant_mode_i),
    .eps_mult_i(requant_mult_i),
    .right_shift_i(requant_shift_i),
    .add_i({N{requant_add_i}}),
    .calc_en_i(calc_en_q2),
    .calc_en_q_i(calc_en_q3),
    .result_i(requant_in),
    .requant_oup_o(requant_out)
  );

  generate
    for (genvar i = 0; i < N; i++) begin: relu_instances
      ita_relu i_relu (
        .data_i((calc_en_q2 && activation_q2_i == Relu) ? data_q2[i] : '0),
        .data_o(relu_out[i])
      );
    end
  endgenerate

  generate
    for (genvar i = 0; i < N; i++) begin: gelu_instances
      ita_gelu i_gelu (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .b_i(b_i),
        .c_i(c_i),
        .calc_en_i(calc_en_i),
        .calc_en_q_i(calc_en_q_i),
        .data_i((calc_en_i && activation_i == Gelu) ? data_i[i] : '0),
        .data_o(gelu_out[i])
      );
    end
  endgenerate

  always_comb begin
    case (activation_q2_i)
      Gelu: begin
        requant_in = gelu_out;
      end
      Relu: begin
        for (int i = 0; i < N; i++) begin
          requant_in[i] = {{(WO-WI){relu_out[i][WI-1]}}, relu_out[i]};
        end
      end
      default: begin
        requant_in = '0;
      end
    endcase
  end


  always_comb begin
    case (activation_q4)
      Gelu, Relu: begin
        data_o = requant_out;
      end
      default: begin
        data_o = data_q4;
      end
    endcase
  end

  always_ff @(posedge clk_i) begin
    if (rst_ni == 0) begin
      activation_q3 <= Identity;
      activation_q4 <= Identity;
      data_q1 <= '0;
      data_q2 <= '0;
      data_q3 <= '0;
      data_q4 <= '0;
      calc_en_q2 <= 0;
      calc_en_q3 <= 0;
    end else begin
      activation_q3 <= activation_q2_i;
      activation_q4 <= activation_q3;
      data_q1 <= data_i;
      data_q2 <= data_q1;
      data_q3 <= data_q2;
      data_q4 <= data_q3;
      calc_en_q2 <= calc_en_q_i;
      calc_en_q3 <= calc_en_q2;
    end
  end
endmodule