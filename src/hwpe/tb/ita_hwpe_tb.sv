// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

`include "hci_helpers.svh"

module ita_hwpe_tb;

  import ita_hwpe_package::*;
  import ita_package::*;
  import hci_package::*;
  import hwpe_stream_package::*;

  timeunit 10ps;
  timeprecision 1ps;

  localparam time CLK_PERIOD          = 2000ps;
  localparam time APPL_DELAY          = 400ps;
  localparam time ACQ_DELAY           = 1600ps;
  localparam unsigned RST_CLK_CYCLES  = 10;

  // Parameters
  parameter integer N_PE = `ifdef ITA_N `ITA_N `else 16 `endif;
  parameter integer M_TILE_LEN = `ifdef ITA_M `ITA_M `else 64 `endif;
  parameter integer SEQUENCE_LEN = `ifdef SEQ_LENGTH `SEQ_LENGTH `else M_TILE_LEN `endif;
  parameter integer PROJECTION_SPACE = `ifdef PROJ_SPACE `PROJ_SPACE `else M_TILE_LEN `endif;
  parameter integer EMBEDDING_SIZE = `ifdef EMBED_SIZE `EMBED_SIZE `else M_TILE_LEN `endif;
  parameter integer FEEDFORWARD_SIZE = `ifdef FF_SIZE `FF_SIZE `else M_TILE_LEN `endif;
  parameter activation_e ACTIVATION = `ifdef ACTIVATION `ACTIVATION `else Identity `endif;

  integer N_TILES_SEQUENCE_DIM, N_TILES_EMBEDDING_DIM, N_TILES_PROJECTION_DIM, N_TILES_FEEDFORWARD_DIM;
  integer N_ELEMENTS_PER_TILE;
  integer N_TILES_OUTER_X[N_STATES], N_TILES_OUTER_Y [N_STATES], N_TILES_INNER_DIM[N_STATES];

  // Memory Map with
  // 0:  q  (SxE bytes)
  // 1:  k  (SxE bytes)
  // 2:  Wq (ExP bytes)
  // 3:  Wk (ExP bytes)
  // 4:  Wv (ExP bytes)
  // 5:  Wo (PxE bytes)
  // 6:  Bq (P*3 bytes) (four 24bit values per 32bit word)
  // 7:  Bk (P*3 bytes) (four 24bit values per 32bit word)
  // 8:  Bv (P*3 bytes) (four 24bit values per 32bit word)
  // 9:  Bo (E*3 bytes) (four 24bit values per 32bit word)
  // 10: Q  (SxP bytes)
  // 11: K  (SxP bytes)
  // 12: V  (SxP bytes)
  // 13: QK (SxS bytes)
  // 14: AV (SxP bytes)
  // 15: OW (SxE bytes)
  integer BASE_PTR[16];

  logic [N_STATES][31:0] BASE_PTR_INPUT;
  logic [N_STATES][31:0] BASE_PTR_WEIGHT0;
  logic [N_STATES][31:0] BASE_PTR_WEIGHT1;
  logic [N_STATES][31:0] BASE_PTR_BIAS;
  logic [N_STATES][31:0] BASE_PTR_OUTPUT;

  // HWPE Parameters
  localparam unsigned ITA_REG_OFFSET  = 32'h20;
  parameter real PROB_STALL = 0.1;
  parameter MEMORY_SIZE = SEQUENCE_LEN*EMBEDDING_SIZE*3+EMBEDDING_SIZE*PROJECTION_SPACE*4+PROJECTION_SPACE*3*3+EMBEDDING_SIZE*3+SEQUENCE_LEN*PROJECTION_SPACE*4+SEQUENCE_LEN*SEQUENCE_LEN;

  parameter int unsigned AccDataWidth = ITA_TCDM_DW;
  parameter int unsigned IdWidth      = 8;

  // system params
  parameter int unsigned MemDataWidth = 32;
  parameter int unsigned MP           = (AccDataWidth / MemDataWidth);

  // Variables
  string simdir;
  string gelu_one_file = "GELU_ONE.txt";
  string gelu_b_file = "GELU_B.txt";
  string gelu_c_file = "GELU_C.txt";
  string activation_requant_mult_file = "activation_requant_mult.txt";
  string activation_requant_shift_file = "activation_requant_shift.txt";
  string activation_requant_add_file = "activation_requant_add.txt";

  // Signals
  logic         clk, rst_n;
  logic [N_CORES-1:0][1:0] evt;
  logic         busy;

  logic [MP-1:0]                        tcdm_req;
  logic [MP-1:0]                        tcdm_gnt;
  logic [MP-1:0][MemDataWidth-1:0]      tcdm_add;
  logic [MP-1:0]                        tcdm_wen;
  logic [MP-1:0][(MemDataWidth/8)-1:0]  tcdm_be;
  logic [MP-1:0][MemDataWidth-1:0]      tcdm_data;
  logic [MP-1:0][MemDataWidth-1:0]      tcdm_r_data;
  logic [MP-1:0]                        tcdm_r_valid;
  logic [MP-1:0]                        tcdm_r_ready;

  hwpe_ctrl_intf_periph #(
    .ID_WIDTH  (IdWidth)
  ) periph (
    .clk (clk)
  );

  localparam hci_size_parameter_t `HCI_SIZE_PARAM(tcdm_mem) = '{
    DW:  ITA_TCDM_DW,
    AW:  DEFAULT_AW,
    BW:  DEFAULT_BW,
    UW:  DEFAULT_UW,
    IW:  DEFAULT_IW,
    EW:  DEFAULT_EW,
    EHW: DEFAULT_EHW
  };
  `HCI_INTF_ARRAY(tcdm_mem, clk_i, MP-1:0);

  initial begin
    simdir = {
      "../../simvectors/data_S",
      $sformatf("%0d", SEQUENCE_LEN),
      "_E",
      $sformatf("%0d", EMBEDDING_SIZE),
      "_P",
      $sformatf("%0d", PROJECTION_SPACE),
      "_F",
      $sformatf("%0d", FEEDFORWARD_SIZE),
      "_H1_B",
      $sformatf("%0d", `ifdef BIAS `BIAS `else 0 `endif)
    };
    // Number of tiles in the sequence dimension
    N_TILES_SEQUENCE_DIM = SEQUENCE_LEN / M_TILE_LEN;
    // Number of tiles in the embedding dimension
    N_TILES_EMBEDDING_DIM = EMBEDDING_SIZE / M_TILE_LEN;
    // Number of tiles in the projection dimension
    N_TILES_PROJECTION_DIM = PROJECTION_SPACE / M_TILE_LEN;
    // Number of tiles in the feedforward dimension
    N_TILES_FEEDFORWARD_DIM = FEEDFORWARD_SIZE / M_TILE_LEN;
    // Number of entries per tile
    N_ELEMENTS_PER_TILE = M_TILE_LEN * M_TILE_LEN;
    // Number of output tiles in X direction per step
    N_TILES_OUTER_X[Q ] = N_TILES_PROJECTION_DIM;
    N_TILES_OUTER_X[K ] = N_TILES_PROJECTION_DIM;
    N_TILES_OUTER_X[V ] = N_TILES_SEQUENCE_DIM; // V is calculated transposed
    N_TILES_OUTER_X[QK] = N_TILES_SEQUENCE_DIM;
    N_TILES_OUTER_X[AV] = N_TILES_PROJECTION_DIM;
    N_TILES_OUTER_X[OW] = N_TILES_EMBEDDING_DIM;
    // Number of output tiles in Y direction per step
    N_TILES_OUTER_Y[Q ] = N_TILES_SEQUENCE_DIM;
    N_TILES_OUTER_Y[K ] = N_TILES_SEQUENCE_DIM;
    N_TILES_OUTER_Y[V ] = N_TILES_PROJECTION_DIM; // V is calculated transposed
    N_TILES_OUTER_Y[QK] = 1; // Only one tile row is calculated before switching to AV)
    N_TILES_OUTER_Y[AV] = 1; // Only one tile row is calculated before switching to QK)
    N_TILES_OUTER_Y[OW] = N_TILES_SEQUENCE_DIM;
    // Number of inner tiles per step
    N_TILES_INNER_DIM[Q ] = N_TILES_EMBEDDING_DIM;
    N_TILES_INNER_DIM[K ] = N_TILES_EMBEDDING_DIM;
    N_TILES_INNER_DIM[V ] = N_TILES_EMBEDDING_DIM;
    N_TILES_INNER_DIM[QK] = N_TILES_PROJECTION_DIM;
    N_TILES_INNER_DIM[AV] = N_TILES_SEQUENCE_DIM;
    N_TILES_INNER_DIM[OW] = N_TILES_PROJECTION_DIM;

    BASE_PTR[0 ] = 0;
    BASE_PTR[1 ] = BASE_PTR[0 ] + SEQUENCE_LEN * EMBEDDING_SIZE;
    BASE_PTR[2 ] = BASE_PTR[1 ] + SEQUENCE_LEN * EMBEDDING_SIZE;
    BASE_PTR[3 ] = BASE_PTR[2 ] + PROJECTION_SPACE * EMBEDDING_SIZE;
    BASE_PTR[4 ] = BASE_PTR[3 ] + PROJECTION_SPACE * EMBEDDING_SIZE;
    BASE_PTR[5 ] = BASE_PTR[4 ] + PROJECTION_SPACE * EMBEDDING_SIZE;
    BASE_PTR[6 ] = BASE_PTR[5 ] + PROJECTION_SPACE * EMBEDDING_SIZE;
    BASE_PTR[7 ] = BASE_PTR[6 ] + PROJECTION_SPACE * 3;
    BASE_PTR[8 ] = BASE_PTR[7 ] + PROJECTION_SPACE * 3;
    BASE_PTR[9 ] = BASE_PTR[8 ] + PROJECTION_SPACE * 3;
    BASE_PTR[10] = BASE_PTR[9 ] + EMBEDDING_SIZE * 3;
    BASE_PTR[11] = BASE_PTR[10] + SEQUENCE_LEN * PROJECTION_SPACE;
    BASE_PTR[12] = BASE_PTR[11] + SEQUENCE_LEN * PROJECTION_SPACE;
    BASE_PTR[13] = BASE_PTR[12] + SEQUENCE_LEN * PROJECTION_SPACE;
    BASE_PTR[14] = BASE_PTR[13] + SEQUENCE_LEN * SEQUENCE_LEN;
    BASE_PTR[15] = BASE_PTR[14] + SEQUENCE_LEN * PROJECTION_SPACE;

    // Base pointers
    BASE_PTR_INPUT[Q ]   = BASE_PTR[0 ];  // q
    BASE_PTR_INPUT[K ]   = BASE_PTR[1 ];  // k
    BASE_PTR_INPUT[V ]   = BASE_PTR[4 ];  // Wv
    BASE_PTR_INPUT[QK]   = BASE_PTR[10];  // Q
    BASE_PTR_INPUT[AV]   = BASE_PTR[13];  // QK
    BASE_PTR_INPUT[OW]   = BASE_PTR[14];  // AV
    BASE_PTR_WEIGHT0[Q ] = BASE_PTR[2 ];  // Wq
    BASE_PTR_WEIGHT0[K ] = BASE_PTR[3 ];  // Wk
    BASE_PTR_WEIGHT0[V ] = BASE_PTR[1 ];  // k
    BASE_PTR_WEIGHT0[QK] = BASE_PTR[11];  // K
    BASE_PTR_WEIGHT0[AV] = BASE_PTR[12];  // V
    BASE_PTR_WEIGHT0[OW] = BASE_PTR[5 ];  // Wo
    BASE_PTR_BIAS[Q ]    = BASE_PTR[6 ];  // Bq
    BASE_PTR_BIAS[K ]    = BASE_PTR[7 ];  // Bk
    BASE_PTR_BIAS[V ]    = BASE_PTR[8 ];  // Bv
    BASE_PTR_BIAS[QK]    = 32'hXXXX;
    BASE_PTR_BIAS[AV]    = 32'hXXXX;
    BASE_PTR_BIAS[OW]    = BASE_PTR[9 ];  // Bo
    BASE_PTR_OUTPUT[Q ]  = BASE_PTR[10];  // Q
    BASE_PTR_OUTPUT[K ]  = BASE_PTR[11];  // K
    BASE_PTR_OUTPUT[V ]  = BASE_PTR[12];  // V
    BASE_PTR_OUTPUT[QK]  = BASE_PTR[13];  // QK
    BASE_PTR_OUTPUT[AV]  = BASE_PTR[14];  // AV
    BASE_PTR_OUTPUT[OW]  = BASE_PTR[15];  // OW

    for (int i = 0; i < 5; i++) begin
      BASE_PTR_WEIGHT1[i] = BASE_PTR_WEIGHT0[i+1];
    end
    BASE_PTR_WEIGHT1[5] = 32'hXXXX;

  end

  generate
    for(genvar ii=0; ii<MP; ii++) begin : tcdm_binding
      assign tcdm_mem[ii].req  = tcdm_req[ii];
      assign tcdm_mem[ii].add  = tcdm_add[ii];
      assign tcdm_mem[ii].wen  = tcdm_wen[ii];
      assign tcdm_mem[ii].be   = tcdm_be[ii];
      assign tcdm_mem[ii].data = tcdm_data[ii];
      assign tcdm_gnt[ii] = tcdm_mem[ii].gnt;
      assign tcdm_r_valid[ii] = tcdm_mem[ii].r_valid;
      assign tcdm_r_data[ii] = tcdm_mem[ii].r_data;
      // Default values -> check if needed
      assign tcdm_mem[ii].user = '0;
      assign tcdm_mem[ii].id = '0;
      assign tcdm_mem[ii].ecc = '0;
      assign tcdm_mem[ii].ereq = '0;
      assign tcdm_mem[ii].r_ready = 1'b1;
      assign tcdm_mem[ii].r_eready = 1'b1;
    end : tcdm_binding
  endgenerate

  clk_rst_gen #(
    .CLK_PERIOD    (CLK_PERIOD    ),
    .RST_CLK_CYCLES(RST_CLK_CYCLES)
  ) i_clk_rst_gen (
    .clk_o (clk  ),
    .rst_no(rst_n)
  );

  // Instantiate the DUT for initial simulation.
  ita_hwpe_wrap #(
    .AccDataWidth (ITA_TCDM_DW ),
    .IdWidth      (IdWidth     ),
    .MemDataWidth (MemDataWidth)
  ) dut (
    .clk_i              (clk                 ),
    .rst_ni             (rst_n               ),
    .test_mode_i        (1'b0                ),
    .evt_o              (evt                 ),
    .busy_o             (busy                ),

    .tcdm_req_o         ( tcdm_req           ),
    .tcdm_add_o         ( tcdm_add           ),
    .tcdm_wen_o         ( tcdm_wen           ),
    .tcdm_be_o          ( tcdm_be            ),
    .tcdm_data_o        ( tcdm_data          ),
    .tcdm_gnt_i         ( tcdm_gnt           ),
    .tcdm_r_data_i      ( tcdm_r_data        ),
    .tcdm_r_valid_i     ( tcdm_r_valid       ),

    .periph_req_i       ( periph.req         ),
    .periph_gnt_o       ( periph.gnt         ),
    .periph_add_i       ( periph.add         ),
    .periph_wen_i       ( periph.wen         ),
    .periph_be_i        ( periph.be          ),
    .periph_data_i      ( periph.data        ),
    .periph_id_i        ( periph.id          ),
    .periph_r_data_o    ( periph.r_data      ),
    .periph_r_valid_o   ( periph.r_valid     ),
    .periph_r_id_o      ( periph.r_id        )
  );

  tb_dummy_memory #(
    .MP              ( MP          ),
    .MEMORY_SIZE     ( MEMORY_SIZE ),
    .BASE_ADDR       ( 32'h0       ),
    .PROB_STALL      ( PROB_STALL  ),
    .TCP             ( CLK_PERIOD  ),
    .TA              ( APPL_DELAY  ),
    .TT              ( ACQ_DELAY   )
  ) i_data_memory (
    .clk_i       ( clk      ),
    .enable_i    ( 1'b1     ),
    .stallable_i ( 1'b1     ),
    .tcdm        ( tcdm_mem )
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

  initial begin
    // Signals
    logic [31:0] status;
    string STIM_DATA;
    logic [31:0] ita_reg_tiles_val;
    logic [5:0][31:0] ita_reg_rqs_val;
    logic [31:0] ita_reg_gelu_one_val, ita_reg_gelu_b_c_val;
    logic [31:0] ita_reg_activation_rqs_val;

    $timeformat(-9, 2, " ns", 10);

    // Wait for reset to be released
    wait (rst_n);

    // Load memory
    STIM_DATA = {simdir,"/hwpe/mem.txt"};
    $readmemh(STIM_DATA, ita_hwpe_tb.i_data_memory.memory);

    ita_reg_tiles_val_compute(N_TILES_SEQUENCE_DIM, N_TILES_EMBEDDING_DIM, N_TILES_PROJECTION_DIM, N_TILES_FEEDFORWARD_DIM, ita_reg_tiles_val);
    ita_reg_eps_mult_val_compute(ita_reg_rqs_val);
    ita_reg_activation_constants_compute(ita_reg_gelu_one_val, ita_reg_gelu_b_c_val, ita_reg_activation_rqs_val);

    // soft clear
    PERIPH_WRITE( 32'h14, 32'h0, 32'h0,  clk);

    // acquire job
    status = -1;
    while(status < 32'h00)
      PERIPH_READ( 32'h04, 32'h0, status, clk);

    // 1: Step Q
    ita_compute_step(Q, ita_reg_tiles_val, ita_reg_rqs_val, ita_reg_gelu_one_val, ita_reg_gelu_b_c_val, ita_reg_activation_rqs_val, clk);

    // 2: Step K
    ita_compute_step(K, ita_reg_tiles_val, ita_reg_rqs_val, ita_reg_gelu_one_val, ita_reg_gelu_b_c_val, ita_reg_activation_rqs_val, clk);

    // 3: Step V
    ita_compute_step(V, ita_reg_tiles_val, ita_reg_rqs_val, ita_reg_gelu_one_val, ita_reg_gelu_b_c_val, ita_reg_activation_rqs_val, clk);


    for (int group = 0; group < N_TILES_SEQUENCE_DIM; group++) begin
      BASE_PTR_INPUT[QK]  = BASE_PTR[10] + group * N_TILES_INNER_DIM[QK] * N_ELEMENTS_PER_TILE;
      BASE_PTR_OUTPUT[QK] = BASE_PTR[13] + group * N_TILES_OUTER_X[QK] * N_ELEMENTS_PER_TILE;

      BASE_PTR_INPUT[AV]  = BASE_PTR[13] + group * N_TILES_INNER_DIM[AV] * N_ELEMENTS_PER_TILE;
      BASE_PTR_OUTPUT[AV] = BASE_PTR[14] + group * N_TILES_OUTER_X[AV] * N_ELEMENTS_PER_TILE;

      // 4: Step QK
      ita_compute_step(QK, ita_reg_tiles_val, ita_reg_rqs_val, ita_reg_gelu_one_val, ita_reg_gelu_b_c_val, ita_reg_activation_rqs_val, clk);

      // WIESEP: Hack to ensure that during the last tile of AV, the weight pointer is set correctly
      if (group == N_TILES_SEQUENCE_DIM-1) begin
        BASE_PTR_WEIGHT0[QK] = BASE_PTR_WEIGHT0[OW];
      end

      // 5: Step AV
      ita_compute_step(AV, ita_reg_tiles_val, ita_reg_rqs_val, ita_reg_gelu_one_val, ita_reg_gelu_b_c_val, ita_reg_activation_rqs_val, clk);
    end

    // 6: Step OW
    ita_compute_step(OW, ita_reg_tiles_val, ita_reg_rqs_val, ita_reg_gelu_one_val, ita_reg_gelu_b_c_val, ita_reg_activation_rqs_val, clk);

    // Wait for the last step to finish
    wait(evt);

    // soft clear
    PERIPH_WRITE( 32'h14, 32'h0, 32'h0,  clk);

    #(10ns);

    compare_output("hwpe/Q.txt",  BASE_PTR[10]);
    compare_output("hwpe/K.txt",  BASE_PTR[11]);
    compare_output("hwpe/V.txt",  BASE_PTR[12]);
    compare_output("hwpe/QK.txt", BASE_PTR[13]);
    compare_output("hwpe/AV.txt", BASE_PTR[14]);
    compare_output("hwpe/OW.txt", BASE_PTR[15]);

    // Finish the simulation
    $finish;
  end

  task automatic ita_compute_step(
    input  step_e       step,
    input  logic [31:0] ita_reg_tiles_val,
    input  logic [5:0][31:0] ita_reg_rqs_val,
    input  logic [31:0] ita_reg_gelu_one_val,
    input  logic [31:0] ita_reg_gelu_b_c_val,
    input  logic [31:0] ita_reg_activation_rqs_val,
    ref    logic        clk_i
  );

    logic [31:0] ctrl_engine_val;
    logic [31:0] ctrl_stream_val;
    logic        weight_ptr_en;
    logic        bias_ptr_en;
    logic        ita_reg_en;

    logic [31:0] input_base_ptr   = BASE_PTR_INPUT[step];
    logic [31:0] weight_base_ptr0 = BASE_PTR_WEIGHT0[step];
    logic [31:0] weight_base_ptr1 = BASE_PTR_WEIGHT1[step];
    logic [31:0] bias_base_ptr    = BASE_PTR_BIAS[step];
    logic [31:0] output_base_ptr  = BASE_PTR_OUTPUT[step];

    logic [31:0] input_ptr;
    logic [31:0] weight_ptr0;
    logic [31:0] weight_ptr1;
    logic [31:0] bias_ptr;
    logic [31:0] output_ptr;


    // Reprogram ITA once for every tile
    for (int tile_y = 0; tile_y < N_TILES_OUTER_Y[step]; tile_y++) begin

      for (int tile_x = 0; tile_x < N_TILES_OUTER_X[step]; tile_x++) begin
        integer output_tile = tile_y * N_TILES_OUTER_X[step] + tile_x;

        for (int tile_inner = 0; tile_inner < N_TILES_INNER_DIM[step]; tile_inner++) begin
          integer tile = output_tile * N_TILES_INNER_DIM[step] + tile_inner;
          $display("[ITA] Step %0d, Tile %0d (X %0d, Y %0d, I %0d) @ %0t", step, tile, tile_x, tile_y, tile_inner, $time);

          // Calculate input_ptr, weight_ptr0, weight_ptr1, bias_ptr, and output_ptr
          ita_ptrs_compute(input_base_ptr, weight_base_ptr0, weight_base_ptr1, bias_base_ptr, output_base_ptr, step, tile, tile_x, tile_y, tile_inner, input_ptr, weight_ptr0, weight_ptr1, bias_ptr, output_ptr);

          // Calculate ita_reg_en
          ita_reg_en_compute(step, tile, ita_reg_en);
          // Calculate ctrl_stream_val, weight_ptr_en, and bias_ptr_en
          ctrl_val_compute(step, tile, ctrl_engine_val, ctrl_stream_val, weight_ptr_en, bias_ptr_en);

          // $display(" - Input_ptr 0x%0h, Weight_ptr0 0x%0h, Weight_ptr1 0x%0h, Bias_ptr 0x%0h, Output_ptr 0x%0h", input_ptr, weight_ptr0, weight_ptr1, bias_ptr, output_ptr);
          $display(" - ITA Reg En 0x%0h, Ctrl Stream Val 0x%0h, Weight Ptr En %0d, Bias Ptr En %0d", ita_reg_en, ctrl_stream_val, weight_ptr_en, bias_ptr_en);

          // Program ITA
          PROGRAM_ITA(input_ptr, weight_ptr0, weight_ptr1, weight_ptr_en, bias_ptr, bias_ptr_en, output_ptr, ita_reg_tiles_val, ita_reg_rqs_val, ita_reg_gelu_one_val, ita_reg_gelu_b_c_val, ita_reg_activation_rqs_val, ita_reg_en, ctrl_engine_val, ctrl_stream_val, clk_i);

          // Wait for ITA to finish
          @(posedge clk_i);
          if (step == Q && tile == 0) begin
            // Trigger ITA
            PERIPH_WRITE( 32'h0, 32'h0, 32'h0, clk_i);
          end else begin
            wait(busy == 1'b0);
            // Trigger ITA
            PERIPH_WRITE( 32'h0, 32'h0, 32'h0, clk_i);
          end
          #(10ns);

        end
      end
    end
  endtask

  task automatic ita_ptrs_compute(
    input  logic [31:0] input_base_ptr,
    input  logic [31:0] weight_base_ptr0,
    input  logic [31:0] weight_base_ptr1,
    input  logic [31:0] bias_base_ptr,
    input  logic [31:0] output_base_ptr,
    input  step_e       step,
    input  integer      tile,
    input  integer      tile_x,
    input  integer      tile_y,
    input  integer      tile_inner,
    output logic [31:0] input_ptr,
    output logic [31:0] weight_ptr0,
    output logic [31:0] weight_ptr1,
    output logic [31:0] bias_ptr,
    output logic [31:0] output_ptr
  );
    input_ptr = input_base_ptr + (tile_y * N_TILES_INNER_DIM[step] + tile_inner) * N_ELEMENTS_PER_TILE;
    output_ptr = output_base_ptr + (tile_y * N_TILES_OUTER_X[step] + tile_x) * N_ELEMENTS_PER_TILE;

    if (step == V) begin
      bias_ptr = bias_base_ptr + tile_y * M_TILE_LEN * 3;
    end else begin
      bias_ptr = bias_base_ptr + tile_x * M_TILE_LEN * 3;
    end

    weight_ptr0 =  weight_base_ptr0 + ( tile % (N_TILES_OUTER_X[step] * N_TILES_INNER_DIM[step])) * N_ELEMENTS_PER_TILE;

    // Calulate next weight pointer
    if (tile == (N_TILES_OUTER_X[step]*N_TILES_OUTER_Y[step]*N_TILES_INNER_DIM[step])-1) begin
      weight_ptr1 = weight_base_ptr1;
      if (step == AV) begin
          weight_ptr1 = BASE_PTR_WEIGHT0[QK];
      end
      $display("> Last Output Tile");
    end else begin
      weight_ptr1 = weight_base_ptr0 + ( (tile + 1) % (N_TILES_OUTER_X[step] * N_TILES_INNER_DIM[step])) * N_ELEMENTS_PER_TILE;
      $display("> Next Output Tile");
    end
    $display(" - input_ptr   0x%08h (input_base_ptr   0x%08h)", input_ptr, input_base_ptr);
    $display(" - weight_ptr0 0x%08h (weight_base_ptr0 0x%08h)", weight_ptr0, weight_base_ptr0);
    $display(" - weight_ptr1 0x%08h (weight_base_ptr1 0x%08h)", weight_ptr1, weight_base_ptr1);
    $display(" - bias_ptr    0x%08h (bias_base_ptr    0x%08h)", bias_ptr, bias_base_ptr);
    $display(" - output_ptr  0x%08h (output_base_ptr  0x%08h)", output_ptr, output_base_ptr);
  endtask


  task automatic ita_reg_en_compute(
    input   step_e  step,
    input   integer tile,
    output  logic   enable
  );
    enable = 1'b0;
    // Write requantization parameters only in first two programming phases
    if (step == Q) begin
      if (tile == 0 || tile == 1)
        enable = 1'b1;
    end else if (step == K && N_TILES_OUTER_X[Q]*N_TILES_OUTER_Y[Q]*N_TILES_INNER_DIM[Q] == 1) begin
      if (tile == 0)
        enable = 1'b1;
    end
  endtask

  task automatic ctrl_val_compute(
    input   step_e        step,
    input   integer       tile,
    output  logic [31:0]  ctrl_engine_val,
    output  logic [31:0]  ctrl_stream_val,
    output  logic         reg_weight_en,
    output  logic         reg_bias_en
  );
    layer_e layer_type;
    activation_e activation_function;

    // Default values
    ctrl_stream_val = 32'h0;
    reg_weight_en = 1'b0;
    reg_bias_en = 1'b0;
    layer_type = Attention;
    activation_function = Identity;

    ctrl_engine_val = layer_type | activation_function << 1;

    // ctrl_stream [0]: weight preload,
    // ctrl_stream [1]: weight nextload,
    // ctrl_stream [2]: bias disable,
    // ctrl_stream [3]: bias direction
    // ctrl_stream [4]: output disable

    // reg_weight_en: Load weight for next step
    // reg_bias_en: Load bias for current step
    case(step)
      Q : begin
        if (tile == 0) begin
          ctrl_stream_val = {28'b0, 4'b0011}; // weight preload and weight nextload
        end else begin
          ctrl_stream_val = {28'b0, 4'b0010}; // weight nextload
        end
        reg_weight_en = 1'b1;
        reg_bias_en = 1'b1;
      end
      K : begin
        ctrl_stream_val = {28'b0, 4'b0010}; // weight nextload
        reg_weight_en = 1'b1;
        reg_bias_en = 1'b1;
      end
      V : begin
        ctrl_stream_val = {28'b0, 4'b1010}; // weight nextload and invert bias direction
        reg_weight_en = 1'b1;
        reg_bias_en = 1'b1;
      end
      QK : begin
        ctrl_stream_val = {28'b0, 4'b0110}; // weight nextload and disable bias
        reg_weight_en = 1'b1;
        reg_bias_en = 1'b0;
      end
      AV : begin
        ctrl_stream_val = {28'b0, 4'b0110}; // weight nextload and disable bias
        reg_weight_en = 1'b1;
        reg_bias_en = 1'b0;
      end
      OW : begin
        if (tile == (N_TILES_OUTER_X[OW]*N_TILES_OUTER_Y[OW]*N_TILES_INNER_DIM[OW])-1) begin
          ctrl_stream_val = {28'b0, 4'b0000};
          reg_weight_en = 1'b0;
        end else begin
          ctrl_stream_val = {28'b0, 4'b0010}; // weight nextload
          reg_weight_en = 1'b1;
        end
        reg_bias_en = 1'b1;
      end
    endcase

    ctrl_stream_val[4] = ( (tile+1) % N_TILES_INNER_DIM[step] == 0) ? 1'b0 : 1'b1;
  endtask

  task automatic ita_reg_tiles_val_compute(
    input integer tile_s,
    input integer tile_e,
    input integer tile_p,
    input integer tile_f,
    output logic [31:0] reg_val
  );
    reg_val = tile_s | tile_e << 4 | tile_p << 8 | tile_f << 12;
  endtask

  task automatic ita_reg_activation_constants_compute(
    output logic [31:0] gelu_one_reg,
    output logic [31:0] gelu_b_c_reg,
    output logic [31:0] activation_requant_reg
  );
    gelu_const_t gelu_one;
    gelu_const_t gelu_b;
    gelu_const_t gelu_c;
    requant_const_t activation_requant_mult;
    requant_const_t activation_requant_shift;
    requant_t activation_requant_add;
    read_activation_constants(gelu_one, gelu_b, gelu_c, activation_requant_mult, activation_requant_shift, activation_requant_add);
    gelu_one_reg = {16'h0, gelu_one};
    gelu_b_c_reg = gelu_b | gelu_c << 16;
    activation_requant_reg = activation_requant_mult | activation_requant_shift << 8 | activation_requant_add << 16;
  endtask

  task automatic read_activation_constants(
    output gelu_const_t gelu_one,
    output gelu_const_t gelu_b,
    output gelu_const_t gelu_c,
    output requant_const_t gelu_eps_mult,
    output requant_const_t gelu_right_shift,
    output requant_t gelu_add
  );
    integer one_fd;
    integer b_fd;
    integer c_fd;
    integer rqs_mul_fd;
    integer rqs_shift_fd;
    integer add_fd;
    int return_code;

    one_fd = open_stim_file(gelu_one_file);
    b_fd = open_stim_file(gelu_b_file);
    c_fd = open_stim_file(gelu_c_file);
    rqs_mul_fd = open_stim_file(activation_requant_mult_file);
    rqs_shift_fd = open_stim_file(activation_requant_shift_file);
    add_fd = open_stim_file(activation_requant_add_file);

    return_code = $fscanf(one_fd, "%d", gelu_one);
    return_code = $fscanf(b_fd, "%d", gelu_b);
    return_code = $fscanf(c_fd, "%d", gelu_c);
    return_code = $fscanf(rqs_mul_fd, "%d", gelu_eps_mult);
    return_code = $fscanf(rqs_shift_fd, "%d", gelu_right_shift);
    return_code = $fscanf(add_fd, "%d", gelu_add);

    $fclose(one_fd);
    $fclose(b_fd);
    $fclose(c_fd);
    $fclose(rqs_mul_fd);
    $fclose(rqs_shift_fd);
    $fclose(add_fd);
  endtask

  task automatic ita_reg_eps_mult_val_compute(
    output logic [5:0][31:0] reg_val
  );
    logic [5:0][EMS-1:0] eps_mult;
    logic [5:0][EMS-1:0] right_shift;
    logic [5:0][ WI-1:0] add;
    read_ITA_rqs(eps_mult, right_shift, add);
    reg_val[0] = eps_mult[0] | eps_mult[1] << 8 | eps_mult[2] << 16 | eps_mult[3] << 24;
    reg_val[1] = eps_mult[4] | eps_mult[5] << 8;
    reg_val[2] = right_shift[0] | right_shift[1] << 8 | right_shift[2] << 16 | right_shift[3] << 24;
    reg_val[3] = right_shift[4] | right_shift[5] << 8;
    reg_val[4] = add[0] | add[1] << 8 | add[2] << 16 | add[3] << 24;
    reg_val[5] = add[4] | add[5] << 8;
  endtask

  task automatic compare_output(string STIM_DATA, integer address);
    integer stim_fd;
    integer ret_code;
    integer counter;
    integer exp_res;

    $display("Comparing output for %s @ 0x%0h @ %0t", STIM_DATA, address, $time);

    stim_fd = open_stim_file(STIM_DATA);

    // Warning: Make sure the counter points to the correct output address
    counter = address/4;
    while (!$feof(stim_fd)) begin
      ret_code = $fscanf(stim_fd, "%x\n", exp_res);
      if (exp_res !== ita_hwpe_tb.i_data_memory.memory[counter]) begin
        $display("Output mismatch at address %x (index %0d): Expected %x, Got %x", counter*4, counter*4-address, exp_res, ita_hwpe_tb.i_data_memory.memory[counter]);
      end
      counter++;
    end
    $fclose(stim_fd);
  endtask

  task read_ITA_rqs(
    output logic [5:0][EMS-1:0]  eps_mult,
    output logic [5:0][EMS-1:0]  right_shift,
    output logic [5:0][ WI-1:0]  add
  );
    integer stim_fd_rqs;
    integer ret_code;

    for (int phase = 0; phase < 3; phase++) begin
      case(phase)
        0 : begin
          stim_fd_rqs = open_stim_file("RQS_MUL.txt");
        end
        1 : begin
          stim_fd_rqs = open_stim_file("RQS_SHIFT.txt");
        end
        2 : begin
          stim_fd_rqs = open_stim_file("RQS_ADD.txt");
        end
      endcase

      case(phase)
        0 : begin
          for (int j = 0; j < 6; j++) begin
            ret_code = $fscanf(stim_fd_rqs, "%d\n", eps_mult[j]);
          end
        end
        1 : begin
          for (int j = 0; j < 6; j++) begin
            ret_code = $fscanf(stim_fd_rqs, "%d\n", right_shift[j]);
          end
        end
        2 : begin
          for (int j = 0; j < 6; j++) begin
            ret_code = $fscanf(stim_fd_rqs, "%d\n", add[j]);
          end
        end
      endcase

      $fclose(stim_fd_rqs);
    end
  endtask

  task automatic PROGRAM_ITA(
    input  logic [31:0] input_ptr,
    input  logic [31:0] weight_ptr0,
    input  logic [31:0] weight_ptr1,
    input  logic        weight_ptr_en,
    input  logic [31:0] bias_ptr,
    input  logic        bias_ptr_en,
    input  logic [31:0] output_ptr,
    input  logic [31:0] ita_reg_tiles_val,
    input  logic [5:0][31:0] ita_reg_rqs_val,
    input  logic [31:0] ita_reg_gelu_one_val,
    input  logic [31:0] ita_reg_gelu_b_c_val,
    input  logic [31:0] ita_reg_activation_rqs_val,
    input  logic        ita_reg_en,
    input  logic [31:0] ctrl_engine_val,
    input  logic [31:0] ctrl_stream_val,
    ref    logic        clk_i
  );
    PERIPH_WRITE( 4*ITA_REG_INPUT_PTR,   ITA_REG_OFFSET, input_ptr, clk_i);
    PERIPH_WRITE( 4*ITA_REG_WEIGHT_PTR0, ITA_REG_OFFSET, weight_ptr0, clk_i);
    if (weight_ptr_en)
      PERIPH_WRITE( 4*ITA_REG_WEIGHT_PTR1, ITA_REG_OFFSET, weight_ptr1, clk_i);
    if (bias_ptr_en)
      PERIPH_WRITE( 4*ITA_REG_BIAS_PTR,    ITA_REG_OFFSET, bias_ptr, clk_i);
    PERIPH_WRITE( 4*ITA_REG_OUTPUT_PTR,  ITA_REG_OFFSET, output_ptr, clk_i);

    if (ita_reg_en) begin
      PERIPH_WRITE( 4*ITA_REG_TILES,       ITA_REG_OFFSET, ita_reg_tiles_val, clk_i);
      PERIPH_WRITE( 4*ITA_REG_EPS_MULT0,   ITA_REG_OFFSET, ita_reg_rqs_val[0], clk_i);
      PERIPH_WRITE( 4*ITA_REG_EPS_MULT1,   ITA_REG_OFFSET, ita_reg_rqs_val[1], clk_i);
      PERIPH_WRITE( 4*ITA_REG_RIGHT_SHIFT0,ITA_REG_OFFSET, ita_reg_rqs_val[2], clk_i);
      PERIPH_WRITE( 4*ITA_REG_RIGHT_SHIFT1,ITA_REG_OFFSET, ita_reg_rqs_val[3], clk_i);
      PERIPH_WRITE( 4*ITA_REG_ADD0,        ITA_REG_OFFSET, ita_reg_rqs_val[4], clk_i);
      PERIPH_WRITE( 4*ITA_REG_ADD1,        ITA_REG_OFFSET, ita_reg_rqs_val[5], clk_i);
    end

    PERIPH_WRITE( 4*ITA_REG_CTRL_STREAM, ITA_REG_OFFSET, ctrl_stream_val, clk_i);
  endtask : PROGRAM_ITA

  localparam ID = 0; // Core id

  task automatic PERIPH_WRITE(
      input  logic [31:0] base_addr,
      input  logic [31:0] offset,
      input  logic [31:0] data,
      ref    logic        clk_i
  );
      // Initial bus configuration for a write operation
      periph.req  = 1'b0;
      periph.add  = 32'b0;
      periph.wen  = 1'b1;
      periph.be   = 4'b0; // 'be' is 4 bits for byte enable
      periph.data = 32'b0;
      periph.id   = ID;

      // Setup phase
      @(posedge clk_i);
      #APPL_DELAY; // Application Delay
      periph.req  = 1'b1;
      periph.add  = base_addr + offset;
      periph.wen  = 1'b0; // Indicating write operation
      periph.be   = 4'b1111; // Assuming full byte write
      periph.data = data;

      // Wait for grant, it can arrive in the same clock cycle too
      wait(periph.gnt);

      // Hold phase
      @(posedge clk_i);
      #APPL_DELAY; // Test Delay

      // Termination phase
      periph.req  = 1'b0;
      periph.add  = 32'b0;
      periph.wen  = 1'b1; // Default state
      periph.be   = 4'b1111; // Maintaining byte enable
      @(posedge clk_i);
  endtask : PERIPH_WRITE

  task automatic PERIPH_READ(
      input  logic [31:0] base_addr,
      input  logic [31:0] offset,
      output logic [31:0] data,
      ref    logic        clk_i
  );
      // Initial bus configuration for a read operation
      periph.req  = 1'b0;
      periph.add  = 32'b0;
      periph.wen  = 1'b1; // Indicating not a write operation
      periph.be   = 4'b0; //  'be' is for byte enable, reset to 0
      periph.data = 32'b0; // Data not used in read setup
      periph.id   = ID;

      // Setup phase
      @(posedge clk_i);
      #APPL_DELAY; // Application Delay
      periph.req  = 1'b1;
      periph.add  = base_addr + offset;
      periph.wen  = 1'b1; // indicating not a write operation
      periph.be   = 4'b1111;
      // Wait for grant
      wait(periph.gnt);

      // Wait for read data to be valid
      @(posedge clk_i);
      wait(periph.r_valid);
      data = periph.r_data;
      // Termination phase
      @(posedge clk_i);
      periph.req  = 1'b0;
      periph.add  = 32'b0;
      periph.wen  = 1'b1; // Default state
      periph.be   = 4'b1111; // Maintaining byte enable for consistency

  endtask : PERIPH_READ

endmodule
