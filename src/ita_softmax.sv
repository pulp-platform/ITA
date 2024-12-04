// Copyright 2021 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51


module ita_softmax
  import ita_package::*;
(
  // Clock and reset
  input  logic                                clk_i,
  input  logic                                rst_ni,
  input  ctrl_t                               ctrl_i,
  input  step_e                               step_i,
  input  logic                                calc_en_i,
  input  requant_oup_t                        requant_oup_i,
  input  logic                                calc_stream_soft_en_i,
  output counter_t                            soft_addr_div_o,
  output logic                                softmax_done_o,
  output logic                                pop_softmax_fifo_o,
  input  inp_t                                inp_i,
  output inp_t                                inp_stream_soft_o,
  output logic [SoftmaxAccDataWidth-1:0]      div_inp_o,
  output logic [NumDiv-1:0]                   div_valid_o,
  input  logic [NumDiv-1:0]                   div_ready_i,
  input  logic [NumDiv-1:0]                   div_valid_i,
  output logic [NumDiv-1:0]                   div_ready_o,
  input  logic [NumDiv-1:0][DividerWidth-1:0] div_oup_i,
  output logic [1:0]                          read_acc_en_o,
  output logic [1:0][InputAddrWidth-1:0]      read_acc_addr_o,
  input  logic [1:0][SoftmaxAccDataWidth-1:0] read_acc_data_i,
  output logic                                write_acc_en_o,
  output logic [InputAddrWidth-1:0]           write_acc_addr_o,
  output logic [SoftmaxAccDataWidth-1:0]      write_acc_data_o,
  output requant_t                            prev_max_o,
  input  requant_t                            max_i,
  output requant_oup_t                        max_o,
  output logic [1:0]                          read_max_en_o,
  output logic [1:0][InputAddrWidth-1:0]      read_max_addr_o,
  input  requant_t [1:0]                      read_max_data_i,
  output logic                                write_max_en_o,
  output logic [InputAddrWidth-1:0]           write_max_addr_o,
  output requant_t                            write_max_data_o,
  input  counter_t                            tile_x_i,
  input  counter_t                            tile_y_i,
  input  counter_t                            inner_tile_i,
  input  logic [N-1:0]                        mask_i
);

  counter_t tile_d, tile_q1, tile_q2, tile_q3, tile_q4;
  counter_t count_d, count_q1, count_q2, count_q3, count_q4;
  counter_t inner_tile_q;
  counter_t tile_x_q, tile_y_q;
  counter_t mask_tile_x_d, mask_tile_x_q, mask_tile_y_d, mask_tile_y_q;
  counter_t mask_tile_outer_dim_d, mask_tile_outer_dim_q;

  logic unsigned [SoftmaxAccDataWidth-1:0] exp_sum_d, exp_sum_q;
  counter_t count_soft_d, count_soft_q1, count_soft_q2, count_soft_mask_q;

  counter_t count_div_d, count_div_q, addr_div_d, addr_div_q;
  logic [NumDiv-1:0] div_read_d, div_read_q, div_write_d, div_write_q;

  requant_oup_t requant_oup_q;
  requant_t max_d, max_q;

  logic unsigned [N-1:0][3:0] shift_d, shift_q;
  logic [N-1:0][WI-1:0] shift_diff;
  logic unsigned [3:0] shift_sum_d, shift_sum_q;
  logic [WI-1:0] max_diff;
  logic unsigned [M-1:0][3:0] shift_inp;
  logic [M-1:0][WI-1:0] shift_inp_diff;

  logic calc_stream_soft_en_q;
  logic calc_en_d, calc_en_q1, calc_en_q2, calc_en_q3;

  // FIFO signals
  logic        fifo_full, fifo_empty, push_to_fifo, pop_from_fifo;
  logic [SoftmaxAccDataWidth-1:0]  data_to_fifo, data_from_fifo;
  soft_fifo_usage_t fifo_usage  ;

  logic [N-1:0] disable_shift;
  logic disable_row;
  logic [M-1:0]disable_col;

  assign disable_row = ((count_soft_q2 & (M-1)) + tile_y_q * M) > (ctrl_i.seq_length - 1);

  assign pop_softmax_fifo_o = pop_from_fifo;
  assign soft_addr_div_o    = addr_div_q;

  always_comb begin
    tile_d            = tile_q1;
    count_d           = count_q1;
    count_soft_d      = count_soft_q1;
    count_div_d       = count_div_q;
    div_read_d        = div_read_q;
    div_write_d       = div_write_q;
    addr_div_d        = addr_div_q;
    calc_en_d         = 1'b0;
    exp_sum_d         = '0;
    read_acc_en_o     = 0;
    read_acc_addr_o   = '0;
    write_acc_en_o    = 0;
    write_acc_addr_o  = '0;
    write_acc_data_o  = '0;
    read_max_en_o     = '0;
    read_max_addr_o   = '0;
    write_max_en_o    = 0;
    write_max_addr_o  = '0;
    write_max_data_o  = '0;
    push_to_fifo      = 0;
    pop_from_fifo     = 0;
    data_to_fifo      = '0;
    div_inp_o         = data_from_fifo;
    div_valid_o       = 0;
    div_ready_o       = 0;
    prev_max_o        = '0;
    max_o             = '0;
    max_d             = max_q;
    shift_d           = '0;
    shift_diff        = '0;
    shift_sum_d       = '0;
    max_diff          = '0;
    shift_inp         = '0;
    shift_inp_diff    = '0;
    inp_stream_soft_o = '0;
    softmax_done_o    = 0;
    mask_tile_x_d     = mask_tile_x_q;
    mask_tile_y_d     = mask_tile_y_q;
    mask_tile_outer_dim_d       = mask_tile_outer_dim_q;
    

    //************ Accumulation ************//
    case (step_i)
      default : begin
        tile_d      = '0;
        count_d     = '0;
      end
      QK : begin
        //************ Pipeline Stage 0 ************//
        if (calc_en_i) begin // After first part of the row check previous max
          calc_en_d = 1'b1;
          count_d = count_q1 + 1;
          if (count_q1 == M*M/N-1) begin
            tile_d  = tile_q1 + 1;
            count_d = '0;
          end
          if (tile_q1 != '0 || count_q1 >= M) begin
            read_max_en_o[0]   = 1;
            read_max_addr_o[0] = count_q1;
          end
        end
      end
    endcase

    //************ Pipeline Stage 1 ************//
    if (calc_en_q1) begin // Find max and accumulate
      max_d = max_i;
      for (int i = 0; i < N; i++) begin
        shift_diff[i] = max_i - requant_oup_q[i];
        disable_shift[i] = ((tile_q2*M+N*(count_q2 >> $clog2(M))+i ) >= ctrl_i.seq_length);

        if (disable_shift[i] || mask_i[i]) begin
          max_o[i] = 8'h80;
          shift_d[i] = 4'hF;
        end else begin
          max_o[i] = requant_oup_q[i];
          shift_d[i]    = unsigned'(shift_diff[i]) >> 5;
          if (shift_diff[i][4])
            shift_d[i] = (unsigned'(shift_diff[i]) >> 5) + 1;
        end
      end
      if (tile_q2 != '0 || count_q2>=M) begin // If not first part of the first row, normalize previous sum
        read_acc_en_o[0]   = 1;
        read_acc_addr_o[0] = count_q2;
        prev_max_o  = read_max_data_i[0];
        max_diff    = max_i - prev_max_o;
        shift_sum_d = max_diff >> 5;
        if (max_diff[4])
          shift_sum_d = (max_diff >> 5) + 1;
      end else begin
        prev_max_o = 8'h80;
      end
    end

    //************ Pipeline Stage 2 ************//
    if (calc_en_q2) begin // Write max and accumulate
      write_max_en_o   = 1;
      write_max_addr_o = count_q3;
      write_max_data_o = max_q;
      for (int i = 0; i < N; i++) begin
        if (shift_q[i] != 4'hF)
          exp_sum_d += unsigned'(9'h100)>>shift_q[i];
      end
      if (tile_q3 != '0 || count_q3>=M) begin // If not first part of the first row
        exp_sum_d += ( unsigned'(read_acc_data_i[0]) >> shift_sum_q);
      end
    end

    //************ Pipeline Stage 3 ************//
    // Write accumulated sum or send to division fifo
    if (calc_en_q3) begin // Write accumulated sum or send to division fifo
      if (count_q4>=(M*M/N-M) && tile_q4 == ctrl_i.tile_s-1) begin // If last tile and last part of the row
        // Main controller checks if FIFO is full
        push_to_fifo = 1;
        data_to_fifo = exp_sum_q;
      end else begin
        write_acc_en_o   = 1;
        write_acc_addr_o = count_q4;
        write_acc_data_o = exp_sum_q;
      end
    end

    //************** Division **************//
      div_valid_o[div_read_q]  = !fifo_empty;
      div_ready_o[div_write_q] = 1;
      if (div_valid_o[div_read_q] && div_ready_i[div_read_q]) begin
        pop_from_fifo   = 1;
        count_div_d = count_div_q + 1;
        div_read_d  = div_read_q + 1;
        if (div_read_d==NumDiv)
          div_read_d = 0;
      end
      if (div_valid_i[div_write_q]) begin
        write_acc_en_o   = 1;
        write_acc_addr_o = addr_div_q;
        addr_div_d       = addr_div_q + 1;
        write_acc_data_o = div_oup_i[div_write_q];
        div_write_d      = div_write_q + 1;
        if (div_write_d==NumDiv)
          div_write_d = 0;
        if (addr_div_d==M) begin
          addr_div_d     = '0;
          count_div_d    = '0;
          softmax_done_o = 1;
        end
      end

    //*********** Stream Softmax ***********//
    // Main controller checks if division is ready
    if (calc_stream_soft_en_i) begin
      count_soft_d    = count_soft_q1 + 1;
      read_acc_en_o[1]   = 1;
      read_acc_addr_o[1] = count_soft_q1[5:0];
      read_max_en_o[1]   = 1;
      read_max_addr_o[1] = count_soft_q1[5:0];
      if (count_soft_d == M*M/N) begin
        count_soft_d = '0;
      end
    end
    if (calc_stream_soft_en_q) begin
      if (count_soft_mask_q == (((M*M)/N)-1)) begin
        if (mask_tile_x_q == (ctrl_i.tile_s - 1)) begin
          mask_tile_x_d = '0;
          mask_tile_outer_dim_d = mask_tile_outer_dim_q + 1;
          if (mask_tile_outer_dim_q == (ctrl_i.tile_p - 1)) begin
            mask_tile_outer_dim_d = '0;
            mask_tile_y_d = mask_tile_y_q + 1;
          end
        end else begin
          mask_tile_x_d = mask_tile_x_q + 1;
        end
        if (mask_tile_y_q == ctrl_i.tile_s) begin
          mask_tile_outer_dim_d = '0;
          mask_tile_x_d = '0;
          mask_tile_y_d = '0;
        end
      end

      if (disable_row) begin
        inp_stream_soft_o = { M { '0 } };
      end else begin
        for (int i = 0; i < M; i++) begin
          if ((inner_tile_q*M + i) >= ctrl_i.seq_length) begin
            disable_col[i] = 1'b1;
          end else begin
            disable_col[i] = 1'b0;
            case (ctrl_i.mask_type)
              UpperTriangular: begin
                // (ctrl_i.mask_start_index / M) -> tile where the masking starts
                if ((mask_tile_x_q - (ctrl_i.mask_start_index / M)) == mask_tile_y_q) begin
                  if (i >= ((count_soft_mask_q & (M-1)) + (ctrl_i.mask_start_index & (M-1)))) begin
                    disable_col[i] = 1'b1;
                  end else begin
                    disable_col[i] = 1'b0;
                  end
                end else if (mask_tile_x_q == ((ctrl_i.mask_start_index / M) + 1'b1 + mask_tile_y_q)) begin
                  if ((count_soft_mask_q & (M-1)) > (M - (ctrl_i.mask_start_index & (M-1)))) begin
                    if (i < ((count_soft_mask_q & (M-1)) - (M - (ctrl_i.mask_start_index & (M-1))))) begin
                      disable_col[i] = 1'b0;
                    end else begin
                      disable_col[i] = 1'b1;
                    end
                  end else begin
                    disable_col[i] = 1'b1;
                  end
                end else if (mask_tile_x_q > ((ctrl_i.mask_start_index / M) + 1'b1 + mask_tile_y_q)) begin
                  disable_col[i] = 1'b1;
                end else if (mask_tile_x_q <= (ctrl_i.mask_start_index / M)) begin
                  disable_col[i] = 1'b0;
                end else begin
                  disable_col[i] = 1'b0;
                end
              end
              LowerTriangular: begin
                
              end 
              None: begin
                
              end 
            endcase          
          end
          
          if (disable_col[i]) begin
            inp_stream_soft_o[i] = '0;
          end else begin
            shift_inp_diff[i] = read_max_data_i[1]-inp_i[i];
            shift_inp[i]      = unsigned'(shift_inp_diff[i]) >> 5;
            if (shift_inp_diff[i][4])
              shift_inp[i] = (unsigned'(shift_inp_diff[i]) >> 5) + 1;
            inp_stream_soft_o[i] = read_acc_data_i[1] >> shift_inp[i];
          end
        end
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      inner_tile_q          <= '0;
      tile_x_q              <= '0;
      tile_y_q              <= '0;
      mask_tile_x_q         <= '0;
      mask_tile_y_q         <= '0;
      mask_tile_outer_dim_q <= '0;
      tile_q4               <= '0;
      tile_q3               <= '0;
      tile_q2               <= '0;
      tile_q1               <= '0;
      count_q4              <= M*M/N;
      count_q3              <= M*M/N;
      count_q2              <= M*M/N;
      count_q1              <= M*M/N;
      count_soft_q1         <= '0;
      count_soft_q2         <= '0;
      count_soft_mask_q     <= '0;    
      count_div_q           <= '0;
      div_read_q            <= '0;
      div_write_q           <= '0;
      addr_div_q            <= '0;
      exp_sum_q             <= '0;
      requant_oup_q         <= '0;
      max_q                 <= '0;
      calc_stream_soft_en_q <= 0;
      shift_q               <= '0;
      shift_sum_q           <= '0;
    end else begin
      inner_tile_q          <= inner_tile_i;
      tile_x_q              <= tile_x_i;
      tile_y_q              <= tile_y_i;
      tile_q4               <= tile_q3;
      tile_q3               <= tile_q2;
      tile_q2               <= tile_q1;
      tile_q1               <= tile_d;
      count_q4              <= count_q3;
      count_q3              <= count_q2;
      count_q2              <= count_q1;
      count_q1              <= count_d;
      count_soft_q1         <= count_soft_d;
      count_soft_q2         <= count_soft_q1;
      if (calc_stream_soft_en_i) begin
        count_soft_mask_q   <= count_soft_q1;
      end
      mask_tile_x_q       <= mask_tile_x_d;
      mask_tile_y_q       <= mask_tile_y_d;
      mask_tile_outer_dim_q <= mask_tile_outer_dim_d;
      count_div_q           <= count_div_d;
      div_read_q            <= div_read_d;
      div_write_q           <= div_write_d;
      addr_div_q            <= addr_div_d;
      exp_sum_q             <= exp_sum_d;
      requant_oup_q         <= requant_oup_i;
      max_q                 <= max_d;
      calc_stream_soft_en_q <= calc_stream_soft_en_i;
      shift_q               <= shift_d;
      shift_sum_q           <= shift_sum_d;
    end
  end

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      calc_en_q3 <= 0;
      calc_en_q2 <= 0;
      calc_en_q1 <= 0;
    end else begin
      calc_en_q3 <= calc_en_q2;
      calc_en_q2 <= calc_en_q1;
      calc_en_q1 <= calc_en_d;
    end
  end

  fifo_v3 #(
    .FALL_THROUGH(1'b0               ),
    .DATA_WIDTH  (SoftmaxAccDataWidth),
    .DEPTH       (SoftFifoDepth      )
  ) i_fifo (
    .clk_i     (clk_i         ),
    .rst_ni    (rst_ni        ),
    .flush_i   (1'b0          ),
    .testmode_i(1'b0          ),
    // status flags
    .full_o    (fifo_full     ), // queue is full
    .empty_o   (fifo_empty    ), // queue is empty
    .usage_o   (fifo_usage    ),
    // as long as the queue is not full we can push new data
    .data_i    (data_to_fifo  ),
    .push_i    (push_to_fifo  ),
    // as long as the queue is not empty we can pop new elements
    .data_o    (data_from_fifo),
    .pop_i     (pop_from_fifo )
  );

endmodule : ita_softmax
