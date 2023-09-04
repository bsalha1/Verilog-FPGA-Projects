set PROJECT_NAME              blink
set PROJECT_CONSTRAINT_FILE ./constraints/boolean.xdc
set OUTPUT_DIR ./output 

file mkdir ${OUTPUT_DIR}
create_project ${PROJECT_NAME} ${OUTPUT_DIR}/${PROJECT_NAME} -part xc7s50csga324-1
add_files {./src  }
import_files -force
import_files -fileset constrs_1 -force -norecurse ${PROJECT_CONSTRAINT_FILE}

update_compile_order -fileset sources_1

# Synthesis.
launch_runs synth_1
wait_on_run synth_1
open_run synth_1 -name netlist_1

# Timing and power report.
report_timing_summary -delay_type max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -file ${OUTPUT_DIR}/syn_timing.rpt
report_power -file ${OUTPUT_DIR}/syn_power.rpt

# Implementation.
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1 
open_run impl_1

# Timing and power report.
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -file ${OUTPUT_DIR}/imp_timing.rpt
report_power -file ${OUTPUT_DIR}/imp_power.rpt

# Open hardware target for programming.
connect_hw_server -allow_non_jtag
open_hw_target

start_gui