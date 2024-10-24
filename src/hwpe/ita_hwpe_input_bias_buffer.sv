// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

import ita_package::*;

module ita_hwpe_input_bias_buffer #(
  parameter int unsigned INPUT_DATA_WIDTH  = 32,
  parameter int unsigned OUTPUT_DATA_WIDTH = 32
)
(
  input  logic                   clk_i ,
  input  logic                   rst_ni,
  // For the transpose
  input  logic                   bias_dir_i,
  hwpe_stream_intf_stream.sink   data_i,
  hwpe_stream_intf_stream.source data_o
);

  typedef enum logic { Read, Write } bias_state_t;

  bias_state_t state_d, state_q;

  logic [8-1:0] read_cnt_d, read_cnt_q;
  logic [4-1:0] write_cnt_d, write_cnt_q;

  logic [1:0] read_addr;
  logic write_addr;
  logic read_enable, read_enable_q;
  logic write_enable;
  logic [OUTPUT_DATA_WIDTH-1:0] read_data;

  bias_t bias_reshape;

  always_comb begin
    // Default assignments
    state_d = state_q;
    read_cnt_d  = read_cnt_q;
    write_cnt_d = write_cnt_q;
    read_addr = '0;
    write_addr = write_cnt_q;
    read_enable  = 0;
    write_enable = 0;
    data_i.ready = 0;
    data_o.valid = 0;
    data_o.strb  = 48'hFFFFFFFFFFFF;
    data_o.data  = '0;
    bias_reshape = '0;

    case(state_q)
      Write: begin
        data_i.ready = 1;
        if(data_i.valid) begin
          write_enable = 1;
          write_cnt_d = write_cnt_q + 1;
          if(write_cnt_q == 1) begin
            state_d = Read;
            write_cnt_d = 0;
          end
        end
      end
      Read: begin
        data_o.valid = read_enable_q;
        if (read_enable_q) begin
          data_o.data = read_data;
          if (bias_dir_i) begin
            bias_reshape = read_data >> read_cnt_q[3:0] * 24;
            data_o.data = {N {bias_reshape[0]}};
          end
        end
        read_enable = 1;
        if(data_o.valid && data_o.ready) begin
          read_cnt_d = read_cnt_q + 1;
          if(read_cnt_q == 255) begin
            state_d = Write;
            read_cnt_d = 0;
          end
        end
        if (bias_dir_i) begin
          read_addr = read_cnt_d[5:4];
        end else begin
          read_addr = read_cnt_d[7:6];
        end
      end
    endcase
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      state_q     <= Write;
      read_cnt_q  <= 0;
      write_cnt_q <= 0;
      read_enable_q <= 0;
    end else begin
      state_q     <= state_d;
      read_cnt_q  <= read_cnt_d;
      write_cnt_q <= write_cnt_d;
      read_enable_q <= read_enable;
    end
  end

  ita_register_file_1w_1r_double_width_write #(
    .WADDR_WIDTH(1),
    .WDATA_WIDTH(2*OUTPUT_DATA_WIDTH),
    .RDATA_WIDTH(OUTPUT_DATA_WIDTH  )
  ) i_register_file (
    .clk         (clk_i),
    .rst_n       (rst_ni),
    .ReadEnable  (read_enable),
    .ReadAddr    (read_addr),
    .ReadData    (read_data),
    .WriteEnable (write_enable),
    .WriteAddr   (write_addr),
    .WriteData   (data_i.data[2*OUTPUT_DATA_WIDTH-1:0])
  );

endmodule
