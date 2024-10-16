// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

/**
  ITA top module.
*/

module ita
  import ita_package::*;
(
  input  logic         clk_i             ,
  input  logic         rst_ni            ,
  // Network sizes
  input  ctrl_t        ctrl_i            ,
  // Handshake
  input  logic         inp_valid_i       ,
  output logic         inp_ready_o       ,
  input  logic         inp_weight_valid_i,
  output logic         inp_weight_ready_o,
  input  logic         inp_bias_valid_i  ,
  output logic         inp_bias_ready_o  ,
  output logic         valid_o           ,
  input  logic         ready_i           ,
  output logic         busy_o            ,
  // Input
  input  inp_t         inp_i             ,
  // Weights and biases
  input  inp_weight_t  inp_weight_i      ,
  input  bias_t        inp_bias_i        ,
  // Output
  output requant_oup_t oup_o
);

  step_e  step, step_q1, step_q2, step_q3, step_q4, step_q5, step_q6;
  logic   calc_en, calc_en_q1, calc_en_q2, calc_en_q3, calc_en_q4, calc_en_q5, calc_en_q6, calc_en_q7, calc_en_q8, calc_en_q9, calc_en_q10;
  logic   first_inner_tile, first_inner_tile_q1, first_inner_tile_q2, first_inner_tile_q3;
  logic   last_inner_tile, last_inner_tile_q1, last_inner_tile_q2, last_inner_tile_q3, last_inner_tile_q4, last_inner_tile_q5, last_inner_tile_q6, last_inner_tile_q7, last_inner_tile_q8, last_inner_tile_q9, last_inner_tile_q10;

  logic         weight_valid, weight_ready;
  inp_t         inp, inp_stream_soft;
  weight_t      inp1, inp1_q, inp2, inp2_q;
  bias_t        inp_bias, inp_bias_padded, inp_bias_q1, inp_bias_q2;
  oup_t         oup, oup_q, accumulator_oup;
  requant_const_t    requant_mult, requant_shift, activation_requant_mult, activation_requant_shift;
  requant_oup_t requant_oup;
  requant_t         requant_add, activation_requant_add;
  requant_mode_e    requant_mode, activation_requant_mode;
  requant_oup_t post_activation;

  // FIFO signals
  logic        fifo_full, fifo_empty, push_to_fifo, pop_from_fifo;
  fifo_data_t  data_to_fifo, data_from_fifo;
  fifo_usage_t fifo_usage  ;

  // Softmax signals
  logic pop_softmax_fifo;
  counter_t soft_addr_div;
  logic softmax_done;

  // Weight buffer signals
  logic          read_en, read_addr, write_en, write_addr;
  weight_t       read_data   ;
  write_data_t   write_data  ;
  write_select_t write_select;

  // Activation signals
  activation_e activation_q1, activation_q2, activation_q3, activation_q4, activation_q5, activation_q6, activation_q7, activation_q8, activation_q9, activation_q10;

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      calc_en_q10           <= 0;
      calc_en_q9            <= 0;
      calc_en_q8            <= 0;
      calc_en_q7            <= 0;
      calc_en_q6            <= 0;
      calc_en_q5            <= 0;
      calc_en_q4            <= 0;
      calc_en_q3            <= 0;
      calc_en_q2            <= 0;
      calc_en_q1            <= 0;
      first_inner_tile_q3   <= 0;
      first_inner_tile_q2   <= 0;
      first_inner_tile_q1   <= 0;
      last_inner_tile_q10    <= 0;
      last_inner_tile_q9    <= 0;
      last_inner_tile_q8    <= 0;
      last_inner_tile_q7    <= 0;
      last_inner_tile_q6    <= 1'b0;
      last_inner_tile_q5    <= 1'b0;
      last_inner_tile_q4    <= 1'b0;
      last_inner_tile_q3    <= 1'b0;
      last_inner_tile_q2    <= 1'b0;
      last_inner_tile_q1    <= 1'b0;
      step_q6               <= Idle;
      step_q5               <= Idle;
      step_q4               <= Idle;
      step_q3               <= Idle;
      step_q2               <= Idle;
      step_q1               <= Idle;
      activation_q8         <= Identity;
      activation_q7         <= Identity;
      activation_q6         <= Identity;
      activation_q5         <= Identity;
      activation_q4         <= Identity;
      activation_q3         <= Identity;
      activation_q2         <= Identity;
      activation_q1         <= Identity;
    end else begin
      calc_en_q10           <= calc_en_q9;
      calc_en_q9            <= calc_en_q8;
      calc_en_q8            <= calc_en_q7;
      calc_en_q7            <= calc_en_q6;
      calc_en_q6            <= calc_en_q5;
      calc_en_q5            <= calc_en_q4;
      calc_en_q4            <= calc_en_q3;
      calc_en_q3            <= calc_en_q2;
      calc_en_q2            <= calc_en_q1;
      calc_en_q1            <= calc_en;
      first_inner_tile_q3   <= first_inner_tile_q2;
      first_inner_tile_q2   <= first_inner_tile_q1;
      first_inner_tile_q1   <= first_inner_tile;
      last_inner_tile_q10    <= last_inner_tile_q9;
      last_inner_tile_q9    <= last_inner_tile_q8;
      last_inner_tile_q8    <= last_inner_tile_q7;
      last_inner_tile_q7    <= last_inner_tile_q6;
      last_inner_tile_q6    <= last_inner_tile_q5;
      last_inner_tile_q5    <= last_inner_tile_q4;
      last_inner_tile_q4    <= last_inner_tile_q3;
      last_inner_tile_q3    <= last_inner_tile_q2;
      last_inner_tile_q2    <= last_inner_tile_q1;
      last_inner_tile_q1    <= last_inner_tile;
      step_q6               <= step_q5;
      step_q5               <= step_q4;
      step_q4               <= step_q3;
      step_q3               <= step_q2;
      step_q2               <= step_q1;
      step_q1               <= step;
      activation_q10        <= activation_q9;
      activation_q9         <= activation_q8;
      activation_q8         <= activation_q7;
      activation_q7         <= activation_q6;
      activation_q6         <= activation_q5;
      activation_q5         <= activation_q4;
      activation_q4         <= activation_q3;
      activation_q3         <= activation_q2;
      activation_q2         <= activation_q1;
      activation_q1         <= ctrl_i.activation;
    end
  end

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      inp1_q      <= '0;
      inp2_q      <= '0;
      inp_bias_q2 <= '0;
      inp_bias_q1 <= '0;
      oup_q       <= '0;
    end else begin
      if (calc_en_q2) begin
        inp_bias_q2 <= inp_bias_q1;
        oup_q       <= oup;
      end
      if (calc_en_q1) begin
        inp_bias_q1 <= inp_bias_padded;
        inp1_q      <= inp1;
        inp2_q      <= inp2;
      end
    end
  end

  assign oup_o = valid_o ? data_from_fifo : '0;

  requant_oup_t requant_add_o;

  counter_t inner_tile;
  counter_t tile_x;
  counter_t tile_y;

  ita_controller i_controller (
    .clk_i                (clk_i              ),
    .rst_ni               (rst_ni             ),
    .ctrl_i               (ctrl_i             ),
    .inp_valid_i          (inp_valid_i        ),
    .inp_ready_o          (inp_ready_o        ),
    .weight_valid_i       (weight_valid       ),
    .weight_ready_o       (weight_ready       ),
    .bias_valid_i         (inp_bias_valid_i   ),
    .bias_ready_o         (inp_bias_ready_o   ),
    .oup_valid_i          (valid_o            ),
    .oup_ready_i          (ready_i            ),
    .step_o               (step               ),
    .soft_addr_div_i      (soft_addr_div      ),
    .softmax_done_i       (softmax_done       ),
    .pop_softmax_fifo_i   (pop_softmax_fifo   ),
    .calc_en_o            (calc_en            ),
    .first_inner_tile_o   (first_inner_tile   ),
    .last_inner_tile_o    (last_inner_tile    ),
    .tile_x_o             (tile_x             ),
    .tile_y_o             (tile_y             ),
    .inner_tile_o         (inner_tile         ),
    .requant_add_i        (requant_add        ),
    .requant_add_o        (requant_add_o      ),
    .inp_bias_pad_i       (inp_bias           ),
    .inp_bias_pad_o       (inp_bias_padded    ),
    .busy_o               (busy_o             )
  );

  ita_input_sampler i_input_sampler (
    .clk_i       (clk_i           ),
    .rst_ni      (rst_ni          ),
    .valid_i     (inp_valid_i     ),
    .ready_i     (inp_ready_o     ),
    .inp_i       (inp_i           ),
    .inp_bias_i  ((step == QK || step == AV) ? '0 : ((step == V) ? {N {inp_bias_i[0]}} : inp_bias_i) ), // TODO: temporary fix
    .inp_o       (inp             ),
    .inp_bias_o  (inp_bias        )
  );

  ita_inp1_mux i_inp1_mux (
    .clk_i    (clk_i                                  ),
    .rst_ni   (rst_ni                                 ),
    .calc_en_i(calc_en_q1                             ),
    .inp_i    ((step_q1 == AV) ? inp_stream_soft : inp),
    .inp1_o   (inp1                                   )
  );

  ita_inp2_mux i_inp2_mux (
    .clk_i    (clk_i     ),
    .rst_ni   (rst_ni    ),
    .calc_en_i(calc_en_q1),
    .weight_i (read_data ),
    .inp2_o   (inp2      )
  );

  ita_sumdotp i_sumdotp (
    .sign_mode_i((step_q2 == AV) ? 1'b0 : 1'b1),
    .inp1_i     (inp1_q                       ),
    .inp2_i     (inp2_q                       ),
    .oup_o      (oup                          )
  );

  ita_accumulator i_accumulator (
    .clk_i         (clk_i              ),
    .rst_ni        (rst_ni             ),

    .calc_en_i     (calc_en_q2         ),
    .calc_en_q_i   (calc_en_q3         ),
    .first_tile_i  (first_inner_tile_q2),
    .first_tile_q_i(first_inner_tile_q3),
    .last_tile_i   (last_inner_tile_q2 ),
    .last_tile_q_i (last_inner_tile_q3 ),

    .oup_i         (oup_q              ),
    .inp_bias_i    (inp_bias_q2        ),
    .result_o      (accumulator_oup    )
  );

  ita_softmax_top i_softmax_top (
    .clk_i                (clk_i                           ),
    .rst_ni               (rst_ni                          ),
    .ctrl_i               (ctrl_i                          ),
    .requant_oup_i        (requant_oup                     ),
    .step_i               (step_q6                         ),
    .calc_en_i            (calc_en_q6 && last_inner_tile_q6),
    .inp_i                (inp                             ),
    .calc_stream_soft_en_i((step == AV) && calc_en         ),
    .soft_addr_div_o      (soft_addr_div                   ),
    .softmax_done_o       (softmax_done                    ),
    .pop_softmax_fifo_o   (pop_softmax_fifo                ),
    .inp_stream_soft_o    (inp_stream_soft                 ),
    .tile_x_i             (tile_x                          ),
    .tile_y_i             (tile_y                          ),
    .inner_tile_i         (inner_tile                      )
  );


  ita_requatization_controller i_requantization_controller (
    .ctrl_i             (ctrl_i            ),
    .requantizer_step_i (step_q4          ),
    .requant_mult_o     (requant_mult     ),
    .requant_shift_o    (requant_shift    ),
    .requant_add_o      (requant_add      ),
    .requant_mode_o     (requant_mode     ),
    .activation_requant_mult_o (activation_requant_mult),
    .activation_requant_shift_o(activation_requant_shift),
    .activation_requant_add_o  (activation_requant_add  ),
    .activation_requant_mode_o (activation_requant_mode )
  );

  ita_requantizer i_requantizer (
    .clk_i        ( clk_i             ),
    .rst_ni       ( rst_ni            ),

    .mode_i       ( requant_mode      ),
    .eps_mult_i   ( requant_mult      ),
    .right_shift_i( requant_shift     ),

    .calc_en_i    ( calc_en_q4 && last_inner_tile_q4       ),
    .calc_en_q_i  ( calc_en_q5 && last_inner_tile_q5       ),
    .result_i     ( accumulator_oup   ),
    .add_i        ( requant_add_o     ),
    .requant_oup_o( requant_oup       )
  );

  ita_activation i_activation (
    .clk_i         (clk_i       ),
    .rst_ni        (rst_ni      ),
    .activation_i  (activation_q10),
    .calc_en_i     (calc_en_q6 && last_inner_tile_q6  ),
    .calc_en_q_i  (calc_en_q7 && last_inner_tile_q7  ),
    .b_i           (ctrl_i.gelu_b  ),
    .c_i           (ctrl_i.gelu_c  ),
    .requant_mode_i  (activation_requant_mode),
    .requant_mult_i    (activation_requant_mult),
    .requant_shift_i (activation_requant_shift),
    .requant_add_i         (activation_requant_add),
    .data_i        (requant_oup),
    .data_o        (post_activation)
  );

  ita_fifo_controller i_fifo_controller (
    .clk_i         (clk_i       ),
    .rst_ni        (rst_ni      ),

    .requant_oup_i (post_activation),
    .activation_done_i     (calc_en_q10 && last_inner_tile_q10 ),
    .fifo_full_i   (fifo_full   ),
    .push_to_fifo_o(push_to_fifo),
    .data_to_fifo_o(data_to_fifo)
  );

  ita_output_controller i_output_controller (
    .clk_i             (clk_i           ),
    .rst_ni            (rst_ni          ),

    .fifo_empty_i      (fifo_empty      ),
    .pop_from_fifo_o   (pop_from_fifo   ),
    .data_from_fifo_i  (data_from_fifo  ),

    .ready_i           (ready_i         ),
    .valid_o           (valid_o         )
  );

  fifo_v3 #(
    .FALL_THROUGH(1'b0     ),
    .DATA_WIDTH  (N*WI     ),
    .DEPTH       (FifoDepth)
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

  ita_weight_controller i_weight_controller (
    .clk_i             (clk_i             ),
    .rst_ni            (rst_ni            ),

    .inp_weight_valid_i(inp_weight_valid_i),
    .inp_weight_ready_o(inp_weight_ready_o),
    .inp_weight_i      (inp_weight_i      ),

    .weight_valid_o    (weight_valid      ),
    .weight_ready_i    (weight_ready      ),

    .read_en_o         (read_en           ),
    .read_addr_o       (read_addr         ),

    .write_en_o        (write_en          ),
    .write_addr_o      (write_addr        ),
    .write_data_o      (write_data        ),
    .write_select_o    (write_select      )
  );

  ita_register_file_1w_multi_port_read_we #(
    .ADDR_WIDTH(1         ),
    .DATA_WIDTH(N*M*WI    ),
    .N_READ    (1         ),
    .N_WRITE   (1         ),
    .N_EN      (N_WRITE_EN)
  ) i_weight_buffer (
    .clk        (clk_i       ),
    .rst_n      (rst_ni      ),

    .ReadEnable (read_en     ),
    .ReadAddr   (read_addr   ),
    .ReadData   (read_data   ),

    .WriteEnable(write_en    ),
    .WriteAddr  (write_addr  ),
    .WriteData  (write_data  ),
    .WriteSelect(write_select)
  );

  // pragma translate_off
  // Monitor FIFO usage
  ongoing_t fifo_usage_max;
  step_e step_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_fifo_usage_max
    if(~rst_ni || step == Idle) begin
      fifo_usage_max <= 0;
      step_q <= Idle;
    end else if (fifo_usage>fifo_usage_max || fifo_full) begin
      fifo_usage_max <= fifo_usage;
      if (fifo_full)
        fifo_usage_max <= FifoDepth;
      step_q <= step;
    end
    if ((step_q==OW) && (step==Idle)) begin
      $display("[ITA] Max FIFO usage during Attention: %d", fifo_usage_max);
    end
    if ((step_q==F2) && (step==Idle)) begin
      $display("[ITA] Max FIFO usage during Feedforward: %d", fifo_usage_max);
    end
  end
  // pragma translate_on
endmodule
