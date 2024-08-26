// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

/**
  SumDotP module.
  Calculates N number of dot products of two 8-bit vector of size M.
  */

 module ita_sumdotp
    import ita_package::*;
 (
     input  logic                                  sign_mode_i,
     input  logic  signed [N-1:0] [M-1:0] [WI-1:0] inp1_i,
     input  logic  signed [N-1:0] [M-1:0] [WI-1:0] inp2_i,
     output logic  signed [N-1:0] [WO-1:0]         oup_o
 );

    logic [N-1:0] [M-1:0] [(WI+1)-1:0] inp1;

    always_comb begin
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < M; j++) begin
                if (sign_mode_i == 1'b1) begin
                    inp1[i][j] = {inp1_i[i][j][WI-1], inp1_i[i][j]};                    
                end else begin
                    inp1[i][j] = {              1'b0, inp1_i[i][j]};
                end
            end
        end
    end

    generate for (genvar i = 0; i < N; i++) begin: calculate_dotp
        ita_dotp #(
            .M (M ),
            .WI(WI),
            .WO(WO)
        ) i_dotp (
            .inp1_i  (inp1   [i] ),
            .inp2_i  (inp2_i [i] ),
            .oup_o   (oup_o  [i] )
        );
    end endgenerate

 endmodule
