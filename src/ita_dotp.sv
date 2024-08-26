// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51


/**
  DotP submodule.
  Calculates the dot product of two 8-bit vector of size M.
  */

module ita_dotp #(
    parameter integer M  = 64,
    parameter integer WI = 8,
    parameter integer WO = 26,
    parameter integer WS = WI + 1
) (
    input  logic signed [WS*M-1:0]     inp1_i,
    input  logic signed [WI*M-1:0]     inp2_i,
    output logic signed [  WO-1:0]     oup_o
);

    logic signed [WO-1:0] int_dotp[0:M-1]; // intermediate dotproducts

    assign int_dotp[0] = signed'(inp1_i[0 +: WS]) * signed'(inp2_i[0 +: WI]);

    generate
        for (genvar i = 1; i < M; i = i + 1) begin: dotp_loop
            assign int_dotp[i] = signed'(int_dotp[i-1]) + signed'(inp1_i[WS*i +: WS]) * signed'(inp2_i[WI*i +: WI]);
        end
    endgenerate

    assign oup_o = int_dotp[M-1];

endmodule
