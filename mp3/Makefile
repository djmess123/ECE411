SHELL = /bin/bash -o pipefail

#Collect All Source Files
PKG_SRCS := $(shell find $(PWD)/pkg -name '*.sv')
HDL_SRCS := $(shell find $(PWD)/hdl -name '*.sv')
HVL_SRCS := $(shell find $(PWD)/hvl -name '*.sv' -o -name '*.v')
SRCS := $(PKG_SRCS) $(HDL_SRCS) $(HVL_SRCS)

SYNTH_TCL := $(CURDIR)/synthesis.tcl

VCS_FLAGS= -full64 -lca -sverilog +lint=all,noNS -timescale=1ns/10ps -debug_acc+all -kdb -fsdb 

.PHONY: clean
.PHONY: run


sim/simv: $(SRCS) $(ASM)
	mkdir -p sim
	bin/rv_load_memory.sh $(ASM) 2>&1 | tee sim/asm.log	
	cd sim && vcs $(SRCS) $(VCS_FLAGS) -msg_config=../warn.config -l compile.log
	cd sim && ./simv -l simulation.log

run: sim/simv $(ASM)
	bin/rv_load_memory.sh $(ASM) 2>&1 | tee sim/asm.log
	cd sim && ./simv

clean:
	rm -rf sim synth