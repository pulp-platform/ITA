// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

module ita_relu
  import ita_package::*;
  (
    input requant_t  data_i,
    output requant_t data_o
  );

  assign data_o = data_i > 0 ? data_i : 0;

endmodule