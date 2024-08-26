// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// Author: Gamze Islamoglu <gislamoglu@iis.ee.ethz.ch>

import ita_hwpe_package::*;

module ita_hwpe_engine
(
  // global signals
  input  logic                   clk_i,
  input  logic                   rst_ni,
  input  logic                   test_mode_i,
  // input a stream
  hwpe_stream_intf_stream.sink   input_i,
  // input b stream
  hwpe_stream_intf_stream.sink   weight_i,
  // input c stream
  hwpe_stream_intf_stream.sink   bias_i,
  // output d stream
  hwpe_stream_intf_stream.source output_o,
  // control channel
  input  ctrl_engine_t           ctrl_i,
  output flags_engine_t          flags_o
);


  ita i_ita (
    .clk_i             (clk_i           ),
    .rst_ni            (rst_ni          ),
    .ctrl_i            (ctrl_i          ),
    .inp_valid_i       (input_i.valid   ),
    .inp_ready_o       (input_i.ready   ),
    .inp_weight_valid_i(weight_i.valid  ),
    .inp_weight_ready_o(weight_i.ready  ),
    .inp_bias_valid_i  (bias_i.valid    ),
    .inp_bias_ready_o  (bias_i.ready    ),
    .inp_i             (input_i.data    ),
    .inp_weight_i      (weight_i.data   ),
    .inp_bias_i        (bias_i.data     ),
    .oup_o             (output_o.data   ),
    .valid_o           (output_o.valid  ),
    .ready_i           (output_o.ready  ),
    .busy_o            (flags_o.busy    )
  );

  assign output_o.strb = {(ITA_OUTPUT_DW/8){1'b1}};

endmodule : ita_hwpe_engine
