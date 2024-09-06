// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51


module ita_requatization_controller
  import ita_package::*;
(
  input step_e requantizer_step_i,
  input ctrl_t ctrl_i,
  output requant_const_t requant_mult_o,
  output requant_const_t requant_shift_o,
  output requant_t requant_add_o,
  output requant_mode_e requant_mode_o,
  output requant_const_t activation_requant_mult_o,
  output requant_const_t activation_requant_shift_o,
  output requant_t activation_requant_add_o,
  output requant_mode_e activation_requant_mode_o
);
  logic [$clog2(N_REQUANT_CONSTS)-1:0] constant_idx;

  always_comb begin
    case (requantizer_step_i)
      Q: constant_idx = 0;
      K: constant_idx = 1;
      V: constant_idx = 2;
      QK: constant_idx = 3;
      AV: constant_idx = 4;
      OW: constant_idx = 5;
      F1: constant_idx = 6;
      F2: constant_idx = 7;
      default: constant_idx = 0;
    endcase
  end

  assign requant_mult_o = ctrl_i.eps_mult[constant_idx];
  assign requant_shift_o = ctrl_i.right_shift[constant_idx];
  assign requant_add_o = ctrl_i.add[constant_idx];
  assign activation_requant_mult_o = ctrl_i.activation_requant_mult;
  assign activation_requant_shift_o = ctrl_i.activation_requant_shift;
  assign activation_requant_add_o = ctrl_i.activation_requant_add;
  assign requant_mode_o = requant_mode_e'(REQUANT_MODE);
  assign activation_requant_mode_o = requant_mode_e'(REQUANT_MODE);
 endmodule
