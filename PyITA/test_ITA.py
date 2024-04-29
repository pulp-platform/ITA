import pytest
import torch
import numpy as np
import pytest_check as check

from .ITA import i_poly, i_poly_wrapper, quantize, dequantize, i_erf_wrapper


def test_erf():
    xs = np.linspace(0, 1.769, 10)
    alpha, n_bits = 3, 8
    x_qs, S = quantize(xs, alpha, n_bits)

    for x, x_q in zip(xs, x_qs):
        res_q, res_S = i_erf_wrapper(x_q, S)
        deq_res = res_q * res_S
        exp_res = torch.erf(torch.tensor(x, dtype=torch.float32)).item()
        print(f"x={x}, x_q={x_q}, S={S}, res_q={res_q}, res_S={res_S}, deq_res={deq_res}, exp_res={exp_res}")
        check.almost_equal(deq_res, exp_res, abs=1e-1)

def test_erf_simple():
    xs = np.array([-20, -10, -3, -2, -1, 0, 1, 2, 3, 10, 20]) * 0.1
    alpha, n_bits = 3, 8
    x_qs, S = quantize(xs, alpha, n_bits)

    for x, x_q in zip(xs, x_qs):
        res_q, res_S = i_erf_wrapper(x_q, S)
        deq_res = res_q * res_S
        exp_res = torch.erf(torch.tensor(x, dtype=torch.float32)).item()
        print(f"x={x}, x_q={x_q}, S={S}, res_q={res_q}, res_S={res_S}, deq_res={deq_res}, exp_res={exp_res}")
        check.almost_equal(deq_res, exp_res, abs=1e-1)

    
def test_i_poly():
    a, b, c = -0.2888, -1.769, 1
    # a, b, c = 2, 1, 1
    xs = np.linspace(0, 1.769, 10)
    alpha, n_bits = 2, 8
    x_qs, S = quantize(xs, alpha, n_bits)
    for x, x_q in zip(xs, x_qs):
        res_q, res_S = i_poly_wrapper(x_q, S, a, b, c)
        deq_res = res_q * res_S
        exp_res = a * (x + b)**2 + c
        print(f"x={x}, x_q={x_q}, res_q={res_q}, res_S={res_S}, deq_res={deq_res}, exp_res={exp_res}")
        check.almost_equal(deq_res, exp_res, abs=1e-1)

def test_i_poly_simple():
    a, b, c = 2, 1, 1
    xs = np.array([-2, -1, -0.5, -0.25, 0, 0.25, 0.5, 1, 2])
    alpha, n_bits = 32, 8
    x_qs, S = quantize(xs, alpha, n_bits)
    for x, x_q in zip(xs, x_qs):
        res_q, res_S = i_poly_wrapper(x_q, S, a, b, c)
        deq_res = res_q * res_S
        exp_res = a * (x + b)**2 + c
        print(f"x={x}, x_q={x_q}, S={S}, res_q={res_q}, res_S={res_S}, deq_res={deq_res}, exp_res={exp_res}")
        check.almost_equal(deq_res, exp_res, abs=2*S)

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
