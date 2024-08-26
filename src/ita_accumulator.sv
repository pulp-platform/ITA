// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

module ita_accumulator
  import ita_package::*;
#(
  parameter LATCH_BUFFER = 0
)(
  input  logic  clk_i     ,
  input  logic  rst_ni    ,
  input  logic  calc_en_i ,
  input  logic  calc_en_q_i,
  input  logic  first_tile_i,
  input  logic  first_tile_q_i,
  input  logic  last_tile_i,
  input  logic  last_tile_q_i,
  input  oup_t  oup_i     ,
  input  bias_t inp_bias_i,
  output oup_t  result_o
);

  logic  read_en;
  logic [$clog2(M*M/N)-1:0] read_addr;
  oup_t read_data, read_data_unused;
  logic write_en;
  logic [$clog2(M*M/N)-1:0] write_addr;
  oup_t write_data;
  logic [$clog2(M*M/N)-1:0] read_addr_d, read_addr_q, write_addr_d, write_addr_q;

  oup_t result_d, result_q;

  assign result_o = result_q;

  always_comb begin
    read_addr_d    = read_addr_q;
    write_addr_d   = write_addr_q;
    result_d       = '0;
    read_en        = 1'b0;
    read_addr      = read_addr_q;
    write_en       = 1'b0;
    write_data     = '0;
    write_addr     = write_addr_q;

    if (calc_en_i && !first_tile_i) begin
      read_en = 1'b1;
      read_addr_d = read_addr_q + 1;
    end
    if (calc_en_q_i) begin
      if (first_tile_q_i && last_tile_q_i) begin
        for (int i = 0; i < N; i++) begin
          result_d[i] = oup_i[i] + WO'(signed'(inp_bias_i[i]));
        end
      end else if (first_tile_q_i) begin
        write_en = 1'b1;
        write_addr_d = write_addr_q + 1;
        for (int i = 0; i < N; i++) begin
          write_data[i] = oup_i[i];
        end
      end else if (last_tile_q_i) begin
        for (int i = 0; i < N; i++) begin
          result_d[i] = oup_i[i] + read_data[i] + WO'(signed'(inp_bias_i[i]));
        end
      end else begin
        write_en = 1'b1;
        write_addr_d = write_addr_q + 1;
        for (int i = 0; i < N; i++) begin
          write_data[i] = oup_i[i] + read_data[i];
        end
      end
    end
  end

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      read_addr_q    <= '0;
      write_addr_q   <= '0;
      result_q       <= '0;
    end else begin
      read_addr_q    <= read_addr_d;
      write_addr_q   <= write_addr_d;
      result_q       <= result_d;
    end
  end

  if (LATCH_BUFFER) begin : partialsum_buffer_latch
    register_file_1w_multi_port_read #(
      .ADDR_WIDTH($clog2(M*M/N)),
      .DATA_WIDTH(N*WO),
      .N_READ    (1     ),
      .N_WRITE   (1     )
    ) i_partialsum_buffer (
      .clk        (clk_i       ),
      .rst_n      (rst_ni      ),
      .test_en_i  (1'b0        ),

      .ReadEnable (read_en     ),
      .ReadAddr   (read_addr   ),
      .ReadData   (read_data   ),

      .WriteEnable(write_en    ),
      .WriteAddr  (write_addr  ),
      .WriteData  (write_data  )
    );
  end else begin : partialsum_buffer_sram
    tc_sram #(
      .NumWords (M*M/N),
      .DataWidth (N*WO),
      .ByteWidth (8),
      .NumPorts (2),
      .Latency (1)
    ) i_partialsum_buffer (
      .clk_i,
      .rst_ni,
      .req_i ({write_en, read_en}),
      .we_i ({1'b1, 1'b0}),
      .addr_i ({write_addr, read_addr}),
      .wdata_i ({write_data, {(N*WO){1'b0}}}),
      .be_i ({{(N*WO/8){1'b1}}, {(N*WO/8){1'b0}}}),
      .rdata_o ({read_data_unused, read_data})
    );
  end

endmodule
