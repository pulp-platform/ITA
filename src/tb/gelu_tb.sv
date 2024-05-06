// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

module gelu_tb;

  import accel_pkg::*;

  timeunit 10ps;
  timeprecision 1ps;

  localparam time CLK_PERIOD          = 2000ps;
  localparam time APPL_DELAY          = 400ps;
  localparam time ACQ_DELAY           = 1600ps;
  localparam unsigned RST_CLK_CYCLES  = 10;
  localparam unsigned CONT            = 1;

  string constant_one_file = "Q1.txt";
  string constant_b_file = "QB.txt";
  string constant_c_file = "QC.txt";
  string input_file = "preactivation.txt";
  string output_file = "postactivation.txt";

  integer N_PE, M_TILE_LEN;
  integer SEQUENCE_LEN, PROJECTION_SIZE, EMBEDDING_SIZE, FEEDFORWARD_SIZE;

  logic         clk, rst_n;
  oup_t preactivations;
  oup_t expected_postactivations;
  logic signed [GELU_CONSTANTS_WIDTH-1:0] one;
  logic signed [GELU_CONSTANTS_WIDTH-1:0] b;
  logic signed [GELU_CONSTANTS_WIDTH-1:0] c;

  string simdir;
  integer stim_applied;

  initial begin
    N_PE = `ifdef ITA_N `ITA_N `else 16 `endif;
    M_TILE_LEN = `ifdef ITA_M `ITA_M `else 64 `endif;
    SEQUENCE_LEN = `ifdef SEQ_LENGTH `SEQ_LENGTH `else M_TILE_LEN `endif;
    PROJECTION_SIZE = `ifdef PROJ_SPACE `PROJ_SPACE `else M_TILE_LEN `endif;
    EMBEDDING_SIZE = `ifdef EMBED_SIZE `EMBED_SIZE `else M_TILE_LEN `endif;
    FEEDFORWARD_SIZE = `ifdef FF_SIZE `FF_SIZE `else M_TILE_LEN `endif;
    simdir = {
      "../../simvectors/data_S",
      $sformatf("%0d", SEQUENCE_LEN),
      "_E",
      $sformatf("%0d", EMBEDDING_SIZE),
      "_P",
      $sformatf("%0d", PROJECTION_SIZE),
      "_F",
      $sformatf("%0d", FEEDFORWARD_SIZE),
      "_H1_B",
      $sformatf("%0d", `ifdef BIAS `BIAS `else 0 `endif)
    };
  end

  clk_rst_gen #(
    .CLK_PERIOD    (CLK_PERIOD    ),
    .RST_CLK_CYCLES(RST_CLK_CYCLES)
  ) i_clk_rst_gen (
    .clk_o (clk  ),
    .rst_no(rst_n)
  );

  ita_gelu i_dut (
    .clk_i        (clk  ),
    .rst_ni       (rst_n),
    .one_i        (one  ),
    .b_i          (b    ),
    .c_i          (c    ),
    .data_i       (preactivations[0]),
    .data_o       (expected_postactivations[0])
  );

  function automatic integer open_stim_file(string filename);
    integer stim_fd;
    if (filename == "")
      return 0;
    stim_fd = $fopen({simdir,"/",filename}, "r");
    if (stim_fd == 0) begin
      $fatal(1, "[TB] ITA: Could not open %s stim file!", filename);
    end
    return stim_fd;
  endfunction

  function automatic void read_constant_one(integer stim_fd, string filename);
    int return_code;
    $display("[TB] ITA: Reading %s file:", filename);
    return_code = $fscanf(stim_fd, "%d", one);
    $display("%d", one);
  endfunction

  function automatic void read_constant_b(integer stim_fd, string filename);
    int return_code;
    $display("[TB] ITA: Reading %s file:", filename);
    return_code = $fscanf(stim_fd, "%d", b);
    $display("%d", b);
  endfunction

  function automatic void read_constant_c(integer stim_fd, string filename);
    int return_code;
    $display("[TB] ITA: Reading %s file:", filename);
    return_code = $fscanf(stim_fd, "%d", c);
    $display("%d", c);
  endfunction

  function automatic void read_preactivations(integer stim_fd, string filename);
    int return_code;
    $display("[TB] ITA: Reading %s file:", filename);
    for (int i = 0; i < 1; i++) begin
      return_code = $fscanf(stim_fd, "%d", preactivations[i]);
      $display("%d", preactivations[i]);
    end
  endfunction

  function automatic void read_postactivations(integer stim_fd, string filename);
    int return_code;
    $display("[TB] ITA: Reading %s file:", filename);
    for (int i = 0; i < 1; i++) begin
      return_code = $fscanf(stim_fd, "%d", expected_postactivations[i]);
      $display("%d", expected_postactivations[i]);
    end
  endfunction

  initial begin: application_block
    integer one_fd;
    integer b_fd;
    integer c_fd;
    integer input_fd;
    integer output_fd;
    integer is_end_of_file;

    is_end_of_file = 0;

    wait (rst_n);

    @(posedge clk);
    #(APPL_DELAY);
    one_fd = open_stim_file(constant_one_file);
    b_fd = open_stim_file(constant_b_file);
    c_fd = open_stim_file(constant_c_file);
    input_fd = open_stim_file(input_file);
    output_fd = open_stim_file(output_file);

    read_constant_one(one_fd, constant_one_file);
    read_constant_b(b_fd, constant_b_file);
    read_constant_c(c_fd, constant_c_file);

    while (!is_end_of_file) begin
      read_preactivations(input_fd, input_file);
      read_postactivations(output_fd, output_file);
      is_end_of_file = 1;
    end
    
    stim_applied = 1;
    $fclose(one_fd);
    $fclose(b_fd);
    $fclose(c_fd);
    $fclose(input_fd);
    $fclose(output_fd);

    @(posedge clk);


  end

  initial begin: checker_block
    wait (stim_applied);

    @(posedge clk);

    #(300*CLK_PERIOD);
    $stop();
  end

endmodule
