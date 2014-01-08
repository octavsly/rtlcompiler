# This file is setting up the PLE mode for synthesis. It is design & technology specific.

# Set lib_lef_consistency_check_enable to false or the *lib modules without LEF's will not be used
set_attribute   lib_lef_consistency_check_enable   false

# Add more lef's when they become available
set_attribute 	lef_library $lefs

set_attribute 	cap_table_file $cap_table_file

set_attribute 	ple_mode 		global
set_attribute 	interconnect_mode	ple

set 		analysis_type 		wc
