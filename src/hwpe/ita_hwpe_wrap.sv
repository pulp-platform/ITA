// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// Author: Gamze Islamoglu <gislamoglu@iis.ee.ethz.ch>

`include "hci_helpers.svh"

import ita_hwpe_package::*;
import hwpe_ctrl_package::*;
import hwpe_stream_package::*;
import hci_package::*;

module ita_hwpe_wrap
#(
  // hwpe params
  parameter int unsigned AccDataWidth = 1024,
  parameter int unsigned IdWidth      = ID_WIDTH,
  // system params
  parameter int unsigned MemDataWidth = 64,
  parameter int unsigned MP           = (AccDataWidth / MemDataWidth)
) (
  // global signals
  input  logic                      clk_i         ,
  input  logic                      rst_ni        ,
  input  logic                      test_mode_i   ,

  // events
  output logic [N_CORES-1:0][1:0]   evt_o         ,
  output logic                      busy_o        ,

  // tcdm master ports
  output logic [      MP-1:0]                     tcdm_req_o      ,
  input  logic [      MP-1:0]                     tcdm_gnt_i      ,
  output logic [      MP-1:0][31:0]               tcdm_add_o      ,
  output logic [      MP-1:0]                     tcdm_wen_o      ,
  output logic [      MP-1:0][MemDataWidth/8-1:0] tcdm_be_o       ,
  output logic [      MP-1:0][MemDataWidth-1:0]   tcdm_data_o     ,
  input  logic [      MP-1:0][MemDataWidth-1:0]   tcdm_r_data_i   ,
  input  logic [      MP-1:0]                     tcdm_r_valid_i  ,

  // periph slave port
  input  logic                      periph_req_i    ,
  output logic                      periph_gnt_o    ,
  input  logic [        31:0]       periph_add_i    ,
  input  logic                      periph_wen_i    ,
  input  logic [         3:0]       periph_be_i     ,
  input  logic [        31:0]       periph_data_i   ,
  input  logic [ IdWidth-1:0]       periph_id_i     ,
  output logic [        31:0]       periph_r_data_o ,
  output logic                      periph_r_valid_o,
  output logic [ IdWidth-1:0]       periph_r_id_o
);

  localparam hci_size_parameter_t `HCI_SIZE_PARAM(tcdm) = '{
    DW:  AccDataWidth,
    AW:  DEFAULT_AW,
    BW:  DEFAULT_BW,
    UW:  DEFAULT_UW,
    IW:  ID_WIDTH,
    EW:  DEFAULT_EW,
    EHW: DEFAULT_EHW
  };
  `HCI_INTF(tcdm, clk_i);

  hwpe_ctrl_intf_periph #(.ID_WIDTH(IdWidth)) periph (.clk(clk_i));

  for(genvar i=0; i<MP; i++) begin: gen_tcdm_binding
    assign tcdm_req_o  [i] = tcdm.req;
    assign tcdm_add_o  [i] = tcdm.add + i*(MemDataWidth/8);
    assign tcdm_wen_o  [i] = tcdm.wen;
    assign tcdm_be_o   [i] = tcdm.be[i*(MemDataWidth/8)+:(MemDataWidth/8)];
    assign tcdm_data_o [i] = tcdm.data[i*MemDataWidth+:MemDataWidth];
  end
  assign tcdm.gnt      = &(tcdm_gnt_i);
  assign tcdm.r_valid  = &(tcdm_r_valid_i);
  assign tcdm.r_data   = { >> {tcdm_r_data_i} };
  assign tcdm.r_user   = '0;
  assign tcdm.r_id     = '0;
  assign tcdm.r_opc    = '0;
  assign tcdm.r_ecc    = '0;
  assign tcdm.egnt     = '0;
  assign tcdm.r_evalid = '0;

  always_comb begin
    periph.req       = periph_req_i;
    periph.add       = periph_add_i;
    periph.wen       = periph_wen_i;
    periph.be        = periph_be_i;
    periph.data      = periph_data_i;
    periph.id        = periph_id_i;
    periph_gnt_o     = periph.gnt;
    periph_r_data_o  = periph.r_data;
    periph_r_valid_o = periph.r_valid;
    periph_r_id_o    = periph.r_id;
  end

  ita_hwpe_top i_ita (
    .clk_i,
    .rst_ni,
    .test_mode_i (test_mode_i ),
    .evt_o       (evt_o       ),
    .busy_o      (busy_o      ),
    .tcdm        (tcdm        ),
    .periph      (periph      )
  );

endmodule : ita_hwpe_wrap