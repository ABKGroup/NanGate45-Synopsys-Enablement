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

set lib_file_names [glob *.lib]

foreach lib_file_name $lib_file_names {
	read_lib $lib_file_name
}

set lib_names [get_libs]

foreach_in_collection lib $lib_names {
	set lib_name [get_object_name $lib]
	write_lib ${lib_name} -output ${lib_name}.db
}
