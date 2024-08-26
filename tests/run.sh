#!/bin/bash

# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

echo "Testing ITA ..."

source venv/bin/activate

export buildpath=build
export SIM_PATH=modelsim/$buildpath

# Set to -gui to use the GUI of QuestaSim
export VSIM_FLAGS=-c

export no_stalls=0
export s=64
export e=64
export p=64
export bias=1

# Create test vectors if don't exist
if [ ! -d simvectors/data_S${s}_E${e}_P${p}_H1_B${bias} ]
then
    if [ $bias -eq 1 ]
    then
        python testGenerator.py -S $s -P $p -E $e -H 1
    else
        python testGenerator.py -S $s -P $p -E $e -H 1 --no-bias
    fi
fi

# Run the test
make sim VSIM_FLAGS=-c no_stalls=$no_stalls s=$s e=$e p=$p bias=$bias
./modelsim/return_status.sh ${SIM_PATH}/transcript $s $e ita_tb
