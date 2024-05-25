# Integer Transformer Accelerator
The Integer Transformer Accelerator is a hardware accelerator for the Multi-Head Attention (MHA) operation in the Transformer model.
It targets  efficient inference on embedded systems by exploiting 8-bit quantization and an innovative softmax implementation that operates exclusively on integer values.
By computing on-the-fly in streaming mode, our softmax implementation minimizes data movement and energy consumption.
ITA achieves competitive energy efficiency with respect to state-of-the-art transformer accelerators with 16.9 TOPS/W, while outperforming them in area efficiency with 5.93 TOPS/mm2 in 22 nm fully-depleted silicon-on-insulator technology at 0.8 V.

This repository contains the RTL code and test generator for the ITA.

## Structure
The repository is structured as follows:

- `modelsim` contains Makefiles and scripts to run the simulation in ModelSim.
- `PyITA` contains the test generator for the ITA.
- `src` contains the RTL code.
    * `tb` contains the testbenches for the ITA modules.

## RTL Simulation
We use [Bender](https://github.com/pulp-platform/bender) to generate our simulation scripts. Make sure you have Bender installed, or install it in the ITA repository with:
```bash
$> make bender
```

To run the RTL simulation, execute the following command:
```sh
$> make sim
$> s=64 e=128 p=192 make sim # To use different dimensions
$> target=sim_ita_hwpe_tb make sim # To run ITA with HWPE wrapper
```

## Test Vector Generation
The test generator creates ONNX graphs and in case of MHA (Multi-Head Attention), additional test vectors for RTL simulations. The relevant files for ITA are located in the `PyITA` directory.

## Tests
In `tests` directory, several tests are available to verify the correctness of the ITA. To run the example test, execute the following command:
```sh
$> ./tests/run.sh
```

To run a series of tests, execute the following command:
```sh
$> ./tests/run_loop.sh
```

Test granularity and stalling can be set with the following commands before running the script:
```sh
$> export granularity=64
$> export no_stalls=1
```

#### Requirements
To install the required Python packages, create a virtual environment. Make sure to first deactivate any existing virtual environment or conda/mamba environment. Then, create a new virtual environment and install the required packages:

```sh
$> python -m venv venv
$> source venv/bin/activate
$> pip install -r requirements.txt
```

If you want to enable pre-commit hooks, which perform code formatting and linting, run the following command:
```sh
$> pre-commit install
```

In case you want to compare the softmax implementation with the QuantLib implementation, you need to install the QuantLib library and additional dependencies. To do so, create a virtual environment:

```sh
$> pip install torch torchvision scipy pandas
```
and install QuantLib from [GitHub](https://github.com/pulp-platform/quantlib).

```sh
$> git clone git@github.com:pulp-platform/quantlib.git
```

#### ITA Multi-Head Attention
To get an overview of possible options run:
```sh
$> python testGenerator.py -h
```

To generate a ONNX graph and test vectors for RTL simulations for a MHA operation run:
```sh
$> python testGenerator.py -H 1 -S 64 -E 128 -P 192
```

To visualize the ONNX graph after generation, run:
```sh
$> netron simvectors/data_S64_E128_P192_H1_B1/network.onnx
```

## Contributors
- **Gamze İslamoğlu** ([gislamoglu@iis.ee.ethz.ch](mailto:gislamoglu@iis.ee.ethz.ch))
- **Philip Wiese** ([wiesep@iis.ee.ethz.ch](mailto:wiesep@iis.ee.ethz.ch))

## License
This repository makes use of two licenses:
- for all *software*: Apache License Version 2.0
- for all *hardware*: Solderpad Hardware License Version 0.51

For further information have a look at the license files: `LICENSE.hw`, `LICENSE.sw`

## References
<details>
<summary><i>ITA: An Energy-Efficient Attention and Softmax Accelerator for Quantized Transformers</i></summary>
<p>

```
@INPROCEEDINGS{10244348,
  author={Islamoglu, Gamze and Scherer, Moritz and Paulin, Gianna and Fischer, Tim and Jung, Victor J.B. and Garofalo, Angelo and Benini, Luca},
  booktitle={2023 IEEE/ACM International Symposium on Low Power Electronics and Design (ISLPED)},
  title={ITA: An Energy-Efficient Attention and Softmax Accelerator for Quantized Transformers},
  year={2023},
  volume={},
  number={},
  pages={1-6},
  keywords={Quantization (signal);Embedded systems;Power demand;Computational modeling;Silicon-on-insulator;Parallel processing;Transformers;neural network accelerators;transformers;attention;softmax},
  doi={10.1109/ISLPED58423.2023.10244348}}
```
This paper was published on [IEEE Xplore](https://ieeexplore.ieee.org/document/10244348) and is also available on [arXiv:2307.03493 [cs.AR]](https://arxiv.org/abs/2307.03493).

</p>
</details>