// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51


module ita_softmax_top
  import ita_package::*;
(
  input  logic         clk_i                ,
  input  logic         rst_ni               ,
  input  ctrl_t        ctrl_i               ,
  // Input
  input  requant_oup_t requant_oup_i        ,
  input  step_e        step_i               ,
  input  logic         calc_en_i            ,
  input  inp_t         inp_i                ,
  input  logic         calc_stream_soft_en_i,
  // Output
  output counter_t     soft_addr_div_o      ,
  output logic         softmax_done_o       ,
  output logic         pop_softmax_fifo_o   ,
  output inp_t         inp_stream_soft_o    ,
  input  counter_t     tile_x_i             ,
  input  counter_t     tile_y_i             ,
  input  counter_t     inner_tile_i

);

  logic          [1:0]                                       read_acc_en;
  logic          [1:0][SoftmaxAccDataWidth-1:0]              read_acc_data;
  logic          [1:0][     InputAddrWidth-1:0]              read_acc_addr;
  logic                                                      write_acc_en;
  logic          [SoftmaxAccDataWidth-1:0]                   write_acc_data;
  logic          [     InputAddrWidth-1:0]                   write_acc_addr;
  logic          [SoftmaxAccDataWidth-1:0]                   div_inp      ;
  logic          [             NumDiv-1:0]                   div_valid_inp, div_ready_inp;
  logic          [             NumDiv-1:0]                   div_valid_oup, div_ready_oup;
  logic unsigned [             NumDiv-1:0][DividerWidth-1:0] div_oup      ;
  logic unsigned [       DividerWidth-1:0]                   val          ;

  requant_oup_t max_in  ;
  requant_t     prev_max, max_out;

  ita_max_finder i_max_finder (
    .clk_i     (clk_i        ),
    .rst_ni    (rst_ni       ),
    .x_i       (max_in       ),
    .prev_max_i(prev_max     ),
    .max_o     (max_out      ),
    .max_diff_o(/* unused */ )
  );

  logic [1:0]                     read_max_en;
  requant_t [1:0]                 read_max_data;
  logic [1:0][InputAddrWidth-1:0] read_max_addr;

  logic                      write_max_en;
  requant_t                  write_max_data;
  logic [InputAddrWidth-1:0] write_max_addr;

  ita_register_file_1w_multi_port_read #(
    .ADDR_WIDTH(InputAddrWidth),
    .DATA_WIDTH(WI            ),
    .N_READ    (2             ),
    .N_WRITE   (1             )
  ) i_softmax_max_buffer (
    .clk        (clk_i         ),
    .rst_n      (rst_ni        ),
    .test_en_i  (1'b0          ),

    .ReadEnable (read_max_en   ),
    .ReadAddr   (read_max_addr ),
    .ReadData   (read_max_data ),

    .WriteEnable(write_max_en  ),
    .WriteAddr  (write_max_addr),
    .WriteData  (write_max_data)
  );

  ita_softmax i_softmax (
    .clk_i                (clk_i                ),
    .rst_ni               (rst_ni               ),
    .ctrl_i               (ctrl_i               ),
    .step_i               (step_i               ),
    .calc_en_i            (calc_en_i            ),
    .requant_oup_i        (requant_oup_i        ),

    .calc_stream_soft_en_i(calc_stream_soft_en_i),
    .soft_addr_div_o      (soft_addr_div_o      ),
    .softmax_done_o       (softmax_done_o       ),
    .pop_softmax_fifo_o   (pop_softmax_fifo_o   ),
    .inp_i                (inp_i                ),
    .inp_stream_soft_o    (inp_stream_soft_o    ),

    .div_inp_o            (div_inp              ),
    .div_valid_o          (div_valid_inp        ),
    .div_ready_i          (div_ready_inp        ),
    .div_valid_i          (div_valid_oup        ),
    .div_ready_o          (div_ready_oup        ),
    .div_oup_i            (div_oup              ),

    .read_acc_en_o        (read_acc_en          ),
    .read_acc_addr_o      (read_acc_addr        ),
    .read_acc_data_i      (read_acc_data        ),

    .write_acc_en_o       (write_acc_en         ),
    .write_acc_addr_o     (write_acc_addr       ),
    .write_acc_data_o     (write_acc_data       ),

    .prev_max_o           (prev_max             ),
    .max_i                (max_out              ),
    .max_o                (max_in               ),

    .read_max_en_o        (read_max_en          ),
    .read_max_addr_o      (read_max_addr        ),
    .read_max_data_i      (read_max_data        ),

    .write_max_en_o       (write_max_en         ),
    .write_max_addr_o     (write_max_addr       ),
    .write_max_data_o     (write_max_data       ),

    .tile_x_i             (tile_x_i             ),
    .tile_y_i             (tile_y_i             ),
    .inner_tile_i         (inner_tile_i          )
  );

  ita_register_file_1w_multi_port_read #(
    .ADDR_WIDTH(InputAddrWidth     ),
    .DATA_WIDTH(SoftmaxAccDataWidth),
    .N_READ    (2                  ),
    .N_WRITE   (1                  )
  ) i_softmax_acc_buffer (
    .clk        (clk_i         ),
    .rst_n      (rst_ni        ),
    .test_en_i  (1'b0          ),

    .ReadEnable (read_acc_en   ),
    .ReadAddr   (read_acc_addr ),
    .ReadData   (read_acc_data ),

    .WriteEnable(write_acc_en  ),
    .WriteAddr  (write_acc_addr),
    .WriteData  (write_acc_data)
  );

  // Softmax
  assign val = SoftmaxScalar;

  for (genvar i = 0; i < NumDiv; i++) begin
    ita_serdiv #(
      .WIDTH(DividerWidth)
    ) i_serdiv (
      .clk_i    (clk_i                 ),
      .rst_ni   (rst_ni                ),

      .op_a_i   (val                   ),
      .op_b_i   (DividerWidth'(div_inp)),
      .opcode_i ('0                    ),
      .in_vld_i (div_valid_inp[i]      ),
      .in_rdy_o (div_ready_inp[i]      ),
      .flush_i  (1'b0                  ),
      .out_vld_o(div_valid_oup[i]      ),
      .out_rdy_i(div_ready_oup[i]      ),
      .res_o    (div_oup[i]            )
    );
  end

endmodule
