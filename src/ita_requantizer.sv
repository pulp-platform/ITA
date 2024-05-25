// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51


module ita_requantizer
  import ita_package::*;
(
  input  logic           clk_i        ,
  input  logic           rst_ni       ,
  input  requant_mode_e  mode_i       ,
  input  requant_const_t eps_mult_i   ,
  input  requant_const_t right_shift_i,
  input  logic           calc_en_i    ,
  input  logic           calc_en_q_i  ,
  input  oup_t           result_i     ,
  input  requant_oup_t   add_i        ,
  output requant_oup_t   requant_oup_o
);

  logic signed [      WO:0]             mult_signed  ;
  logic signed [EMS+WO:0]               product      ;
  logic signed [EMS+WO:0]               shifted_added;
  logic signed [     N-1:0][EMS+WO-1:0] shifted_d, shifted_q;
  requant_oup_t                         add_q1, requant_oup_d, requant_oup_q;

  assign requant_oup_o   = requant_oup_q;


  always_comb begin
    shifted_d     = '0;
    requant_oup_d = '0;
    product       = '0;
    shifted_added = '0;

    for (int i = 0; i < N; i++) begin
      if (mode_i === UNSIGNED) begin
        mult_signed = {1'b0, result_i[i]};
      end else begin
        mult_signed = signed'(result_i[i]);
      end
      if (calc_en_i) begin
        product = signed'({1'b0,eps_mult_i}) * signed'(mult_signed);
        shifted_d[i] = product >>> right_shift_i;

        // Perform rounding half away from zero
        if ( (right_shift_i > 0) & (product[right_shift_i-1]) ) begin
          shifted_d[i] = (product >>> right_shift_i) + 1;
        end
      end
      if (calc_en_q_i) begin
        shifted_added    = shifted_q[i] + (EMS+WO)'(signed'(add_q1[i]));
        requant_oup_d[i] = shifted_added[WI-1:0];
        if (~shifted_added[EMS+WO-1] & (|(shifted_added[EMS+WO-2:WI-1]))) begin
          requant_oup_d[i]       = '1;
          requant_oup_d[i][WI-1] = 1'b0; // sat+
        end
        else if (shifted_added[EMS+WO-1] & (|(~shifted_added[EMS+WO-2:WI-1]))) begin
          requant_oup_d[i]       = '0;
          requant_oup_d[i][WI-1] = 1'b1; // sat-
        end
      end
    end
  end

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      shifted_q     <= '0;
      requant_oup_q <= '0;
    end else begin
      shifted_q     <= shifted_d;
      requant_oup_q <= requant_oup_d;
    end
  end

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      add_q1         <= '0;
    end else begin
      add_q1         <= add_i;
    end
  end
endmodule
