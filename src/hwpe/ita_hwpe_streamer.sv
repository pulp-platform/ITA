// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// Author: Gamze Islamoglu <gislamoglu@iis.ee.ethz.ch>

`include "hci_helpers.svh"

import ita_hwpe_package::*;
import ita_package::M;
import ita_package::N;
import hwpe_stream_package::*;
import hci_package::*;

module ita_hwpe_streamer #(
  parameter int unsigned  TCDM_DW = 32,
  localparam int unsigned REALIGN = 0
) (
  // global signals
  input  logic                   clk_i,
  input  logic                   rst_ni,
  input  logic                   test_mode_i,
  // local enable & clear
  input  logic                   enable_i,
  input  logic                   clear_i,
  // input stream + handshake
  hwpe_stream_intf_stream.source input_o,
  // input weight stream + handshake
  hwpe_stream_intf_stream.source weight_o,
  // input bias stream + handshake
  hwpe_stream_intf_stream.source bias_o,
  // output stream + handshake
  hwpe_stream_intf_stream.sink   output_i,
  // TCDM ports
  hci_core_intf.initiator        tcdm_o,
  // control channel
  input  ctrl_streamer_t         ctrl_i,
  output flags_streamer_t        flags_o,
  output flags_fifo_t [1:0]      flags_fifo_o
);

  // Multiplex TCDM ports (input, weight, output)
  localparam hci_size_parameter_t `HCI_SIZE_PARAM(tcdm_dw) = '{
    DW:  ITA_TCDM_DW,
    AW:  DEFAULT_AW,
    BW:  DEFAULT_BW,
    UW:  DEFAULT_UW,
    IW:  ID_WIDTH,
    EW:  DEFAULT_EW,
    EHW: DEFAULT_EHW
  };
  `HCI_INTF_EXPLICIT_PARAM(tcdm_input, clk_i, HCI_SIZE_tcdm_dw);
  `HCI_INTF_EXPLICIT_PARAM(tcdm_weight, clk_i, HCI_SIZE_tcdm_dw);
  `HCI_INTF_EXPLICIT_PARAM(tcdm_bias, clk_i, HCI_SIZE_tcdm_dw);
  `HCI_INTF_EXPLICIT_PARAM(tcdm_output, clk_i, HCI_SIZE_tcdm_dw);

  localparam hci_size_parameter_t `HCI_SIZE_PARAM(virt_tcdm) = '{
    DW:  ITA_TCDM_DW,
    AW:  DEFAULT_AW,
    BW:  DEFAULT_BW,
    UW:  DEFAULT_UW,
    IW:  ID_WIDTH,
    EW:  DEFAULT_EW,
    EHW: DEFAULT_EHW
  };
  `HCI_INTF_ARRAY(virt_tcdm, clk_i, 0:3);

  `HCI_INTF_EXPLICIT_PARAM(ldst_tcdm, clk_i, HCI_SIZE_tcdm_dw); // IW=2?

  hci_core_assign i_load_input_assign   ( .tcdm_target (tcdm_input),  .tcdm_initiator (virt_tcdm[0]) );
  hci_core_assign i_load_weight_assign  ( .tcdm_target (tcdm_weight), .tcdm_initiator (virt_tcdm[1]) );
  hci_core_assign i_load_bias_assign    ( .tcdm_target (tcdm_bias),   .tcdm_initiator (virt_tcdm[2]) );
  hci_core_assign i_store_output_assign ( .tcdm_target (tcdm_output), .tcdm_initiator (virt_tcdm[3]) );

  hci_core_mux_ooo #(
    .NB_CHAN ( 4 ),
    .`HCI_SIZE_PARAM(out) ( `HCI_SIZE_PARAM(tcdm_dw) )
  ) i_ldst_mux (
    .clk_i            ( clk_i     ),
    .rst_ni           ( rst_ni    ),
    .clear_i          ( clear_i   ),
    .priority_force_i ( 1'b0      ),
    .priority_i       ( {2'h2,2'h3,2'h0,2'h1} ), // weight > input > output > bias
    .in               ( virt_tcdm ),
    .out              ( ldst_tcdm )
  );

  // Read request has to be served within 1 cycle
  hci_core_r_id_filter #(
    .`HCI_SIZE_PARAM(tcdm_target) ( `HCI_SIZE_PARAM(tcdm_dw) )
  ) i_ldst_filter (
    .clk_i          ( clk_i     ),
    .rst_ni         ( rst_ni    ),
    .clear_i        ( clear_i   ),
    .enable_i       ( enable_i  ),
    .tcdm_target    ( ldst_tcdm ),
    .tcdm_initiator ( tcdm_o    )
  );

  // Defined explicitly to waive the assertion

  // `HCI_INTF_EXPLICIT_PARAM(tcdm_input_fifo, clk_i, HCI_SIZE_tcdm_dw);
  // `HCI_INTF_EXPLICIT_PARAM(tcdm_weight_fifo, clk_i, HCI_SIZE_tcdm_dw);
  // `HCI_INTF_EXPLICIT_PARAM(tcdm_bias_fifo, clk_i, HCI_SIZE_tcdm_dw);
  // `HCI_INTF_EXPLICIT_PARAM(tcdm_output_fifo, clk_i, HCI_SIZE_tcdm_dw);

  hci_core_intf #(
  `ifndef SYNTHESIS
    .WAIVE_RQ4_ASSERT (    1'b1 ),
  `endif
    .DW  ( HCI_SIZE_tcdm_dw.DW  ),
    .AW  ( HCI_SIZE_tcdm_dw.AW  ),
    .BW  ( HCI_SIZE_tcdm_dw.BW  ),
    .UW  ( HCI_SIZE_tcdm_dw.UW  ),
    .IW  ( HCI_SIZE_tcdm_dw.IW  ),
    .EW  ( HCI_SIZE_tcdm_dw.EW  ),
    .EHW ( HCI_SIZE_tcdm_dw.EHW )
  ) tcdm_input_fifo (
    .clk ( clk_i )
  ); 

  hci_core_intf #(
  `ifndef SYNTHESIS
    .WAIVE_RQ4_ASSERT (    1'b1 ),
  `endif
    .DW  ( HCI_SIZE_tcdm_dw.DW  ),
    .AW  ( HCI_SIZE_tcdm_dw.AW  ),
    .BW  ( HCI_SIZE_tcdm_dw.BW  ),
    .UW  ( HCI_SIZE_tcdm_dw.UW  ),
    .IW  ( HCI_SIZE_tcdm_dw.IW  ),
    .EW  ( HCI_SIZE_tcdm_dw.EW  ),
    .EHW ( HCI_SIZE_tcdm_dw.EHW )
  ) tcdm_weight_fifo (
    .clk ( clk_i )
  );

  hci_core_intf #(
  `ifndef SYNTHESIS
    .WAIVE_RQ4_ASSERT (    1'b1 ),
  `endif
    .DW  ( HCI_SIZE_tcdm_dw.DW  ),
    .AW  ( HCI_SIZE_tcdm_dw.AW  ),
    .BW  ( HCI_SIZE_tcdm_dw.BW  ),
    .UW  ( HCI_SIZE_tcdm_dw.UW  ),
    .IW  ( HCI_SIZE_tcdm_dw.IW  ),
    .EW  ( HCI_SIZE_tcdm_dw.EW  ),
    .EHW ( HCI_SIZE_tcdm_dw.EHW )
  ) tcdm_bias_fifo (
    .clk ( clk_i )
  );

  hci_core_intf #(
  `ifndef SYNTHESIS
    .WAIVE_RQ4_ASSERT (    1'b1 ),
  `endif
    .DW  ( HCI_SIZE_tcdm_dw.DW  ),
    .AW  ( HCI_SIZE_tcdm_dw.AW  ),
    .BW  ( HCI_SIZE_tcdm_dw.BW  ),
    .UW  ( HCI_SIZE_tcdm_dw.UW  ),
    .IW  ( HCI_SIZE_tcdm_dw.IW  ),
    .EW  ( HCI_SIZE_tcdm_dw.EW  ),
    .EHW ( HCI_SIZE_tcdm_dw.EHW )
  ) tcdm_output_fifo (
    .clk ( clk_i )
  );

  // source and sink modules
  hci_core_source       #(
    .MISALIGNED_ACCESSES ( REALIGN ),
    .`HCI_SIZE_PARAM(tcdm) ( `HCI_SIZE_PARAM(tcdm_dw) )
  ) i_input_stream_source (
    .clk_i       ( clk_i                      ),
    .rst_ni      ( rst_ni                     ),
    .test_mode_i ( test_mode_i                ),
    .clear_i     ( clear_i                    ),
    .enable_i    ( enable_i                   ),
    .tcdm        ( tcdm_input_fifo            ),
    .stream      ( input_o                    ),
    .ctrl_i      ( ctrl_i.input_source_ctrl   ),
    .flags_o     ( flags_o.input_source_flags )
  );

  hci_core_source       #(
    .MISALIGNED_ACCESSES ( REALIGN ),
    .`HCI_SIZE_PARAM(tcdm) ( `HCI_SIZE_PARAM(tcdm_dw) )
  ) i_weight_stream_source (
    .clk_i       ( clk_i                       ),
    .rst_ni      ( rst_ni                      ),
    .test_mode_i ( test_mode_i                 ),
    .clear_i     ( clear_i                     ),
    .enable_i    ( enable_i                    ),
    .tcdm        ( tcdm_weight_fifo            ),
    .stream      ( weight_o                    ),
    .ctrl_i      ( ctrl_i.weight_source_ctrl   ),
    .flags_o     ( flags_o.weight_source_flags )
  );

  hci_core_source       #(
    .MISALIGNED_ACCESSES ( REALIGN ),
    .`HCI_SIZE_PARAM(tcdm) ( `HCI_SIZE_PARAM(tcdm_dw) )
  ) i_bias_stream_source (
    .clk_i       ( clk_i                     ),
    .rst_ni      ( rst_ni                    ),
    .test_mode_i ( test_mode_i               ),
    .clear_i     ( clear_i                   ),
    .enable_i    ( enable_i                  ),
    .tcdm        ( tcdm_bias_fifo            ),
    .stream      ( bias_o                    ),
    .ctrl_i      ( ctrl_i.bias_source_ctrl   ),
    .flags_o     ( flags_o.bias_source_flags )
  );

  hci_core_sink #(
    .MISALIGNED_ACCESSES ( REALIGN ),
    .`HCI_SIZE_PARAM(tcdm) ( `HCI_SIZE_PARAM(tcdm_dw) )
  ) i_output_stream_sink (
    .clk_i       ( clk_i                     ),
    .rst_ni      ( rst_ni                    ),
    .test_mode_i ( test_mode_i               ),
    .clear_i     ( clear_i                   ),
    .enable_i    ( enable_i                  ),
    .tcdm        ( tcdm_output_fifo          ),
    .stream      ( output_i                  ),
    .ctrl_i      ( ctrl_i.output_sink_ctrl   ),
    .flags_o     ( flags_o.output_sink_flags )
  );

  // TCDM-side FIFOs
  hci_core_fifo #(
    .FIFO_DEPTH ( 2 ),
    .`HCI_SIZE_PARAM(tcdm_initiator) ( `HCI_SIZE_PARAM(tcdm_dw) )
  ) i_tcdm_input_fifo (
    .clk_i          ( clk_i           ),
    .rst_ni         ( rst_ni          ),
    .clear_i        ( clear_i         ),
    .flags_o        (                 ),
    .tcdm_target    ( tcdm_input_fifo ),
    .tcdm_initiator ( tcdm_input      )
  );

  hci_core_fifo #(
    .FIFO_DEPTH ( 2 ),
    .`HCI_SIZE_PARAM(tcdm_initiator) ( `HCI_SIZE_PARAM(tcdm_dw) )
  ) i_tcdm_weight_fifo (
    .clk_i          ( clk_i            ),
    .rst_ni         ( rst_ni           ),
    .clear_i        ( clear_i          ),
    .flags_o        ( flags_fifo_o[0]  ),
    .tcdm_target    ( tcdm_weight_fifo ),
    .tcdm_initiator ( tcdm_weight      )
  );

  hci_core_fifo #(
    .FIFO_DEPTH ( 2 ),
    .`HCI_SIZE_PARAM(tcdm_initiator) ( `HCI_SIZE_PARAM(tcdm_dw) )
  ) i_tcdm_bias_fifo (
    .clk_i          ( clk_i          ),
    .rst_ni         ( rst_ni         ),
    .clear_i        ( clear_i        ),
    .flags_o        (                ),
    .tcdm_target    ( tcdm_bias_fifo ),
    .tcdm_initiator ( tcdm_bias      )
  );

  hci_core_fifo #(
    .FIFO_DEPTH ( 2 ),
    .`HCI_SIZE_PARAM(tcdm_initiator) ( `HCI_SIZE_PARAM(tcdm_dw) )
  ) i_tcdm_output_fifo (
    .clk_i          ( clk_i            ),
    .rst_ni         ( rst_ni           ),
    .clear_i        ( clear_i          ),
    .flags_o        ( flags_fifo_o[1]  ),
    .tcdm_target    ( tcdm_output_fifo ),
    .tcdm_initiator ( tcdm_output      )
  );

endmodule : ita_hwpe_streamer