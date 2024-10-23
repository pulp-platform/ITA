// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51


/**
	ITA controller.
*/

module ita_controller
  import ita_package::*;
(
  input  logic         clk_i                ,
  input  logic         rst_ni               ,
  input  ctrl_t        ctrl_i               ,
  input  logic         inp_valid_i          ,
  output logic         inp_ready_o          ,
  input  logic         weight_valid_i       ,
  output logic         weight_ready_o       ,
  input  logic         bias_valid_i         ,
  output logic         bias_ready_o         ,
  input  logic         oup_valid_i          ,
  input  logic         oup_ready_i          ,
  input  logic         pop_softmax_fifo_i   ,
  output step_e        step_o               ,
  input  counter_t     soft_addr_div_i      ,
  input  logic         softmax_done_i       ,
  output logic         calc_en_o            ,
  output logic         first_inner_tile_o   ,
  output logic         last_inner_tile_o    ,
  output counter_t     tile_x_o             ,
  output counter_t     tile_y_o             ,
  output counter_t     inner_tile_o         ,
  input  requant_t     requant_add_i        ,
  output requant_oup_t requant_add_o        ,
  input  bias_t        inp_bias_i           ,
  output bias_t        inp_bias_pad_o       ,
  output logic         busy_o
);

  step_e    step_d, step_q;
  counter_t count_d, count_q;
  counter_t tile_d, tile_q;
  counter_t inner_tile_d, inner_tile_q;
  counter_t tile_x_d, tile_x_q;
  counter_t tile_y_d, tile_y_q;
  counter_t softmax_tile_d, softmax_tile_q;
  ongoing_t ongoing_d, ongoing_q;
  ongoing_soft_t ongoing_soft_d, ongoing_soft_q;

  bias_t inp_bias, inp_bias_padded;

  tile_t inner_tile_dim;
  logic [WO-WI*2-2:0] first_outer_dim, second_outer_dim;

  logic softmax_fifo, softmax_div, softmax_div_done_d, softmax_div_done_q, busy_d, busy_q;
  requant_oup_t requant_add_d, requant_add_q;

  assign step_o         = step_q;
  assign busy_o         = busy_q;
  assign tile_x_o       = tile_x_q;
  assign tile_y_o       = tile_y_q;
  assign inner_tile_o   = inner_tile_q;
  assign requant_add_o  = requant_add_q;
  assign inp_bias_pad_o = inp_bias_padded;

  always_comb begin
    count_d            = count_q;
    tile_d             = tile_q;
    inner_tile_d       = inner_tile_q;
    tile_x_d           = tile_x_q;
    tile_y_d           = tile_y_q;
    first_inner_tile_o = (inner_tile_q == 0) ? 1'b1 : 1'b0;
    last_inner_tile_o  = 1'b0;
    ongoing_d          = ongoing_q;
    ongoing_soft_d     = ongoing_soft_q;
    inp_ready_o        = 0;
    weight_ready_o     = 0;
    bias_ready_o       = 0;
    calc_en_o          = 0;
    step_d             = step_q;
    softmax_tile_d     = softmax_tile_q;
    softmax_div_done_d = softmax_div_done_q;
    requant_add_d      = {N {requant_add_i}};
    inp_bias           = inp_bias_i;
    

    busy_d       = busy_q;
    softmax_fifo = 1'b0;
    softmax_div  = 1'b0;

    if (step_q != AV) begin
      softmax_div_done_d = 1'b0;
    end else if (softmax_done_i) begin
      softmax_div_done_d = 1'b1;
    end

    if (ctrl_i.start) begin
      busy_d = 1'b1;
    end

    

    // default handshake
    if (step_q != Idle) begin
      // Check if division for softmax is going to FIFO
      if (step_q == QK && inner_tile_q == ctrl_i.tile_p-1 && tile_q == ctrl_i.tile_s-1 && count_q >= (M*M/N-M)) begin
        softmax_fifo = 1'b1;
      end
      // Check if division for softmax is completed for the row
      if (softmax_div_done_q != 1'b1 && step_q == AV && inner_tile_q == 0 && tile_q == 0 && count_q < M && count_q >= soft_addr_div_i) begin
        softmax_div = 1'b1;
      end
      if (ongoing_q>=FifoDepth || (softmax_fifo && ongoing_soft_q>=SoftFifoDepth) || softmax_div) begin
        inp_ready_o    = 1'b0;
        weight_ready_o = 1'b0;
        bias_ready_o   = 1'b0;
      end else begin
        inp_ready_o    = weight_valid_i;
        weight_ready_o = inp_valid_i;
        bias_ready_o   = weight_valid_i;
        if (inp_valid_i && weight_valid_i && bias_valid_i) begin
          calc_en_o = 1;
          count_d   = count_q + 1;
          busy_d    = 1'b1;
          if (count_d == M*M/N) begin // end of tile
            busy_d = 1'b0; // Generate done signal for current tile
            count_d = '0;
            inner_tile_d = inner_tile_q + 1;
          end
        end
      end
    end

    case (step_q)
      Idle : begin
        inner_tile_d = '0;
        tile_x_d = '0;
        tile_y_d = '0;
        tile_d = '0;
        softmax_tile_d = '0;
        softmax_div_done_d = 1'b0;
        busy_d = 1'b0;
        if (ctrl_i.start) begin
          if(ctrl_i.layer == Attention) begin
            step_d = Q;
          end else if (ctrl_i.layer == Feedforward) begin
            step_d = F1;
          end else if (ctrl_i.layer == Linear) begin
            step_d = MatMul;
          end else if (ctrl_i.layer == SingleAttention) begin
            step_d = QK;
          end
        end
      end
      // Attention
      Q : begin
        inner_tile_dim = ctrl_i.tile_e-1;
        first_outer_dim = ctrl_i.seq_length;
        second_outer_dim = ctrl_i.proj_space;
        if (inner_tile_d == ctrl_i.tile_e) begin // end of inner tile
          inner_tile_d = '0;
          tile_d = tile_q + 1;
          if (tile_x_q == (ctrl_i.tile_p-1)) begin // end of step Q
            tile_x_d = '0;
            tile_y_d = tile_y_q + 1;
          end else begin
            tile_x_d = tile_x_q + 1;
          end
          if (tile_d == ctrl_i.tile_s*ctrl_i.tile_p) begin // end of step Q
            tile_d = '0;
            tile_x_d = '0;
            tile_y_d = '0;
            step_d = K;
          end
        end
      end
      K: begin
        inner_tile_dim = ctrl_i.tile_e-1;
        first_outer_dim = ctrl_i.seq_length;
        second_outer_dim = ctrl_i.proj_space;
        if (inner_tile_d == ctrl_i.tile_e) begin // end of inner tile
          inner_tile_d = '0;
          tile_d = tile_q + 1;
          if (tile_x_q == (ctrl_i.tile_p-1)) begin // end of step Q
            tile_x_d = '0;
            tile_y_d = tile_y_q + 1;
          end else begin
            tile_x_d = tile_x_q + 1;
          end
          if (tile_d == ctrl_i.tile_s*ctrl_i.tile_p) begin // end of step K
            tile_d = '0;
            tile_x_d = '0;
            tile_y_d = '0;
            step_d = V;
          end
        end
      end
      V: begin
        inner_tile_dim = ctrl_i.tile_e-1;
        first_outer_dim = ctrl_i.proj_space;
        second_outer_dim = ctrl_i.seq_length;
        if (inner_tile_d == ctrl_i.tile_e) begin // end of inner tile
          inner_tile_d = '0;
          tile_d = tile_q + 1;
          if (tile_x_q == (ctrl_i.tile_s-1)) begin // end of step Q
            tile_x_d = '0;
            tile_y_d = tile_y_q + 1;
          end else begin
            tile_x_d = tile_x_q + 1;
          end
          if (tile_d == ctrl_i.tile_s*ctrl_i.tile_p) begin // end of step V
            tile_d = '0;
            tile_x_d = '0;
            tile_y_d = '0;
            step_d = QK;
          end
        end
      end
      QK : begin
        inner_tile_dim = ctrl_i.tile_p-1;
        first_outer_dim = ctrl_i.seq_length;
        second_outer_dim = ctrl_i.seq_length;
        if (inner_tile_d == ctrl_i.tile_p) begin // end of inner tile
          inner_tile_d = '0;
          tile_d = tile_q + 1;
          if (tile_x_q == (ctrl_i.tile_s-1)) begin // end of step Q
            tile_x_d = '0;
          end else begin
            tile_x_d = tile_x_q + 1;
          end
          if (tile_d == ctrl_i.tile_s) begin // end of step QK
            tile_d = '0;
            step_d = AV;
          end
        end
      end
      AV : begin
        inner_tile_dim = ctrl_i.tile_s-1;
        first_outer_dim = ctrl_i.seq_length;
        second_outer_dim = ctrl_i.proj_space;
        if (inner_tile_d == ctrl_i.tile_s) begin // end of inner tile
          inner_tile_d = '0;
          tile_d = tile_q + 1;
          if (tile_x_q == (ctrl_i.tile_p-1)) begin // end of step Q
            tile_x_d = '0;
          end else begin
            tile_x_d = tile_x_q + 1;
          end
          if (tile_d == ctrl_i.tile_p) begin
            tile_d = '0;
            softmax_tile_d = softmax_tile_q + 1;
            if (softmax_tile_d == ctrl_i.tile_s) begin
              softmax_tile_d = '0;
              tile_x_d = '0;
              tile_y_d = '0;
              if (ctrl_i.layer == Attention) begin
                step_d = OW;
              end else if (ctrl_i.layer == SingleAttention) begin
                step_d = Idle;
              end
            end else begin
              tile_y_d = tile_y_q + 1;
              step_d = QK;
            end
          end
        end
      end
      OW : begin
        inner_tile_dim = ctrl_i.tile_p-1;
        first_outer_dim = ctrl_i.seq_length;
        second_outer_dim = ctrl_i.embed_size;
        if (inner_tile_d == ctrl_i.tile_p) begin // end of inner tile
          inner_tile_d = '0;
          tile_d = tile_q + 1;
          if (tile_x_q == (ctrl_i.tile_e-1)) begin // end of step Q
            tile_x_d = '0;
            tile_y_d = tile_y_q + 1;
          end else begin
            tile_x_d = tile_x_q + 1;
          end
          if (tile_d == ctrl_i.tile_s*ctrl_i.tile_e) begin // end of step OW
            tile_d = '0;
            tile_x_d = '0;
            tile_y_d = '0;
            step_d = Idle;
          end
        end
      end
      // Feedforward
      F1: begin
        inner_tile_dim = ctrl_i.tile_e-1;
        first_outer_dim = ctrl_i.seq_length;
        second_outer_dim = ctrl_i.embed_size;
        if (inner_tile_q == ctrl_i.tile_e-1) begin
          last_inner_tile_o = 1'b1;
        end
        if (inner_tile_d == ctrl_i.tile_e) begin // end of inner tile
          inner_tile_d = '0;
          tile_d = tile_q + 1;
          if (tile_d == ctrl_i.tile_s*ctrl_i.tile_f) begin
            tile_d = '0;
            step_d = F2;
          end
        end
      end
      F2: begin
        inner_tile_dim = ctrl_i.tile_e-1;
        first_outer_dim = ctrl_i.seq_length;
        second_outer_dim = ctrl_i.embed_size;
        if (inner_tile_q == ctrl_i.tile_f-1) begin
          last_inner_tile_o = 1'b1;
        end
        if (inner_tile_d == ctrl_i.tile_f) begin // end of inner tile
          inner_tile_d = '0;
          tile_d = tile_q + 1;
          if (tile_d == ctrl_i.tile_s*ctrl_i.tile_e) begin
            tile_d = '0;
            step_d = Idle;
          end
        end
      end
      // Linear
      MatMul: begin
        if (inner_tile_q == ctrl_i.tile_e-1) begin
          last_inner_tile_o = 1'b1;
        end
        if (inner_tile_d == ctrl_i.tile_e) begin // end of inner tile
          inner_tile_d = '0;
          tile_d = tile_q + 1;
          if (tile_d == ctrl_i.tile_s*ctrl_i.tile_p) begin
            tile_d = '0;
            step_d = Idle;
          end
        end
      end
    endcase
    
    if (step_q != Idle && step_q != MatMul) begin
      if (inner_tile_q == inner_tile_dim) begin
        last_inner_tile_o = 1'b1;
        if ( ( (((count_q & (M-1)) + tile_y_q * M)) > ( (first_outer_dim - 1) ) ) ) begin
          requant_add_d = {N {1'b0}};
          //inp_bias = {N {1'b0}};
        end else begin
          if ( (count_q + tile_x_q * M*M/N) >= (second_outer_dim / N) * M ) begin
            if ( ((count_q / M) * N + tile_x_q * M ) < second_outer_dim) begin
              for (int i = (second_outer_dim & (N-1)); i < N; i++) begin
                requant_add_d[i] = 1'b0;
                //inp_bias[i] = 1'b0;
              end
            end else begin
              requant_add_d = {N {1'b0}};
              //inp_bias = {N {1'b0}};
            end
          end
        end

        if ( ( ((((count_q-1) & (M-1)) + tile_y_q * M)) > ( (first_outer_dim - 1) ) ) ) begin
          inp_bias = {N {1'b0}};
        end else begin
          if ( ((count_q-1) + tile_x_q * M*M/N) >= (second_outer_dim / N) * M ) begin
            if ( (((count_q-1) / M) * N + tile_x_q * M ) < second_outer_dim) begin
              for (int i = (second_outer_dim & (N-1)); i < N; i++) begin
                inp_bias[i] = 1'b0;
              end
            end else begin
              inp_bias = {N {1'b0}};
            end
          end
        end
      end
    end

    inp_bias_padded = inp_bias;

    if (inp_valid_i && inp_ready_o && oup_valid_i && oup_ready_i && last_inner_tile_o) begin
      ongoing_d = ongoing_q;
    end else if (inp_valid_i && inp_ready_o && last_inner_tile_o) begin
      ongoing_d = ongoing_q + 1;
    end else if (oup_valid_i && oup_ready_i) begin
      ongoing_d = ongoing_q - 1;
    end
    if (softmax_fifo && inp_valid_i && inp_ready_o && pop_softmax_fifo_i) begin
      ongoing_soft_d = ongoing_soft_q;
    end else if (softmax_fifo && inp_valid_i && inp_ready_o) begin
      ongoing_soft_d = ongoing_soft_q + 1;
    end else if (pop_softmax_fifo_i) begin
      ongoing_soft_d = ongoing_soft_q - 1;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      step_q    <= Idle;
      count_q   <= '0;
      tile_q    <= '0;
      inner_tile_q <= '0;
      softmax_tile_q <= '0;
      ongoing_q <= '0;
      ongoing_soft_q <= '0;
      softmax_div_done_q <= 1'b0;
      requant_add_q <= '0;
      busy_q <= 1'b0;
    end else begin
      step_q    <= step_d;
      count_q   <= count_d;
      tile_q    <= tile_d;
      tile_x_q  <= tile_x_d;
      tile_y_q  <= tile_y_d;
      inner_tile_q <= inner_tile_d;
      softmax_tile_q <= softmax_tile_d;
      ongoing_q <= ongoing_d;
      ongoing_soft_q <= ongoing_soft_d;
      softmax_div_done_q <= softmax_div_done_d;
      requant_add_q <= requant_add_d;
      busy_q <= busy_d;
    end
  end
endmodule
