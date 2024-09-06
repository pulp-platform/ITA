// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// Author: Gamze Islamoglu <gislamoglu@iis.ee.ethz.ch>

package ita_hwpe_package;

  import ita_package::*;

  // HWPE Configuration
  parameter int unsigned N_CORES     = 9;
  parameter int unsigned N_CONTEXT   = 2;
  parameter int unsigned ID_WIDTH    = 2;
  parameter int unsigned ITA_IO_REGS = 17; // 5 address + 11 parameters + 1 sync

  parameter int unsigned ITA_TCDM_DW = 1024;
  parameter int unsigned ITA_INPUT_DW  = M*WI;
  parameter int unsigned ITA_WEIGHT_DW = (N*M*WI/N_WRITE_EN);
  parameter int unsigned ITA_BIAS_DW   = N*(WO-2);
  parameter int unsigned ITA_OUTPUT_DW = N*WI;

  // Register file map
  parameter int unsigned ITA_REG_INPUT_PTR    =  0;
  parameter int unsigned ITA_REG_WEIGHT_PTR0  =  1;
  parameter int unsigned ITA_REG_WEIGHT_PTR1  =  2;
  parameter int unsigned ITA_REG_BIAS_PTR     =  3;
  parameter int unsigned ITA_REG_OUTPUT_PTR   =  4;
  parameter int unsigned ITA_REG_SEQ_LENGTH   =  5;
  parameter int unsigned ITA_REG_TILES        =  6; // tile_s [3:0], tile_e [7:4], tile_p [11:8], tile_f [15:12]
  parameter int unsigned ITA_REG_EPS_MULT0    =  7; // eps_mult[0] [7:0], eps_mult[1] [15:8], eps_mult[2] [23:16], eps_mult[3] [31:24]
  parameter int unsigned ITA_REG_EPS_MULT1    =  8; // eps_mult[4] [7:0], eps_mult[5] [15:8], eps_mult[6] [23:16], eps_mult[7] [31:24]
  parameter int unsigned ITA_REG_RIGHT_SHIFT0 =  9; // right_shift[0] [7:0], right_shift[1] [15:8], right_shift[2] [23:16], right_shift[3] [31:24]
  parameter int unsigned ITA_REG_RIGHT_SHIFT1 = 10; // right_shift[4] [7:0], right_shift[5] [15:8], right_shift[6] [23:16], right_shift[7] [31:24]
  parameter int unsigned ITA_REG_ADD0         = 11; // add[0] [7:0], add[1] [15:8], add[2] [23:16], add[3] [31:24]
  parameter int unsigned ITA_REG_ADD1         = 12; // add[4] [7:0], add[5] [15:8], add[6] [23:16], add[7] [31:24]
  parameter int unsigned ITA_REG_CTRL_ENGINE  = 13; // layer [1:0], activation [3:2]
  parameter int unsigned ITA_REG_CTRL_STREAM  = 14; // ctrl_stream [0]: weight preload, ctrl_stream [1]: weight nextload, ctrl_stream [2]: bias disable, ctrl_stream [3]: bias direction, ctrl_stream [4]: output disable
  parameter int unsigned ITA_REG_GELU_B_C     = 15; // gelu_b [15:0], gelu_c [31:16]
  parameter int unsigned ITA_REG_ACTIVATION_REQUANT = 16; // activation_requant_mult [7:0], activation_requant_shift [15:8], activation_requant_add [23:16]


  typedef struct packed {
    hci_package::hci_streamer_ctrl_t input_source_ctrl;
    hci_package::hci_streamer_ctrl_t weight_source_ctrl;
    hci_package::hci_streamer_ctrl_t bias_source_ctrl;
    hci_package::hci_streamer_ctrl_t output_sink_ctrl;
  } ctrl_streamer_t;

  typedef struct packed {
    hci_package::hci_streamer_flags_t input_source_flags;
    hci_package::hci_streamer_flags_t weight_source_flags;
    hci_package::hci_streamer_flags_t bias_source_flags;
    hci_package::hci_streamer_flags_t output_sink_flags;
  } flags_streamer_t;

  typedef ctrl_t ctrl_engine_t;

  typedef struct packed {
    logic busy;
  } flags_engine_t;

  typedef struct packed {
    logic weight_preload;
    logic weight_nextload;
    logic bias_disable;
    logic bias_direction;
    logic output_disable;
  } ctrl_stream_t;

  typedef enum logic [1:0] {
    ItaIdle,
    NextLoad,
    Done
  } state_t;

endpackage : ita_hwpe_package