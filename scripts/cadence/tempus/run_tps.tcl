# This script was written and developed by ABKGroup students at UCSD. However, the underlying commands and reports are copyrighted by Cadence. 
# We thank Cadence for granting permission to share our research to help promote and foster the next generation of innovators.

source ../func.tcl
source ../design_setup.tcl

set NWORST $env(NWORST)
set CC $env(CC)
set SI $env(SI)
set PEX $env(PEX)
set STA "TPS"

set CAP_EX_DIR "${CAP_EX_DIR}/${PEX}/CC_${CC}"
set TIMING_EX_DIR "${TIMING_EX_DIR}/${PEX}-${STA}/CC_${CC}_SI_${SI}"

set SPEF_FILE "${DESIGN_DIR}/${DESIGN}_${PEX}_CC_${CC}.spef"

setLibraryUnit -time 1ns 
#setLibraryUnit -cap 0.001pf

read_lib ${LIB_FILE}
read_verilog ${NETLIST_FILE}
set_top_module ${DESIGN}
read_spef ${SPEF_FILE}
read_sdc ${SDC_FILE}

set_interactive_constraint_modes [all_constraint_modes -active]
set_propagated_clock [all_clocks]
set_clock_propagation propagated

set_delay_cal_mode -siAware ${SI}
report_timing

save_cap_file ${CAP_EX_DIR}
save_timing_file ${TIMING_EX_DIR} ${NWORST} 

exit
