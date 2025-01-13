// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

/**
  ITA masking module.
*/

module ita_masking
  import ita_package::*;
(
    input logic clk_i,
    input logic rst_ni,
    input ctrl_t ctrl_i,
    input step_e step_i,
    input logic calc_en_i,
    input logic last_inner_tile_i,
    input counter_t count_i,
    input counter_t tile_x_i,
    input counter_t tile_y_i,
    output logic [N-1:0] mask_o
);

  logic [3:0]     mask_col_offset_d, mask_col_offset_q;
  counter_t       mask_tile_x_pos_d, mask_tile_x_pos_q;
  counter_t       mask_tile_y_pos_d, mask_tile_y_pos_q;
  counter_t       mask_pos_d, mask_pos_q;
  logic [N-1:0]   mask_d, mask_q;

  assign mask_o = mask_q;

  always_comb begin
    case (ctrl_i.mask_type)
      None: begin
        mask_col_offset_d = '0;
        mask_tile_x_pos_d = '0;
        mask_tile_y_pos_d = '0;
        mask_pos_d        = '0;
        mask_d            = '0;
      end
      UpperTriangular: begin
        mask_col_offset_d  = (step_i == QK || step_i == AV) ? mask_col_offset_q : ((ctrl_i.mask_start_index) & (N-1));
        mask_tile_x_pos_d  = (step_i == QK || step_i == AV) ? mask_tile_x_pos_q : ((ctrl_i.mask_start_index) / M);
        mask_tile_y_pos_d  = mask_tile_y_pos_q;
        mask_pos_d         = (step_i == QK || step_i == AV) ? mask_pos_q : ((((ctrl_i.mask_start_index)/N)*M) & ((M*M/N)-1));
        mask_d             = '0;

        if (step_i == QK) begin
          if (mask_tile_x_pos_q == tile_x_i && mask_tile_y_pos_q == tile_y_i && last_inner_tile_i == 1'b1) begin
            if (count_i == ((M * M / N) - 1)) begin
              mask_tile_x_pos_d = mask_tile_x_pos_q + 1'b1;
            end
            if ((count_i >= mask_pos_q) && (count_i < (mask_pos_q + N))) begin
              if ((count_i & (M-1)) == (M-1) && !(((count_i + mask_col_offset_q) & (N-1)) == (N-1))) begin
                mask_tile_y_pos_d = tile_y_i + 1'b1;
                mask_tile_x_pos_d = tile_x_i;
                mask_pos_d = ((count_i + (((ctrl_i.tile_s * (M*M/N)) - M) + 1)) & ((M*M/N)-1));
              end else if ((count_i & (M-1)) == (M-1) && (((count_i + mask_col_offset_q) & (N-1)) == (N-1))) begin
                if ((count_i / M) == ((M / N) - 1)) begin
                  mask_tile_y_pos_d = tile_y_i + 1'b1;
                  mask_tile_x_pos_d = tile_x_i + 1'b1;
                  mask_pos_d = ((count_i + ((ctrl_i.tile_s * (M*M/N)) + 1)) & ((M*M/N)-1));
                end else begin
                  mask_tile_y_pos_d = tile_y_i + 1'b1;
                  mask_tile_x_pos_d = tile_x_i;
                  mask_pos_d = ((count_i + ((ctrl_i.tile_s * (M*M/N)) + 1)) & ((M*M/N)-1));
                end
              end else if (((count_i + mask_col_offset_q) & (N - 1)) == (N - 1)) begin
                mask_pos_d = (mask_pos_q + (N - ((mask_pos_q + mask_col_offset_q) & (N-1))) + M) & ((M*M/N)-1);
              end
              for (int i = 0; i < N; i++) begin
                if (((count_i + mask_col_offset_q) & (N - 1)) <= i) begin
                  mask_d[i] = 1'b1;
                end else begin
                  mask_d[i] = 1'b0;
                end
              end
            end else if ((count_i & (M - 1)) < (mask_pos_q & (M - 1))) begin
              for (int i = 0; i < N; i++) begin
                mask_d[i] = 1'b1;
              end
            end
          end else if (mask_tile_x_pos_q <= tile_x_i && mask_tile_y_pos_q != tile_y_i && last_inner_tile_i == 1'b1) begin
            for (int i = 0; i < N; i++) begin
              mask_d[i] = 1'b1;
            end
          end else if (mask_tile_x_pos_q != tile_x_i && mask_tile_y_pos_q == tile_y_i && last_inner_tile_i == 1'b1) begin
            for (int i = 0; i < N; i++) begin
              mask_d[i] = 1'b0;
            end
          end
        end
      end
      LowerTriangular: begin
        mask_col_offset_d  = '0;
        mask_tile_x_pos_d  = mask_tile_x_pos_q;
        mask_tile_y_pos_d  = (step_i == QK || step_i == AV) ? mask_tile_y_pos_q : ((ctrl_i.mask_start_index) / M);
        mask_pos_d         = (step_i == QK || step_i == AV) ? mask_pos_q : (ctrl_i.mask_start_index & (M-1));
        mask_d             = '0;

        if (step_i == QK) begin
          if (mask_tile_x_pos_q == tile_x_i && mask_tile_y_pos_q == tile_y_i && last_inner_tile_i == 1'b1) begin
            if (count_i == ((M * M / N) - 1)) begin
              mask_tile_x_pos_d = mask_tile_x_pos_q + 1'b1;
            end
            if ((count_i >= mask_pos_q) && (count_i < (mask_pos_q + N))) begin
              if (((count_i & (M-1)) == (M-1)) && !(((count_i + (N - (ctrl_i.mask_start_index & (N-1)))) & (N-1)) == (N-1))) begin
                mask_tile_y_pos_d = tile_y_i + 1'b1;
                mask_tile_x_pos_d = tile_x_i;
                mask_pos_d = ((count_i + (((ctrl_i.tile_s * (M*M/N)) - M) + 1)) & ((M*M/N)-1));
              end else if (((count_i & (M-1)) == (M-1)) && (((count_i + (N - (ctrl_i.mask_start_index & (N-1)))) & (N-1)) == (N-1))) begin
                if ((count_i / M) == ((M / N) - 1)) begin
                  mask_tile_y_pos_d = tile_y_i + 1'b1;
                  mask_tile_x_pos_d = tile_x_i + 1'b1;
                  mask_pos_d = ((count_i + ((ctrl_i.tile_s * (M*M/N)) + 1)) & ((M*M/N)-1));
                end else begin
                  mask_tile_y_pos_d = tile_y_i + 1'b1;
                  mask_tile_x_pos_d = tile_x_i;
                  mask_pos_d = ((count_i + ((ctrl_i.tile_s * (M*M/N)) + 1)) & ((M*M/N)-1));
                end
              end else if (((count_i + (N - (ctrl_i.mask_start_index & (N-1)))) & (N-1)) == (N-1)) begin
                mask_pos_d = (mask_pos_q + (count_i - mask_pos_q + 1) + M) & ((M * M / N) - 1);
              end
              for (int i = 0; i < N; i++) begin
                if (((count_i + (N - (ctrl_i.mask_start_index & (N - 1)))) & (N - 1)) >= i) begin
                  mask_d[i] = 1'b1;
                end else begin
                  mask_d[i] = 1'b0;
                end
              end
            end else if ((count_i & (M - 1)) >= (mask_pos_q & (M - 1))) begin
              for (int i = 0; i < N; i++) begin
                mask_d[i] = 1'b1;
              end
            end
          end else if (mask_tile_x_pos_q > tile_x_i && mask_tile_y_pos_q == tile_y_i && last_inner_tile_i == 1'b1) begin
            for (int i = 0; i < N; i++) begin
              mask_d[i] = 1'b1;
            end
          end else if (mask_tile_x_pos_q >= tile_x_i && mask_tile_y_pos_q != tile_y_i && last_inner_tile_i == 1'b1) begin
            for (int i = 0; i < N; i++) begin
              mask_d[i] = 1'b0;
            end
          end
        end
      end
      Strided: begin
        mask_col_offset_d = '0;
        mask_tile_x_pos_d = '0;
        mask_tile_y_pos_d = '0;
        mask_pos_d        = '0;
        mask_d            = '0;

        if (step_i == QK) begin
          if (last_inner_tile_i == 1'b1) begin
            for (int i = 0; i < N; i++) begin
              //col_pos = count_i/M * N + i + tile_x_i * M
              //row_pos = count_i & (M-1) + tile_y_i * M
              //Marcel Kant: Does only work if ctrl_i.mask_start_index is a power of two
              if ((((((count_i / M) * N) + i + (tile_x_i * M)) - ((count_i & (M-1)) + (tile_y_i * M))) & (ctrl_i.mask_start_index-1)) == 0) begin
                mask_d[i] = 1'b0;
              end else begin
                mask_d[i] = 1'b1;
              end
            end
          end
        end
      end
      UpperStrided: begin
        mask_col_offset_d = '0;
        mask_tile_x_pos_d = '0;
        mask_tile_y_pos_d = '0;
        mask_pos_d        = '0;
        mask_d            = '0;

        if (step_i == QK) begin
          if (last_inner_tile_i == 1'b1) begin
            for (int i = 0; i < N; i++) begin
              //Marcel Kant: Does only work if ctrl_i.mask_start_index is a power of two
              if ((((((count_i / M) * N) + i + (tile_x_i * M)) - ((count_i & (M-1)) + (tile_y_i * M))) & (ctrl_i.mask_start_index-1)) == 0 &&
                      ((((count_i / M) * N) + i + (tile_x_i * M)) >= ((count_i & (M-1)) + (tile_y_i * M)))) begin
                mask_d[i] = 1'b0;
              end else begin
                mask_d[i] = 1'b1;
              end
            end
          end
        end
      end
      LowerStrided: begin
        mask_col_offset_d = '0;
        mask_tile_x_pos_d = '0;
        mask_tile_y_pos_d = '0;
        mask_pos_d        = '0;
        mask_d            = '0;

        if (step_i == QK) begin
          if (last_inner_tile_i == 1'b1) begin
            for (int i = 0; i < N; i++) begin
              //Marcel Kant: Does only work if ctrl_i.mask_start_index is a power of two
              if ((((((count_i / M) * N) + i + (tile_x_i * M)) - ((count_i & (M-1)) + (tile_y_i * M))) & (ctrl_i.mask_start_index-1)) == 0 &&
                      ((((count_i / M) * N) + i + (tile_x_i * M)) <= ((count_i & (M-1)) + (tile_y_i * M)))) begin
                mask_d[i] = 1'b0;
              end else begin
                mask_d[i] = 1'b1;
              end
            end
          end
        end
      end
      SlidingWindow: begin
        mask_col_offset_d = '0;
        mask_tile_x_pos_d = '0;
        mask_tile_y_pos_d = '0;
        mask_pos_d        = '0;
        mask_d            = '0;

        if (step_i == QK) begin
          if (last_inner_tile_i == 1'b1) begin
            for (int i = 0; i < N; i++) begin
              if (((count_i & (M-1)) + (tile_y_i * M)) < ctrl_i.mask_start_index) begin
                if ((((count_i / M) * N) + i + (tile_x_i * M)) < (ctrl_i.mask_start_index + ((count_i & (M-1)) + (tile_y_i * M)))) begin
                  mask_d[i] = 1'b0;
                end else begin
                  mask_d[i] = 1'b1;
                end
              end else begin
                if ((((count_i & (M-1)) + (tile_y_i * M) - (ctrl_i.mask_start_index-1)) <= (((count_i / M) * N) + i + (tile_x_i * M))) && 
                    ((((count_i / M) * N) + i + (tile_x_i * M)) < ((count_i & (M-1)) + (tile_y_i * M) + ctrl_i.mask_start_index))) begin
                  mask_d[i] = 1'b0;
                end else begin
                  mask_d[i] = 1'b1;
                end
              end     
            end       
          end
        end
      end
      StridedSlidingWindow: begin
        mask_col_offset_d = '0;
        mask_tile_x_pos_d = '0;
        mask_tile_y_pos_d = '0;
        mask_pos_d        = '0;
        mask_d            = '0;

        if (step_i == QK) begin
          if (last_inner_tile_i == 1'b1) begin
            for (int i = 0; i < N; i++) begin
              //Strided logic
              if ((((((count_i / M) * N) + i + (tile_x_i * M)) - ((count_i & (M-1)) + (tile_y_i * M))) & (ctrl_i.mask_start_index-1)) == 0) begin
                mask_d[i] = 1'b0;
              end else begin
                //Sliding window logic
                if (((count_i & (M-1)) + (tile_y_i * M)) < ctrl_i.mask_start_index) begin
                  if ((((count_i / M) * N) + i + (tile_x_i * M)) < (ctrl_i.mask_start_index + ((count_i & (M-1)) + (tile_y_i * M)))) begin
                    mask_d[i] = 1'b0;
                  end else begin
                    mask_d[i] = 1'b1;
                  end
                end else begin
                  if ((((count_i & (M-1)) + (tile_y_i * M) - (ctrl_i.mask_start_index-1)) <= (((count_i / M) * N) + i + (tile_x_i * M))) && 
                      ((((count_i / M) * N) + i + (tile_x_i * M)) < ((count_i & (M-1)) + (tile_y_i * M) + ctrl_i.mask_start_index))) begin
                    mask_d[i] = 1'b0;
                  end else begin
                    mask_d[i] = 1'b1;
                  end
                end  
              end 
            end       
          end
        end
      end
    endcase
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      mask_pos_q <= '0;
      mask_tile_x_pos_q <= '0;
      mask_tile_y_pos_q <= '0;
      mask_col_offset_q <= '0;
      mask_q <= '0;
    end else begin
      if (calc_en_i) begin
        mask_pos_q <= mask_pos_d;
        mask_tile_x_pos_q <= mask_tile_x_pos_d;
        mask_tile_y_pos_q <= mask_tile_y_pos_d;
      end
      mask_col_offset_q <= mask_col_offset_d;
      mask_q <= mask_d;
    end
  end

endmodule
