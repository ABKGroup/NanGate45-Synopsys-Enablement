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
        set name [get_attribute ${net} full_name]
        set cap [get_attribute ${net} wire_capacitance_max]

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
	puts $fileId "points,tran_type,slews,delays,arrival,required,slack"

	set timing_path1 [get_timing_paths -from [all_inputs] -to [all_registers -data_pins] -slack_lesser_than 10000 -max_paths 1000000 -nworst $NWORST]
	set timing_path2 [get_timing_paths -from [all_registers -clock_pins] -to [all_registers -data_pins] -slack_lesser_than 10000 -max_paths 1000000 -nworst $NWORST]
	set timing_path3 [get_timing_paths -from [all_registers -clock_pins] -to [all_outputs] -slack_lesser_than 10000 -max_paths 1000000 -nworst $NWORST]
	set timing_path4 [get_timing_paths -from [all_inputs] -to [all_outputs] -slack_lesser_than 10000 -max_paths 1000000 -nworst $NWORST]

	set timing_paths [list $timing_path1 $timing_path2 $timing_path3 $timing_path4]

	foreach timing_path $timing_paths {
		foreach_in_collection timing_path $timing_paths {
			set timing_pin_names [get_object_name [get_attribute [get_attribute $timing_path points] object]]

			set tran_type [get_attribute [get_attribute $timing_path points] rise_fall]
			set slews [get_attribute [get_attribute $timing_path points] transition]

			set each_cell_arrival [get_attribute [get_attribute $timing_path points] arrival]
			set delays {0.0}

			set length [llength $each_cell_arrival]

			for {set i 0} {$i < $length-1} {incr i} {
				set val1 [lindex $each_cell_arrival $i]
				set val2 [lindex $each_cell_arrival [expr {$i + 1}]]

				lappend delays [expr {$val2 - $val1}]
			}

			set arrival [get_attribute $timing_path arrival]
			set required [get_attribute $timing_path required]
			set slack [get_attribute $timing_path slack]

			puts $fileId "$timing_pin_names,$tran_type,$slews,$delays,$arrival,$required,$slack"
		}
	}
	close $fileId
}

source ../design_setup.tcl

set CC $env(CC)
set SI $env(SI)
set PEX $env(PEX)
set STA "PT"

set CAP_EX_DIR "${CAP_EX_DIR}/${PEX}/CC_${CC}"
set TIMING_EX_DIR "${TIMING_EX_DIR}/${PEX}-${STA}/CC_${CC}_SI_${SI}"

set SPEF_FILE "${DESIGN_DIR}/${DESIGN}_${PEX}_CC_${CC}.spef"

read_verilog ${NETLIST_FILE}
link_design ${DESIGN}

read_sdc ${SDC_FILE}

set_units -time 1ns
#set_units -capacitance 0.001pF


if { $SI == "true" } {
	set si_enable_analysis ${SI}
	read_parasitics -keep_capacitive_coupling -format SPEF ${SPEF_FILE}
} else {
	set si_enable_analysis ${SI}
	read_parasitics -format SPEF ${SPEF_FILE}
}

save_cap_file ${CAP_EX_DIR}
save_timing_file ${TIMING_EX_DIR} ${NWORST}

exit
