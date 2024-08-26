#!/bin/bash

# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Number of dot product units
export ITA_N=16
export ITA_M=64

# Check if the simulation log exists
if [ ! -f $1 ]
then
    echo "❗ Simulation log not found."
    exit 1
fi

# ITA TB
# Check if the simulation log has finished successfully by checking the number of outputs
if [ $4 == "ita_tb" ]
then
    # Round $2 and $3 to the clostest of multiple of $ITA_M
    ita_s=$(( ITA_M * ( (( $2 - 1) / ITA_M) + 1) ))
    ita_e=$(( ITA_M * ( (( $3 - 1) / ITA_M) + 1) ))
    num_outputs=$((ita_s * ita_e / ITA_N))
    if grep -q "${num_outputs} outputs were checked in phase 4." $1
    then
        count=$(grep -c "Wrong value" $1)

        if [ $count -gt 0 ];
        then
            echo "❌ Found ${count} errors in the simulation log."
            exit 1
        else
            echo "✅ No errors found in the simulation log."
            exit 0
        fi
    else
        echo "❗ Simulation did not finish successfully."
        exit 1
    fi
# HWPE TB
# Check if the simulation log has finished successfully
elif [ $4 == "hwpe_tb" ]
then
    if grep -q "Comparing output" $1 && grep -q "\$finish" $1
    then
        count=$(grep -c "mismatch" $1)

        if [ $count -gt 0 ];
        then
            echo "❌ Found ${count} errors in the simulation log."
            exit 1
        else
            echo "✅ No errors found in the simulation log."
            exit 0
        fi
    else
        echo "❗ Simulation did not finish successfully."
        exit 1
    fi
fi
