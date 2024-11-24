# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# ----------------------------------------------------------------------
#
# File: util.py
#
# Last edited: 24.05.2024
#
# Copyright (C) 2024, ETH Zurich and University of Bologna.
#
# Authors:
# - Philip Wiese (wiesep@iis.ee.ethz.ch), ETH Zurich
#
# ----------------------------------------------------------------------

import os
from typing import Optional, SupportsIndex, Tuple, Union

import numpy as np
from numpy.typing import DTypeLike

from numpy import int8 as i8, int16 as i16, int32 as i32, float32 as f32, uint8 as u8, uint16 as u16


def random_shuffled_tensor(shape, bitwidth: int, type: DTypeLike = np.int8, scaling = 1 / 4) -> np.ndarray:
    """
    Generates a random shuffled tensor with a specified shape, bit width, and type.

    Args:
        shape (tuple): The shape of the tensor.
        bitwidth (int): The bitwidth for the values in the tensor.
        type (DTypeLike, optional): The data type of the tensor. Default is np.int8.
        scaling (int, optional): The factor to scale the distribution . Default is 1/4.

    Returns:
        np.ndarray: A tensor with random shuffled values.
    """
    scale = 2**(bitwidth - 1)
    tensor = np.random.standard_cauchy(size = shape) * scale * scaling
    tensor = np.clip(tensor, -scale, scale - 1)
    return tensor.astype(type)


def write_matrix(matrix: np.ndarray, name: str, path: Union[str, os.PathLike]):
    """
    Writes a matrix to a text file.

    Args:
        matrix (np.ndarray): The matrix to write.
        name (str): The name of the file.
        path (Union[str, os.PathLike]): The path to the directory where the file will be saved.
    """
    if isinstance(matrix, np.ndarray):
        print(matrix)
        import matplotlib.pyplot as plt
        heatmap = np.squeeze(matrix)
        plt.imshow(heatmap, cmap='viridis')
        plt.colorbar()
        plt.title(f"{name}")
        plt.show()

    with open('%s%s.txt' % (path, name), "wb+") as f:
        for row in matrix:
            np.savetxt(f, row, fmt = '%d')
        # Truncate file to remove last newline
        f.seek(-1, os.SEEK_END)
        f.truncate()


def to_hex(val: int, bit_size: int) -> str:
    """
    Converts a signed integer to its hexadecimal representation based on bit size.

    Args:
        val (int): The integer value to convert.
        bit_size (int): The bit size to use for conversion.

    Returns:
        str: The hexadecimal representation of the integer.
    """
    # Cast to int32 to avoid overflow
    val = np.int32(val)

    # Function to convert signed integer to hexadecimal representation based on bit size
    if val < 0:
        val += 2**bit_size  # Adjust for negative values based on bit size
    hex_digits = bit_size // 4
    format_string = f'0{hex_digits}x'
    return format(val, format_string)


def pack_hex_08x(row: np.ndarray) -> str:
    """
    Packs every four 8-bit hex values into one 32-bit hex value.

    Args:
        row (np.ndarray): The array of hex values to pack.

    Returns:
        str: The packed hex string.
    """
    # Function to pack every four 02x hex values into one 08x hex value
    # Reverse each group of four, then join and pack
    return [''.join(row[i:i + 4][::-1]) for i in range(0, len(row), 4)]


def pack_hex_24b(row: np.ndarray) -> str:
    """
    Packs every four 24-bit hex values into three 32-bit hex value.

    Args:
        row (np.ndarray): The array of hex values to pack.

    Returns:
        str: The packed hex string.
    """
    # Join each group of four and pack
    tmp = [''.join(row[i:i + 4][::-1]) for i in range(0, len(row), 4)]
    # Divide each tmp element into three
    result = ['' for i in range(3 * len(tmp))]
    for i in range(len(tmp)):
        result[3 * i] = tmp[i][16:24]
        result[3 * i + 1] = tmp[i][8:16]
        result[3 * i + 2] = tmp[i][0:8]
    return result


