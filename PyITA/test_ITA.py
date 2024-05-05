import pytest
import torch
import numpy as np
import pytest_check as check
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

from .ITA import i_poly, i_poly_wrapper, quantize, dequantize, i_erf_wrapper, i_gelu_wrapper

def pretty_print(x, x_q, S, res_q, res_S, deq_res, exp_res):
    print(
        f"x={x:>10.2f}, x_q={x_q:>10}, S={S:>10.1g}, res_q={res_q:>10}, res_S={res_S:>10.1g}, deq_res={deq_res:>10.2f}, exp_res={exp_res:>10.2f}, abs_err={(np.abs(deq_res - exp_res)):>10.3f}"
    )


def plot(data: pd.DataFrame, title: str, quantized_y_label: str, expected_y_label: str, alpha: float):
    l2_error = np.linalg.norm(data['deq_res'] - data['exp_res']) / len(data)
    l_inf_error = np.max(np.abs(data['deq_res'] - data['exp_res']))
    print(f'alpha: {alpha}, average L2 error: {l2_error:.4f}, Linf error: {l_inf_error:.3f}')
    sns.set_theme()
    fig, ax = plt.subplots(1, 1, figsize = (10, 6))
    sns.lineplot(data = data,
                 x = 'x',
                 y = 'deq_res',
                 label = quantized_y_label,
                 ax = ax,
                 marker = 'o',
                 linestyle = '--')
    sns.lineplot(data = data, x = 'x', y = 'exp_res', label = expected_y_label, ax = ax)
    ax.set_title(f'{title}\n($\\alpha$: {alpha}, average $L_2$ error: {l2_error:.4f}, $L_{{\\infty}}$ error: {l_inf_error:.3f})')

    ax.set_xlabel('$x$')
    ax.set_ylabel('Value')
    plt.savefig(f'{title}.png')



def test_gelu():
    n_bits = 8
    xs = np.linspace(-4, 4, 69)
    # xs = np.linspace(-1.769, 1.769, 25)
    alpha = np.abs(xs).max()
    # alpha = 4
    print(f'alpha = {alpha}')
    x_qs, S = quantize(xs, alpha, n_bits)
    data = []

    for x, x_q in zip(xs, x_qs):
        res_q, res_S = i_gelu_wrapper(x_q, S)
        deq_res = res_q * res_S
        exp_res = torch.nn.functional.gelu(torch.tensor(x, dtype = torch.float32)).item()
        pretty_print(x, x_q, S, res_q, res_S, deq_res, exp_res)
        data.append({
            'x': x,
            'x_q': x_q,
            'S': S,
            'res_q': res_q,
            'res_S': res_S,
            'deq_res': deq_res,
            'exp_res': exp_res
        })
        check.almost_equal(deq_res, exp_res, abs = 69e-2)
    plot(pd.DataFrame(data),
         quantized_y_label = 'I-GELU(x)',
         expected_y_label = 'GELU(x)',
         title = 'I-GELU with 8-bit symmetric quantization',
         alpha = alpha)

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
    xs = np.linspace(-4, 4, 69)
    # xs = np.linspace(-1.769, 1.769, 25)
    n_bits = 8
    alpha = np.abs(xs).max()
    # alpha = 4
    x_qs, S = quantize(xs, alpha, n_bits)
    data = []

    for x, x_q in zip(xs, x_qs):
        res_q, res_S = i_erf_wrapper(x_q, S)
        deq_res = res_q * res_S
        exp_res = torch.erf(torch.tensor(x, dtype = torch.float32)).item()
        pretty_print(x, x_q, S, res_q, res_S, deq_res, exp_res)
        data.append({
            'x': x,
            'x_q': x_q,
            'S': S,
            'res_q': res_q,
            'res_S': res_S,
            'deq_res': deq_res,
            'exp_res': exp_res
        })
        check.almost_equal(deq_res, exp_res, abs = 1e-1)
    plot(pd.DataFrame(data),
         quantized_y_label = 'I-ERF(x)',
         expected_y_label = 'ERF(x)',
         title = 'I-ERF with 8-bit symmetric quantization', alpha = alpha)


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