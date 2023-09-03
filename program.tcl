# Parse the arguments.
if { $argc != 1 } {
    error "$argv0 <bitstream file>"
} else {
    lassign $argv bitstream_file
}

open_hw_manager
connect_hw_server
current_hw_target
open_hw_target
set_property PROGRAM.FILE "${bitstream_file}" [current_hw_device]
program_hw_devices [current_hw_device]