# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# ----------------------------------------------------------------------
#
# File: softmax.py
#
# Last edited: 5.03.2024
#
# Copyright (C) 2024, ETH Zurich and University of Bologna.
#
# Author: Philip Wiese (wiesep@iis.ee.ethz.ch), ETH Zurich
#
# ----------------------------------------------------------------------

import numpy as np


def fastSoftmax(x, integerize = True):
    if not integerize:
        x = x.astype(np.float64)
    else:
        x = x.astype(np.int32)

    seq_length = x.shape[-1]
    n_heads = x.shape[-3]

    # Number of bits
    B = 8

    # Scaling factor
    range_scale = 32
    eps_max = range_scale * B / (2**B)

    # Find the maximum for each row in the current column block (consisting of 16 columns)
    max = np.repeat(np.max(x, axis = -1), seq_length).reshape(n_heads, seq_length, seq_length)

    # Find the difference between the maximum and x in the current part of the row
    diff = max - x

    # Shift the values by B-log2B -> multiply by B/2**B = log2e*eps_x
    # Make sure to do use round-half-up instead of round-half-to-even
    if integerize:
        shift = np.floor(diff * eps_max + 0.5 + np.finfo(np.float32).eps).astype(int)
    else:
        shift = diff

    # Calculate exponential sum over the  the row and scale it by 2**10 to prevent underflow
    if integerize:
        exp_sum = np.floor(np.sum(2**8 / 2**shift, axis = -1))
    else:
        exp_sum = np.sum(1 / 2**shift, axis = -1)

    # Invert the partial sum
    if integerize:
        exp_sum_inverse = np.floor((2**8 - 1) * 2**8 / exp_sum).astype(int)
    else:
        exp_sum_inverse = 1 / exp_sum

    # Calculate the activation value
    if integerize:
        return (np.floor(np.repeat(exp_sum_inverse, seq_length).reshape(n_heads, seq_length, seq_length) /
                         2**shift)).astype(np.int8)
    else:
        return np.repeat(exp_sum_inverse, seq_length).reshape(n_heads, seq_length, seq_length) / 2**shift


