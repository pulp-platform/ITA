#!/bin/bash

# Copyright 2023 ETH Zurich and University
# of Bologna. Licensed under the Apache License,
# Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

echo "Testing ITA ..."

# Set the log file
log_file=tests/logs/run_loop_$(date +%Y%m%d%H%M%S).log

# Create folder and log file
mkdir -p tests/logs
touch $log_file

# Activate the virtual environment
source venv/bin/activate

# Set the simulation path
export buildpath=build
export SIM_PATH=modelsim/$buildpath

# Set to -gui to use the GUI of QuestaSim
export vsim_flags=-c

# Set the no_stalls if not set
if [ -z "$no_stalls" ]; then
    no_stalls=0
    echo "No_stalls not set. Using default value: $no_stalls"
fi

# Set the n_tests if not set
if [ -z "$n_tests" ]; then
    n_tests=1
    echo "Granularity not set. Using default value: $n_tests"
fi

# Log the parameters
echo "no_stalls=$no_stalls" >> $log_file
echo "n_tests=$n_tests" >> $log_file

# List of masking names
masking_names=("upper_triangular")

# List of activation names
activation_names=("identity")

# Helper function: checks if a mask is one of the strided ones
is_strided_mask() {
    case "$1" in
        "strided"|"upper_strided"|"lower_strided"|"strided_sliding_window")
            return 0  # True
            ;;
        *)
            return 1  # False
            ;;
    esac
}

# Run the tests
for test_idx in $(seq 1 $n_tests); do
    # Randomly pick s, e, p, f in [2..512]
    s=128
    e=64
    p=64
    f=64

    # Pick one random masking
    random_mask_idx=$((RANDOM % ${#masking_names[@]}))
    masking=${masking_names[$random_mask_idx]}

    # Pick one random activation
    random_activation_idx=$((RANDOM % ${#activation_names[@]}))
    activation=${activation_names[$random_activation_idx]}

    # Pick one random bias (0 or 1)
    bias=1

    # Decide how to pick i based on whether masking is strided
    if is_strided_mask "$masking"; then
        # 1) We need i that is < s and also a power of two
        valid_i_list=( $(powers_of_two_less_than_s $s) )

        # If no valid i found, skip this iteration
        if [ ${#valid_i_list[@]} -eq 0 ]; then
            echo "No valid i for mask=$masking with s=$s (need i < s and i a power of two). Skipping..."
            continue
        fi

        # Pick a random valid i from the list
        i=${valid_i_list[$((RANDOM % ${#valid_i_list[@]}))]}
    else
        # 2) Non-strided masks: pick i in [1 .. s-1]
        if [ "$s" -le 1 ]; then
            echo "No valid i for mask=$masking with s=$s (need i < s). Skipping..."
            continue
        fi
	i=1
        # i=$((1 + (RANDOM % (s-1))))
    fi

    echo "Index is: $i  (Masking = $masking, s=$s)"

    # Create test vectors (no-bias and bias)
    echo "creating test vectors"
    if [ "$bias" -eq 1 ]; then
        python testGenerator.py -H 1 -S $s -P $p -E $e -F $f \
            --activation "$activation" --mask "$masking" -I "$i"
    else
        python testGenerator.py -H 1 -S $s -P $p -E $e -F $f \
            --activation "$activation" --mask "$masking" -I "$i" --no-bias
    fi                

    # Log the test
    echo "Testing ita_tb: S=$s E=$e P=$p F=$f Activation=$activation Masking=$masking I=$i Bias=$bias" >> $log_file

    # Run the test
    make sim VSIM_FLAGS=$vsim_flags DEBUG=ON target=sim_ita_hwpe_tb \
            no_stalls=$no_stalls s=$s e=$e p=$p f=$f bias=$bias \
            activation=$activation mask=$masking i=$i

    # Check the simulation status
    ./modelsim/return_status.sh "${SIM_PATH}/transcript" \
        "$s" "$e" "$p" "$f" ita_tb "$masking" "$i" >> $log_file

    # Format masking for directory name (e.g. "upper_strided" -> "UpperStrided")
    formatted_masking=""
    for word in ${masking//_/ }; do
        formatted_masking+="${word^}"
    done

    # echo "simvectors/data_S${s}_E${e}_P${p}_F${f}_H1_B${bias}_${activation^}_${formatted_masking}_I${i}" >> $log_file

    # Remove the test vectors
    rm -rf simvectors/data_S${s}_E${e}_P${p}_F${f}_H1_B${bias}_${activation^}_${formatted_masking}_I${i}

done
