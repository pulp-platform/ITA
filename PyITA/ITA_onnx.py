# ----------------------------------------------------------------------
#
# File: ITA_onnx.py
#
# Last edited: 5.03.2024
#
# Copyright (C) 2024, ETH Zurich and University of Bologna.
#
# Author: Philip Wiese (wiesep@iis.ee.ethz.ch), ETH Zurich
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
import onnx


def create_initializer_tensor(name: str,
                              tensor_array: np.ndarray,
                              data_type: onnx.TensorProto = onnx.TensorProto.INT8) -> onnx.TensorProto:

    # (TensorProto)
    initializer_tensor = onnx.helper.make_tensor(name = name,
                                                 data_type = data_type,
                                                 dims = tensor_array.shape,
                                                 vals = tensor_array.flatten().tolist())

    return initializer_tensor


def create_projection(input_name, weight_name, bias_name, output_name, bias = True):
    nodes = []
    nodes += [
        onnx.helper.make_node(
            name = f"MatMul_{output_name}",
            op_type = "MatMul",
            inputs = [input_name, weight_name],
            outputs = [f"MatMul_{output_name}_output"],
        )
    ]
    if bias:
        nodes += [
            onnx.helper.make_node(
                name = f"Add_{output_name}",
                op_type = "Add",
                inputs = [f"MatMul_{output_name}_output", bias_name],
                outputs = [f"Add_{output_name}_output"],
            )
        ]
    nodes += [
        onnx.helper.make_node(
            name = f"RequantShift_{output_name}",
            op_type = "Relu",
            inputs = [f"Add_{output_name}_output" if bias else f"MatMul_{output_name}_output"],
            outputs = [output_name],
        )
    ]
    return nodes


