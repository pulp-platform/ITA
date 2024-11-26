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
  output logic [N-1:0] mask_o               ,
  output logic         busy_o               ,
  input  logic         calc_en_q1_i          
);

  step_e    step_d, step_q;
  counter_t count_d, count_q, bias_count;
  counter_t mask_pos_d, mask_pos_q;
  logic [3:0] mask_col_offset_d, mask_col_offset_q;
  counter_t mask_count_d, mask_count_q1, mask_count_q2, mask_count_q3;
  counter_t tile_d, tile_q;
  counter_t inner_tile_d, inner_tile_q;
  counter_t mask_tile_x_pos_d, mask_tile_x_pos_q;
  counter_t mask_tile_y_pos_d, mask_tile_y_pos_q;
  counter_t tile_x_d, tile_x_q, bias_tile_x_d, bias_tile_x_q1, bias_tile_x_q2, mask_tile_x_q3;
  counter_t tile_y_d, tile_y_q, bias_tile_y_d, bias_tile_y_q1, bias_tile_y_q2, mask_tile_y_q3;
  counter_t softmax_tile_d, softmax_tile_q;
  ongoing_t ongoing_d, ongoing_q;
  ongoing_soft_t ongoing_soft_d, ongoing_soft_q;

  bias_t inp_bias, inp_bias_padded;
  logic last_time;
  logic [N-1:0] mask_d, mask_q;

  tile_t inner_tile_dim;
  logic [WO-WI*2-2:0] first_outer_dim, second_outer_dim;
  logic [WO-WI*2-2:0] first_outer_dim_d, first_outer_dim_q;
  logic [WO-WI*2-2:0] second_outer_dim_d, second_outer_dim_q;  
  

  logic softmax_fifo, softmax_div, softmax_div_done_d, softmax_div_done_q, busy_d, busy_q;
  requant_oup_t requant_add, requant_add_d, requant_add_q;

  assign step_o            = step_q;
  assign busy_o            = busy_q;
  assign tile_x_o          = tile_x_q;
  assign tile_y_o          = tile_y_q;
  assign inner_tile_o      = inner_tile_q;
  assign requant_add_o     = requant_add_q;
  assign inp_bias_pad_o    = inp_bias_padded;
  assign mask_o            = mask_q;

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
    last_time          = 1'b0;
    requant_add        = {N {requant_add_i}};
    mask_col_offset_d  = (step_q == QK) ? mask_col_offset_q : ((ctrl_i.mask_start_index) & (N-1));
    mask_pos_d         = (step_q == QK) ? mask_pos_q : (((ctrl_i.mask_start_index)/N)*M);
    mask_tile_x_pos_d  = mask_tile_x_pos_q;
    mask_tile_y_pos_d  = mask_tile_y_pos_q;
    mask_d             = mask_q;

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
            count_d   = '0;
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
          if (tile_x_q == (ctrl_i.tile_p-1)) begin 
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
          if (tile_x_q == (ctrl_i.tile_s-1)) begin
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
          if (tile_x_q == (ctrl_i.tile_s-1)) begin
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
          if (tile_x_q == (ctrl_i.tile_p-1)) begin
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
          if (tile_x_q == (ctrl_i.tile_e-1)) begin
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
        second_outer_dim = ctrl_i.ff_size;
        if (inner_tile_d == ctrl_i.tile_e) begin // end of inner tile
          inner_tile_d = '0;
          tile_d = tile_q + 1;
          if (tile_x_q == (ctrl_i.tile_f-1)) begin 
            tile_x_d = '0;
            tile_y_d = tile_y_q + 1;
          end else begin
            tile_x_d = tile_x_q + 1;
          end
          if (tile_d == ctrl_i.tile_s*ctrl_i.tile_f) begin 
            tile_d = '0;
            tile_x_d = '0;
            tile_y_d = '0;
            step_d = F2;
          end
        end
      end
      F2: begin
        inner_tile_dim = ctrl_i.tile_f-1;
        first_outer_dim = ctrl_i.seq_length;
        second_outer_dim = ctrl_i.embed_size;
        if (inner_tile_d == ctrl_i.tile_f) begin // end of inner tile
          inner_tile_d = '0;
          tile_d = tile_q + 1;
          if (tile_x_q == (ctrl_i.tile_e-1)) begin
            tile_x_d = '0;
            tile_y_d = tile_y_q + 1;
          end else begin
            tile_x_d = tile_x_q + 1;
          end
          if (tile_d == ctrl_i.tile_s*ctrl_i.tile_e) begin
            tile_d = '0;
            tile_x_d = '0;
            tile_y_d = '0;
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

    inp_bias             = inp_bias_i;
    requant_add_d        = requant_add;
    bias_count = (count_q == 0) ? 255 : count_q - 1;
    bias_tile_x_d        = (count_q == 0) ? bias_tile_x_q1 : tile_x_q;
    bias_tile_y_d        = (count_q == 0) ? bias_tile_y_q1 : tile_y_q;
    first_outer_dim_d    = (count_q == 0) ? first_outer_dim_q : first_outer_dim;
    second_outer_dim_d   = (count_q == 0) ? second_outer_dim_q : second_outer_dim;
    mask_count_d         = bias_count;

    if ((step_q != Idle && step_q != MatMul) || (step_q == Idle && bias_count == 255)) begin
      if (inner_tile_q == inner_tile_dim) begin
        last_inner_tile_o = 1'b1;
      end
      if ((((((bias_count) & (M-1)) + bias_tile_y_d * M)) > ((first_outer_dim_d - 1)))) begin
        requant_add_d = {N {1'b0}};
        inp_bias = {N {1'b0}};
      end else begin
        if ( ((bias_count) + bias_tile_x_d * M*M/N) >= (second_outer_dim_d / N) * M ) begin
          if ( (((bias_count) / M) * N + bias_tile_x_d * M ) < second_outer_dim_d) begin
            for (int i = 0; i < N; i++) begin
              if (i >= (second_outer_dim_d & (N-1))) begin
                requant_add_d[i] = 1'b0;
                inp_bias[i] = 1'b0;
              end else begin
                requant_add_d[i] = requant_add[i];
                inp_bias[i] = inp_bias_i[i];
              end
            end
          end else begin
            requant_add_d = {N {1'b0}};
            inp_bias = {N {1'b0}};
          end
        end
      end
    end
    inp_bias_padded = inp_bias;

    
    for (int i = 0; i < N; i++) begin
      mask_d[i] = 1'b0;
    end
    case (ctrl_i.mask_type)
      None: begin
        
      end
      UpperTriangular: begin
        // With calc_en_q4
        if (step_q == QK) begin
          // if ((mask_tile_x_pos_q == ctrl_i.tile_s-1) && (mask_count_q3 == ((M*M/N)-1))) begin
          //   mask_tile_x_pos_d = 1'b0;
          // end else if (mask_count_q3 == ((M*M/N)-1) && calc_en_q4_i) begin
          //   mask_tile_x_pos_d = mask_tile_x_pos_q + 1'b1;
          // end else begin
          //   mask_tile_x_pos_d = mask_tile_x_pos_q;
          // end

          // if (mask_tile_x_q3 == mask_tile_x_pos_q && mask_tile_y_q3 == mask_tile_y_pos_q) begin
            if ((count_q >= mask_pos_q) && (count_q < (mask_pos_q + N))) begin
              // if ((count_q & (M-1)) == 6'd63) begin
              //   mask_tile_y_pos_d = mask_tile_y_pos_q + 1'b1;
              //   mask_pos_d = (count_q + ((7*M) + 1)) & ((M*M/N)-1);
              // end else 
              if (((count_q + mask_col_offset_q) & (N-1)) == (N-1)) begin
                mask_pos_d = (mask_pos_q + (N - ((mask_pos_q + mask_col_offset_q) & (N-1))) + M) & ((M*M/N)-1);
              end
              for (int i = 0; i < N; i++) begin
                if (((count_q + mask_col_offset_q) & (N-1)) <= i) begin
                  mask_d[i] = 1'b1;
                end else begin
                  mask_d[i] = 1'b0;
                end
              end
            end else if ((count_q & (M-1)) < (mask_pos_q & (M-1))) begin
              for (int i = 0; i < N; i++) begin
                mask_d[i] = 1'b1;
              end
            end else begin
              for (int i = 0; i < N; i++) begin
                 mask_d[i] = 1'b0;
              end
            end
          // end else if (mask_tile_x_q3 == mask_tile_x_pos_q && mask_tile_y_q3 != mask_tile_y_pos_q) begin
          //   for (int i = 0; i < N; i++) begin
          //     mask_d[i] = 1'b1;
          //   end
          // end else begin
          //   for (int i = 0; i < N; i++) begin
          //     mask_d[i] = 1'b0;
          //   end
          // end   
        end
      end
      LowerTriangular: begin
        
      end
    endcase

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
      tile_x_q  <= '0;
      tile_y_q  <= '0;
      inner_tile_q <= '0;
      softmax_tile_q <= '0;
      ongoing_q <= '0;
      ongoing_soft_q <= '0;
      softmax_div_done_q <= 1'b0;
      requant_add_q <= '0;
      busy_q <= 1'b0;
      bias_tile_x_q1 <= '0;
      bias_tile_x_q2 <= '0;
      mask_tile_x_q3 <= '0;
      bias_tile_y_q1 <= '0;
      bias_tile_y_q2 <= '0;
      mask_tile_y_q3 <= '0;
      first_outer_dim_q <= '0;
      second_outer_dim_q <= '0;
      mask_pos_q <= '0;
      mask_col_offset_q <= '0;
      mask_count_q1 <= '0;
      mask_count_q2 <= '0;
      mask_count_q3 <= '0;
      mask_tile_x_pos_q <= '0;
      mask_tile_y_pos_q <= '0;
      mask_q <= '0;
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
      bias_tile_x_q1 <= bias_tile_x_d;
      bias_tile_x_q2 <= bias_tile_x_q1;
      mask_tile_x_q3 <= bias_tile_x_q2;
      bias_tile_y_q1 <= bias_tile_y_d;
      bias_tile_y_q2 <= bias_tile_y_q1;
      mask_tile_y_q3 <= bias_tile_y_q2;
      first_outer_dim_q <= first_outer_dim_d;
      second_outer_dim_q <= second_outer_dim_d;
      if (calc_en_o) begin
        mask_pos_q <= mask_pos_d;
        mask_q <= mask_d;
      end
      mask_col_offset_q <= mask_col_offset_d;
      mask_count_q1 <= mask_count_d;
      mask_count_q2 <= mask_count_q1;
      mask_count_q3 <= mask_count_q2;
      mask_tile_x_pos_q <= mask_tile_x_pos_d;
      mask_tile_y_pos_q <= mask_tile_y_pos_d;
    end
  end
endmodule
