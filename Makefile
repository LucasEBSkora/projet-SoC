# vhdl files
FILES = packages/*.vhd source/*.vhd

# testbench
TESTBENCHPATH = testbench/${TESTBENCHFILE}*
TESTBENCHFILE = ${TESTBENCH}_tb
WORKDIR = work

#GHDL CONFIG
GHDL_CMD = ghdl
GHDL_FLAGS  = --ieee=synopsys --warn-no-vital-generic --workdir=$(WORKDIR) --std=08

STOP_TIME = 1us
# Simulation break condition
GHDL_SIM_OPT = --stop-time=$(STOP_TIME)

WAVEFORM_VIEWER = gtkwave

.PHONY: clean

all: clean make run view

test: clean make run
wave: clean make run view
make:
ifeq ($(strip $(TESTBENCH)),)
	@echo "TESTBENCH not set. Use TESTBENCH=<value> to set it."
	@exit 1
endif

	@mkdir -p $(WORKDIR)
	@$(GHDL_CMD) -a $(GHDL_FLAGS) $(FILES)
	@$(GHDL_CMD) -a $(GHDL_FLAGS) $(TESTBENCHPATH)
	@$(GHDL_CMD) -e $(GHDL_FLAGS) $(TESTBENCHFILE)

run:
	@$(GHDL_CMD) -r $(GHDL_FLAGS) --workdir=$(WORKDIR) $(TESTBENCHFILE) --vcd=$(TESTBENCHFILE).vcd $(GHDL_SIM_OPT)
	@mv $(TESTBENCHFILE).vcd $(WORKDIR)/

view:
	@$(WAVEFORM_VIEWER) --dump=$(WORKDIR)/$(TESTBENCHFILE).vcd

clean:
	@rm -rf $(WORKDIR)
