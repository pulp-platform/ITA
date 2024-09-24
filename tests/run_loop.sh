#!/bin/bash

# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

echo "Testing ITA ..."

# Set the log file
log_file=tests/logs/run_loop_$(date +%Y%m%d%H%M%S).log

# Create folder and log file
mkdir -p tests/logs
touch $log_file

# Activate the virtual environment
source venv/bin/activate

# Set the no_stalls if not set
if [ -z "$no_stalls" ]
then
    no_stalls=0
    echo "No_stalls not set. Using default value: $no_stalls"
fi

# Set the granularity if not set
if [ -z "$granularity" ]
then
    granularity=256
    echo "Granularity not set. Using default value: $granularity"
else
    # check if the granularity is a multiple of 64 and less than or equal to 512
    if [ $((granularity % 64)) -ne 0 ] || [ $granularity -gt 512 ]
    then
        echo "Granularity must be a multiple of 64 and less than or equal to 512."
        exit 1
    fi
fi

# Log the parameters
echo "no_stalls=$no_stalls" >> $log_file
echo "granularity=$granularity" >> $log_file

# Run the tests
for s in $(eval echo "{$granularity..512..$granularity}")
do
    for e in $(eval echo "{$granularity..512..$granularity}")
    do
        for p in $(eval echo "{$granularity..512..$granularity}")
        do
            # Create test vectors
            python testGenerator.py -S $s -E $e -P $p -H 1 --no-bias
            python testGenerator.py -S $s -E $e -P $p -H 1

            for bias in {0..1}
            do
                # Log the test
                echo "Testing S=$s E=$e P=$p bias=$bias" >> $log_file

                # Run the test
                make sim VSIM_FLAGS=-c no_stalls=$no_stalls s=$s e=$e p=$p bias=$bias
                ./modelsim/return_status.sh modelsim/build/transcript $s $e ita_tb >> $log_file

                # Remove the test vectors
                rm -rf simvectors/data_S${s}_E${e}_P${p}_H1_B${bias}
            done
        done
    done
done
