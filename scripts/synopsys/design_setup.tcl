##################################################################
# Portions Copyright 2022 Synopsys, Inc. All rights reserved.
# Portions of these TCL scripts are proprietary to and owned
# by Synopsys, Inc. and may only be used for internal use by
# educational institutions (including United States government
# labs, research institutes and federally funded research and
# development centers) on Synopsys tools for non-profit research,
# development, instruction, and other non-commercial uses or as
# otherwise specifically set forth by written agreement with
# Synopsys. All other use, reproduction, modification, or
# distribution of these TCL scripts is strictly prohibited.
##################################################################

set DESIGN $env(DESIGN)
set NWORST $env(NWORST)

set HOME_DIR "../../.."
set PDK_DIR "${HOME_DIR}/NanGate45"
set DESIGN_DIR "${HOME_DIR}/benchmark/${DESIGN}"
set CAP_EX_DIR "${DESIGN_DIR}/net_capacitance"
set TIMING_EX_DIR "${DESIGN_DIR}/timing_details"

set DB_FILE " \
    fakeram45_128x116.db \
    fakeram45_128x256.db \
    fakeram45_128x32.db \
    fakeram45_256x16.db \
    fakeram45_256x32.db \
    fakeram45_256x48.db \
    fakeram45_256x64.db \
    fakeram45_32x32.db \
    fakeram45_512x64.db \
    fakeram45_64x124.db \
    fakeram45_64x256.db \
    fakeram45_64x62.db \
    fakeram45_64x64.db \
    NangateOpenCellLibrary_typical.db \
    "
set SDC_FILE "${DESIGN_DIR}/${DESIGN}.sdc"
set NETLIST_FILE "${DESIGN_DIR}/${DESIGN}.v"


set search_path ". ${PDK_DIR}/db"
set target_library ${DB_FILE}
set link_library "* ${target_library}"