def pack_array_8b_to_word(array: np.ndarray, hex_string = True) -> np.ndarray:
    """
    Packs an 2D array of 8-bit values into word-sized (32-bit) hex strings.

    This function converts an array of 8-bit values into their hexadecimal representation,
    then packs each row of these hex values into a single hex string. Optionally, it returns
    these packed hex values as strings prefixed with '0x'.

    Args:
        array (np.ndarray): The input array of 8-bit values to be packed.
        hex_string (bool, optional): If True, returns the packed hex values as strings prefixed
                                     with '0x'. If False, returns the packed hex values as plain
                                     hex strings. Default is True.

    Returns:
        np.ndarray: An string array of packed hex values. Each element is a string representing a
                    packed row of the input array.

    Example:
        >>> array = np.array([[1, 2, 3, 4], [5, 6, 7, 8]])
        >>> pack_array_8b_to_word(array)
        array([['0x04030201'], ['0x08070605']], dtype='<U10')
    """
    array_hex = np.vectorize(lambda val: to_hex(val, bit_size = 8))(array)
    packed_array_hex = np.array([pack_hex_08x(row) for row in array_hex])
    if hex_string:
        return np.vectorize(lambda val: '0x' + val)(packed_array_hex)
    else:
        return packed_array_hex


def pack_24b_to_word(array: np.ndarray) -> np.ndarray:
    """
    Packs an 1D array of 24-bit values into 32-bit words.

    This function converts an array of 24-bit values into their hexadecimal representation,
    then packs these values into 32-bit words. The packed hex values are then converted back
    into a numpy array of 32-bit integers.

    Args:
        array (np.ndarray): The input array of 24-bit values to be packed.

    Returns:
        np.ndarray: An string array of 32-bit integers representing the packed 24-bit values.

    Example:
        >>> array = np.array([167752, 838607, 65500])
        >>> pack_24b_to_word(array)
        array([        72, -875625841,   16768012], dtype=int32)
    """
    _hex = np.vectorize(lambda val: to_hex(val, bit_size = 24))(array)
    # pack 24-bit values into 32-bit words
    packed_hex = np.array(pack_hex_24b(_hex))
    # save back to numpy array
    return np.vectorize(lambda x: int(x, 16), otypes = [np.int32])(packed_hex)


def pack_multihead_8b_to_word(multihead_array: np.ndarray):
    """
    Packs a multihead array of 8-bit values into word-sized (32-bit) hex strings for each head.

    This function takes a multihead array (a list of 2D arrays) of 8-bit values and converts
    each array into its packed hex representation using `pack_array_8b_to_word`.

    Args:
        multihead_array (np.ndarray): A list of 2D arrays where each array represents a head
                                      with 8-bit values to be packed.

    Returns:
        list: A list of packed hex arrays, where each element corresponds to a head in the
              multihead array.

    Example:
        >>> multihead_array = [np.array([[1, 2, 3, 4], [5, 6, 7, 8]]), np.array([[9, 10, 11, 12], [13, 14, 15, 16]])]
        >>> pack_multihead_8b_to_word(multihead_array)
        [array([['0x04030201'], ['0x08070605']], dtype='<U10'), array([['0x0c0b0a09'], ['0x100f0e0d']], dtype='<U10')]
    """
    ret = []
    for array in multihead_array:
        ret.append(pack_array_8b_to_word(array))
    return ret


def pack_multihead_24b_to_word(multihead_array: np.ndarray):
    """
    Packs a multihead array of 24-bit values into 32-bit words for each head.

    This function takes a multihead array (a list of 2D arrays) of 24-bit values and converts
    each array into its packed 32-bit word representation using `pack_24b_to_word`.

    Args:
        multihead_array (np.ndarray): A list of 2D arrays where each array represents a head
                                      with 24-bit values to be packed.

    Returns:
        np.ndarray: A 2D array where each element is a packed array of 32-bit words corresponding
                    to a head in the multihead array.

    Example:
        >>> multihead_array = [np.array([642, 807, 604]), np.array([4193, 2051, 954])]
        >>> pack_multihead_24b_to_word(multihead_array)
        array([[      130,  52887554,    154624],
               [       97, 134414352,    244224]], dtype=int32)
    """
    return np.array([pack_24b_to_word(array) for array in multihead_array])


