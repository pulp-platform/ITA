// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

/// ITA Configuration.
package ita_package;

  import cf_math_pkg::idx_width;

  parameter  int unsigned N       = `ifdef ITA_N `ITA_N `else 16 `endif;
  parameter  int unsigned M       = `ifdef ITA_M `ITA_M `else 64 `endif;
  parameter  int unsigned S       = `ifdef ITA_S `ITA_S `else 64 `endif;
  parameter  int unsigned P       = `ifdef ITA_P `ITA_P `else 64 `endif;
  parameter  int unsigned E       = `ifdef ITA_E `ITA_E `else 64 `endif;
  parameter  int unsigned H       = `ifdef ITA_H `ITA_H `else 1  `endif;
  localparam int unsigned WI      = 8                                  ;
  localparam int unsigned WO      = 26                                 ;
  localparam int unsigned EMS     = 8                                  ;
  localparam int unsigned Latency = 7                                  ;

  parameter  int unsigned InputAddrWidth = idx_width(S)                                                      ;
  parameter  int unsigned MAddrWidth     = idx_width(H*S)                                                    ;
  parameter  int unsigned M3AddrWidth    = idx_width(S)                                                      ;
  parameter  int unsigned NumReadPorts   = N                                                                 ;
  parameter  int unsigned MNumReadPorts  = N                                                                 ;
  parameter  int unsigned FifoDepth      = `ifdef ITA_OUTPUT_FIFO_DEPTH `ITA_OUTPUT_FIFO_DEPTH `else 8 `endif;
  localparam int unsigned SplitFactor    = 4                                                                 ;

  parameter  int unsigned N_WRITE_EN     = `ifdef TARGET_ITA_HWPE 8 `else M `endif;

  // IO
  typedef logic [WO-WI*2-2:0] seq_length_t;
  typedef logic [WO-WI*2-2:0] proj_space_t;
  typedef logic [WO-WI*2-2:0] embed_size_t;
  typedef logic [idx_width(H+1)-1:0] n_heads_t;
  typedef logic [           EMS-1:0] eps_mult_t;
  typedef logic [           EMS-1:0] right_shift_t;
  typedef logic [            WI-1:0] add_t;

  typedef struct packed {
    logic                         start       ;
    seq_length_t                  seq_length  ;
    proj_space_t                  proj_space  ;
    embed_size_t                  embed_size  ;
    n_heads_t                     n_heads     ;
    logic         [5:0][EMS-1:0]  eps_mult    ;
    logic         [5:0][EMS-1:0]  right_shift ;
    logic         [5:0][WI-1:0]   add         ;
    logic              [32-1:0]   lin_tiles   ;
    logic              [32-1:0]   attn_tiles  ;
    logic              [32-1:0]   tile_s;
    logic              [32-1:0]   tile_e;
    logic              [32-1:0]   tile_p;
  } ctrl_t;

  typedef struct packed {
    logic [InputAddrWidth-1:0]         addr;
    logic [             E-1:0][WI-1:0] data;
  } write_port_t;

  typedef logic signed [WI-1:0] requant_t;

  typedef logic signed [N-1:0][M-1:0][WI-1:0] weight_t;
  typedef logic signed [N-1:0][(WO-2)-1:0]    bias_t;

  typedef logic signed [N-1:0][WO-1:0]        oup_t;
  typedef requant_t    [N-1:0]        requant_oup_t;

  // States
  typedef enum {Idle=6, Q=0, K=1, V=2, QK=3, AV=4, OW=5} step_e;

  // Inputs and weights
  typedef logic signed [M-1:0][  WI-1:0] inp_t;
  typedef logic [(N*M/N_WRITE_EN)-1:0][  WI-1:0] inp_weight_t;
  typedef logic [N_WRITE_EN-1:0]           write_select_t;
  typedef logic [N_WRITE_EN-1:0][(N*M*WI/N_WRITE_EN)-1:0] write_data_t;

  // FIFO
  typedef logic [                N*WI-1:0]   fifo_data_t;
  typedef logic [idx_width(FifoDepth)-1:0]   fifo_usage_t;
  typedef logic [idx_width(FifoDepth+1)-1:0] ongoing_t;

  // Counter
  typedef logic [idx_width(7*H*S*S/N+1)-1:0] counter_t;

  // Softmax
  localparam int unsigned SoftmaxScalar = 65280; // (2**8-1) * 2**8
  localparam int unsigned SoftmaxAccDataWidth = 19; // Up to S = 2048
  localparam int unsigned SoftFifoDepth = 4;
  typedef logic [idx_width(SoftFifoDepth)-1:0] soft_fifo_usage_t;
  typedef logic [idx_width(SoftFifoDepth+1)-1:0] ongoing_soft_t;
  localparam int unsigned DividerWidth = SoftmaxAccDataWidth + 1;
  localparam int unsigned NumDiv = 5;

endpackage : ita_package
