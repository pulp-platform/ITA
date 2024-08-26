// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

module ita_weight_controller
  import ita_package::*;
(
  input  logic          clk_i             ,
  input  logic          rst_ni            ,
  input  logic          inp_weight_valid_i,
  output logic          inp_weight_ready_o,
  output logic          weight_valid_o    ,
  input  logic          weight_ready_i    ,
  output logic          read_en_o         ,
  output logic          read_addr_o       ,
  input  inp_weight_t   inp_weight_i      ,
  output logic          write_en_o        ,
  output logic          write_addr_o      ,
  output write_data_t   write_data_o      ,
  output write_select_t write_select_o
);

  logic [            1:0] status_d, status_q;
  logic                   write_addr_d, write_addr_q, read_addr_d, read_addr_q;
  logic [  $clog2(N_WRITE_EN)-1:0] next_d, next_q;
  logic [$clog2(S+1)-1:0] weight_cnt_d, weight_cnt_q;

  assign write_addr_o = write_addr_q;
  assign read_addr_o = read_addr_q;

  always_comb begin
    // Default assignments
    status_d           = status_q;
    write_addr_d       = write_addr_q;
    read_addr_d        = read_addr_q;
    next_d             = next_q;
    weight_cnt_d       = weight_cnt_q;
    inp_weight_ready_o = 0;
    weight_valid_o     = 0;
    read_en_o          = 0;
    write_en_o         = 0;
    write_data_o       = '0;
    write_select_o     = '0;
    if (!status_q[write_addr_q]) begin
      inp_weight_ready_o = 1;
      if (inp_weight_valid_i) begin
        next_d                 = next_q + 1;
        write_en_o             = 1;
        write_data_o[next_q]   = inp_weight_i;
        write_select_o[next_q] = 1;
        if (next_d==0) begin
          status_d[write_addr_q] = 1;
          write_addr_d           = ~write_addr_q;
        end
      end
    end
    if (status_q[read_addr_q]) begin
      weight_valid_o = 1;
      if (weight_ready_i) begin
        read_en_o = 1;
      end
    end
    if (weight_valid_o && weight_ready_i) begin
      weight_cnt_d = weight_cnt_q + 1;
      if (weight_cnt_d==S) begin
        weight_cnt_d          = 0;
        status_d[read_addr_q] = 0;
        read_addr_d           = ~read_addr_q;
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      status_q       <= '0;
      write_addr_q   <= 0;
      read_addr_q    <= 0;
      next_q         <= '0;
      weight_cnt_q   <= '0;
    end else begin
      status_q       <= status_d;
      write_addr_q   <= write_addr_d;
      read_addr_q    <= read_addr_d;
      next_q         <= next_d;
      weight_cnt_q   <= weight_cnt_d;
    end
  end
endmodule
