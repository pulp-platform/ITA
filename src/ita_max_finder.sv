// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

module ita_max_finder
  import ita_package::*;
(
  input  logic         clk_i     ,
  input  logic         rst_ni    ,
  // Input
  input  requant_oup_t x_i       ,
  input  requant_t     prev_max_i,
  output requant_t     max_o     ,
  output requant_t     max_diff_o
);

  // find maximum
  requant_t [N/2-1:0] max_tmp;
  requant_t [N/4-1:0] max_tmp2;
  requant_t [N/8-1:0] max_tmp3;
  requant_t max_tmp4;

  always_comb begin

    for (int i = 0; i < N/2; i++) begin
      if (x_i[2*i]>x_i[2*i+1])
        max_tmp[i] = x_i[2*i];
      else
        max_tmp[i] = x_i[2*i+1];
    end

    for (int i = 0; i < N/4; i++) begin
      if (max_tmp[2*i]>max_tmp[2*i+1])
        max_tmp2[i] = max_tmp[2*i];
      else
        max_tmp2[i] = max_tmp[2*i+1];
    end

    for (int i = 0; i < N/8; i++) begin
      if (max_tmp2[2*i]>max_tmp2[2*i+1])
        max_tmp3[i] = max_tmp2[2*i];
      else
        max_tmp3[i] = max_tmp2[2*i+1];
    end

    if (max_tmp3[0]>max_tmp3[1])
      max_tmp4 = max_tmp3[0];
    else
      max_tmp4 = max_tmp3[1];

    if (prev_max_i>max_tmp4) begin
      max_o = prev_max_i;
      max_diff_o = '0;
    end else begin
      max_o = max_tmp4;
      max_diff_o = max_o-prev_max_i;
    end

  end

endmodule