def pack_8b_to_word(array: np.ndarray):
    """
    Packs an 1D array of 8-bit values into word-sized 32-bit numbers.

    This function takes an array of 8-bit values and packs every four consecutive 8-bit values
    into a single 32-bit word.

    Args:
        array (np.ndarray): The input array of 8-bit values to be packed.

    Returns:
        np.ndarray: An array of 32-bit words representing the packed 8-bit values.

    Example:
        >>> array = np.array([1, 2, 3, 4, 5, 6, 7, 8], dtype=np.uint8)
        >>> pack_8b_to_word(array)
        array([ 67305985, 134678021])
    """

    # Cast to uint32 to avoid overflow
    array = np.array(array, dtype = np.uint32)

    ret = []
    for i in range(0, len(array), 4):
        ret.append((array[i] & 0xff) | ((array[i + 1] & 0xff) << 8) | ((array[i + 2] & 0xff) << 16) |
                   ((array[i + 3] & 0xff) << 24))
    return np.array(ret)


def write_vector_mem_hex(vector: np.ndarray, name: str, path: Union[str, os.PathLike]):
    """
    Writes a vector of hexadecimal values to a text file.

    Args:
        vector (np.ndarray): The vector of hexadecimal values to write.
        name (str): The name of the file.
        path (Union[str, os.PathLike]): The path to the directory where the file will be saved.
    """
    with open('%s%s.txt' % (path, name), "a+") as f:
        np.savetxt(f, vector, fmt = '%s')


def write_matrix_mem_hex(matrix: np.ndarray, name: str, path: Union[str, os.PathLike]):
    """
    Writes a matrix of hexadecimal values to a text file.

    Args:
        matrix (np.ndarray): The matrix of hexadecimal values to write.
        name (str): The name of the file.
        path (Union[str, os.PathLike]): The path to the directory where the file will be saved.
    """
    with open('%s%s.txt' % (path, name), "a+") as f:
        for row in matrix:
            np.savetxt(f, row, fmt = '%s')


def generate_matrix_mem(matrix: np.ndarray) -> str:
    """
    Generates a memory representation of a matrix as a string.

    Args:
        matrix (np.ndarray): The input matrix.

    Returns:
        str: A string representation of the matrix values, flattened and separated by commas.
    """
    return np.array2string(matrix.flatten(), separator = ',', formatter = {'numpystr': lambda x: x})[1:-1]


def write_matrix_mem(matrix: np.ndarray, name: str, path: Union[str, os.PathLike]):
    """
    Writes a matrix of integer values to a C source file.

    Args:
        matrix (np.ndarray): The matrix of integer values to write.
        name (str): The name of the file.
        path (Union[str, os.PathLike]): The path to the directory where the file will be saved.
    """
    with open('%s%s.c' % (path, name), "a+") as f:
        for row in matrix:
            np.savetxt(f, row, fmt = '%d', delimiter = ',', newline = ',')


def clip(matrix: np.ndarray) -> np.ndarray:
    """
    Clips the values in a matrix to the range [-128, 127].

    Args:
        matrix (np.ndarray): The input matrix to be clipped.

    Returns:
        np.ndarray: The clipped matrix with values in the range [-128, 127].

    Example:
        >>> matrix = np.array([[150, -200], [50, 100]])
        >>> clip(matrix)
        array([[ 127, -128],
               [  50,  100]], dtype=int8)
    """
    result = np.empty(matrix.shape, dtype = np.int8)
    for r_ind, row in enumerate(matrix):
        for c_ind, element in enumerate(row):
            if element > 127:
                result[r_ind, c_ind] = 127
            elif element < -128:
                result[r_ind, c_ind] = -128
            else:
                result[r_ind, c_ind] = element
    return result


