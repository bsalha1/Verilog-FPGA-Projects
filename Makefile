# Project variables.
OUTPUT_DIR = output
DESIGN_NAME = uart
FPGA = xc7s50csga324-1
CONSTRAINTS_FILE = constraints/boolean.xdc
BITSTREAM_FILE = output/$(DESIGN_NAME).bit
ARGS = -nojournal -nolog -mode batch

# Does everything.
all:
	@make clean
	@make build
	@make program

# Removes any built artifacts.
clean:
	rm -rf $(OUTPUT_DIR)

# Builds the bitstream.
build:
	[ -d $(OUTPUT_DIR) ] || mkdir $(OUTPUT_DIR)
	vivado $(ARGS) -source build.tcl -tclargs $(DESIGN_NAME) $(FPGA) $(CONSTRAINTS_FILE) $(BITSTREAM_FILE)

# Programs the FPGA with the bitstream.
program:
	vivado $(ARGS) -source program.tcl -tclargs $(BITSTREAM_FILE)