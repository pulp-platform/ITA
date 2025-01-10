# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Set working library.
set LIB work

set VOPT_ARG "+acc"
echo $VOPT_ARG
set DB_SW "-debugdb"

quit -sim

vsim -voptargs=$VOPT_ARG $DB_SW -pedanticerrors -lib $LIB ita_tb

if {$DEBUG == "ON"} {
    add log -r /*
    source ../sim_ita_tb_wave.tcl
}

run -a
