import pytest
import torch
import numpy as np
import pytest_check as check

from .ITA import i_poly, i_poly_wrapper, quantize, dequantize, i_erf_wrapper, i_gelu_wrapper

def pretty_print(x, x_q, S, res_q, res_S, deq_res, exp_res):
    print(f"x={x:>10.2f}, x_q={x_q:>10}, S={S:>10.1g}, res_q={res_q:>10}, res_S={res_S:>10.1g}, deq_res={deq_res:>10.2f}, exp_res={exp_res:>10.2f}, abs_err={(np.abs(deq_res - exp_res)):>10.2f}")

def test_gelu():
    n_bits = 8
    xs = np.linspace(0, 1.769, 10)
    alpha = np.abs(xs).max()**2
    x_qs, S = quantize(xs, alpha, n_bits)

    for x, x_q in zip(xs, x_qs):
        res_q, res_S = i_gelu_wrapper(x_q, S)
        deq_res = res_q * res_S
        exp_res = torch.nn.functional.gelu(torch.tensor(x, dtype=torch.float32)).item()
        pretty_print(x, x_q, S, res_q, res_S, deq_res, exp_res)
        check.almost_equal(deq_res, exp_res, abs=2e-2)

def test_gelu_simple():
    xs = np.array([-20, -10, -3, -2, -1, 0, 1, 2, 3, 10, 20]) * 0.1
    alpha, n_bits = 3, 8
    x_qs, S = quantize(xs, alpha, n_bits)

    for x, x_q in zip(xs, x_qs):
        res_q, res_S = i_gelu_wrapper(x_q, S)
        deq_res = res_q * res_S
        exp_res = torch.nn.functional.gelu(torch.tensor(x, dtype=torch.float32)).item()
        pretty_print(x, x_q, S, res_q, res_S, deq_res, exp_res)
        check.almost_equal(deq_res, exp_res, abs=1e-1)


def test_erf():
    xs = np.linspace(0, 1.769, 10)
    alpha, n_bits = 3, 8
    x_qs, S = quantize(xs, alpha, n_bits)

    for x, x_q in zip(xs, x_qs):
        res_q, res_S = i_erf_wrapper(x_q, S)
        deq_res = res_q * res_S
        exp_res = torch.erf(torch.tensor(x, dtype=torch.float32)).item()
        pretty_print(x, x_q, S, res_q, res_S, deq_res, exp_res)
        check.almost_equal(deq_res, exp_res, abs=6e-2)


def test_erf_simple():
    xs = np.array([-20, -10, -3, -2, -1, 0, 1, 2, 3, 10, 20]) * 0.1
    alpha, n_bits = 3, 8
    x_qs, S = quantize(xs, alpha, n_bits)

    for x, x_q in zip(xs, x_qs):
        res_q, res_S = i_erf_wrapper(x_q, S)
        deq_res = res_q * res_S
        exp_res = torch.erf(torch.tensor(x, dtype = torch.float32)).item()
        pretty_print(x, x_q, S, res_q, res_S, deq_res, exp_res)
        check.almost_equal(deq_res, exp_res, abs = 8-2)


def test_i_poly():
    n_bits = 8
    xs = np.linspace(0, 1.769, 10)
    a, b, c = -0.2888, -1.769, 1
    alpha = np.abs(xs).max()**2
    x_qs, S = quantize(xs, alpha, n_bits)
    for x, x_q in zip(xs, x_qs):
        res_q, res_S = i_poly_wrapper(x_q, S, a, b, c)
        deq_res = res_q * res_S
        exp_res = a * (x + b)**2 + c
        pretty_print(x, x_q, S, res_q, res_S, deq_res, exp_res)
        check.almost_equal(deq_res, exp_res, abs = 1e-2)


def test_i_poly_simple():
    n_bits = 8
    a, b, c = 2, 1, 1
    xs = np.array([-3, -1, 0, 1, 2], dtype = np.int8)
    alpha = np.abs(xs).max()
    x_qs, S = quantize(xs, alpha, n_bits)
    for x, x_q in zip(xs, x_qs):
        res_q, res_S = i_poly_wrapper(x_q, S, a, b, c)
        deq_res = res_q * res_S
        exp_res = a * (x + b)**2 + c
        pretty_print(x, x_q, S, res_q, res_S, deq_res, exp_res)
        check.almost_equal(deq_res, exp_res, abs = 13e-2)


def test_quantize():
    activations = np.array([-2, -1, 0, 1, 2, 3])
    alpha = 3
    n_bits = 3
    expected_output = np.array([-2, -1, 0, 1, 2, 3], dtype = np.int8)
    x_q, _ = quantize(activations, alpha, n_bits)
    assert np.array_equal(x_q, expected_output)

    activations = np.array([-4, -2, 0, 2, 4, 6])
    alpha = 3
    n_bits = 3
    expected_output = np.array([-3, -2, 0, 2, 3, 3], dtype = np.int8)
    x_q, _ = quantize(activations, alpha, n_bits)
    assert np.array_equal(x_q, expected_output)

    activations = np.array([-4, -2, 0, 2, 4, 6])
    alpha = 3
    n_bits = 2
    expected_output = np.array([-1, -1, 0, 1, 1, 1], dtype = np.int8)
    output, _ = quantize(activations, alpha, n_bits)
    assert np.array_equal(output, expected_output)

def test_dequantize():
    quantized_activations = np.array([-2, -1, 0, 1, 2, 3], dtype = np.int8)
    alpha = 3
    n_bits = 3
    expected_output = np.array([-2, -1, 0, 1, 2, 3])
    output = dequantize(quantized_activations, alpha, n_bits)
    assert np.allclose(output, expected_output)

if __name__ == '__main__':
    pytest.main(['-v', __file__])