def requantize(matrix: np.ndarray, eps_mult: int, right_shift: int, add: int):
    """
    Requantizes the values in a 3D matrix with specified multipliers, right shifts, and additions.

    Args:
        matrix (np.ndarray): The input 3D matrix to be requantized.
        eps_mult (int): The multipliers for the elements.
        right_shift (int): The amounts to right shift the result.
        add (int): The values to add after shifting.

    Returns:
        np.ndarray: The requantized 3D matrix.

    Example:
        >>> matrix = np.array([[[50, 100], [150, 200]]])
        >>> eps_mult = [2]
        >>> right_shift = [1]
        >>> add = [1]
        >>> requantize3(matrix, eps_mult, right_shift, add)
        array([[[ 51, 101],
                [127, 127]]], dtype=int8)
    """

    # Cast up to int32 to avoid overflow
    eps_mult = np.array(eps_mult, dtype = np.uint32)
    right_shift = np.array(right_shift, dtype = np.uint32)
    add = np.array(add, dtype = np.int32)

    result = np.empty(matrix.shape, dtype = np.int8)
    for h_ind, heads in enumerate(matrix):
        for r_ind, row in enumerate(heads):
            for c_ind, element in enumerate(row):
                # shifted = ((eps_mult[h_ind] * element) >> right_shift[h_ind]) + add[h_ind]
                shifted = ((eps_mult[h_ind] * element) / 2**right_shift[h_ind]) + add[h_ind]
                shifted = np.floor(shifted + 0.5 + np.finfo(np.float32).eps)
                if shifted > 127:
                    result[h_ind, r_ind, c_ind] = 127
                elif shifted < -128:
                    result[h_ind, r_ind, c_ind] = -128
                else:
                    result[h_ind, r_ind, c_ind] = shifted.astype(np.int8)
    return result