def streamingPartialSoftmax(x, integerize = True):
    if not integerize:
        x = x.astype(np.float32)

    seq_length = x.shape[-1]
    n_heads = x.shape[-3]
    width = 16  # 16 PE (processing units)
    groups = seq_length // width

    assert seq_length % width == 0, f"Sequence length must be a multiple of width ({width})"

    # Number of bits
    B = 8

    # Scaling factor
    range_scale = 32
    eps_max = range_scale * B / (2**B)

    if integerize:
        x = x
    else:
        x = x / eps_max

    # Initialize denominator
    if integerize:
        exp_partial_sum = np.zeros((n_heads, seq_length), dtype = np.int32)
    else:
        exp_partial_sum = np.zeros((n_heads, seq_length), dtype = np.float32)

    # Initialize maximum with minimal possible value
    # max = np.full((n_heads, seq_length), -2**(B - 1), dtype = np.int8)
    if integerize:
        global_max = np.full((n_heads, seq_length), -128, dtype = np.int8)
    else:
        global_max = np.full((n_heads, seq_length), -np.Infinity, dtype = np.float32)

    ## STAGE 1: Compute the denominator of the softmax
    for i in range(groups):
        # Find the maximum for each row in the current column block (consisting of 16 columns)
        if integerize:
            current_max = np.max(x[..., 0 + i * width:width + i * width].astype(np.int32), axis = -1)
        else:
            current_max = np.max(x[..., 0 + i * width:width + i * width].astype(np.float32), axis = -1)

        # Initialize all shift values for each row to zero
        if integerize:
            shift_sum = np.zeros((n_heads, seq_length), dtype = np.int32)
        else:
            shift_sum = np.zeros((n_heads, seq_length), dtype = np.float32)

        # Calculate the number of shifts required to updated the already accumulated sum
        # Make sure to do use round-half-up instead of round-half-to-even
        if integerize:
            max_shift = np.floor((current_max - global_max) * eps_max + 0.5 + np.finfo(np.float32).eps)
        else:
            max_shift = (current_max - global_max) * eps_max

        # Update all shift values where new maximum is larger
        shift_sum[current_max > global_max] = max_shift[current_max > global_max]

        # Updated all maximums where they changed
        global_max[current_max > global_max] = current_max[current_max > global_max]

        # Find the difference between the maximum and x in the current part of the row
        if integerize:
            diff = np.repeat(global_max, width).reshape(
                n_heads, seq_length, width) - x[..., 0 + i * width:width + i * width].astype(np.int32)
        else:
            diff = np.repeat(global_max, width).reshape(
                n_heads, seq_length, width) - x[..., 0 + i * width:width + i * width].astype(np.float32)

        # Shift the values by B-log2B -> multiply by B/2**B = log2e*eps_x
        # Make sure to do use round-half-up instead of round-half-to-even
        if integerize:
            shift = np.floor(diff * eps_max + 0.5 + np.finfo(np.float32).eps).astype(np.int32)
        else:
            shift = diff * eps_max

        # Calculate exponential sum over the current part of the row and scale it by 2**10 to prevent underflow
        if integerize:
            # exp_sum = np.sum(2**8 >> shift, -1) # or
            exp_sum = np.floor(np.sum(2**8 >> shift, axis = -1))
        else:
            exp_sum = np.sum(1 / 2**shift, axis = -1)

        # Update the accumulated sum and add the accumulation over the current part of the row
        if integerize:
            exp_partial_sum = np.floor((exp_partial_sum.astype(np.int32) >> shift_sum)) + exp_sum
        else:
            exp_partial_sum = (exp_partial_sum / 2**(shift_sum.astype(np.float32))) + exp_sum

    ## STAGE 2: Calculate the softmax activation
    # Invert the partial sum
    if integerize:
        exp_partial_sum_inverse = np.floor((2**8 - 1) * 2**8 // exp_partial_sum).astype(np.int32)
    else:
        exp_partial_sum_inverse = 1 / exp_partial_sum

    # Find the difference between the maximum and x
    diff = np.repeat(global_max, seq_length).reshape(n_heads, seq_length, seq_length) - x.astype(np.int32)

    # Shift the values by B-log2B -> multiply by B/2**B = log2e*eps_x
    # Make sure to do use round-half-up instead of round-half-to-even
    if integerize:
        shift = np.floor(diff * eps_max + 0.5 + np.finfo(np.float32).eps).astype(np.int32)
    else:
        shift = diff * eps_max

    # Calculate the activation value
    if integerize:
        # A_partial_softmax[0] = np.repeat(exp_partial_sum_inverse, seq_length).reshape(seq_length, seq_length) >> shift
        return np.floor(
            np.repeat(exp_partial_sum_inverse, seq_length).reshape(n_heads, seq_length, seq_length) >> shift).astype(
                np.uint8)
    else:
        return np.repeat(exp_partial_sum_inverse, seq_length).reshape(n_heads, seq_length, seq_length) / 2**shift


def realSoftmax(A_requant, integerize = True):
    n_heads = A_requant.shape[-3]

    B = 8
    log2e = np.log2(np.exp(1))
    range_scale = 32
    eps_x = range_scale * B / (2**B * log2e)

    if integerize:
        x = A_requant * eps_x
    else:
        x = A_requant.astype(np.float64)

    exp = np.exp(x - np.max(x, axis = 2).reshape(n_heads, -1, 1))
    if integerize:
        return (exp / exp.sum(axis = 2).reshape(n_heads, -1, 1) * (2**7 - 1)).astype(A_requant.dtype)
    else:
        return exp / exp.sum(axis = 2).reshape(n_heads, -1, 1)
