# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

.PHONY: lib build
all: lib build

QUESTA_SEPP ?= questa-2023.4
buildpath   ?= build
VOPT        ?= $(QUESTA_SEPP) vopt
VSIM        ?= $(QUESTA_SEPP) vsim
VLIB        ?= $(QUESTA_SEPP) vlib
VMAP        ?= $(QUESTA_SEPP) vmap
VSIM_FLAGS  ?= -gui
DEBUG       ?= ON

lib:
	cd $(buildpath) && $(VLIB) work && $(VMAP) work work

build:
	cd $(buildpath) && $(VSIM) -c -do 'source compile.tcl; quit'

sim_ita_tb: lib build
	cd $(buildpath) && $(VSIM) $(VSIM_FLAGS) -do 'source ../sim_ita_tb.tcl'

sim_ita_hwpe_tb: lib build
	cd $(buildpath) && $(VSIM) $(VSIM_FLAGS) -do 'set DEBUG $(DEBUG); source ../sim_ita_hwpe_tb.tcl'

sim_activation_tb: lib build
	cd $(buildpath) && $(VSIM) $(VSIM_FLAGS) -do 'source ../sim_activation_tb.tcl'