def split_matrix(m: np.ndarray, block_shape: Tuple[SupportsIndex, SupportsIndex], flatten = True) -> np.ndarray:
    """
    Splits a 2-dimensional numpy array into smaller blocks of a specified shape.

    This function takes a 2D numpy array `m` and divides it into smaller 2D blocks. Each block will have the shape specified by `block_shape`. The array is first reshaped and then transposed to get the desired block layout.

    Parameters:
        m (np.ndarray): A 2-dimensional numpy array to be split into blocks.
        block_shape (Tuple[SupportsIndex, SupportsIndex]): A tuple specifying the shape of the blocks. The first element is the number of rows in each block and the second is the number of columns.
        flatten (bool): If True, the function will return a 2D array with shape (-1, block_shape[1]), thus stacking all blocks vertically. If False, the function will return a 4D array where each block is 2D.

    Returns:
        np.ndarray: If flatten is True, the function will return a 2D array where all blocks are stacked vertically. If flatten is False, the function returns a 4D numpy array where each block is accessed by the indices [i, j], where `i` is the block row index and `j` is the block column index.

    Raises:
        ValueError: If the input matrix `m` is not 2-dimensional.

    Example:
        Given a 2D array like this (4x4):

        ```
        [[1, 2, 3, 4],
        [5, 6, 7, 8],
        [9, 10, 11, 12],
        [13, 14, 15, 16]]
        ```

        and `block_shape` of (2, 2), the function will return a 4D array where each 2x2 block can be accessed separately.
        Illustration:
        Original Matrix:
        ```
        +----+----+----+----+
        |  1 |  2 |  3 |  4 |
        +----+----+----+----+
        |  5 |  6 |  7 |  8 |
        +----+----+----+----+
        |  9 | 10 | 11 | 12 |
        +----+----+----+----+
        | 13 | 14 | 15 | 16 |
        +----+----+----+----+
        ```

        After splitting into 2x2 blocks:
        ```
        +-------+-------+
        | [1 2  | [3 4  |
        |  5 6] |  7 8] |
        +-------+-------+
        | [9 10 | [11 12|
        | 13 14]| 15 16]|
        +-------+-------+
        ```

        Each pair of brackets [] represents a separate block.
    """
    if m.ndim == 2:
        res = m.reshape((-1, block_shape[0], m.shape[1] // block_shape[1], block_shape[1])).transpose((0, 2, 1, 3))
        if flatten:
            return res.reshape((-1, block_shape[1]))
        else:
            return res
    else:
        raise ValueError("Matrix must be 2D")


def round(x: f32, n_bits: int = 8):
    x_clip = np.clip(x, -2**(n_bits - 1), 2**(n_bits - 1) - 1)
    return np.floor(x_clip + 0.5 + np.finfo(f32).eps).astype(int)


def clip(x: f32, n_bits: int = 8) -> f32:
    return np.clip(x, -2**(n_bits - 1), 2**(n_bits - 1) - 1)


def round_and_clip(x: f32, n_bits: int = 8) -> f32:
    x_rounded = np.floor(x + 0.5 + np.finfo(f32).eps)
    x_clipped = clip(x_rounded, n_bits)
    return x_clipped


def round_to_i8(x: f32) -> i8:
    x_rounded_clipped: f32 = round_and_clip(x, 8)
    return x_rounded_clipped.astype(i8)


def round_to_u8(x: f32) -> u8:
    x_rounded_clipped: f32 = round_and_clip(x, 8)
    return x_rounded_clipped.astype(u8)


def round_to_i16(x: f32) -> i16:
    x_rounded_clipped: f32 = round_and_clip(x, 16)
    return x_rounded_clipped.astype(i16)


def get_scaling_factor(alpha: f32, n_bits: int = 8) -> f32:
    S: f32 = alpha / (2**(n_bits - 1) - 1)
    return S


def quantize(activations: np.ndarray, alpha: f32, n_bits: int = 8, S: Optional[f32] = None) -> Tuple[np.ndarray, f32]:
    x_q = np.clip(activations, -alpha, alpha)
    if S is None:
        S = get_scaling_factor(alpha, n_bits)
    x_q = x_q / S
    x_q = np.array(list(map(round, x_q)))
    return x_q, S


def dequantize(quantized_activations: np.ndarray, alpha: f32, n_bits: int = 8) -> np.ndarray:
    S = get_scaling_factor(alpha, n_bits)
    activations = quantized_activations * S
    return activations


def get_almost_symmetric_scaling_factor(clip_lo: f32, n_bits: int = 8) -> Tuple[f32, f32]:
    if 2**n_bits == 2:
        return 1
    n_levels = 2**n_bits
    scale = (-n_levels + 2) / n_levels
    clip_hi = clip_lo * scale
    S = clip_hi / (n_levels / 2 - 1)
    return S, clip_hi


def almost_symmetric_quantize(activations: np.ndarray, clip_lo: f32, n_bits: int = 8) -> Tuple[np.ndarray, f32]:
    S, clip_hi = get_almost_symmetric_scaling_factor(clip_lo, n_bits)
    x_q = np.clip(activations, clip_lo, clip_hi)
    x_q = x_q / S
    x_q = np.array(list(map(round, x_q)))
    return x_q, S


def almost_symmetric_dequantize(quantized_activations: np.ndarray, clip_lo: f32, n_bits: int = 8) -> np.ndarray:
    S, _ = get_almost_symmetric_scaling_factor(clip_lo, n_bits)
    activations = quantized_activations * S
    return activations


def error_MAEP(a: np.ndarray, b: np.ndarray):
    """
    Compute the mean absolute error percentage (MAEP) between two tensors.
    A value of 0 indicates that the two tensors are equal.
    A value of 100 indicates that the second tensor is on average twice as large as the first tensor.

    Parameters:
        a (np.ndarray): The first tensor.
        b (np.ndarray): The second tensor.

    Returns:
        np.ndarray: The mean absolute error percentage between the two tensors.
    """
    return 100 * np.mean(np.abs(a - b)) / max(
        np.abs(np.max(a)) + np.abs(np.min(a)),
        np.abs(np.max(b)) + np.abs(np.min(b)))
