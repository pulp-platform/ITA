// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

/**
  * Synchronous Reset Generator
  *
  * Generates reset signals synchronous to a reference clock.  The resets are asserted after
  * initialization or when the external active-low reset is asserted.  Once asserted, the resets
  * are deasserted after a configurable number of cycles of the reference clock.
  *
  * Maintainer: VLSI I Assistants <vlsi1@iis.ee.ethz.ch>
  */

module rst_gen #(
    parameter integer RST_CLK_CYCLES
) (
    input  logic clk_i,     // Reference clock
    input  logic rst_ni,    // External active-low reset
    output logic rst_o,     // Active-high reset output
    output logic rst_no     // Active-low reset output
);

    // Define signals.
    logic [$clog2(RST_CLK_CYCLES+1)-1:0]    cnt_d,          cnt_q;
    logic                                   rst_d,          rst_q;

    // Increment counter until the configured number of clock cycles is reached.
    always_comb begin
        cnt_d = cnt_q;
        if (cnt_q < RST_CLK_CYCLES) begin
            cnt_d += 1;
        end
    end

    // Deassert reset after the configured number of clock cycles is reached.
    assign rst_d = (cnt_q >= RST_CLK_CYCLES) ? 1'b0 : 1'b1;

    // Drive reset outputs directly from register
    assign rst_o    = rst_q;
    assign rst_no   = ~rst_q;

    // Infer rising-edge-triggered synchronous-(re)set FFs for the counter and reset register.
    always @(posedge clk_i) begin
        if (~rst_ni) begin
            cnt_q <= '0;
            rst_q <= 1'b1;
        end else begin
            cnt_q <= cnt_d;
            rst_q <= rst_d;
        end
    end

    // Define initial values for FFs on the FPGA.
    initial begin
        cnt_q = '0;
        rst_q = 1'b1;
    end

endmodule