def create_mha(q_name,
               k_name,
               v_name,
               o_name,
               wq_name,
               wk_name,
               wv_name,
               wo_name,
               bq_name,
               bk_name,
               bv_name,
               bo_name,
               H,
               P,
               bias = True):
    nodes = []
    initializers = []

    nodes += create_projection(q_name, wq_name, bq_name, "pQ", bias = bias)
    initializers += [create_initializer_tensor("Reshape_pQ_shape", np.array([1, -1, H, P]), onnx.TensorProto.INT64)]
    nodes += [
        onnx.helper.make_node(
            name = "Reshape_pQ",
            op_type = "Reshape",
            inputs = ["pQ", "Reshape_pQ_shape"],
            outputs = ["Reshape_pQ_output"],
        )
    ]

    nodes += create_projection(k_name, wk_name, bk_name, "pK", bias = bias)
    initializers += [create_initializer_tensor("Reshape_pK_shape", np.array([1, -1, H, P]), onnx.TensorProto.INT64)]
    nodes += [
        onnx.helper.make_node(
            name = "Reshape_pK",
            op_type = "Reshape",
            inputs = ["pK", "Reshape_pK_shape"],
            outputs = ["Reshape_pK_output"],
        )
    ]

    nodes += create_projection(v_name, wv_name, bv_name, "pV", bias = bias)
    initializers += [create_initializer_tensor("Reshape_pV_shape", np.array([1, -1, H, P]), onnx.TensorProto.INT64)]
    nodes += [
        onnx.helper.make_node(
            name = "Reshape_pV",
            op_type = "Reshape",
            inputs = ["pV", "Reshape_pV_shape"],
            outputs = ["Reshape_pV_output"],
        )
    ]

    nodes += [
        onnx.helper.make_node(name = f"Transpose_pQ",
                              op_type = "Transpose",
                              inputs = ["Reshape_pQ_output"],
                              outputs = ["Transpose_pQ_output"],
                              perm = np.array([0, 2, 1, 3]))
    ]
    nodes += [
        onnx.helper.make_node(name = f"Transpose_pK",
                              op_type = "Transpose",
                              inputs = ["Reshape_pK_output"],
                              outputs = ["Transpose_pK_output"],
                              perm = np.array([0, 2, 3, 1]))
    ]
    nodes += [
        onnx.helper.make_node(
            name = f"MatMul_A",
            op_type = "MatMul",
            inputs = ["Transpose_pQ_output", "Transpose_pK_output"],
            outputs = ["MatMul_A_output"],
        )
    ]
    nodes += [
        onnx.helper.make_node(
            name = f"RequantShift_A",
            op_type = "Relu",
            inputs = [f"MatMul_A_output"],
            outputs = ["RequantShift_A_output"],
        )
    ]
    nodes += [
        onnx.helper.make_node(
            name = f"Softmax_A",
            op_type = "Softmax",
            inputs = ["RequantShift_A_output"],
            outputs = ["A"],
        )
    ]

    nodes += [
        onnx.helper.make_node(name = f"Transpose_pV",
                              op_type = "Transpose",
                              inputs = ["Reshape_pV_output"],
                              outputs = ["Transpose_pV_output"],
                              perm = np.array([0, 2, 1, 3]))
    ]
    nodes += [
        onnx.helper.make_node(
            name = f"MatMul_O",
            op_type = "MatMul",
            inputs = ["A", "Transpose_pV_output"],
            outputs = ["MatMul_O_output"],
        )
    ]
    nodes += [
        onnx.helper.make_node(name = f"RequantShift_O",
                              op_type = "Relu",
                              inputs = [f"MatMul_O_output"],
                              outputs = ["RequantShift_O_output"])
    ]
    # nodes += [
    #     onnx.helper.make_node(name = f"Transpose_O",
    #                           op_type = "Transpose",
    #                           inputs = ["RequantShift_O_output"],
    #                           outputs = ["Transpose_O_output"],
    #                           perm = np.array([0, 2, 1, 3]))
    # ]
    # initializers += [create_initializer_tensor("Reshape_O_shape", np.array([1, -1, H*P]), onnx.TensorProto.INT64)]
    # nodes += [
    #     onnx.helper.make_node(
    #         name = "Reshape_O",
    #         op_type = "Reshape",
    #         inputs = ["Transpose_O_output", "Reshape_O_shape"],
    #         outputs = ["Reshape_O_output"],
    #     )
    # ]
    nodes += [
        onnx.helper.make_node(
            name = f"MatMul_out",
            op_type = "MatMul",
            inputs = ["RequantShift_O_output", wo_name],
            outputs = [f"MatMul_out_output"],
        )
    ]
    if bias:
        nodes += [
            onnx.helper.make_node(
                name = f"Add_out",
                op_type = "Add",
                inputs = [f"MatMul_out_output", bo_name],
                outputs = [f"Add_out_output"],
            )
        ]
    nodes += [
        onnx.helper.make_node(
            name = f"RequantShift_out",
            op_type = "Relu",
            inputs = [f"Add_out_output" if bias else f"MatMul_out_output"],
            outputs = [f"RequantShift_out_output"],
        )
    ]
    nodes += [
        onnx.helper.make_node(
            name = f"ReduceSum_out",
            op_type = "ReduceSum",
            inputs = [f"RequantShift_out_output"],
            outputs = ["ReduceSum_out_output"],
            keepdims = 0,
            axes = [1],
        )
    ]
    nodes += [
        onnx.helper.make_node(name = f"RequantShift_sum",
                              op_type = "Relu",
                              inputs = [f"ReduceSum_out_output"],
                              outputs = [o_name])
    ]

    return nodes, initializers


