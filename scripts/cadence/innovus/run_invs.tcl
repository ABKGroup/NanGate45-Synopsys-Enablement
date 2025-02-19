# This script was written and developed by ABKGroup students at UCSD. However, the underlying commands and reports are copyrighted by Cadence. 
# We thank Cadence for granting permission to share our research to help promote and foster the next generation of innovators.

source ../func.tcl
source ../design_setup.tcl

set NWORST $env(NWORST)
set CC $env(CC)
set SI $env(SI)
set PEX "INVS"
set STA "INVS"

set CAP_EX_DIR "${CAP_EX_DIR}/${PEX}/CC_${CC}"
set TIMING_EX_DIR "${TIMING_EX_DIR}/${PEX}-${STA}/CC_${CC}_SI_${SI}"

set TECH_LEF_FILE "${PDK_DIR}/lef/NangateOpenCellLibrary.tech.lef"
set MACRO_LEF_FILE "${PDK_DIR}/lef/NangateOpenCellLibrary.macro.mod.lef [glob "${PDK_DIR}/lef/fakeram45*.lef"]"
set QRC_FILE "${PDK_DIR}/qrc/NangateOpenCellLibrary.tch"
set DEF_FILE "${DESIGN_DIR}/${DESIGN}.def"

set libworst $LIB_FILE
set libbest $libworst

set lefs " \
    ${TECH_LEF_FILE} \
    ${MACRO_LEF_FILE} \
    "

set qrc_max "${QRC_FILE}"
set qrc_min "${QRC_FILE}"

setLibraryUnit -time 1ns 
#setLibraryUnit -cap 0.001pf

create_library_set -name WC_LIB -timing $libworst
create_library_set -name BC_LIB -timing $libbest

create_rc_corner -name Cmax -qx_tech_file $qrc_max
create_rc_corner -name Cmin -qx_tech_file $qrc_min

create_delay_corner -name WC -library_set WC_LIB -rc_corner Cmax
create_delay_corner -name BC -library_set BC_LIB -rc_corner Cmin

create_constraint_mode -name CON -sdc_file $SDC_FILE
create_analysis_view -name WC_VIEW -delay_corner WC -constraint_mode CON 
create_analysis_view -name BC_VIEW -delay_corner BC -constraint_mode CON 

# default settings
set init_pwr_net VDD
set init_gnd_net VSS

# default settings
set init_verilog "$NETLIST_FILE"
set init_design_NETLISTtype "Verilog"
set init_design_settop 1
set init_top_cell "$DESIGN"
set init_lef_file "$lefs"

# MCMM setup
init_design -setup {WC_VIEW} -hold {BC_VIEW}
defIn ${DEF_FILE}

# Use TQuantus.
setExtractRCMode -effortLevel medium 
setExtractRCMode -engine postRoute -coupled ${CC}
if { $SI == true } {
#	setExtractRCMode -effortLevel high # Use IQuantus. This needs Quantus license.
	setAnalysisMode -analysisType onChipVariation -cppr both
	setSIMode -analysisType aae
	setDelayCalMode -SIAware true
}
extractRC
rcOut -spef ${DESIGN_DIR}/${DESIGN}_${PEX}_CC_${CC}.spef

report_timing

save_cap_file ${CAP_EX_DIR}
save_timing_file ${TIMING_EX_DIR} ${NWORST}

exit
