// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51


module ita_output_controller
  import ita_package::*;
(
  input  logic            clk_i             ,
  input  logic            rst_ni            ,
  input  logic            fifo_empty_i      ,
  output logic            pop_from_fifo_o   ,
  input  fifo_data_t      data_from_fifo_i  ,
  input  logic            ready_i           ,
  output logic            valid_o
);

  always_comb begin
    // Default assignments

    pop_from_fifo_o = 0;
    valid_o         = 0;

    if (!fifo_empty_i) begin
      valid_o         = 1;
      if (ready_i) begin
        pop_from_fifo_o = 1'b1;
      end
    end
  end

endmodule



