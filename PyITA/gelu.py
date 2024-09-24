# ----------------------------------------------------------------------
#
# File: gelu.py
#
# Last edited: 24.09.2024
#
# Copyright (C) 2024, ETH Zurich and University of Bologna.
#
# ----------------------------------------------------------------------
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the License); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an AS IS BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import numpy as np

from .util import (round_to_i8, round_to_u8, round_to_i16)
from typing import Tuple
from numpy import int8 as i8, int16 as i16, int32 as i32, float32 as f32, uint8 as u8, uint16 as u16


def i_gelu(q: i8, q_1: i16, q_b: i16, q_c: i16) -> i32:
    q_clipped = max(q, -2**7 + 1)
    q_erf: i32 = i_erf(q_clipped, q_b, q_c)
    q_out: i32 = q_clipped * (q_erf + q_1)
    return q_out


def gelu_requantize(q: i32, eps_mul: i8, eps_shift: u8, eps_add: u8) -> i8:
    q_mul: i64 = eps_mul * q
    shifted: f32 = q_mul / 2**float(eps_shift) + eps_add
    q_req: i8 = round_to_i8(shifted)
    return q_req


def i_gelu_requantized(q: i8, q_1: i16, q_b: i16, q_c: i16, eps_mul: u8, eps_shift: u8, eps_add: u8) -> i8:
    q_out: i32 = i_gelu(q, q_1, q_b, q_c)
    q_req: i8 = gelu_requantize(q_out, eps_mul, eps_shift, eps_add)
    return q_req


def get_i_gelu_constants(S: f32) -> Tuple[i16, i16, i16, float, float, float]:
    a: float = -0.2888
    b: float = -1.769
    c: float = 1
    S_2: f32 = S / np.sqrt(2)
    q_1: i16 = round_to_i16(1 / (a * S_2**2))
    q_b: i16 = round_to_i16(b / S_2)
    q_c: i16 = round_to_i16(c / (a * S_2**2))
    return q_1, q_b, q_c, a, b, c


def get_i_gelu_requantized_constants(S: f32, D: i32) -> Tuple[i16, i16, i16, float, float, float, u8, u8, u8, f32]:
    q_1, q_b, q_c, a, b, c = get_i_gelu_constants(S)
    S_2: f32 = S / np.sqrt(2)
    S_out: f32 = S * a * S_2**2 / 2
    # Flip sign of eps_mul to ensure its positive
    eps_mul: u8 = round_to_u8(-S_out / S * D)
    eps_shift: u8 = round_to_i8(np.log2(D))
    eps_add: u8 = 0
    # Compensate for the sign flip in eps_mul by negating S
    return q_1, q_b, q_c, a, b, c, eps_mul, eps_shift, eps_add, -S


def i_gelu_wrapper(q: i8, S: f32) -> Tuple[i32, f32]:
    S_2: f32 = S / np.sqrt(2)
    q_1, q_b, q_c, a, _, _ = get_i_gelu_constants(S)
    q_out: i32 = i_gelu(q, q_1, q_b, q_c)
    S_out: f32 = S * a * S_2**2 / 2
    return q_out, S_out


def i_gelu_wrapper_requantized(q: i8, S: f32, D: i32) -> Tuple[i8, f32]:
    q_1, q_b, q_c, a, _, _, eps_mul, eps_shift, eps_add, S_out = get_i_gelu_requantized_constants(S, D)
    q_out: i32 = i_gelu_requantized(q, q_1, q_b, q_c, eps_mul, eps_shift, eps_add)
    return q_out, S_out


def i_erf(q: i8, q_b: i16, q_c: i16) -> i32:
    q_sgn: i8 = np.sign(q)
    q_abs: i8 = np.abs(q)
    q_clipped: i8 = np.clip(q_abs, 0, -q_b)
    q_L: i32 = i_poly(q_clipped, q_b, q_c)
    q_out: i32 = q_sgn * q_L
    return q_out


def i_erf_wrapper(q: i8, S: i8) -> Tuple[i32, f32]:
    a: float = -0.2888
    b: float = -1.769
    c: float = 1
    q_b: i16 = round_to_i16(b / S)
    q_c: i16 = round_to_i16(c / (a * S**2))
    S_out: f32 = a * S**2
    q_out: i32 = i_erf(q, q_b, q_c)
    return q_out, S_out


def i_poly(q: i8, q_b: i16, q_c: i16) -> i32:
    q16: i16 = q.astype(i16)
    q_c32: i32 = q_c.astype(i32)
    d: i16 = q16 + q_b
    d_sq: i16 = d**2
    q_out: i32 = d_sq + q_c32
    return q_out.astype(i32)


def i_poly_wrapper(q: i8, S: f32, a: f32, b: f32, c: f32) -> Tuple[i32, f32]:
    q_b: i16 = round_to_i16(b / S)
    q_c: i16 = round_to_i16(c / (a * S**2))
    S_out: f32 = a * S**2
    q_out: i32 = i_poly(q, q_b, q_c)
    return q_out, S_out
