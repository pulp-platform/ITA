# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# ----------------------------------------------------------------------
#
# File: ITA.py
#
# Last edited: 5.03.2024
#
# Copyright (C) 2024, ETH Zurich and University of Bologna.
#
# Author: Philip Wiese (wiesep@iis.ee.ethz.ch), ETH Zurich
#
# ----------------------------------------------------------------------

import os
import sys
from functools import partial
from typing import Union

import numpy as np
from numpy.typing import ArrayLike, DTypeLike

import seaborn as sns
import matplotlib.pyplot as plt

from .softmax import fastSoftmax, realSoftmax, streamingPartialSoftmax
from .gelu import gelu_requantize, i_gelu_requantized, get_i_gelu_constants, get_i_gelu_requantized_constants
from .util import (generate_matrix_mem, pack_8b_to_word, pack_array_8b_to_word, pack_hex_24b, pack_multihead_8b_to_word,
                   pack_multihead_24b_to_word, random_shuffled_tensor, requantize, split_matrix, to_hex, write_matrix,
                   write_matrix_mem, write_matrix_mem_hex, write_vector_mem_hex, get_almost_symmetric_scaling_factor,
                   error_MAEP)


class Transformer:
    WO = 26
    WI = 8

    def __init__(self,
                 S: int,
                 P: int,
                 E: int,
                 F: int,
                 H: int,
                 path: Union[str, os.PathLike],
                 bias: bool = True,
                 activation: str = "identity",
                 mask: str = "none",
                 Q: ArrayLike = None,
                 K: ArrayLike = None,
                 V: ArrayLike = None,
                 Wq: ArrayLike = None,
                 Wk: ArrayLike = None,
                 Wv: ArrayLike = None,
                 Wo: ArrayLike = None,
                 Bq: ArrayLike = None,
                 Bk: ArrayLike = None,
                 Bv: ArrayLike = None,
                 Bo: ArrayLike = None,
                 FF_in: ArrayLike = None,
                 Wff: ArrayLike = None,
                 Wff2: ArrayLike = None,
                 Bff: ArrayLike = None,
                 Bff2: ArrayLike = None):

        self.ITA_N = 16
        self.ITA_M = 64

        # WIESEP: Set numpy print options
        np.set_printoptions(threshold = sys.maxsize)
        np.set_printoptions(linewidth = np.inf)

        self._init_paths(path)

        self.S_ITA = ((S - 1) // self.ITA_M + 1) * self.ITA_M
        self.P_ITA = ((P - 1) // self.ITA_M + 1) * self.ITA_M
        self.E_ITA = ((E - 1) // self.ITA_M + 1) * self.ITA_M
        self.F_ITA = ((F - 1) // self.ITA_M + 1) * self.ITA_M
        self.H_ITA = 4
        self.split = self.ITA_M // self.ITA_N

        self.S = S
        self.P = P
        self.E = E
        self.F = F
        self.H = H
        self.bias = bias
        self.activation = activation
        self.mask = mask

        # Setup transformation functions
        self.split_m_m = partial(split_matrix, block_shape = (self.ITA_M, self.ITA_M))
        self.split_m_n = partial(split_matrix, block_shape = (self.ITA_M, self.ITA_N))

        self._validate_matrix_constraints(K, V)
        self._initialize_quantization_parameters()
        self._init_gelu_constants()
        self._initialize_tensors(Q, V, Wq, Wk, Wv, Wo, Bq, Bk, Bv, Bo, FF_in, Wff, Wff2, Bff, Bff2)

    def split_multihead_m_m(self, multihead_array: np.ndarray):
        """
        Split a multihead array into blocks of size ITA_M x ITA_M.

        Args:
            multihead_array (np.ndarray): A 3-dimensional numpy array to be split into blocks.

        Returns:
            np.ndarray: A 3-dimensional numpy array with the blocks of size ITA_M x ITA_M, where all blocks are stacked vertically in the inner dimensions.
        """
        return [self.split_m_m(array) for array in multihead_array]

    def _validate_matrix_constraints(self, K: ArrayLike, V: ArrayLike):
        # WIESEP: Ensure that K is the same as V because we do cross-attention
        assert (np.all(K == V))

        # WIESEP: Current restrictions for ITA
        # assert (self.S % self.ITA_M == 0), "Sequence length must be divisible by ITA_M"
        # assert (self.P % self.ITA_M == 0), "Projection space must be divisible by ITA_M"
        # assert (self.E % self.ITA_M == 0), "Embedding size must be divisible by ITA_M"
        # assert (self.F % self.ITA_M == 0), "Feedforward size must be divisible by ITA_M"

        assert (
            self.E <= 512
        ), f"Embedding size must be less than {int(2**(self.WO-17))} because the internal bit width is {self.WO} bits"
        assert (
            self.P <= 512
        ), f"Projection space must be less than {int(2**(self.WO-17))} because the internal bit width is {self.WO} bits"
        assert (
            self.S <= 512
        ), f"Sequence length must be less than {int(2**(self.WO-17))} because the internal bit width is {self.WO} bits"
        assert (
            self.F <= 512
        ), f"Feedforward size must be less than {int(2**(self.WO-17))} because the internal bit width is {self.WO} bits"

        # assert (self.H % self.H_ITA == 0 or self.H == 1), "Number of heads must be one or divisible by H_ITA"

    def _initialize_tensors(self, Q, V, Wq, Wk, Wv, Wo, Bq, Bk, Bv, Bo, FF_in, Wff, Wff2, Bff, Bff2):

        self.exp_sum = np.zeros(self.S, dtype = np.int32)

        self.Q_in = random_shuffled_tensor((self.S, self.E), self.WI) if Q is None else Q
        self.Q = np.pad(self.Q_in, ((0, self.S_ITA - self.S), (0, self.E_ITA - self.E)))

        self.V_in = random_shuffled_tensor((self.S, self.E), self.WI) if V is None else V
        self.V = np.pad(self.V_in, ((0, self.S_ITA - self.S), (0, self.E_ITA - self.E)))

        # WIESEP: K is the same as V because we do cross-attention
        self.K_in = self.V_in
        self.K = self.V

        self.FF_in = random_shuffled_tensor((self.S, self.E), self.WI) if FF_in is None else FF_in
        self.FF = np.pad(self.FF_in, ((0, self.S_ITA - self.S), (0, self.E_ITA - self.E)))

        #### Weight matrices ####
        self.Wq_in = random_shuffled_tensor((self.H, self.E, self.P), self.WI) if Wq is None else Wq
        self.Wq = np.pad(self.Wq_in, ((0, 0), (0, self.E_ITA - self.E), (0, self.P_ITA - self.P)))

        self.Wk_in = random_shuffled_tensor((self.H, self.E, self.P), self.WI) if Wk is None else Wk
        self.Wk = np.pad(self.Wk_in, ((0, 0), (0, self.E_ITA - self.E), (0, self.P_ITA - self.P)))

        self.Wv_in = random_shuffled_tensor((self.H, self.E, self.P), self.WI) if Wv is None else Wv
        self.Wv = np.pad(self.Wv_in, ((0, 0), (0, self.E_ITA - self.E), (0, self.P_ITA - self.P)))

        self.Wo_in = random_shuffled_tensor((self.H, self.P, self.E), self.WI) if Wo is None else Wo
        self.Wo = np.pad(self.Wo_in, ((0, 0), (0, self.P_ITA - self.P), (0, self.E_ITA - self.E)))

        self.Wff_in = random_shuffled_tensor((1, self.E, self.F), self.WI) if Wff is None else Wff
        self.Wff = np.pad(self.Wff_in, ((0, 0), (0, self.E_ITA - self.E), (0, self.F_ITA - self.F)))
        self.Wff2_in = random_shuffled_tensor((1, self.F, self.E), self.WI) if Wff2 is None else Wff2
        self.Wff2 = np.pad(self.Wff2_in, ((0, 0), (0, self.F_ITA - self.F), (0, self.E_ITA - self.E)))

        #### Bias matrices ####
        if self.bias:
            self.Bq_in = random_shuffled_tensor(
                (self.H, self.P), int(np.log2(self.P)) + 8, type = np.int32) if Bq is None else Bq
        else:
            self.Bq_in = np.zeros((self.H, self.P), dtype = np.int8)
        self.Bq = np.pad(self.Bq_in, ((0, 0), (0, self.P_ITA - self.P)))
        self.Bq_broadcast = np.reshape(np.repeat(self.Bq, self.S, axis = 0), (self.H, self.S, self.P_ITA))
        self.Bq_broadcast = np.pad(self.Bq_broadcast, ((0, 0), (0, self.S_ITA - self.S), (0, 0)))


        if self.bias:
            self.Bk_in = random_shuffled_tensor(
                (self.H, self.P), int(np.log2(self.P)) + 8, type = np.int32) if Bk is None else Bk
        else:
            self.Bk_in = np.zeros((self.H, self.P), dtype = np.int8)
        self.Bk = np.pad(self.Bk_in, ((0, 0), (0, self.P_ITA - self.P)))
        self.Bk_broadcast = np.reshape(np.repeat(self.Bk, self.S, axis = 0), (self.H, self.S, self.P_ITA))
        self.Bk_broadcast = np.pad(self.Bk_broadcast, ((0, 0), (0, self.S_ITA - self.S), (0, 0)))

        if self.bias:
            self.Bv_in = random_shuffled_tensor(
                (self.H, self.P), int(np.log2(self.P)) + 8, type = np.int32) if Bv is None else Bv
        else:
            self.Bv_in = np.zeros((self.H, self.P), dtype = np.int8)
        self.Bv = np.pad(self.Bv_in, ((0, 0), (0, self.P_ITA - self.P)))
        self.Bv_broadcast = np.reshape(np.repeat(self.Bv, self.S, axis = 0), (self.H, self.S, self.P_ITA))
        self.Bv_broadcast = np.pad(self.Bv_broadcast, ((0, 0), (0, self.S_ITA - self.S), (0, 0)))

        if self.bias:
            self.Bo_in = random_shuffled_tensor(
                (self.H, self.E), int(np.log2(self.E)) + 8, type = np.int32) if Bo is None else Bo
        else:
            self.Bo_in = np.zeros((self.H, self.E), dtype = np.int8)
        self.Bo = np.pad(self.Bo_in, ((0, 0), (0, self.E_ITA - self.E)))
        self.Bo_broadcast = np.reshape(np.repeat(self.Bo, self.S, axis = 0), (self.H, self.S, self.E_ITA))
        self.Bo_broadcast = np.pad(self.Bo_broadcast, ((0, 0), (0, self.S_ITA - self.S), (0, 0)))

        if self.bias:
            self.Bff_in = random_shuffled_tensor(
                (1, self.F), int(np.log2(self.F)) + 8, type = np.int32) if Bff is None else Bff
        else:
            self.Bff_in = np.zeros((1, self.F), dtype = np.int8)
        self.Bff = np.pad(self.Bff_in, ((0, 0), (0, self.F_ITA - self.F)))
        self.Bff_broadcast = np.reshape(np.repeat(self.Bff, self.S, axis = 0), (1, self.S, self.F_ITA))
        self.Bff_broadcast = np.pad(self.Bff_broadcast, ((0, 0), (0, self.S_ITA - self.S), (0, 0)))
        if self.bias:
            self.Bff2_in = random_shuffled_tensor(
                (1, self.E), int(np.log2(self.E)) + 8, type = np.int32) if Bff2 is None else Bff2
        else:
            self.Bff2_in = np.zeros((1, self.E), dtype = np.int8)
        self.Bff2 = np.pad(self.Bff2_in, ((0, 0), (0, self.E_ITA - self.E)))
        self.Bff2_broadcast = np.reshape(np.repeat(self.Bff2, self.S, axis = 0), (1, self.S, self.E_ITA))
        self.Bff2_broadcast = np.pad(self.Bff2_broadcast, ((0, 0), (0, self.S_ITA - self.S), (0, 0)))

        #### Intermediate tensors ####

        self.Qp = None
        self.Qp_requant = None
        self.Kp = None
        self.Kp_requant = None
        self.Vp = None
        self.Vp_requant = None
        self.FFp = None
        self.FFp_requant = None
        self.FF2p = None
        self.FF2p_requant = None

        self.A = None
        self.A_requant = None
        self.A_real_softmax = np.zeros([self.H, self.S, self.S], dtype = np.int8)
        self.A_partial_softmax = np.zeros([self.H, self.S, self.S], dtype = np.int8)

        self.Mask = None

        self.O_soft = None
        self.O_soft_requant = None

        self.Out_soft = None
        self.Out_soft_requant = None

        self.Out_soft_sum = None
        self.Out_soft_sum_requant = None

        self.preactivation = np.random.randint(-128, 127, size = (self.S, self.F), dtype = np.int8)
        self.postactivation = None

    def _initialize_quantization_parameters(self):
        # WIESEP: 6 steps for attention layer and one to requantize the accumulated output, 2 for feedforward
        self.requant_eps_mult = np.zeros((7, self.H), dtype = np.uint8)
        self.requant_right_shift = np.zeros((7, self.H), dtype = np.uint8)

        # WIESEP: Add parameter in transformers will always be zero as there are no batch normalization layers
        self.requant_add = np.zeros((7, self.H), dtype = np.int8)

        for i in range(7):
            self.requant_eps_mult[i, :] = np.random.randint(64, 127, size = (1, self.H), dtype = np.uint8)

            if i < 3:  # Q, K, V
                max_bit_width = np.log2(self.requant_eps_mult[i, :].astype(np.uint32) * self.E * 2**9).astype(np.uint32)
            elif i == 3:  # QK
                max_bit_width = np.log2(self.requant_eps_mult[i, :].astype(np.uint32) * self.P * 2**8).astype(np.uint32)
            elif i == 4:  # AV
                max_bit_width = np.log2(self.requant_eps_mult[i, :].astype(np.uint32) * self.S * 2**5).astype(np.uint32)
            elif i == 5:  # OW
                max_bit_width = np.log2(self.requant_eps_mult[i, :].astype(np.uint32) * self.E * 2**9).astype(np.uint32)
            elif i == 6:  # Sum OW
                max_bit_width = np.log2(self.requant_eps_mult[i, :].astype(np.uint32) * self.H * 2**7).astype(np.uint32)

            # WIESEP: Last requatization after head summation shares the same parameters
            if i == 6:
                self.requant_right_shift[i, :] = np.tile(max_bit_width[0] - 8 + 2, self.H)
            else:
                self.requant_right_shift[i, :] = max_bit_width - 8 + 2

        write_matrix([self.requant_eps_mult.T], "RQS_ATTN_MUL", self.paths["base"])
        write_matrix([self.requant_right_shift.T], "RQS_ATTN_SHIFT", self.paths["base"])
        write_matrix([self.requant_add.T], "RQS_ATTN_ADD", self.paths["base"])

        self.requant_eps_mult_ffn = np.zeros((2, 1), dtype = np.uint8)
        self.requant_right_shift_ffn = np.zeros((2, 1), dtype = np.uint8)
        self.requant_add_ffn = np.zeros((2, 1), dtype = np.int8)

        for i in range(2):
            self.requant_eps_mult_ffn[i, :] = np.random.randint(64, 127, size = (1, 1), dtype = np.uint8)

            if i == 0:
                max_bit_width = np.log2(self.requant_eps_mult_ffn[i, :].astype(np.uint32) * self.E * 2**9).astype(
                    np.uint32)
            elif i == 1:
                max_bit_width = np.log2(self.requant_eps_mult_ffn[i, :].astype(np.uint32) * self.F * 2**9).astype(
                    np.uint32)

            self.requant_right_shift_ffn[i, :] = max_bit_width - 8 + 2

        write_matrix([self.requant_eps_mult_ffn.T], "RQS_FFN_MUL", self.paths["base"])
        write_matrix([self.requant_right_shift_ffn.T], "RQS_FFN_SHIFT", self.paths["base"])
        write_matrix([self.requant_add_ffn.T], "RQS_FFN_ADD", self.paths["base"])

    def _init_gelu_constants(self):
        CLIP_LO = -4
        D = 2**20

        gelu_eps_mult, _ = get_almost_symmetric_scaling_factor(CLIP_LO, n_bits = 8)
        self.q_1, self.q_b, self.q_c, _, _, _, self.gelu_rqs_mul, self.gelu_rqs_shift, self.gelu_rqs_add, S_out = get_i_gelu_requantized_constants(
            gelu_eps_mult, D)

        write_matrix([[self.q_1]], "GELU_ONE", self.paths["base"])
        write_matrix([[self.q_b]], "GELU_B", self.paths["base"])
        write_matrix([[self.q_c]], "GELU_C", self.paths["base"])
        write_matrix([[self.gelu_rqs_mul]], "activation_requant_mult", self.paths["base"])
        write_matrix([[self.gelu_rqs_shift]], "activation_requant_shift", self.paths["base"])
        write_matrix([[self.gelu_rqs_add]], "activation_requant_add", self.paths["base"])

    def _init_paths(self, base_path: Union[str, os.PathLike]):
        self.paths = {
            "base": base_path,
            "mempool": os.path.join(base_path, "mempool/"),
            "hwpe": os.path.join(base_path, "hwpe/"),
            "standalone": os.path.join(base_path, "standalone/"),
            "snitch-cluster": os.path.join(base_path, "snitch-cluster/")
        }
        for path in self.paths.values():
            os.makedirs(path, exist_ok = True)

    def print_properties(self, verbose: int, text_align = 30):
        if verbose > 0:
            print(f"{'ITA Sequence Length ' :<{text_align}}: {self.S_ITA}")
            print(f"{'ITA Projection Space' :<{text_align}}: {self.P_ITA}")
            print(f"{'ITA Embedding Size  ' :<{text_align}}: {self.E_ITA}")
            print(f"{'ITA Number of Heads ' :<{text_align}}: {self.H_ITA}")
            print(f"{'Matrix Sequence Length ' :<{text_align}}: {self.S}")
            print(f"{'Matrix Projection Space' :<{text_align}}: {self.P}")
            print(f"{'Matrix Embedding Size  ' :<{text_align}}: {self.E}")
            print(f"{'Matrix Feedforward Size' :<{text_align}}: {self.F}")
            print(f"{'Matrix Number of Heads ' :<{text_align}}: {self.H}")
            print(f"{'Bias ' :<{text_align}}: {bool(self.bias)}")
            print(f"{'Requant Mult Attention ' :<{text_align}}: {list(self.requant_eps_mult)}")
            print(f"{'Requant Shift Attention ' :<{text_align}}: {list(self.requant_right_shift)}")
            print(f"{'Requant Add Attention ' :<{text_align}}: {list(self.requant_add)}")
            print(f"{'Requant Mult FFN ' :<{text_align}}: {list(self.requant_eps_mult_ffn)}")
            print(f"{'Requant Shift FFN ' :<{text_align}}: {list(self.requant_right_shift_ffn)}")
            print(f"{'Requant Add FFN ' :<{text_align}}: {list(self.requant_add_ffn)}")

    def tiler_QK(self, qk: np.ndarray, weight: np.ndarray, bias: np.ndarray, output: np.ndarray, input_file: str,
                 weight_file: str, bias_file: str, output_file: str):
        """
        Tile input, weight, bias and output for Q and K generation
        """

        # Weight Wqk is H x E x P
        # Transpose Wqk to H x P x E
        # print(f"qk: {qk.shape}")
        # print(f"qk: {weight.shape}")

        weight = np.transpose(weight, (0, 2, 1))

        tile_x = qk.shape[0] // self.ITA_M  # S // ITA_M
        tile_inner = qk.shape[1] // self.ITA_M  # E // ITA_M
        tile_y = weight.shape[1] // self.ITA_M  # P // ITA_M
        print(f"=> Tile: {input_file} x {weight_file} + {bias_file} = {output_file}")
        print(f"    X: {tile_x}, Y: {tile_y}, Inner: {tile_inner}")

        # Input QK is S x E
        Input = split_matrix(qk, (self.ITA_M, self.ITA_M), flatten = False)
        # Repeat each row of each tile split times
        Input = np.tile(Input, [1, 1, self.split, 1])
        # Repeat each tile number of output row tiles times
        Input = np.tile(Input, [1, tile_y, 1, 1]).reshape((-1, self.ITA_M))
        # fig, ax = plt.subplots(1, 2)  # Create a figure with two subplots
        # im0 = ax[0].imshow(Input, cmap='viridis')
        # im1 = ax[1].imshow(np.squeeze(weight, axis=0))

        # # Add colorbars for each image if needed
        # fig.colorbar(im0, ax=ax[0])
        # fig.colorbar(im1, ax=ax[1])

        # # Set titles for each subplot
        # ax[0].set_title("Inputs")
        # ax[1].set_title("Weights")

        plt.show()
        write_matrix(Input, input_file, self.paths["standalone"])

        # Transposed Weight Wqk is H x P x E
        for h in range(self.H):
            Weight = split_matrix(weight[h], (self.ITA_M, self.ITA_M))
            # Repeat each tile number of output column tiles times
            Weight = np.tile(Weight, [tile_x, 1])
            write_matrix(Weight, f"{weight_file}_{h}", self.paths["standalone"])

        # Bias Bqk is H x P
        # Broadcast Bias Bqk to H x S x P
        bias = np.tile(bias, [1, self.S_ITA, 1])
        for h in range(self.H):
            Bias = split_matrix(bias[h], (self.ITA_M, self.ITA_N))
            write_matrix(Bias, f"{bias_file}_{h}", self.paths["standalone"])

        # Output QKp is H x S x P
        for h in range(self.H):
            Output = split_matrix(output[h], (self.ITA_M, self.ITA_N))
            write_matrix(Output, f"{output_file}_{h}", self.paths["standalone"])

    def tiler_V(self, v, weight, bias, output, input_file, weight_file, bias_file, output_file):
        """
        Tile input, weight, bias and output for V generation
        *Compute Vp in transposed form*
        """

        # Weight Wv is H x E x P
        # Transpose Wv to H x P x E
        weight = np.transpose(weight, (0, 2, 1))

        tile_x = v.shape[0] // self.ITA_M  # S // ITA_M
        tile_inner = v.shape[1] // self.ITA_M  # E // ITA_M
        tile_y = weight.shape[1] // self.ITA_M  # P // ITA_M
        print(f"=> Tile: {input_file} x {weight_file} + {bias_file} = {output_file}")
        print(f"    X: {tile_x}, Y: {tile_y}, Inner: {tile_inner}")

        # Input V is S x E (will be used as second input)
        Input = split_matrix(v, (self.ITA_M, self.ITA_M))
        # Repeat each tile number of output row tiles times
        Input = np.tile(Input, [tile_y, 1])
        write_matrix(Input, input_file, self.paths["standalone"])

        # Transposed Weight Wv is H x P x E (will be used as first input)
        for h in range(self.H):
            Weight = split_matrix(weight[h], (self.ITA_M, self.ITA_M), flatten = False)
            # Repeat each row of each tile split times
            Weight = np.tile(Weight, [1, 1, self.split, 1])
            # Repeat each tile number of output column tiles times
            Weight = np.tile(Weight, [1, tile_x, 1, 1]).reshape((-1, self.ITA_M))
            write_matrix(Weight, f"{weight_file}_{h}", self.paths["standalone"])

        # Bias Bv is H x P
        # Broadcast Bias Bv to H x S x P
        bias = np.tile(bias, [1, self.S_ITA, 1])
        # Transpose Bias Bv to H x P x S
        bias = np.transpose(bias, (0, 2, 1))
        for h in range(self.H):
            Bias = split_matrix(bias[h], (self.ITA_M, self.ITA_N))
            write_matrix(Bias, f"{bias_file}_{h}", self.paths["standalone"])

        # Output Vp is H x S x P
        # Transpose Vp to H x P x S
        output = np.transpose(output, (0, 2, 1))
        for h in range(self.H):
            Output = split_matrix(output[h], (self.ITA_M, self.ITA_N))
            write_matrix(Output, f"{output_file}_{h}", self.paths["standalone"])

    def tiler_AV(self, Qp, Kp, output, input_file, weight_file, output_file):
        """
        Tile input, weight, and output for Q.K = A and A.V = O generation
        """

        tile_x = Qp.shape[1] // self.ITA_M
        tile_inner = Qp.shape[2] // self.ITA_M
        tile_y = Kp.shape[1] // self.ITA_M
        print(f"=> Tile: {input_file} x {weight_file} = {output_file}")
        print(f"    X: {tile_x}, Y: {tile_y}, Inner: {tile_inner}")

        # Input Qp is H x S x P or A is S x S
        for h in range(self.H):
            Input = split_matrix(Qp[h], (self.ITA_M, self.ITA_M), flatten = False)
            # Repeat each row of each tile split times
            Input = np.tile(Input, [1, 1, self.split, 1])
            # Repeat each tile number of output row tiles times
            Input = np.tile(Input, [1, tile_y, 1, 1]).reshape((-1, self.ITA_M))
            write_matrix(Input, f"{input_file}_{h}", self.paths["standalone"])

        # Weight Kp is H x S x P or V is H x P x S
        for h in range(self.H):
            Weight = split_matrix(Kp[h], (self.ITA_M, self.ITA_M))
            # Repeat each tile number of output column tiles times
            Weight = np.tile(Weight, [tile_x, 1])
            write_matrix(Weight, f"{weight_file}_{h}", self.paths["standalone"])

        # Output A is H x S x S or O is H x S x P
        for h in range(self.H):
            Output = split_matrix(output[h], (self.ITA_M, self.ITA_N))
            write_matrix(Output, f"{output_file}_{h}", self.paths["standalone"])

    def tiler_Out(self, O, weight, bias, output, input_file, weight_file, bias_file, output_file):
        """
        Tile input, weight, bias and output for Output generation
        Same as QK but takes multi-head input
        """

        # Weight Wo is H x P x E
        # Transpose Wo to H x E x P
        weight = np.transpose(weight, (0, 2, 1))

        tile_x = O.shape[1] // self.ITA_M  # S // ITA_M
        tile_inner = O.shape[2] // self.ITA_M  # P // ITA_M
        tile_y = weight.shape[1] // self.ITA_M  # E // ITA_M

        print(f"=> Tile: {input_file} x {weight_file} + {bias_file} = {output_file}")
        print(f"    X: {tile_x}, Y: {tile_y}, Inner: {tile_inner}")

        # Input O is H x S x P
        for h in range(self.H):
            Input = split_matrix(O[h], (self.ITA_M, self.ITA_M), flatten = False)
            # Repeat each row of each tile split times
            Input = np.tile(Input, [1, 1, self.split, 1])
            # Repeat each tile number of output row tiles times
            Input = np.tile(Input, [1, tile_y, 1, 1]).reshape((-1, self.ITA_M))
            write_matrix(Input, f"{input_file}_{h}", self.paths["standalone"])

        # Transposed Weight Wo is H x E x P
        for h in range(self.H):
            Weight = split_matrix(weight[h], (self.ITA_M, self.ITA_M))
            # Repeat each tile number of output column tiles times
            Weight = np.tile(Weight, [tile_x, 1])
            write_matrix(Weight, f"{weight_file}_{h}", self.paths["standalone"])

        # Bias Bo is H x E
        # Broadcast Bias Bo to H x S x E
        bias = np.tile(bias, [1, self.S_ITA, 1])
        for h in range(self.H):
            Bias = split_matrix(bias[h], (self.ITA_M, self.ITA_N))
            write_matrix(Bias, f"{bias_file}_{h}", self.paths["standalone"])

        # Output is H x S x E
        for h in range(self.H):
            Output = split_matrix(output[h], (self.ITA_M, self.ITA_N))
            write_matrix(Output, f"{output_file}_{h}", self.paths["standalone"])

    def step1_Qp(self):
        self.Qp = np.matmul(self.Q, self.Wq, dtype = np.int32) + self.Bq_broadcast
        self.Qp = np.clip(self.Qp, -2**(self.WO - 1), 2**(self.WO - 1) - 1)
        self.Qp_requant = requantize(self.Qp, self.requant_eps_mult[0], self.requant_right_shift[0],
                                     self.requant_add[0])
        
        # Set padded values to zero
        if (self.S_ITA - self.S) > 0:
            self.Qp_requant[:, -(self.S_ITA - self.S):, :] = 0
        if (self.P_ITA - self.P) > 0:
            self.Qp_requant[:, :, -(self.P_ITA - self.P):] = 0

        self.tiler_QK(self.Q, self.Wq, self.Bq, self.Qp_requant, "Q", "Wq", "Bq", "Qp")

    def step2_Kp(self):
        self.Kp = np.matmul(self.K, self.Wk, dtype = np.int32) + self.Bk_broadcast
        self.Kp = np.clip(self.Kp, -2**(self.WO - 1), 2**(self.WO - 1) - 1)
        self.Kp_requant = requantize(self.Kp, self.requant_eps_mult[1], self.requant_right_shift[1],
                                     self.requant_add[1])

        if (self.S_ITA - self.S) > 0:
            self.Kp_requant[:, -(self.S_ITA - self.S):, :] = 0
        if (self.P_ITA - self.P) > 0:
            self.Kp_requant[:, :, -(self.P_ITA - self.P):] = 0

        self.tiler_QK(self.K, self.Wk, self.Bk, self.Kp_requant, "K", "Wk", "Bk", "Kp")

    def step3_Vp(self):
        self.Vp = np.matmul(self.V, self.Wv, dtype = np.int32) + self.Bv_broadcast
        self.Vp = np.clip(self.Vp, -2**(self.WO - 1), 2**(self.WO - 1) - 1)
        self.Vp_requant = requantize(self.Vp, self.requant_eps_mult[2], self.requant_right_shift[2],
                                     self.requant_add[2])

        if (self.S_ITA - self.S) > 0:
            self.Vp_requant[:, -(self.S_ITA - self.S):, :] = 0
        if (self.P_ITA - self.P) > 0:
            self.Vp_requant[:, :, -(self.P_ITA - self.P):] = 0

        # Compute Vp in transposed form
        self.tiler_V(self.V, self.Wv, self.Bv, self.Vp_requant, "V", "Wv", "Bv", "Vp")

    def apply_mask(self, index):
        # True means this positon gets masked
        if (self.mask == 'upper_triangular'):
            self.Mask = np.full((self.H, self.S, self.S), fill_value=False, dtype='bool')
            if (0 < index and index < self.S):
                for h in range(self.Mask.shape[0]):
                    for i in range(self.Mask.shape[1]):
                        for j in range((i + index), self.Mask.shape[2]):
                            self.Mask[h][i][j] = True
            else:
                raise ValueError(f"Index is out of bounds for {self.mask} mask")
        elif (self.mask == 'lower_triangular'):
            self.Mask = np.full((self.H, self.S, self.S), fill_value=False, dtype='bool')
            if (0 < index and index < self.S):
                for h in range(self.Mask.shape[0]):
                    for i in range(index, self.Mask.shape[1]):
                        for j in range((i-(index-1))):
                            self.Mask[h][i][j] = True
            else:
                raise ValueError(f"Index is out of bounds for {self.mask} mask")
        elif (self.mask == 'strided'):
            self.Mask = np.full((self.H, self.S, self.S), fill_value=True, dtype='bool')
            if (0 < index and index < self.S):
                if (index > 0 and (index & (index - 1)) == 0):
                    for h in range(self.Mask.shape[0]):
                        for i in range(self.Mask.shape[1]):
                            self.Mask[h][i][i] = False
                            for j in range(i, self.Mask.shape[2], index):
                                self.Mask[h][i][j] = False
                                self.Mask[h][j][i] = False
                else:
                    raise ValueError(f"Index has to be a power of two for {self.mask} mask")
            else:
                raise ValueError(f"Index is out of bounds for {self.mask} mask")
        elif (self.mask == 'upper_strided'):
            self.Mask = np.full((self.H, self.S, self.S), fill_value=True, dtype='bool')
            if (0 < index and index < self.S):
                if (index > 0 and (index & (index - 1)) == 0):
                    for h in range(self.Mask.shape[0]):
                        for i in range(self.Mask.shape[1]):
                            for j in range(i, self.Mask.shape[2], index):
                                self.Mask[h][i][j] = False
                else:
                    raise ValueError(f"Index has to be a power of two for {self.mask} mask")
            else:
                raise ValueError(f"Index is out of bounds for {self.mask} mask")
        elif (self.mask == 'lower_strided'):
            self.Mask = np.full((self.H, self.S, self.S), fill_value=True, dtype='bool')
            if (0 < index and index < self.S):
                if (index > 0 and (index & (index - 1)) == 0):
                    for h in range(self.Mask.shape[0]):
                        for i in range(self.Mask.shape[1]):
                            for j in range(i, self.Mask.shape[2], index):
                                self.Mask[h][j][i] = False
                else:
                    raise ValueError(f"Index has to be a power of two for {self.mask} mask")
            else:
                raise ValueError(f"Index is out of bounds for {self.mask} mask")
        elif (self.mask == 'sliding_window'):
            self.Mask = np.full((self.H, self.S, self.S), fill_value=True, dtype='bool')
            if (0 < index and index < self.S):
                for h in range(self.Mask.shape[0]):
                    for i in range(self.Mask.shape[1]):
                        for j in range(i, min((index + i), self.Mask.shape[2])):
                            self.Mask[h][i][j] = False
                            self.Mask[h][j][i] = False          
            else:
                raise ValueError(f"Index is out of bounds for {self.mask} mask")
        elif (self.mask == 'strided_sliding_window'):
            self.Mask = np.full((self.H, self.S, self.S), fill_value=True, dtype='bool')
            if (0 < index and index < self.S):
                if (index > 0 and (index & (index - 1)) == 0):
                    for h in range(self.Mask.shape[0]):
                        for i in range(self.Mask.shape[1]):
                            for j in range(i, self.Mask.shape[2]):
                                if (j < (index + i) or ((j-i) % index == 0)):
                                    self.Mask[h][i][j] = False
                                    self.Mask[h][j][i] = False
                else:
                    raise ValueError(f"Index has to be a power of two for {self.mask} mask")                
            else:
                raise ValueError(f"Index is out of bounds for {self.mask} mask")
        elif (self.mask == 'none'):
            self.Mask = np.full((self.H, self.S, self.S), fill_value=False, dtype='bool')       
        else:
            raise ValueError("Mask not supported")
        

    def step4_QK(self, no_partial_softmax, index):
        self.A = np.array(
            [np.matmul(self.Qp_requant[i], np.transpose(self.Kp_requant[i]), dtype = np.int32) for i in range(self.H)])
        self.A = np.clip(self.A, -2**(self.WO - 1), 2**(self.WO - 1) - 1)
        self.A_requant = requantize(self.A, self.requant_eps_mult[3], self.requant_right_shift[3], self.requant_add[3])

        self.apply_mask(index)

        if (self.S_ITA - self.S) > 0:
            self.A_requant[:, -(self.S_ITA - self.S):, :] = 0
            self.A_requant[:, :, -(self.S_ITA - self.S):] = 0
        
        self.soft(no_partial_softmax)

        self.tiler_AV(self.Qp_requant, self.Kp_requant, self.A_requant, "Qp_in", "Kp_in", "A")

    def soft(self, no_partial_softmax = False):
        self.A_real_softmax = realSoftmax(self.A_requant[:, :self.S, :self.S])
        self.A_real_softmax = np.pad(self.A_real_softmax, ((0, 0), (0, self.S_ITA - self.S), (0, self.S_ITA - self.S)))

        if no_partial_softmax:
            self.A_partial_softmax = fastSoftmax(self.A_requant[:, :self.S, :self.S])
            self.A_partial_softmax = np.pad(self.A_partial_softmax,
                                            ((0, 0), (0, self.S_ITA - self.S), (0, self.S_ITA - self.S)))
        else:
            self.A_partial_softmax = streamingPartialSoftmax(self.A_requant[:, :self.S, :self.S], self.Mask)
            self.A_partial_softmax[self.Mask] = 0
            self.A_partial_softmax = np.pad(self.A_partial_softmax,
                                            ((0, 0), (0, self.S_ITA - self.S), (0, self.S_ITA - self.S)))

        if self.H == 1:
            A_save = [np.tile(self.A_partial_softmax[i], [self.split, 1]) for i in range(self.H)]
            write_matrix(A_save, "A_soft_in", self.paths["standalone"])
        for h in range(self.H):
            A_save = self.A_partial_softmax[h]
            write_matrix(A_save, f"A_soft_{h}", self.paths["standalone"])

    def step5_AV(self):        
        self.O_soft = np.array([
            np.matmul(self.A_partial_softmax[i].astype(np.uint8), self.Vp_requant[i], dtype = np.int32)
            for i in range(self.H)
        ])
               
        self.O_soft = np.clip(self.O_soft, -2**(self.WO - 1), 2**(self.WO - 1) - 1)
        self.O_soft_requant = requantize(self.O_soft, self.requant_eps_mult[4], self.requant_right_shift[4],
                                         self.requant_add[4])
        
        if (self.S_ITA - self.S) > 0:
            self.O_soft_requant[:, -(self.S_ITA - self.S):, :] = 0
        if (self.P_ITA - self.P) > 0:
            self.O_soft_requant[:, :, -(self.P_ITA - self.P):] = 0

        self.tiler_AV(self.A_requant, np.transpose(self.Vp_requant, (0, 2, 1)), self.O_soft_requant, "A_stream_soft_in",
                      "Vp_in", "O_soft")
        
        

    def apply_activation(self, preactivation, activation):
        if activation not in ["gelu", "relu", "identity"]:
            raise ValueError("Activation function not supported")

        if activation == "gelu":
            vectorized_gelu = np.vectorize(i_gelu_requantized)
            postactivation = vectorized_gelu(preactivation, self.q_1, self.q_b, self.q_c, self.gelu_rqs_mul,
                                             self.gelu_rqs_shift, self.gelu_rqs_add)
        elif activation == "relu":
            postactivation = np.maximum(preactivation, 0)
            vectorized_requantize = np.vectorize(gelu_requantize)
            postactivation = vectorized_requantize(postactivation, self.gelu_rqs_mul, self.gelu_rqs_shift,
                                                   self.gelu_rqs_add)
        elif activation == "identity":
            postactivation = preactivation.copy()

        return postactivation

    def step6_O(self):
        self.Out_soft = np.matmul(self.O_soft_requant, self.Wo, dtype = np.int32) + self.Bo_broadcast
        self.Out_soft = np.clip(self.Out_soft, -2**(self.WO - 1), 2**(self.WO - 1) - 1)
        self.Out_soft_requant = requantize(self.Out_soft, self.requant_eps_mult[5], self.requant_right_shift[5],
                                           self.requant_add[5])

        if (self.S_ITA - self.S) > 0:
            self.Out_soft_requant[:, -(self.S_ITA - self.S):, :] = 0
        if (self.E_ITA - self.E) > 0:
            self.Out_soft_requant[:, :, -(self.E_ITA - self.E):] = 0

        self.tiler_Out(self.O_soft_requant, self.Wo, self.Bo, self.Out_soft_requant, "O_soft_in", "Wo", "Bo",
                       "Out_soft")

    def feedforward_layer(self):
        self.FFp = np.matmul(self.FF, self.Wff, dtype = np.int32) + self.Bff_broadcast
        self.FFp = np.clip(self.FFp, -2**(self.WO - 1), 2**(self.WO - 1) - 1)
        self.FFp_requant = requantize(self.FFp, self.requant_eps_mult_ffn[0], self.requant_right_shift_ffn[0],
                                      self.requant_add_ffn[0])
        self.FFp_requant = self.apply_activation(self.FFp_requant, self.activation)
    
        self.tiler_QK(self.FF, self.Wff, self.Bff, self.FFp_requant, "FF", "Wff", "Bff", "FFp")

        self.FF2p = np.matmul(self.FFp_requant, self.Wff2, dtype = np.int32) + self.Bff2_broadcast
        self.FF2p = np.clip(self.FF2p, -2**(self.WO - 1), 2**(self.WO - 1) - 1)
        self.FF2p_requant = requantize(self.FF2p, self.requant_eps_mult_ffn[1], self.requant_right_shift_ffn[1],
                                       self.requant_add_ffn[1])

        self.tiler_Out(self.FFp_requant, self.Wff2, self.Bff2, self.FF2p_requant, "FFp_in", "Wff2", "Bff2", "FF2p")

    def step7_Osum(self):
        self.Out_soft_sum = np.sum(self.Out_soft_requant, axis = 0, dtype = np.int32, keepdims = True)
        self.Out_soft_sum_requant = requantize(self.Out_soft_sum, self.requant_eps_mult[6], self.requant_right_shift[6],
                                               self.requant_add[6])

    def test_activations(self):
        write_matrix(self.preactivation, "preactivation", self.paths["standalone"])
        gelu = np.zeros(self.preactivation.shape, dtype = np.int8)
        relu = np.zeros(self.preactivation.shape, dtype = np.int8)
        for i in range(self.preactivation.shape[0]):
            for j in range(self.preactivation.shape[1]):
                gelu[i, j] = i_gelu_requantized(self.preactivation[i, j], self.q_1, self.q_b, self.q_c,
                                                self.gelu_rqs_mul, self.gelu_rqs_shift, self.gelu_rqs_add)
                relu[i, j] = self.preactivation[i, j] if self.preactivation[i, j] > 0 else 0
                relu[i, j] = gelu_requantize(relu[i, j], self.gelu_rqs_mul, self.gelu_rqs_shift, self.gelu_rqs_add)

        write_matrix(gelu, "gelu", self.paths["standalone"])
        write_matrix(relu, "relu", self.paths["standalone"])

    def export_hwpe(self):
        path = self.paths["hwpe"]

        def remove_if_exists(file_name):
            if os.path.exists(file_name):
                os.remove(file_name)

        # WIESEP: Delete the old file otherwise it will lead to mismatches during RTL simulations as the files are memory mapped
        mem_file = "mem"
        files = [
            f"{mem_file}.txt", "Output.txt", "Q.txt", "K.txt", "V.txt", "QK.txt", "A.txt", "AV.txt", "OW.txt", "F1.txt",
            "F2.txt"
        ]
        for file in files:
            remove_if_exists(f"{path}/{file}")

        # Write the new mem file
        # Layer: Attention
        for h in range(self.H):
            q = split_matrix(self.Q, (self.ITA_M, self.ITA_M))
            write_matrix_mem_hex(pack_array_8b_to_word(q, hex_string = False), mem_file, path)

            k = split_matrix(self.K, (self.ITA_M, self.ITA_M))
            write_matrix_mem_hex(pack_array_8b_to_word(k, hex_string = False), mem_file, path)

            w1 = split_matrix(np.transpose(self.Wq[h]), (self.ITA_M, self.ITA_M))
            write_matrix_mem_hex(pack_array_8b_to_word(w1, hex_string = False), mem_file, path)

            w2 = split_matrix(np.transpose(self.Wk[h]), (self.ITA_M, self.ITA_M))
            write_matrix_mem_hex(pack_array_8b_to_word(w2, hex_string = False), mem_file, path)

            w3 = split_matrix(np.transpose(self.Wv[h]), (self.ITA_M, self.ITA_M))
            write_matrix_mem_hex(pack_array_8b_to_word(w3, hex_string = False), mem_file, path)

            w4 = split_matrix(np.transpose(self.Wo[h]), (self.ITA_M, self.ITA_M))
            write_matrix_mem_hex(pack_array_8b_to_word(w4, hex_string = False), mem_file, path)

            b1_hex = np.vectorize(lambda val: to_hex(val, bit_size = 24))(self.Bq[h])
            # pack 24-bit values into 32-bit words
            packed_b1_hex = np.array(pack_hex_24b(b1_hex))
            write_vector_mem_hex(packed_b1_hex, mem_file, path)

            b2_hex = np.vectorize(lambda val: to_hex(val, bit_size = 24))(self.Bk[h])
            # pack 24-bit values into 32-bit words
            packed_b2_hex = np.array(pack_hex_24b(b2_hex))
            write_vector_mem_hex(packed_b2_hex, mem_file, path)

            b3_hex = np.vectorize(lambda val: to_hex(val, bit_size = 24))(self.Bv[h])
            # pack 24-bit values into 32-bit words
            packed_b3_hex = np.array(pack_hex_24b(b3_hex))
            write_vector_mem_hex(packed_b3_hex, mem_file, path)

            b4_hex = np.vectorize(lambda val: to_hex(val, bit_size = 24))(self.Bo[h])
            # pack 24-bit values into 32-bit words
            packed_b4_hex = np.array(pack_hex_24b(b4_hex))
            write_vector_mem_hex(packed_b4_hex, mem_file, path)

            # Write output
            qp = split_matrix(self.Qp_requant[h], (self.ITA_M, self.ITA_M))
            write_matrix_mem_hex(pack_array_8b_to_word(qp, hex_string = False), "Q", path)

            kp = split_matrix(self.Kp_requant[h], (self.ITA_M, self.ITA_M))
            write_matrix_mem_hex(pack_array_8b_to_word(kp, hex_string = False), "K", path)

            v = split_matrix(np.transpose(self.Vp_requant[h]), (self.ITA_M, self.ITA_M))
            write_matrix_mem_hex(pack_array_8b_to_word(v, hex_string = False), "V", path)

            qk = split_matrix(self.A_requant[h], (self.ITA_M, self.ITA_M))
            write_matrix_mem_hex(pack_array_8b_to_word(qk, hex_string = False), "QK", path)

            a = split_matrix(self.A_partial_softmax[h], (self.ITA_M, self.ITA_M))
            write_matrix_mem_hex(pack_array_8b_to_word(a, hex_string = False), "A", path)

            o = split_matrix(self.O_soft_requant[h], (self.ITA_M, self.ITA_M))
            write_matrix_mem_hex(pack_array_8b_to_word(o, hex_string = False), "AV", path)

            out = split_matrix(self.Out_soft_requant[h], (self.ITA_M, self.ITA_M))
            write_matrix_mem_hex(pack_array_8b_to_word(out, hex_string = False), "OW", path)

        # Layer: Feedforward
        ff = split_matrix(self.FF, (self.ITA_M, self.ITA_M))
        write_matrix_mem_hex(pack_array_8b_to_word(ff, hex_string = False), mem_file, path)

        wff = split_matrix(np.transpose(self.Wff[0]), (self.ITA_M, self.ITA_M))
        write_matrix_mem_hex(pack_array_8b_to_word(wff, hex_string = False), mem_file, path)

        wff2 = split_matrix(np.transpose(self.Wff2[0]), (self.ITA_M, self.ITA_M))
        write_matrix_mem_hex(pack_array_8b_to_word(wff2, hex_string = False), mem_file, path)

        bff_hex = np.vectorize(lambda val: to_hex(val, bit_size = 24))(self.Bff[0])
        # pack 24-bit values into 32-bit words
        packed_bff_hex = np.array(pack_hex_24b(bff_hex))
        write_vector_mem_hex(packed_bff_hex, mem_file, path)

        bff2_hex = np.vectorize(lambda val: to_hex(val, bit_size = 24))(self.Bff2[0])
        # pack 24-bit values into 32-bit words
        packed_bff2_hex = np.array(pack_hex_24b(bff2_hex))
        write_vector_mem_hex(packed_bff2_hex, mem_file, path)

        # Write output
        ff = split_matrix(self.FFp_requant[0], (self.ITA_M, self.ITA_M))
        write_matrix_mem_hex(pack_array_8b_to_word(ff, hex_string = False), "F1", path)

        ff2 = split_matrix(self.FF2p_requant[0], (self.ITA_M, self.ITA_M))
        write_matrix_mem_hex(pack_array_8b_to_word(ff2, hex_string = False), "F2", path)

    def generate_snitch_cluster(self) -> str:
        """
        This function generates a header file for ITA integrated into the the Snitch cluster.

        Returns:
            str: The generated configuration file as a string.
        """

        ret = ""

        ret += f"""/* This file is automatically generated by '{" ".join(sys.argv)}'
* Do not edit manually, any manual change will be overwritten.
*/

// clang-format off
"""

        def generate_C_array(array, name, type = "uint32_t"):
            """
            Generates a C-style array declaration from a numpy array.

            Args:
                array (np.ndarray): The numpy array to be converted.
                name (str): The name of the array in the generated code.

            Returns:
                str: The C-style array declaration.
            """
            return f"const {type} {name}[{array.size}] = {{\n{generate_matrix_mem(array)}\n}};\n"

        def generate_multihead_C_array(multihead_array, name, _type):
            ret = ""
            ret += f"const {_type} {name}[{self.H}][{multihead_array[0].size}] = {{\n"
            ret += ",\n".join([f"{{\n{generate_matrix_mem(array)}\n}}" for array in multihead_array])
            ret += "\n};\n"
            return ret

        def requant_multihead_harmonization_and_pack_8b(requant_array):
            ret = []
            for i in range(self.H):
                ret.append(pack_8b_to_word(np.pad(requant_array[:6, i], (0, 2))))
            return np.array(ret)

        def generate_define(name, value):
            return f"#define {name.upper()} {value}\n"

        # Inputs (Q, K)
        ret += generate_C_array(self.split_m_m(self.Q), "input_q", "int8_t")
        ret += generate_C_array(self.split_m_m(self.K), "input_k", "int8_t")

        # Weights (Wq, Wk, Wv, Wo)
        ret += generate_multihead_C_array(self.split_multihead_m_m(self.Wq.transpose(0, 2, 1)), "input_Wq", "int8_t")
        ret += generate_multihead_C_array(self.split_multihead_m_m(self.Wk.transpose(0, 2, 1)), "input_Wk", "int8_t")
        ret += generate_multihead_C_array(self.split_multihead_m_m(self.Wv.transpose(0, 2, 1)), "input_Wv", "int8_t")
        ret += generate_multihead_C_array(self.split_multihead_m_m(self.Wo.transpose(0, 2, 1)), "input_Wo", "int8_t")

        # Biases (Bq, Bk, Bv, Bo)
        ret += generate_multihead_C_array(self.Bq, "input_Bq", "ita_int24_t")
        ret += generate_multihead_C_array(self.Bk, "input_Bk", "ita_int24_t")
        ret += generate_multihead_C_array(self.Bv, "input_Bv", "ita_int24_t")
        ret += generate_multihead_C_array(self.Bo, "input_Bo", "ita_int24_t")

        # Requantization parameters
        ret += generate_multihead_C_array(requant_multihead_harmonization_and_pack_8b(self.requant_eps_mult),
                                          "requant_eps_mult", "int32_t")
        ret += generate_multihead_C_array(requant_multihead_harmonization_and_pack_8b(self.requant_right_shift),
                                          "requant_right_shift", "int32_t")
        ret += generate_multihead_C_array(requant_multihead_harmonization_and_pack_8b(self.requant_add), "requant_add",
                                          "int32_t")

        # Intermediate results (Qp, Kp, Vp, A, O_soft, Out_soft)
        ret += generate_multihead_C_array(self.split_multihead_m_m(self.Qp_requant), "golden_interm_Pq", "int8_t")
        ret += generate_multihead_C_array(self.split_multihead_m_m(self.Kp_requant), "golden_interm_Pk", "int8_t")
        ret += generate_multihead_C_array(self.split_multihead_m_m(self.Vp_requant.transpose((0, 2, 1))),
                                          "golden_interm_Pv", "int8_t")
        ret += generate_multihead_C_array(self.split_multihead_m_m(self.A_requant), "golden_interm_attention", "int8_t")
        ret += generate_multihead_C_array(self.split_multihead_m_m(self.O_soft_requant), "golden_interm_head_output",
                                          "int8_t")
        ret += generate_multihead_C_array(self.split_multihead_m_m(self.Out_soft_requant), "golden_output", "int8_t")

        ret += "\n"

        ret += generate_define("heads", self.H)
        ret += generate_define("sequence_length", self.S)
        ret += generate_define("embedding_space", self.E)
        ret += generate_define("projection_space", self.P)
        ret += generate_define("n_tile_sequence_length", self.S // 64)
        ret += generate_define("n_tile_embedding_space", self.E // 64)
        ret += generate_define("n_tile_projection_space", self.P // 64)
        ret += generate_define("tile_size_sequence_length", 64)
        ret += generate_define("tile_size_embedding_space", 64)
        ret += generate_define("tile_size_projection_space", 64)

        ret += '\n// clang-format on\n'

        return ret

    def export_snitch_cluster(self, path, filename = "mem_snitch_cluster.h"):
        if path == './':
            path = self.paths["snitch-cluster"]

        print(f"=> Exporting memory file to '{path}'")

        with open(os.path.join(path, filename), "w") as f:
            f.write(self.generate_snitch_cluster())

    def export_mempool(self, path):
        # WIESEP: TODO: Refactor code to use new split_matrix function

        if path == './':
            path = self.paths["mempool"]

        print(f"=> Exporting memory file to '{path}'")

        requant_eps_mult = np.pad(self.requant_eps_mult[:6, :].T, ((0, 0), (0, 2)), mode = "constant")
        requant_right_shift = np.pad(self.requant_right_shift[:6, :].T, ((0, 0), (0, 2)), mode = "constant")
        requant_add = np.pad(self.requant_add[:6, :].T, ((0, 0), (0, 2)), mode = "constant")

        with open('%s%s.c' % (path, "mem"), "w+") as f:
            f.write(f"""/* This file is automatically generated by '{" ".join(sys.argv)}'
* Do not edit manually, any manual change will be overwritten.
*/

// clang-format off
""")

        with open('%s%s.c' % (path, "mem"), "a+") as f:
            f.write('#include <stdint.h>\n')
            f.write(f'\nconst uint8_t Requant_Mult[{self.H}][{requant_eps_mult[0].size}] = ' + '{')
        write_matrix_mem([requant_eps_mult], "mem", path)

        with open('%s%s.c' % (path, "mem"), "a+") as f:
            f.write('};' + f'\nconst uint8_t Requant_Shift[{self.H}][{requant_right_shift[0].size}] = ' + '{')
        write_matrix_mem([requant_right_shift], "mem", path)

        with open('%s%s.c' % (path, "mem"), "a+") as f:
            f.write('};' + f'\nconst int8_t Requant_Add[{self.H}][{requant_add[0].size}] = ' + '{')
        write_matrix_mem([requant_add], "mem", path)

        with open('%s%s.c' % (path, "mem"), "a+") as f:
            f.write('};\n\n')

        for h in range(self.H):
            with open('%s%s.c' % (path, "mem"), "a+") as f:
                f.write(f'const int8_t inputs_{h}[] __attribute__((aligned(0x1000))) = ' + '{\n')

            w4 = np.concatenate([np.transpose(self.Wo[h])])
            write_matrix_mem(w4, "mem", path)

            w3 = np.concatenate([np.transpose(self.Wv[h])])
            write_matrix_mem(w3, "mem", path)

            w2 = np.concatenate([np.transpose(self.Wk[h])])
            write_matrix_mem(w2, "mem", path)

            q = np.concatenate(np.split(self.Q, self.split, axis = 1))
            write_matrix_mem(q, "mem", path)

            k = np.concatenate(np.split(self.K, self.split, axis = 1))
            write_matrix_mem(k, "mem", path)

            # w1 = np.concatenate([np.transpose(self.Wq[i]) for i in range(self.H)])
            w1 = np.concatenate(np.split(np.concatenate([np.transpose(self.Wq[h])]), self.split, axis = 1))
            write_matrix_mem(w1, "mem", path)

            b4 = np.reshape(np.split(self.Bo_broadcast[h], self.split, axis = 1), (self.S_ITA, self.E_ITA))
            write_matrix_mem(b4, "mem", path)

            b3 = np.reshape(
                np.split(np.reshape(np.transpose(self.Bv_broadcast[h]), (self.P_ITA, self.S_ITA)), self.split,
                         axis = 1), (self.P_ITA, self.S_ITA))
            write_matrix_mem(b3, "mem", path)

            b2 = np.reshape(np.split(self.Bk_broadcast[h], self.split, axis = 1), (self.S_ITA, self.P_ITA))
            write_matrix_mem(b2, "mem", path)

            b1 = np.reshape(np.split(self.Bq_broadcast[h], self.split, axis = 1), (self.S_ITA, self.P_ITA))
            write_matrix_mem(b1, "mem", path)

            with open('%s%s.c' % (path, "mem"), "ab+") as f:
                f.seek(-1, os.SEEK_END)
                f.truncate()
            with open('%s%s.c' % (path, "mem"), "a+") as f:
                f.write('\n};\n\n')

        with open('%s%s.c' % (path, "mem"), "a+") as f:
            f.write('\n// clang-format on\n')
            tot_bytes = np.size(self.Q) + np.size(self.K) + np.size(self.Wq) + np.size(self.Bq_broadcast) \
                        + np.size(self.Wk) + np.size(self.Bk_broadcast) + np.size(self.Wv) + np.size(self.Bv_broadcast) + \
                        np.size(self.Wo) + np.size(self.Bo_broadcast)

            tot_params = tot_bytes = np.size(self.Q) + np.size(self.K) + np.size(self.Wq) + np.size(self.Bq) \
                        + np.size(self.Wk) + np.size(self.Bk) + np.size(self.Wv) + np.size(self.Bv) + \
                        np.size(self.Wo) + np.size(self.Bo)

        print(f"{'Number of Bytes' :<{30}}: {tot_bytes} ({tot_bytes/1024} kB)")
        print(f"{'Number of Parameters' :<{30}}: {tot_params} ({tot_params/1000} k)")

    def export_numpy(self):
        assert np.all(np.equal(self.K, self.V)), "For ITA, keys and values have to be equal"
        q = self.Q_in
        k = self.K_in
        w1 = self.Wq_in
        b1 = self.Bq_in
        w2 = self.Wk_in
        b2 = self.Bk_in
        w3 = self.Wv_in
        b3 = self.Bv_in
        w4 = self.Wo_in
        b4 = self.Bo_in
        o = self.Out_soft_requant[:, :self.S, :self.E]
        o_sum = self.Out_soft_sum_requant[:, :self.S, :self.E]
        np.savez('%s%s.npz' % (self.paths["base"], "mha"),
                 q = q,
                 k = k,
                 w1 = w1,
                 b1 = b1,
                 w2 = w2,
                 b2 = b2,
                 w3 = w3,
                 b3 = b3,
                 w4 = w4,
                 b4 = b4,
                 o = o,
                 o_sum = o_sum,
                 rqs_mult = self.requant_eps_mult,
                 rqs_shift = self.requant_right_shift,
                 rqs_add = self.requant_add)


def generateTestVectors(path, **kwargs):
    s = kwargs['S']
    p = kwargs['P']
    e = kwargs['E']
    f = kwargs['F']
    h = kwargs['H']
    activation = kwargs['activation']
    mask = kwargs['mask']
    index = kwargs['I']
    bias = int(not kwargs['no_bias'])
    export_snitch_cluster = kwargs['export_snitch_cluster']
    export_mempool = kwargs['export_mempool']

    acc1 = Transformer(s, p, e, f, h, bias = bias, path = path, activation = activation, mask = mask)

    if kwargs['verbose']:
        print("=> Generating test vectors...")
    acc1.print_properties(kwargs['verbose'])
    acc1.step1_Qp()
    acc1.step2_Kp()
    acc1.step3_Vp()
    acc1.step4_QK(kwargs['no_partial_softmax'], index=index)
    acc1.step5_AV()
    acc1.step6_O()
    acc1.step7_Osum()
    acc1.feedforward_layer()
    acc1.test_activations()

    if export_mempool:
        acc1.export_mempool(kwargs['mem_path'])
    if export_snitch_cluster:
        acc1.export_snitch_cluster(kwargs['mem_path'])
    acc1.export_hwpe()
    acc1.export_numpy()

    def calculate_tensor_stats(tensor, name, tol = 1e-1):
        # Calculate the similarly of elements within one row and over all columns
        similarity_row = np.mean(np.abs(np.diff(tensor, axis = -2)))
        similarity_column = np.mean(np.abs(np.diff(tensor, axis = -1)))

        if (similarity_row < tol) or (similarity_column < tol):
            if name is not None:
                print(f"WARNING: {name} is constant!")
                print(f"{name} Mean-Squared Difference (row)   : {similarity_row:5.1f}")
                print(f"{name} Mean-Squared Difference (column): {similarity_column:5.1f}")
                if kwargs['skip_vector_validation'] is False:
                    raise ValueError(f"Tensor {name} is constant! This is a bad test vector!")
                else:
                    print(f"    WARNING: Tensor {name} is constant! This is a bad test vector!")
            else:
                print("    WARNING: Tensor is constant!")
                print(f"    Mean-Squared Difference (row)   : {similarity_row:5.1f}")
                print(f"    Mean-Squared Difference (column): {similarity_column:5.1f}")

        return similarity_row, similarity_column

    def print_tensor_stats(tensor, name = None):
        print(f"    Min: {np.min(tensor)}")
        print(f"    Max: {np.max(tensor)}")

        similarity_row, similarity_column = calculate_tensor_stats(tensor, name)

        print(f"    Mean-Squared Difference (row)   : {similarity_row:5.1f}")
        print(f"    Mean-Squared Difference (column): {similarity_column:5.1f}")

    # Calculate all tensor statistics
    tensors = {
        "Qp": acc1.Qp_requant,
        "Kp": acc1.Kp_requant,
        "Vp": acc1.Vp_requant,
        "A": acc1.A_requant,
        "A_soft": acc1.A_partial_softmax,
        "O_soft": acc1.O_soft_requant,
        "Out_soft": acc1.Out_soft_requant,
        "Out_soft_sum": acc1.Out_soft_sum_requant
    }

    for name, tensor in tensors.items():
        calculate_tensor_stats(tensor, name)

    # Check if softmax is sufficiently precise
    maep_softmax = error_MAEP(acc1.A_partial_softmax, acc1.A_real_softmax)
    if maep_softmax > 5:
        print(f"WARNING: Softmax is not precise enough! MAEP Error to Integer Softmax: {maep_softmax:.2f}%")

    if kwargs['verbose'] > 1:
        print("=> Qp")
        print_tensor_stats(acc1.Qp_requant)
        if kwargs['verbose'] > 4:
            print(acc1.Qp)
        if kwargs['verbose'] > 3:
            print(acc1.Qp_requant)

        print("=> Kp")
        print_tensor_stats(acc1.Kp_requant)
        if kwargs['verbose'] > 4:
            print(acc1.Kp)
        if kwargs['verbose'] > 3:
            print(acc1.Kp_requant)

        print("=> Vp")
        print_tensor_stats(acc1.Vp_requant)
        if kwargs['verbose'] > 4:
            print(acc1.Vp)
        if kwargs['verbose'] > 3:
            print(acc1.Vp_requant)

        print("=> A")
        print_tensor_stats(acc1.A_requant)
        if kwargs['verbose'] > 4:
            print(acc1.A)
        if kwargs['verbose'] > 3:
            print(acc1.A_requant)

        print("=> A (partial softmax)")
        print_tensor_stats(acc1.A_partial_softmax)
        print(f"    MAEP Error to Integer Softmax: {maep_softmax:.2f}%")
        if kwargs['verbose'] > 3:
            print(acc1.A_partial_softmax)

        print("=> O (soft)")
        print_tensor_stats(acc1.O_soft_requant)
        if kwargs['verbose'] > 4:
            print(acc1.O_soft)
        if kwargs['verbose'] > 3:
            print(acc1.O_soft_requant)

        print("=> Output (all heads)")
        print_tensor_stats(acc1.Out_soft_requant)
        if kwargs['verbose'] > 3:
            print(acc1.Out_soft_requant)

        print("=> Output (accumulated)")
        print_tensor_stats(acc1.Out_soft_sum_requant)
        if kwargs['verbose'] > 3:
            print(acc1.Out_soft_sum_requant)

    if kwargs['plot_tensors']:
        # Plot distribution of all input and output tensors
        import matplotlib.pyplot as plt
        import seaborn as sns
        from matplotlib.gridspec import GridSpec

        def plot_distribution(tensor, title, ax):
            sns.histplot(tensor.flatten(), bins = 50, kde = True, ax = ax)
            ax.set_title(title)

        # Plot color values of all tensors
        def plot_heatmap(tensor, title, ax):
            # If tensor is more than 2D, only plot the first 2D
            if len(tensor.shape) > 2:
                tensor = tensor[0]

            sns.heatmap(tensor, ax = ax, cbar = False)
            # Do not show ticks
            ax.set_xticks([])
            ax.set_yticks([])
            ax.set_title(title)

        # Create sublots
        fig = plt.figure(figsize = (12, 12), layout = 'tight', dpi = 72)

        gs = GridSpec(8, 12, figure = fig)

        ax = fig.add_subplot(gs[0, 0:3])
        plot_distribution(acc1.Q, "Q", ax)
        ax = fig.add_subplot(gs[0, 3:6])
        plot_heatmap(acc1.Q, "Q", ax)
        ax = fig.add_subplot(gs[0, 6:9])
        plot_distribution(acc1.K, "K", ax)
        ax = fig.add_subplot(gs[0, 9:12])
        plot_heatmap(acc1.K, "K", ax)

        ax = fig.add_subplot(gs[1, 0:3])
        plot_distribution(acc1.Wq, "Wq", ax)
        ax = fig.add_subplot(gs[1, 3:6])
        plot_distribution(acc1.Wk, "Wk", ax)
        ax = fig.add_subplot(gs[1, 6:9])
        plot_distribution(acc1.Wv, "Wv", ax)
        ax = fig.add_subplot(gs[1, 9:12])
        plot_distribution(acc1.Wo, "Wo", ax)

        ax = fig.add_subplot(gs[2, 0:3])
        plot_heatmap(acc1.Wq, "Wq", ax)
        ax = fig.add_subplot(gs[2, 3:6])
        plot_heatmap(acc1.Wk, "Wk", ax)
        ax = fig.add_subplot(gs[2, 6:9])
        plot_heatmap(acc1.Wv, "Wv", ax)
        ax = fig.add_subplot(gs[2, 9:12])
        plot_heatmap(acc1.Wo, "Wo", ax)

        ax = fig.add_subplot(gs[3, 0:3])
        plot_distribution(acc1.Bq, "Bq", ax)
        ax = fig.add_subplot(gs[3, 3:6])
        plot_distribution(acc1.Bk, "Bk", ax)
        ax = fig.add_subplot(gs[3, 6:9])
        plot_distribution(acc1.Bv, "Bv", ax)
        ax = fig.add_subplot(gs[3, 9:12])
        plot_distribution(acc1.Bo, "Bo", ax)

        ax = fig.add_subplot(gs[4, 0:3])
        plot_distribution(acc1.Qp_requant, "Qp", ax)
        ax = fig.add_subplot(gs[4, 3:6])
        plot_distribution(acc1.Kp_requant, "Kp", ax)
        ax = fig.add_subplot(gs[4, 6:9])
        plot_distribution(acc1.Vp_requant, "Vp", ax)

        ax = fig.add_subplot(gs[5, 0:3])
        plot_heatmap(acc1.Qp_requant, "Qp", ax)
        ax = fig.add_subplot(gs[5, 3:6])
        plot_heatmap(acc1.Kp_requant, "Kp", ax)
        ax = fig.add_subplot(gs[5, 6:9])
        plot_heatmap(acc1.Vp_requant, "Vp", ax)

        ax = fig.add_subplot(gs[6, 0:3])
        plot_distribution(acc1.A_requant, "QK", ax)
        ax = fig.add_subplot(gs[6, 3:6])
        plot_distribution(acc1.A_partial_softmax, "A", ax)
        ax = fig.add_subplot(gs[6, 6:9])
        plot_distribution(acc1.O_soft_requant, "O", ax)
        ax = fig.add_subplot(gs[6, 9:12])
        plot_distribution(acc1.Out_soft_requant, "Out", ax)

        ax = fig.add_subplot(gs[7, 0:3])
        plot_heatmap(acc1.A_requant, "QK", ax)
        ax = fig.add_subplot(gs[7, 3:6])
        plot_heatmap(acc1.A_partial_softmax, "A", ax)
        ax = fig.add_subplot(gs[7, 6:9])
        plot_heatmap(acc1.O_soft_requant, "O", ax)
        ax = fig.add_subplot(gs[7, 9:12])
        plot_heatmap(acc1.Out_soft_requant, "Out", ax)

        plt.show()


def util_main(**kwargs):
    B = 8
    log2e = np.log2(np.exp(1))
    range_scale = 1
    eps_max = range_scale * B / (2**B)

    N = 1024
    A = np.random.randint(-128, 127, size = (1, N, N), dtype = np.int8)
    input_float = A * eps_max  # Assume eps is eps_max
    input_int = A

    fast_softmax = fastSoftmax(input_float, False)
    fast_integer_softmax = fastSoftmax(input_int, True) / 255

    fast_partial_softmax = streamingPartialSoftmax(input_float, False)
    fast_partial_integer_softmax = streamingPartialSoftmax(input_int, True) / 255

    softmax = realSoftmax(input_float, False)
    integer_softmax = realSoftmax(input_int, True) / 255

    print(f"=> L2 Softmax Differences:")
    print(
        f"  Softmax              - Fast Softmax                    : {np.linalg.norm((softmax-fast_softmax)[0], 2):.10}"
    )
    print(
        f"  Softmax              - Fast Partial Softmax            : {np.linalg.norm((softmax-fast_partial_softmax)[0], 2):.10}"
    )
    print(
        f"  Softmax              - Fast Integer Softmax            : {np.linalg.norm((softmax-fast_integer_softmax)[0], 2):.10}"
    )
    print(
        f"  Softmax              - Fast Partial Integer Softmax    : {np.linalg.norm((softmax-fast_partial_integer_softmax)[0], 2):.10}"
    )
    # print(f"  Integer Softmax      - Fast Integer Softmax            : {np.linalg.norm((integer_softmax-fast_integer_softmax)[0], 2):.3}")
    # print(f"  Integer Softmax      - Fast Partial Integer Softmax    : {np.linalg.norm((integer_softmax-fast_partial_integer_softmax)[0], 2):.3}")
    # print(f"  Softmax              - Integer Softmax                 : {np.linalg.norm((integer_softmax-softmax)[0], 2):.3}")
    # print(f"  Fast Softmax         - Fast Partial Softmax            : {np.linalg.norm((fast_softmax-fast_partial_softmax)[0], 2):.3}")
    # print(f"  Fast Integer Softmax - Fast Partial Integer Softmax    : {np.linalg.norm((fast_integer_softmax-fast_partial_integer_softmax)[0], 2):.3}")

    TEST_QUANTLIB = True
    if TEST_QUANTLIB:
        import torch

        from quantlib.algorithms.pact.pact_ops import (PACTIntegerITAMax, PACTIntegerITAPartialMax, PACTITAMax,
                                                       PACTITAPartialMax)
        input = torch.tensor(input_float).unsqueeze(0).float()

        ITAMax = PACTITAMax()
        ITAPartialMax = PACTITAPartialMax(ita_sequence_length = N)
        ITAmax_softmax = ITAMax.forward(input).detach().numpy().squeeze(axis = 0)
        ITApartialmax_softmax = ITAPartialMax.forward(input).detach().numpy().squeeze(axis = 0)

        ITAMax.started = torch.tensor(1)
        ITAPartialMax.started = torch.tensor(1)
        ITAMax.set_eps_in(torch.tensor((eps_max,)))
        ITAPartialMax.set_eps_in(torch.tensor((eps_max,)))
        ITAMax_integer_softmax = ITAMax.forward(input).detach().numpy().squeeze(axis = 0)
        ITAPartialMax_integer_softmax = ITAPartialMax.forward(input).detach().numpy().squeeze(axis = 0)

        input = torch.tensor(input_int).unsqueeze(0).float()
        ITAIntegerMax_softmax = PACTIntegerITAMax.MySoftmax.forward(
            None, input, torch.tensor(256)).detach().numpy().squeeze(axis = 0)
        ITAPartialIntegerMax_softmax = PACTIntegerITAMax.MySoftmax.forward(
            None, input, torch.tensor(256)).detach().numpy().squeeze(axis = 0)

        print()
        print(f"=> L2 PyTorch Softmax Differences:")
        print(
            f"  Fast Softmax                 - ITAmax                       : {np.linalg.norm((fast_softmax-ITAmax_softmax)[0], 2):.3}"
        )
        print(
            f"  Fast Partial Softmax         - ITAPartialMax                : {np.linalg.norm((fast_partial_softmax-ITApartialmax_softmax)[0], 2):.3}"
        )
        print(
            f"  Fast Integer Softmax         - Fake-Quantized ITAmax        : {np.linalg.norm((fast_integer_softmax-ITAMax_integer_softmax)[0], 2):.3}"
        )
        print(
            f"  Fast Integer Partial Softmax - Fake-Quantized ITAPartialMax : {np.linalg.norm((fast_partial_integer_softmax-ITAPartialMax_integer_softmax)[0], 2):.3}"
        )
        print(
            f"  Fast Integer Softmax         - True-Quantized ITAmax        : {np.linalg.norm((fast_integer_softmax-ITAIntegerMax_softmax/255)[0], 2):.3}"
        )
        print(
            f"  Fast Integer Partial Softmax - True-Quantized ITAPartialMax : {np.linalg.norm((fast_partial_integer_softmax-ITAPartialIntegerMax_softmax/255)[0], 2):.3}"
        )
