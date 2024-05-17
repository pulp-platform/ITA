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
  localparam logic requant_mode       = 1'b0;

  string constant_one_file = "GELU_ONE.txt";
  string constant_b_file = "GELU_B.txt";
  string constant_c_file = "GELU_C.txt";
  string constant_rqs_mul_file = "GELU_RQS_MUL.txt";
  string constant_rqs_shift_file = "GELU_RQS_SHIFT.txt";
  string constant_add_file = "GELU_RQS_ADD.txt";
  string input_file = "standalone/preactivation.txt";
  string output_file = "standalone/postactivation.txt";

  integer N_PE, M_TILE_LEN;
  integer SEQUENCE_LEN, PROJECTION_SIZE, EMBEDDING_SIZE, FEEDFORWARD_SIZE;

  logic         clk, rst_n;
  requant_oup_t preactivation_input;
  requant_oup_t preactivation_input_check;
  requant_oup_t expected_postactivation;
  requant_oup_t acquired_postactivation;
  gelu_const_t gelu_one;
  gelu_const_t gelu_b;
  gelu_const_t gelu_c;
  requant_const_t gelu_requant_mult;
  requant_const_t gelu_requant_shift;
  requant_t gelu_requant_add;
  activation_e selected_activation;

  string simdir;

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
    .one_i        (gelu_one  ),
    .b_i          (gelu_b    ),
    .c_i          (gelu_c    ),
    .data_i       (preactivation_input),
    .requant_mode(requant_mode),
    .requant_mult_i   (gelu_requant_mult),
    .requant_shift_i(gelu_requant_shift),
    .activation_i (selected_activation),
    .requant_add_i        (gelu_requant_add  ),
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

  function automatic void read_preactivation(integer stim_fd);
    int return_code;
    for (int i = 0; i < N_PE; i++) begin
      return_code = $fscanf(stim_fd, "%d", preactivation_input[i]);
    end
  endfunction

  function automatic void read_preactivation_check(integer stim_fd);
    int return_code;
    for (int i = 0; i < N_PE; i++) begin
      return_code = $fscanf(stim_fd, "%d", preactivation_input_check[i]);
    end
  endfunction

  function automatic void read_postactivation(integer stim_fd);
    int return_code;
    for (int i = 0; i < N_PE; i++) begin
      return_code = $fscanf(stim_fd, "%d", expected_postactivation[i]);
    end
  endfunction

  task automatic read_gelu_constants(
    output gelu_const_t gelu_one,
    output gelu_const_t gelu_b,
    output gelu_const_t gelu_c,
    output requant_const_t gelu_requant_mult,
    output requant_const_t gelu_requant_shift,
    output requant_t gelu_requant_add
  );
    integer one_fd;
    integer b_fd;
    integer c_fd;
    integer rqs_mul_fd;
    integer rqs_shift_fd;
    integer add_fd;
    int return_code;

    one_fd = open_stim_file(constant_one_file);
    b_fd = open_stim_file(constant_b_file);
    c_fd = open_stim_file(constant_c_file);
    rqs_mul_fd = open_stim_file(constant_rqs_mul_file);
    rqs_shift_fd = open_stim_file(constant_rqs_shift_file);
    add_fd = open_stim_file(constant_add_file);

    return_code = $fscanf(one_fd, "%d", gelu_one);
    return_code = $fscanf(b_fd, "%d", gelu_b);
    return_code = $fscanf(c_fd, "%d", gelu_c);
    return_code = $fscanf(rqs_mul_fd, "%d", gelu_requant_mult);
    return_code = $fscanf(rqs_shift_fd, "%d", gelu_requant_shift);
    return_code = $fscanf(add_fd, "%d", gelu_requant_add);

    $fclose(one_fd);
    $fclose(b_fd);
    $fclose(c_fd);
    $fclose(rqs_mul_fd);
    $fclose(rqs_shift_fd);
    $fclose(add_fd);
  endtask

  initial begin: application_block
    integer input_fd;
    integer is_end_of_file;

    is_end_of_file = 0;

    wait (rst_n);

    read_gelu_constants(gelu_one, gelu_b, gelu_c, gelu_requant_mult, gelu_requant_shift, gelu_requant_add);

    input_fd = open_stim_file(input_file);

    while (!is_end_of_file) begin
      @(posedge clk);
      #(APPL_DELAY);
      read_preactivation(input_fd);
      is_end_of_file = $feof(input_fd);
      selected_activation = GELU;

      // @(posedge clk);
      // #(APPL_DELAY);
      // selected_activation = RELU;

      // @(posedge clk);
      // #(APPL_DELAY);
      // selected_activation = IDENTITY;
    end
    
    $fclose(input_fd);

    @(posedge clk);
  end : application_block

  function automatic void validate_postactivation(inout integer n_checks, inout integer n_errors);
      n_checks += N_PE;
      for (int i = 0; i < N_PE; i++) begin
        if (acquired_postactivation[i] !== expected_postactivation[i]) begin
          n_errors += 1;
          if (n_errors <= 10) begin
            $display(":=( expected %d, not %d for input %d and activation %s at %0d\n", expected_postactivation[i], acquired_postactivation[i], preactivation_input[i], selected_activation, $time);
          end
          if (n_errors == 11) begin
            $display(":=( suppressing further mismatches...\n");
          end
        end
      end
  endfunction

  initial begin: checker_block
    integer is_end_of_file;
    integer n_checks;
    integer n_errors;
    integer input_fd;
    integer output_fd;

    is_end_of_file = 0;
    n_checks = 0;
    n_errors = 0;

    wait (rst_n);

    input_fd = open_stim_file(input_file);
    output_fd = open_stim_file(output_file);
    
    // Wait two extra cycles for requantization to complete
    repeat (2) @(posedge clk);

    while (!is_end_of_file) begin
      @(posedge clk);
      #(ACQ_DELAY);
      // Validate GELU
      read_preactivation_check(input_fd);
      is_end_of_file = $feof(input_fd);
      read_postactivation(output_fd);
      validate_postactivation(n_checks, n_errors);

      // @(posedge clk);
      // #(ACQ_DELAY);
      // // Validate RELU
      // for (int i = 0; i < N_PE; i++) begin
      //   expected_postactivation[i] = preactivation_input[i] < 0 ? 0 : preactivation_input[i];
      // end
      // validate_postactivation(n_checks, n_errors);

      // @(posedge clk);
      // #(ACQ_DELAY);
      // Validate IDENTITY
      // for (int i = 0; i < N_PE; i++) begin
      //   expected_postactivation[i] = preactivation_input_check[i];
      // end
      // validate_postactivation(n_checks, n_errors);
    end
    
    @(posedge clk);

    if (n_errors > 0) begin
      $display(":=( Test failed with ", n_errors, " mismatches out of ", n_checks, " checks!");
    end else begin
      $display(":=) Test passed with ", n_errors, " mismatches out of ", n_checks, " checks!");
    end

    $fclose(input_fd);
    $fclose(output_fd);

    #(100*CLK_PERIOD);
    $finish();
  end

endmodule
