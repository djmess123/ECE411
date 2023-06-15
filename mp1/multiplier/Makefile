
#Collect All Source Files
PKG_SRCS := $(PWD)/pkg/design_types.sv $(PWD)/pkg/grader_types.sv
HDL_SRCS := $(shell find $(PWD)/hdl -name '*.sv')
HVL_SRCS := $(shell find $(PWD)/hvl -name '*.sv' -o -name '*.v')
MOCK_GRADE_SRCS := $(PWD)/grader/mock_grader.sv
GRADE_SRCS := $(PWD)/grader/grader.sv $(PWD)/grader/grader_itf.sv $(PWD)/grader/transaction_monitor.sv $(PWD)/grader/transaction_scoreboard.sv
SRCS := $(PKG_SRCS) $(HDL_SRCS) $(HVL_SRCS)

VCS_FLAGS= -full64 -sv=2012 +lint=all,noSVA-UA,noNS,noSVA-AECASR -timescale=1ns/10ps -debug_acc+all -kdb -fsdb +v2k

.PHONY: clean
.PHONY: run
.PHONY: grade

sim/simv: $(SRCS) $(MOCK_GRADE_SRCS)
	mkdir -p sim
	cd sim && vcs -R $(SRCS) $(MOCK_GRADE_SRCS) $(VCS_FLAGS)

sim/grading: $(SRCS) $(GRADE_SRCS)
	mkdir -p sim
	cd sim && vcs -o grading -R $(SRCS) $(GRADE_SRCS) $(VCS_FLAGS) 

run: sim/simv
	cd sim && ./simv

grade: sim/grading
	cd sim && ./grading

clean: 
	rm -rf sim
