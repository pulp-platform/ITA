// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

module activation_tb;

  timeunit 10ps;
  timeprecision 1ps;
  
  import ita_package::*;

  localparam time CLK_PERIOD          = 2000ps;
  localparam time APPL_DELAY          = 400ps;
  localparam time ACQ_DELAY           = 1600ps;
  localparam unsigned RST_CLK_CYCLES  = 10;

  string constant_one_file = "Q1.txt";
  string constant_b_file = "QB.txt";
  string constant_c_file = "QC.txt";
  string constant_rqs_mul_file = "GELU_RQS_MUL.txt";
  string constant_rqs_shift_file = "GELU_RQS_SHIFT.txt";
  string constant_add_file = "GELU_RQS_ADD.txt";
  string input_file = "preactivation.txt";
  string output_file = "postactivation.txt";

  integer N_PE, M_TILE_LEN;
  integer SEQUENCE_LEN, PROJECTION_SIZE, EMBEDDING_SIZE, FEEDFORWARD_SIZE;

  logic         clk, rst_n;
  requant_oup_t preactivation_input;
  requant_oup_t expected_postactivation;
  requant_oup_t acquired_postactivation;
  logic signed [GELU_CONSTANTS_WIDTH-1:0] one;
  logic signed [GELU_CONSTANTS_WIDTH-1:0] b;
  logic signed [GELU_CONSTANTS_WIDTH-1:0] c;
  logic signed [EMS-1:0] eps_mult;
  logic signed [EMS-1:0] right_shift;
  requant_t add;
  activation_e selected_activation;

  string simdir;
  integer is_end_of_file;

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

  activation dut (
    .clk_i        (clk  ),
    .rst_ni       (rst_n),
    .one_i        (one  ),
    .b_i          (b    ),
    .c_i          (c    ),
    .data_i       (preactivation_input),
    .eps_mult_i   (eps_mult),
    .right_shift_i(right_shift),
    .activation_i (selected_activation),
    .add_i        (add  ),
    .data_o       (acquired_postactivation)
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

  function automatic void read_constant_one(integer stim_fd);
    int return_code;
    return_code = $fscanf(stim_fd, "%d", one);
  endfunction

  function automatic void read_constant_b(integer stim_fd);
    int return_code;
    return_code = $fscanf(stim_fd, "%d", b);
  endfunction

  function automatic void read_constant_c(integer stim_fd);
    int return_code;
    return_code = $fscanf(stim_fd, "%d", c);
  endfunction

  function automatic void read_constant_rqs_mul(integer stim_fd);
    int return_code;
    return_code = $fscanf(stim_fd, "%d", eps_mult);
  endfunction

  function automatic void read_constant_rqs_shift(integer stim_fd);
    int return_code;
    return_code = $fscanf(stim_fd, "%d", right_shift);
  endfunction

  function automatic void read_constant_add(integer stim_fd);
    int return_code;
    return_code = $fscanf(stim_fd, "%d", add);
  endfunction

  function automatic void read_preactivation(integer stim_fd);
    int return_code;
    for (int i = 0; i < N_PE; i++) begin
      return_code = $fscanf(stim_fd, "%d", preactivation_input[i]);
    end
  endfunction

  function automatic void read_postactivation(integer stim_fd);
    int return_code;
    for (int i = 0; i < N_PE; i++) begin
      return_code = $fscanf(stim_fd, "%d", expected_postactivation[i]);
    end
  endfunction

  initial begin: application_block
    integer one_fd;
    integer b_fd;
    integer c_fd;
    integer rqs_mul_fd;
    integer rqs_shift_fd;
    integer add_fd;
    integer input_fd;
    integer output_fd;

    is_end_of_file = 0;

    wait (rst_n);

    one_fd = open_stim_file(constant_one_file);
    b_fd = open_stim_file(constant_b_file);
    c_fd = open_stim_file(constant_c_file);
    rqs_mul_fd = open_stim_file(constant_rqs_mul_file);
    rqs_shift_fd = open_stim_file(constant_rqs_shift_file);
    add_fd = open_stim_file(constant_add_file);
    input_fd = open_stim_file(input_file);
    output_fd = open_stim_file(output_file);

    read_constant_one(one_fd);
    read_constant_b(b_fd);
    read_constant_c(c_fd);
    read_constant_rqs_mul(rqs_mul_fd);
    read_constant_rqs_shift(rqs_shift_fd);
    read_constant_add(add_fd);
    selected_activation = GELU;

    while (!is_end_of_file) begin
      @(posedge clk);
      #(APPL_DELAY);
      read_preactivation(input_fd);
      read_postactivation(output_fd);
      is_end_of_file = $feof(input_fd);
    end
    
    $fclose(one_fd);
    $fclose(b_fd);
    $fclose(c_fd);
    $fclose(input_fd);
    $fclose(output_fd);

    @(posedge clk);
  end : application_block

  initial begin: checker_block
    integer n_checks;
    integer n_errors;

    n_checks = 0;
    n_errors = 0;

    wait (rst_n);

    while (!is_end_of_file) begin
      @(posedge clk);
      #(ACQ_DELAY);

      n_checks += 1;
      for (int i = 0; i < N_PE; i++) begin
        if (acquired_postactivation[i] != expected_postactivation[i]) begin
          n_errors += 1;
          $display(":=( expected %d, not %d for input\n", expected_postactivation[i], acquired_postactivation[i], preactivation_input[i]);
        end
      end
    end
    
    @(posedge clk);

    if (n_errors > 0) begin
      $display(":=( Test failed with ", n_errors, " mismatches out of ", n_checks, " checks!");
    end else begin
      $display(":=) Test passed with ", n_errors, " mismatches out of ", n_checks, " checks!");
    end

    #(300*CLK_PERIOD);
    $finish();
  end

endmodule
