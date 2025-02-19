# This script was written and developed by ABKGroup students at UCSD. However, the underlying commands and reports are copyrighted by Cadence. 
# We thank Cadence for granting permission to share our research to help promote and foster the next generation of innovators.


setMultiCpuUsage -localCpu 16

set DESIGN $env(DESIGN)

set HOME_DIR "../../.."
set PDK_DIR "${HOME_DIR}/NanGate45"
set DESIGN_DIR "${HOME_DIR}/benchmark/${DESIGN}"
set CAP_EX_DIR "${DESIGN_DIR}/net_capacitance"
set TIMING_EX_DIR "${DESIGN_DIR}/timing_details"

set LIB_FILE "${PDK_DIR}/lib/NangateOpenCellLibrary_typical.lib [glob "${PDK_DIR}/lib/fakeram45*.lib"]"
set SDC_FILE "${DESIGN_DIR}/${DESIGN}.sdc"
set NETLIST_FILE "${DESIGN_DIR}/${DESIGN}.v"

