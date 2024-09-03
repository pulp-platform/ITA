#!/bin/bash

# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

export SIM_LOG=$1
export SEQUENCE_LEN=$2
export EMBEDDING_SIZE=$3
export PROJECTION_SIZE=$4
export FEEDFORWARD_SIZE=$5
export TEST_BENCH=$6

# Number of dot product units
export ITA_N=16
export ITA_M=64

# Round to the clostest of multiple of $ITA_M
ita_s=$(( ITA_M * ( (( ${SEQUENCE_LEN} - 1) / ITA_M) + 1) ))
ita_e=$(( ITA_M * ( (( ${EMBEDDING_SIZE} - 1) / ITA_M) + 1) ))
ita_p=$(( ITA_M * ( (( ${PROJECTION_SIZE} - 1) / ITA_M) + 1) ))
ita_f=$(( ITA_M * ( (( ${FEEDFORWARD_SIZE} - 1) / ITA_M) + 1) ))

exp_n_outputs_Q=$((ita_s * ita_p / ITA_N))
exp_n_outputs_K=${exp_n_outputs_Q}
exp_n_outputs_V=${exp_n_outputs_Q}
exp_n_outputs_OW=$((ita_s * ita_e / ITA_N))
exp_n_outputs_FF1=$((ita_s * ita_f / ITA_N))
exp_n_outputs_FF2=$((ita_s * ita_e / ITA_N))

# Check if the simulation log exists
if [[ ! -f ${SIM_LOG} ]]; then
	echo "❗ Simulation log not found."
	exit 1
fi

check_n_outputs() {
	local n_outputs=$1
	local phase=$2

	if ! grep -q "${n_outputs} outputs were checked in phase ${phase}." "${SIM_LOG}"; then
		echo "❌ Simulation did not finish successfully. Expected ${n_outputs} outputs in phase ${phase}."
		exit 1
	fi

	echo "✅ Checked ${n_outputs} outputs in phase ${phase}."
}

# ITA TB
# Check if the simulation log has finished successfully by checking the number of outputs
if [ ${TEST_BENCH} == "ita_tb" ]
then
    check_n_outputs "${exp_n_outputs_Q}" 0
    check_n_outputs "${exp_n_outputs_K}" 1
    check_n_outputs "${exp_n_outputs_V}" 2
    check_n_outputs "${exp_n_outputs_OW}" 4
    check_n_outputs "${exp_n_outputs_FF1}" 5
    check_n_outputs "${exp_n_outputs_FF2}" 6

    n_error_lines=$(grep -c "Wrong value" "${SIM_LOG}")
# HWPE TB
# Check if the simulation log has finished successfully
elif [ ${TEST_BENCH} == "hwpe_tb" ]
then
    if ! grep -q "Comparing output" $1 && grep -q "\$finish" $1
    then
        echo "❗ Simulation did not finish successfully."
        exit 1
    fi

    n_error_lines=$(grep -c "mismatch" "${SIM_LOG}")
fi

if [[ ${n_error_lines} -gt 0 ]]; then
	echo "❌ Found ${n_error_lines} errors in the simulation log."
	exit 1
fi

echo "✅ No errors found in the simulation log."
exit 0