# Parse the arguments.
if { $argc != 5 } {
    error "$argv0 <name> <fpga> <constraints file> <bitstream file> <threads>"
} else {
    lassign $argv name fpga constraints_file bitstream_file threads
}

# Set the number of threads to use.
set_param general.maxThreads "${threads}"

# Read in sources.
read_verilog -sv [glob ./src/*.sv ]

# Read in constraints.
read_xdc "${constraints_file}"

# Synthesize design.
synth_design -top "top" -part "${fpga}"

# Place and route.
opt_design
place_design
route_design

# Create bitstream.
write_bitstream -force "${bitstream_file}"