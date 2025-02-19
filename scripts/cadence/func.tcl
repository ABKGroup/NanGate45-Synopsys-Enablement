# This script was written and developed by ABKGroup students at UCSD. However, the underlying commands and reports are copyrighted by Cadence. 
# We thank Cadence for granting permission to share our research to help promote and foster the next generation of innovators.


proc save_cap_file { CAP_EX_DIR } {
    if { ![file exists ${CAP_EX_DIR}] } { file mkdir ${CAP_EX_DIR} }

    set nets [get_nets -hierarchical]
    set fileId [open "${CAP_EX_DIR}/net_parasitics.csv" "w"]
    puts $fileId "net_name,cap,res"
    foreach_in_collection net $nets {
        set name [get_db $net .name]
        set cap [get_db $net .wire_capacitance_max]
        set res [get_db $net .resistance_max]

		if { $cap != "" } {
			set cap [expr $cap*1000]
        	puts $fileId "$name,$cap,$res"
		}
    }
    close $fileId
}


proc save_timing_file { TIMING_EX_DIR NWORST } {
    if { ![file exists ${TIMING_EX_DIR}] } { file mkdir ${TIMING_EX_DIR} }

    set fileId [open "${TIMING_EX_DIR}/timing_details.csv" "w"]
    puts $fileId "points,tran_type,slews,delays,arrival,required,slack"

    set timing_path1 [report_timing -collection -from [all_inputs] -to [all_registers -data_pins] -max_paths 1000000 -nworst $NWORST]
    set timing_path2 [report_timing -collection -from [all_registers -clock_pins] -to [all_registers -data_pins] -max_paths 1000000 -nworst $NWORST]
    set timing_path3 [report_timing -collection -from [all_registers -clock_pins] -to [all_outputs] -max_paths 1000000 -nworst $NWORST]
    set timing_path4 [report_timing -collection -from [all_inputs] -to [all_outputs] -max_paths 1000000 -nworst $NWORST]
    set timing_paths [list $timing_path1 $timing_path2 $timing_path3 $timing_path4]

    foreach timing_path $timing_paths {
        foreach_in_collection timing_path $timing_paths {
            set timing_pin_names [get_db $timing_path .timing_points.pin.name]
            set tran_type [get_db $timing_path .timing_points.transition_type]
            set slews [get_db $timing_path .timing_points.slew]
            set delays [get_db $timing_path .timing_points.delay]
            set arrival [get_db $timing_path .arrival]
            set required [get_db $timing_path .required_time]
            set slack [get_db $timing_path .slack]

            puts $fileId "$timing_pin_names,$tran_type,$slews,$delays,$arrival,$required,$slack"
        }
    }
    close $fileId
}


