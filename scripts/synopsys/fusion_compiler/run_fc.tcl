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

proc save_cap_file { CAP_EX_DIR } {
	if { ![file exists ${CAP_EX_DIR}] } { file mkdir ${CAP_EX_DIR} }

	set nets [get_nets -hierarchical]

	set fileId [open "${CAP_EX_DIR}/net_parasitics.csv" "w"]
	puts ${fileId} "net_name,cap,res"
	foreach_in_collection net ${nets} {
		set name [get_attribute -class net -name full_name ${net}]
		set cap [get_attribute -class net -name wire_capacitance_max ${net}]

		if { $cap != "" } {
			set cap [expr $cap*1000]
			puts ${fileId} "${name},${cap},0"
		}
	}
	close ${fileId}
}

proc save_timing_file { TIMING_EX_DIR NWORST } {
	if { ![file exists ${TIMING_EX_DIR}] } { file mkdir ${TIMING_EX_DIR} }

	set fileId [open "${TIMING_EX_DIR}/timing_details.csv" "w"]
	puts ${fileId} "points,tran_type,slews,delays,arrival,required,slack"
	set timing_path1 [get_timing_paths -from [all_inputs] -to [all_registers -data_pins] -max_paths 1000000 -nworst ${NWORST}]
	set timing_path2 [get_timing_paths -from [all_registers -clock_pins] -to [all_registers -data_pins] -max_paths 1000000 -nworst ${NWORST}]
	set timing_path3 [get_timing_paths -from [all_registers -clock_pins] -to [all_outputs] -max_paths 1000000 -nworst ${NWORST}]
	set timing_path4 [get_timing_paths -from [all_inputs] -to [all_outputs] -max_paths 1000000 -nworst ${NWORST}]

	set timing_paths [list ${timing_path1} ${timing_path2} ${timing_path3} ${timing_path4}]

	foreach timing_path ${timing_paths} {
		foreach_in_collection timing_path ${timing_paths} {
			set timing_pin_names [get_object_name [get_attribute -class timing_path -name points ${timing_path}]]

			set timing_points [get_attribute -class timing_path -name points ${timing_path}]
			set tran_type [get_attribute -class timing_point -name rise_fall ${timing_points}]
			set slews [get_attribute -class timing_point -name transition ${timing_points}]
			set delays [get_attribute -class timing_point -name delay ${timing_points}]
			set arrival [get_attribute -class timing_path -name arrival ${timing_path}]
			set required [get_attribute -class timing_path -name required ${timing_path}]
			set slack [get_attribute -class timing_path -name slack ${timing_path}]

			puts ${fileId} "${timing_pin_names},${tran_type},${slews},${delays},${arrival},${required},${slack}"
		}
	}
	close ${fileId}
}

source ../design_setup.tcl

set CC $env(CC)
set SI $env(SI)
set PEX "FC"
set STA "FC"

set CAP_EX_DIR "${CAP_EX_DIR}/${PEX}/CC_${CC}"
set TIMING_EX_DIR "${TIMING_EX_DIR}/${PEX}-${STA}/CC_${CC}_SI_${SI}"

set DEF_FILE "${DESIGN_DIR}/${DESIGN}.def"
set TECH_FILE "${PDK_DIR}/tf/NangateOpenCellLibrary.tf"
set MACRO_LEF_FILE "${PDK_DIR}/lef/NangateOpenCellLibrary.macro.mod.lef [glob "${PDK_DIR}/lef/fakeram45*.lef"]"
set TLUP_FILE "${PDK_DIR}/tlup/NangateOpenCellLibrary.tlup"
set LAYERMAP_FILE "${PDK_DIR}/tlup/NangateOpenCellLibrary.layermap"

create_lib -technology ${TECH_FILE} -ref_libs ${MACRO_LEF_FILE} NangateOpenCellLibrary

read_verilog -top ${DESIGN} ${NETLIST_FILE}
link_block

set_user_units -type time -value 1ns
#set_user_units -type capacitance -value 0.001pF

read_def -convert_sites {FreePDK45_38x28_10R_NP_162NW_34O unit} -design ${DESIGN} ${DEF_FILE}
read_parasitic_tech -name "WS" -tlup ${TLUP_FILE} -layermap ${LAYERMAP_FILE} -sanity_check advanced

remove_modes -all; remove_corners -all; remove_scenarios -all

set corner "WC"
create_mode ${corner}
create_corner ${corner}
create_scenario -name ${corner} -mode ${corner} -corner ${corner}
current_scenario ${corner}
set_parasitic_parameters -late_spec WS -early_spec WS
set_voltage 1.1 -corner [current_corner] -object_list [get_supply_nets VDD]
set_voltage 0.0 -corner [current_corner] -object_list [get_supply_nets VSS]

source ${SDC_FILE}

set_scenario_status $corner -none -setup true -hold true -leakage_power true -dynamic_power true -max_transition true -max_capacitance true -min_capacitance false -active true

set_app_options -name extract.enable_coupling_cap -value ${CC}
set_app_options -name extract.high_fanout_threshold -value 100000

write_parasitics -output ${DESIGN}_CC_${CC} -format SPEF

exec mv ${DESIGN}_CC_${CC}.WS_25.spef ${DESIGN_DIR}/${DESIGN}_${PEX}_CC_${CC}.spef
exec rm ${DESIGN}_CC_${CC}.spef_scenario

set_app_options -name time.si_enable_analysis -value ${SI}

set_propagated_clock [all_clocks]

report_timing

save_cap_file ${CAP_EX_DIR}
save_timing_file ${TIMING_EX_DIR} ${NWORST}

exit