def exportONNX(path, verbose = False, **kwargs):
    IN_TYPE_NP = np.int8
    OUT_TYPE_NP = np.int32

    S = kwargs['S']  # Sequence Length
    P = kwargs['P']  # Projection Space
    E = kwargs['E']  # Embedding Size
    H = kwargs['H']  # Number of heads

    BIAS = not kwargs['no_bias']  # Whether to enable bias for query, value, key and output projection

    inputs = np.load(f"{path}/mha.npz")

    if verbose:
        print("=> Read ", inputs.files)

    input0_name = "input0_Q"
    input1_name = "input1_KV"

    RQ_MUL = np.array(inputs['rqs_mult'])
    RQ_SHIFT = np.array(inputs['rqs_shift'])
    RQ_ADD = np.array(inputs['rqs_add'])

    # Transform from MUL-DIV-ADD to MUL-ADD-DIV
    RQ_ADD = (RQ_ADD * 2**RQ_SHIFT.astype(np.float32))

    input0_values = np.expand_dims(inputs['q'][:(S * E // 64), :].reshape(S, E), axis = 0)
    input1_values = np.expand_dims(inputs['k'][:(S * E // 64), :].reshape(S, E), axis = 0)

    np.savez(path + "inputs.npz", input0_values, input1_values)

    input0_tensor = onnx.helper.make_tensor_value_info(input0_name, onnx.TensorProto.FLOAT, input0_values.shape)
    input1_tensor = onnx.helper.make_tensor_value_info(input1_name, onnx.TensorProto.FLOAT, input1_values.shape)

    output0_name = "output0"
    output0_values = inputs['o_sum']
    output0_tensor = onnx.helper.make_tensor_value_info(output0_name, onnx.TensorProto.FLOAT, shape = ([1, S, E]))

    np.savez(path + "outputs.npz", output0_values)

    wq_name = "init_wq"
    wk_name = "init_wk"
    wv_name = "init_wv"
    wo_name = "init_wo"

    wq_values = np.concatenate([inputs['w1'][i] for i in range(H)], axis = -1)
    wk_values = np.concatenate([inputs['w2'][i] for i in range(H)], axis = -1)
    wv_values = np.concatenate([inputs['w3'][i] for i in range(H)], axis = -1)
    wo_values = inputs['w4']

    wq_tensor = create_initializer_tensor(wq_name, wq_values, onnx.TensorProto.FLOAT)
    wk_tensor = create_initializer_tensor(wk_name, wk_values, onnx.TensorProto.FLOAT)
    wv_tensor = create_initializer_tensor(wv_name, wv_values, onnx.TensorProto.FLOAT)
    wo_tensor = create_initializer_tensor(wo_name, wo_values, onnx.TensorProto.FLOAT)

    bq_name = "init_b1"
    bk_name = "init_b2"
    bv_name = "init_b3"
    bo_name = "init_b4"

    bq_values = np.concatenate([inputs['b1'][i] for i in range(H)], axis = -1)
    bk_values = np.concatenate([inputs['b2'][i] for i in range(H)], axis = -1)
    bv_values = np.concatenate([inputs['b3'][i] for i in range(H)], axis = -1)
    # WIESEP ITA supports biases for output projection for every head.
    # However, as all heads get accumulated, one bias is enough
    bo_values = inputs['b4']

    bq_tensor = create_initializer_tensor(bq_name, bq_values, onnx.TensorProto.FLOAT)
    bk_tensor = create_initializer_tensor(bk_name, bk_values, onnx.TensorProto.FLOAT)
    bv_tensor = create_initializer_tensor(bv_name, bv_values, onnx.TensorProto.FLOAT)
    bo_tensor = create_initializer_tensor(bo_name, bo_values, onnx.TensorProto.FLOAT)

    if verbose:
        print("Shape Information:")
        print("  Q      :", input0_values.shape)
        print("  K and V:", input1_values.shape)
        print("  O      :", output0_values.shape)
        print("  wq     :", wq_values.shape)
        print("  wk     :", wk_values.shape)
        print("  wv     :", wv_values.shape)
        print("  wo     :", wo_values.shape)
        print("  bq     :", bq_values.shape)
        print("  bk     :", bk_values.shape)
        print("  bv     :", bv_values.shape)
        print("  bo     :", bo_values.shape)

    nodes, initializers = create_mha(q_name = input0_name,
                                     k_name = input1_name,
                                     v_name = input1_name,
                                     o_name = output0_name,
                                     wq_name = wq_name,
                                     wk_name = wk_name,
                                     wv_name = wv_name,
                                     wo_name = wo_name,
                                     bq_name = bq_name,
                                     bk_name = bk_name,
                                     bv_name = bv_name,
                                     bo_name = bo_name,
                                     H = H,
                                     P = P,
                                     bias = BIAS)

    # Create the graph (GraphProto)
    graph_def = onnx.helper.make_graph(
        nodes = nodes,
        name = "MHA",
        inputs = [input0_tensor, input1_tensor],  # Graph input
        outputs = [output0_tensor],  # Graph output
        initializer = [wq_tensor, bq_tensor, wk_tensor, bk_tensor, wv_tensor, bv_tensor, wo_tensor, bo_tensor] +
        initializers)

    # Create the model (ModelProto)
    model_def = onnx.helper.make_model(graph_def, producer_name = "onnx", producer_version = onnx.__version__)
    model_def.opset_import[0].version = 11

    onnx.save_model(model_def, path + "network.onnx")
    model_def = onnx.shape_inference.infer_shapes(model_def)

    onnx.checker.check_model(model_def)

    div_idx = 0
    rq_idx = 0
    softmax_idx = 0
    for node in model_def.graph.node:
        if node.op_type == "Div":
            node.op_type = "IntegerDiv"
            div_idx += 1
        if node.op_type == "Relu" and "RequantShift" in node.name:
            node.op_type = "RequantShift"

            # WIESEP: Last requantization layer is different
            dims = (1,) if rq_idx == 6 else (H,)
            rq_shift_vals = np.array([RQ_SHIFT[rq_idx][0]]) if rq_idx == 6 else RQ_SHIFT[rq_idx]
            tensor = onnx.helper.make_tensor(name = f"div_val{rq_idx}",
                                             data_type = onnx.TensorProto.FLOAT,
                                             dims = dims,
                                             vals = 2**rq_shift_vals.astype(np.int32))
            attr = onnx.helper.make_attribute(key = 'div', value = tensor)
            node.attribute.append(attr)

            tensor = onnx.helper.make_tensor(name = f"n_levels_out_val{rq_idx}",
                                             data_type = onnx.TensorProto.FLOAT,
                                             dims = (1,),
                                             vals = np.ones(1) * 256)
            attr = onnx.helper.make_attribute(key = 'n_levels_out', value = tensor)
            node.attribute.append(attr)

            tensor = onnx.helper.make_tensor(name = "signed_val",
                                             data_type = onnx.TensorProto.FLOAT,
                                             dims = (1,),
                                             vals = np.ones(1))
            attr = onnx.helper.make_attribute(key = 'signed', value = tensor)
            node.attribute.append(attr)

            rq_mult_vals = np.array([RQ_MUL[rq_idx][0]]) if rq_idx == 6 else RQ_MUL[rq_idx]
            tensor = onnx.helper.make_tensor(name = f"mul{rq_idx}",
                                             data_type = onnx.TensorProto.FLOAT,
                                             dims = dims,
                                             vals = rq_mult_vals)
            node.input.append(f"mul{rq_idx}")
            model_def.graph.initializer.append(tensor)

            rq_add_vals = np.array([RQ_ADD[rq_idx][0]]) if rq_idx == 6 else RQ_ADD[rq_idx]
            tensor = onnx.helper.make_tensor(name = f"add{rq_idx}",
                                             data_type = onnx.AttributeProto.FLOAT,
                                             dims = dims,
                                             vals = rq_add_vals)
            node.input.append(f"add{rq_idx}")
            model_def.graph.initializer.append(tensor)

            rq_idx += 1

        if node.op_type == "Softmax":

            if kwargs['no_partial_softmax']:
                node.op_type = "ITAMax"
            else:
                node.op_type = "ITAPartialMax"
                attr = onnx.helper.make_attribute(key = 'groups', value = int(4))
                node.attribute.append(attr)

                attr = onnx.helper.make_attribute(key = 'group_width', value = int(16))
                node.attribute.append(attr)

            tensor = onnx.helper.make_tensor(name = "n_levels_val",
                                             data_type = onnx.TensorProto.FLOAT,
                                             dims = (1,),
                                             vals = np.ones(1) * 256)
            attr = onnx.helper.make_attribute(key = 'n_levels', value = tensor)
            node.attribute.append(attr)
            softmax_idx += 1

    onnx.save_model(model_def, path + "network.onnx")
