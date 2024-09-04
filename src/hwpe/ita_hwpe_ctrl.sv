// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// Author: Gamze Islamoglu <gislamoglu@iis.ee.ethz.ch>

import ita_hwpe_package::*;
import ita_package::M;
import ita_package::N;
import hwpe_ctrl_package::*;
import hwpe_stream_package::*;
import ita_package::layer_e;
import ita_package::activation_e;

module ita_hwpe_ctrl
(
  // global signals
  input  logic                                  clk_i,
  input  logic                                  rst_ni,
  input  logic                                  test_mode_i,
  output logic                                  clear_o,
  // events
  output logic [N_CORES-1:0][REGFILE_N_EVT-1:0] evt_o,
  output logic                                  busy_o,
  // ctrl & flags
  output ctrl_streamer_t                        ctrl_streamer_o,
  input  flags_streamer_t                       flags_streamer_i,
  input  flags_fifo_t [1:0]                     flags_fifo_i,
  output ctrl_engine_t                          ctrl_engine_o,
  input  flags_engine_t                         flags_engine_i,
  output ctrl_stream_t                          ctrl_stream_o,
  // periph slave port
  hwpe_ctrl_intf_periph.slave                   periph
);

  localparam int unsigned TOT_LEN = M*M/N;

  logic          slave_clear, stream_clear;
  ctrl_slave_t   slave_ctrl;
  flags_slave_t  slave_flags;
  ctrl_regfile_t reg_file;

  /* HWPE controller slave port + register file */
  hwpe_ctrl_slave #(
    .N_CORES        ( N_CORES     ),
    .N_CONTEXT      ( N_CONTEXT   ),
    .N_IO_REGS      ( ITA_IO_REGS ),
    .N_GENERIC_REGS ( 0           ),
    .ID_WIDTH       ( ID_WIDTH    )
  ) i_slave (
    .clk_i    ( clk_i       ),
    .rst_ni   ( rst_ni      ),
    .clear_o  ( slave_clear ),
    .cfg      ( periph      ),
    .ctrl_i   ( slave_ctrl  ),
    .flags_o  ( slave_flags ),
    .reg_file ( reg_file    )
  );

  assign evt_o  = slave_flags.evt;
  assign busy_o = slave_flags.is_working;
  assign clear_o = slave_clear || stream_clear;

  always_comb begin
    ctrl_engine_o = '0;
    ctrl_engine_o.start = slave_flags.start;
    ctrl_engine_o.tile_s = reg_file.hwpe_params[ITA_REG_TILES][3:0];
    ctrl_engine_o.tile_e = reg_file.hwpe_params[ITA_REG_TILES][7:4];
    ctrl_engine_o.tile_p = reg_file.hwpe_params[ITA_REG_TILES][11:8];
    ctrl_engine_o.tile_f = reg_file.hwpe_params[ITA_REG_TILES][15:12];
    ctrl_engine_o.eps_mult[0] = reg_file.hwpe_params[ITA_REG_EPS_MULT0][7:0];
    ctrl_engine_o.eps_mult[1] = reg_file.hwpe_params[ITA_REG_EPS_MULT0][15:8];
    ctrl_engine_o.eps_mult[2] = reg_file.hwpe_params[ITA_REG_EPS_MULT0][23:16];
    ctrl_engine_o.eps_mult[3] = reg_file.hwpe_params[ITA_REG_EPS_MULT0][31:24];
    ctrl_engine_o.eps_mult[4] = reg_file.hwpe_params[ITA_REG_EPS_MULT1][7:0];
    ctrl_engine_o.eps_mult[5] = reg_file.hwpe_params[ITA_REG_EPS_MULT1][15:8];
    ctrl_engine_o.right_shift[0] = reg_file.hwpe_params[ITA_REG_RIGHT_SHIFT0][7:0];
    ctrl_engine_o.right_shift[1] = reg_file.hwpe_params[ITA_REG_RIGHT_SHIFT0][15:8];
    ctrl_engine_o.right_shift[2] = reg_file.hwpe_params[ITA_REG_RIGHT_SHIFT0][23:16];
    ctrl_engine_o.right_shift[3] = reg_file.hwpe_params[ITA_REG_RIGHT_SHIFT0][31:24];
    ctrl_engine_o.right_shift[4] = reg_file.hwpe_params[ITA_REG_RIGHT_SHIFT1][7:0];
    ctrl_engine_o.right_shift[5] = reg_file.hwpe_params[ITA_REG_RIGHT_SHIFT1][15:8];
    ctrl_engine_o.add[0] = reg_file.hwpe_params[ITA_REG_ADD0][7:0];
    ctrl_engine_o.add[1] = reg_file.hwpe_params[ITA_REG_ADD0][15:8];
    ctrl_engine_o.add[2] = reg_file.hwpe_params[ITA_REG_ADD0][23:16];
    ctrl_engine_o.add[3] = reg_file.hwpe_params[ITA_REG_ADD0][31:24];
    ctrl_engine_o.add[4] = reg_file.hwpe_params[ITA_REG_ADD1][7:0];
    ctrl_engine_o.add[5] = reg_file.hwpe_params[ITA_REG_ADD1][15:8];
    ctrl_engine_o.gelu_b = reg_file.hwpe_params[ITA_REG_GELU_B_C][15:0];
    ctrl_engine_o.gelu_c = reg_file.hwpe_params[ITA_REG_GELU_B_C][31:16];
    ctrl_engine_o.activation_requant_mult = reg_file.hwpe_params[ITA_REG_ACTIVATION_REQUANT][7:0];
    ctrl_engine_o.activation_requant_shift = reg_file.hwpe_params[ITA_REG_ACTIVATION_REQUANT][15:8];
    ctrl_engine_o.activation_requant_add = reg_file.hwpe_params[ITA_REG_ACTIVATION_REQUANT][23:16];
    ctrl_engine_o.layer = layer_e'(reg_file.hwpe_params[ITA_REG_CTRL_ENGINE][1:0]);
    ctrl_engine_o.activation = activation_e'(reg_file.hwpe_params[ITA_REG_CTRL_ENGINE][3:2]);
    ctrl_stream_o.weight_preload = reg_file.hwpe_params[ITA_REG_CTRL_STREAM][0];
    ctrl_stream_o.weight_nextload = reg_file.hwpe_params[ITA_REG_CTRL_STREAM][1];
    ctrl_stream_o.bias_disable  = reg_file.hwpe_params[ITA_REG_CTRL_STREAM][2];
    ctrl_stream_o.bias_direction = reg_file.hwpe_params[ITA_REG_CTRL_STREAM][3];
    ctrl_stream_o.output_disable = reg_file.hwpe_params[ITA_REG_CTRL_STREAM][4];
  end

  logic [31:0] input_addr, bias_addr, output_addr;
  logic [1:0] [31:0] weight_addr;
  assign input_addr  = reg_file.hwpe_params[ITA_REG_INPUT_PTR];
  assign weight_addr[0] = reg_file.hwpe_params[ITA_REG_WEIGHT_PTR0];
  assign weight_addr[1] = reg_file.hwpe_params[ITA_REG_WEIGHT_PTR1];
  assign bias_addr   = reg_file.hwpe_params[ITA_REG_BIAS_PTR];
  assign output_addr = reg_file.hwpe_params[ITA_REG_OUTPUT_PTR];

  state_t state_q, state_d;

  logic restart_weight_q, restart_weight_d;

  logic [31:0] weight_base_addr_d, weight_base_addr_q;
  logic [31:0] weight_len_d, weight_len_q;

  always_comb begin
    state_d = state_q;

    restart_weight_d = 1'b0;

    weight_base_addr_d = weight_base_addr_q;
    weight_len_d       = weight_len_q;

    ctrl_streamer_o.input_source_ctrl.req_start  = 1'b0;
    ctrl_streamer_o.weight_source_ctrl.req_start = restart_weight_q;
    ctrl_streamer_o.bias_source_ctrl.req_start   = 1'b0;
    ctrl_streamer_o.output_sink_ctrl.req_start   = 1'b0;

    slave_ctrl = '0;

    stream_clear = 0;

    case (state_q)
      ItaIdle: begin
        if (slave_flags.start) begin
          state_d = ctrl_stream_o.weight_nextload ? NextLoad : Done;
          ctrl_streamer_o.input_source_ctrl.req_start  = 1'b1;
          restart_weight_d = 1'b1;
          ctrl_streamer_o.bias_source_ctrl.req_start   = !ctrl_stream_o.bias_disable;
          ctrl_streamer_o.output_sink_ctrl.req_start   = 1'b1 & !ctrl_stream_o.output_disable;
          weight_len_d = (TOT_LEN / 8) - (!ctrl_stream_o.weight_preload * M / 8);
          weight_base_addr_d = weight_addr[0] + !ctrl_stream_o.weight_preload * N * M;
        end
      end
      NextLoad: begin
        if (flags_streamer_i.weight_source_flags.done) begin
          state_d = Done;
          restart_weight_d = 1'b1;
          weight_len_d = M / 8;
          weight_base_addr_d = weight_addr[1];
        end
      end
      Done: begin
        if (ctrl_stream_o.output_disable && ~flags_engine_i.busy && flags_streamer_i.input_source_flags.ready_start && flags_streamer_i.weight_source_flags.ready_start && flags_streamer_i.bias_source_flags.ready_start) begin
          state_d = ItaIdle;
          slave_ctrl.done = 1'b1;
          stream_clear = 1'b1;
        end
        if (~ctrl_stream_o.output_disable && flags_streamer_i.output_sink_flags.ready_start && flags_streamer_i.weight_source_flags.ready_start && flags_fifo_i[0].empty && flags_fifo_i[1].empty) begin
          state_d = ItaIdle;
          slave_ctrl.done = 1'b1;
          stream_clear = 1'b1;
        end
      end
    endcase

    ctrl_streamer_o.input_source_ctrl.addressgen_ctrl.base_addr     = input_addr;
    ctrl_streamer_o.input_source_ctrl.addressgen_ctrl.tot_len       = TOT_LEN / 2;
    ctrl_streamer_o.input_source_ctrl.addressgen_ctrl.d0_stride     = 2 * ITA_INPUT_DW / 8;
    ctrl_streamer_o.input_source_ctrl.addressgen_ctrl.d0_len        = M / 2;
    ctrl_streamer_o.input_source_ctrl.addressgen_ctrl.d1_stride     = '0;
    ctrl_streamer_o.input_source_ctrl.addressgen_ctrl.d1_len        = M/N;
    ctrl_streamer_o.input_source_ctrl.addressgen_ctrl.d2_stride     = '0;
    ctrl_streamer_o.input_source_ctrl.addressgen_ctrl.dim_enable_1h = 2'b01; // 2D

    ctrl_streamer_o.weight_source_ctrl.addressgen_ctrl.base_addr     = weight_base_addr_q;
    ctrl_streamer_o.weight_source_ctrl.addressgen_ctrl.tot_len       = weight_len_q;
    ctrl_streamer_o.weight_source_ctrl.addressgen_ctrl.d0_stride     = ITA_WEIGHT_DW / 8;
    ctrl_streamer_o.weight_source_ctrl.addressgen_ctrl.d0_len        = weight_len_q;
    ctrl_streamer_o.weight_source_ctrl.addressgen_ctrl.d1_stride     = '0;
    ctrl_streamer_o.weight_source_ctrl.addressgen_ctrl.d1_len        = '0;
    ctrl_streamer_o.weight_source_ctrl.addressgen_ctrl.d2_stride     = '0;
    ctrl_streamer_o.weight_source_ctrl.addressgen_ctrl.dim_enable_1h = 2'b00; // 1D

    ctrl_streamer_o.bias_source_ctrl.addressgen_ctrl.base_addr     = bias_addr;
    ctrl_streamer_o.bias_source_ctrl.addressgen_ctrl.tot_len       = 2;
    ctrl_streamer_o.bias_source_ctrl.addressgen_ctrl.d0_stride     = 96; // 64 * 3 / 2
    ctrl_streamer_o.bias_source_ctrl.addressgen_ctrl.d0_len        = 2;
    ctrl_streamer_o.bias_source_ctrl.addressgen_ctrl.d1_stride     = '0;
    ctrl_streamer_o.bias_source_ctrl.addressgen_ctrl.d1_len        = '0;
    ctrl_streamer_o.bias_source_ctrl.addressgen_ctrl.d2_stride     = '0;
    ctrl_streamer_o.bias_source_ctrl.addressgen_ctrl.dim_enable_1h = 2'b00; // 1D

    ctrl_streamer_o.output_sink_ctrl.addressgen_ctrl.base_addr     = output_addr;
    ctrl_streamer_o.output_sink_ctrl.addressgen_ctrl.tot_len       = TOT_LEN / 2;
    ctrl_streamer_o.output_sink_ctrl.addressgen_ctrl.d0_stride     = 2 * M;
    ctrl_streamer_o.output_sink_ctrl.addressgen_ctrl.d0_len        = M / 2;
    ctrl_streamer_o.output_sink_ctrl.addressgen_ctrl.d1_stride     = N;
    ctrl_streamer_o.output_sink_ctrl.addressgen_ctrl.d1_len        = M/N;
    ctrl_streamer_o.output_sink_ctrl.addressgen_ctrl.d2_stride     = '0;
    ctrl_streamer_o.output_sink_ctrl.addressgen_ctrl.dim_enable_1h = 2'b01; // 2D
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      state_q            <= ItaIdle;
      restart_weight_q   <= 1'b0;
      weight_base_addr_q <= '0;
      weight_len_q       <= '0;
    end else begin
      state_q            <= state_d;
      restart_weight_q   <= restart_weight_d;
      weight_base_addr_q <= weight_base_addr_d;
      weight_len_q       <= weight_len_d;
    end
  end

endmodule : ita_hwpe_ctrl