# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

SHELL = /usr/bin/env bash
ROOT_DIR := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

INSTALL_PREFIX        ?= install
INSTALL_DIR           = ${ROOT_DIR}/${INSTALL_PREFIX}
BENDER_INSTALL_DIR    = ${INSTALL_DIR}/bender

VENV_BIN=venv/bin/

BENDER_VERSION = 0.28.1
SIM_FOLDER  ?= build
SIM_PATH    ?= modelsim/${SIM_FOLDER}
SYNTH_PATH  = synopsys

BENDER_TARGETS = -t rtl -t test

target ?= sim_ita_tb

no_stalls ?= 0
single_attention ?= 0
s ?= 64
e ?= 128
p ?= 192
f ?= 256
bias ?= 0
activation ?= identity
ifeq ($(activation), gelu)
	activation_int = 1
else ifeq ($(activation), relu)
	activation_int = 2
else
	activation_int = 0
endif
vlog_defs += -DNO_STALLS=$(no_stalls) -DSINGLE_ATTENTION=$(single_attention) -DSEQ_LENGTH=$(s) -DEMBED_SIZE=$(e) -DPROJ_SPACE=$(p) -DFF_SIZE=$(f) -DBIAS=$(bias) -DACTIVATION=$(activation_int)

ifeq ($(target), sim_ita_hwpe_tb)
	BENDER_TARGETS += -t ita_hwpe -t ita_hwpe_test
	vlog_defs += -DHCI_ASSERT_DELAY=\#41ps
endif

VLOG_FLAGS += -svinputport=compat
VLOG_FLAGS += -timescale 1ns/1ps

.PHONY: clean-sim sim-script sim synopsys-script
all: testvector sim

clean-sim:
	rm -rf $(SIM_PATH)/work
	rm -rf $(SIM_PATH)/compile.tcl
	rm -rf $(SIM_PATH)/wlft*
	rm -rf $(SIM_PATH)/transcript
	rm -rf $(SIM_PATH)/modelsim.ini
	rm -rf $(SIM_PATH)/vsim.wlf

sim-script: clean-sim
	mkdir -p $(SIM_PATH)
	$(BENDER_INSTALL_DIR)/bender script vsim $(BENDER_TARGETS) $(vlog_defs) --vlog-arg="$(VLOG_FLAGS)" >> $(SIM_PATH)/compile.tcl

sim: sim-script
	cd modelsim && \
	$(MAKE) $(target) buildpath=$(ROOT_DIR)/$(SIM_PATH)

synopsys-script:
	rm ../ita-gf22/$(SYNTH_PATH)/scripts/analyze.tcl
	$(BENDER_INSTALL_DIR)/bender script synopsys -t rtl $(vlog_defs) >> ../ita-gf22/$(SYNTH_PATH)/scripts/analyze.tcl

testvector:
	@if [ ! -d "${ROOT_DIR}/${VENV_BIN}" ]; then \
		echo "Please create a virtual environment and install the required packages"; \
		echo "Run the following commands:"; \
		echo '  $$> python3 -m venv venv'; \
		echo '  $$> source venv/bin/activate'; \
		echo '  $$> pip install -r requirements.txt'; \
		exit 1; \
	fi
	@echo "Generating test vector"
	@if [ $(bias) -eq 0 ]; then \
		source ${ROOT_DIR}/${VENV_BIN}/activate; \
		${VENV_BIN}/python testGenerator.py -S $(s) -P $(p) -E $(e) -B 1 -H 1 --no-bias; \
	else \
		source ${ROOT_DIR}/${VENV_BIN}/activate; \
		${VENV_BIN}/python testGenerator.py -S $(s) -P $(p) -E $(e) -B 1 -H 1; \
	fi

# Bender
bender: check-bender
	$(BENDER_INSTALL_DIR)/bender update
	$(BENDER_INSTALL_DIR)/bender vendor init

check-bender:
	@if [ -x $(BENDER_INSTALL_DIR)/bender ]; then \
		req="bender $(BENDER_VERSION)"; \
		current="$$($(BENDER_INSTALL_DIR)/bender --version)"; \
		if [ "$$(printf '%s\n' "$${req}" "$${current}" | sort -V | head -n1)" != "$${req}" ]; then \
			rm -rf $(BENDER_INSTALL_DIR); \
		fi \
	fi
	@$(MAKE) -C $(ROOT_DIR) $(BENDER_INSTALL_DIR)/bender

$(BENDER_INSTALL_DIR)/bender:
	mkdir -p $(BENDER_INSTALL_DIR) && cd $(BENDER_INSTALL_DIR) && \
	curl --proto '=https' --tlsv1.2 https://pulp-platform.github.io/bender/init -sSf | sh -s -- $(BENDER_VERSION)