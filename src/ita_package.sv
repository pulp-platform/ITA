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
  localparam int unsigned GELU_CONSTANTS_WIDTH = 16                    ;
  localparam int unsigned GELU_OUT_WIDTH = 26                          ;
  localparam int unsigned N_ATTENTION_STEPS = 6                        ;
  localparam int unsigned N_FEEDFORWARD_STEPS = 2                      ;
  localparam int unsigned N_STATES = N_ATTENTION_STEPS + N_FEEDFORWARD_STEPS + 1;
  localparam int unsigned N_REQUANT_CONSTS = N_ATTENTION_STEPS + N_FEEDFORWARD_STEPS;


  parameter  int unsigned InputAddrWidth = idx_width(S)                                                      ;
  parameter  int unsigned MAddrWidth     = idx_width(H*S)                                                    ;
  parameter  int unsigned M3AddrWidth    = idx_width(S)                                                      ;
  parameter  int unsigned NumReadPorts   = N                                                                 ;
  parameter  int unsigned MNumReadPorts  = N                                                                 ;
  parameter  int unsigned FifoDepth      = `ifdef ITA_OUTPUT_FIFO_DEPTH `ITA_OUTPUT_FIFO_DEPTH `else 14 `endif;
  localparam int unsigned SplitFactor    = 4                                                                 ;
  parameter  int unsigned N_WRITE_EN     = `ifdef TARGET_ITA_HWPE 8 `else M `endif;

  // Feedforward
  typedef enum bit [1:0] {Attention=0, Feedforward=1, Linear=2, SingleAttention=3} layer_e;
  typedef enum bit [1:0] {Identity=0, Gelu=1, Relu=2} activation_e;
  typedef logic signed [GELU_CONSTANTS_WIDTH-1:0] gelu_const_t;
  typedef logic signed [GELU_OUT_WIDTH-1:0] gelu_out_t;

  // IO
  typedef logic            [EMS-1:0] requant_const_t;
  typedef logic       [N_REQUANT_CONSTS-1:0][EMS-1:0] requant_const_array_t;
  typedef logic signed      [WI-1:0] requant_t;
  typedef logic signed [N_REQUANT_CONSTS-1:0][WI-1:0] requant_array_t;
  typedef logic [WO-WI*2-2:0] seq_length_t;
  typedef logic [WO-WI*2-2:0] proj_space_t;
  typedef logic [WO-WI*2-2:0] embed_size_t;
  typedef logic [WO-WI*2-2:0] ff_size_t;
  typedef logic [            32-1:0] tile_t;
  typedef struct packed {
    logic                         start       ;
    seq_length_t                  seq_length  ;
    proj_space_t                  proj_space  ;
    embed_size_t                  embed_size  ;
    ff_size_t                     ff_size     ;
    layer_e                       layer       ;
    activation_e                  activation  ;
    requant_const_array_t         eps_mult    ;
    requant_const_array_t         right_shift ;
    requant_array_t               add         ;
    gelu_const_t                  gelu_b;
    gelu_const_t                  gelu_c;
    requant_const_t               activation_requant_mult;
    requant_const_t               activation_requant_shift;
    requant_t                     activation_requant_add;
    tile_t                        tile_s;
    tile_t                        tile_e;
    tile_t                        tile_p;
    tile_t                        tile_f;
  } ctrl_t;
  typedef struct packed {
    logic [InputAddrWidth-1:0]         addr;
    logic [             E-1:0][WI-1:0] data;
  } write_port_t;

  // States
  typedef enum {Idle=0, Q=1, K=2, V=3, QK=4, AV=5, OW=6, F1=7, F2=8, MatMul=9} step_e;

  // Inputs and weights
  typedef logic signed [M-1:0][  WI-1:0] inp_t;
  typedef logic [(N*M/N_WRITE_EN)-1:0][  WI-1:0] inp_weight_t;
  typedef logic [N_WRITE_EN-1:0]           write_select_t;
  typedef logic [N_WRITE_EN-1:0][(N*M*WI/N_WRITE_EN)-1:0] write_data_t;
  typedef logic signed [N-1:0][(WO-2)-1:0]    bias_t;
  typedef logic signed [N-1:0][M-1:0][WI-1:0] weight_t;

  // Accumulator
  typedef logic signed [N-1:0][WO-1:0]        oup_t;

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

  // Requantizer
  typedef enum {Signed=0, Unsigned=1} requant_mode_e;
  localparam requant_mode_e REQUANT_MODE = Signed;
  typedef requant_t    [N-1:0]        requant_oup_t;
endpackage : ita_package
