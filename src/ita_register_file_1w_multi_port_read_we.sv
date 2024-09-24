// Copyright 2014 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// From latch_scm { git: "https://github.com/pulp-platform/scm.git", version: "1.1.0" }, added async rst and NUM_BYTE->N_EN.

module ita_register_file_1w_multi_port_read_we
#(
    parameter ADDR_WIDTH    = 5,
    parameter DATA_WIDTH    = 32,

    parameter N_READ        = 2,
    parameter N_WRITE       = 1,
    parameter N_EN          = 4
)
(
    input  logic                                 clk,
    input  logic                                 rst_n,

    // Read port
    input  logic [N_READ-1:0]                    ReadEnable,
    input  logic [N_READ-1:0][ADDR_WIDTH-1:0]    ReadAddr,
    output logic [N_READ-1:0][DATA_WIDTH-1:0]    ReadData,

    // Write port
    input  logic                                 WriteEnable,
    input  logic [ADDR_WIDTH-1:0]                WriteAddr,
    input  logic [N_EN-1:0][DATA_WIDTH/N_EN-1:0] WriteData,
    input  logic [N_EN-1:0]                      WriteSelect
);

    localparam    NUM_WORDS = 2**ADDR_WIDTH;

    // Read address register, located at the input of the address decoder
    logic [N_READ-1:0][ADDR_WIDTH-1:0]                         RAddrRegxDP;
    logic [N_READ-1:0][NUM_WORDS-1:0]                          RAddrOneHotxD;

    logic [N_EN-1:0][DATA_WIDTH/N_EN-1:0]          MemContentxDP[NUM_WORDS];

    logic [NUM_WORDS-1:0][N_EN-1:0]                WAddrOneHotxD;
    logic [NUM_WORDS-1:0][N_EN-1:0]                ClocksxC;
    logic [N_EN-1:0][DATA_WIDTH/N_EN-1:0]          WDataIntxD;

    logic                                          clk_int;

    int unsigned i;
    int unsigned j;
    int unsigned k;
    int unsigned l;
    int unsigned m;

    genvar       x;
    genvar       y;
    genvar       z;

    cluster_clock_gating CG_WE_GLOBAL
    (
        .clk_o     ( clk_int        ),
        .en_i      ( WriteEnable    ),
        .test_en_i ( 1'b0           ),
        .clk_i     ( clk            )
    );

    //-----------------------------------------------------------------------------
    //-- READ : Read address register
    //-----------------------------------------------------------------------------

    generate
        for(z=0; z<N_READ; z++ )
        begin
            always_ff @(posedge clk, negedge rst_n)
            begin : p_RAddrReg
              if(rst_n == 1'b0)
              begin
                  RAddrRegxDP[z] <= '0;
              end
              else
              if( ReadEnable[z] )
                RAddrRegxDP[z] <= ReadAddr[z];
            end



    //-----------------------------------------------------------------------------
    //-- READ : Read address decoder RAD
    //-----------------------------------------------------------------------------
            always @(*)
            begin : p_RAD
              RAddrOneHotxD[z] = '0;
              RAddrOneHotxD[z][RAddrRegxDP[z]] = 1'b1;
            end
            assign ReadData[z] = MemContentxDP[RAddrRegxDP[z]];

        end
    endgenerate

    //-----------------------------------------------------------------------------
    //-- WRITE : Write Address Decoder (WAD), combinatorial process
    //-----------------------------------------------------------------------------
    always_comb
    begin : p_WAD
      for(i=0; i<NUM_WORDS; i++)
        begin : p_WordIter
            for(j=0; j<N_EN; j++)
              begin : p_ByteIter
                if ( (WriteEnable == 1'b1 ) && (WriteSelect[j] == 1'b1) &&  (WriteAddr == i) )
                  WAddrOneHotxD[i][j] = 1'b1;
                else
                  WAddrOneHotxD[i][j] = 1'b0;
              end
        end
    end



    //-----------------------------------------------------------------------------
    //-- WRITE : Clock gating (if integrated clock-gating cells are available)
    //-----------------------------------------------------------------------------
    generate
    for(x=0; x<NUM_WORDS; x++)
      begin : CG_CELL_WORD_ITER
          for(y=0; y<N_EN; y++)
            begin : CG_CELL_BYTE_ITER
                cluster_clock_gating CG_Inst
                (
                  .clk_o(ClocksxC[x][y]),
                  .en_i(WAddrOneHotxD[x][y]),
                  .test_en_i(1'b0),
                  .clk_i(clk_int)
                );
            end
      end
    endgenerate




    //-----------------------------------------------------------------------------
    // WRITE : SAMPLE INPUT DATA
    //---------------------------------------------------------------------------
    always_ff @(posedge clk, negedge rst_n)
    begin : sample_waddr
      if(rst_n == 1'b0)
      begin
          WDataIntxD <= '0;
      end
      else
      for(m=0; m<N_EN; m++)
        begin
            if(WriteEnable & WriteSelect[m])
              WDataIntxD[m] <= WriteData[m];
        end
    end





    //-----------------------------------------------------------------------------
    //-- WRITE : Write operation
    //-----------------------------------------------------------------------------
    //-- Generate M = WORDS sequential processes, each of which describes one
    //-- word of the memory. The processes are synchronized with the clocks
    //-- ClocksxC(i), i = 0, 1, ..., M-1
    //-- Use active low, i.e. transparent on low latches as storage elements
    //-- Data is sampled on rising clock edge


    always_latch
    begin : latch_wdata
      for(k=0; k<NUM_WORDS; k++)
        begin : w_WordIter
            for(l=0; l<N_EN; l++)
              begin : w_ByteIter
                if( ClocksxC[k][l] == 1'b1)
                  MemContentxDP[k][l] = WDataIntxD[l];
              end
        end
    end


endmodule
