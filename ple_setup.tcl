# This file is setting up the PLE mode for synthesis. It is design & technology specific.

# Set lib_lef_consistency_check_enable to false or the *lib modules without LEF's will not be used
set_attribute   lib_lef_consistency_check_enable   false

# Add more lef's when they become available
# set_attribute 	lef_library "\
# 	$env(CADENV_HOME)/.caddata/krfdi/tools/cadence_edi/xkrfdix_5.6.lef\
# 	$env(CADENV_HOME)/.caddata/hfgerir/ABSTRACT/hfgerir.lef \
# 	$env(CADENV_HOME)/.caddata/hrxc5/ABSTRACT/hrxc5.lef\
# 	$env(CADENV_HOME)/.caddata/sderx/ABSTRACT/rexkrfdix.lef
# 	$env(CADENV_HOME)/.caddata/sderm/ABSTRACT/yxkrfdix.lef
# 	"
#
# set_attribute 	cap_table_file		"$env(CADENV_HOME)/.caddata/krfdi/tools/cadence_edi/xkrfdix_Cmax.capTbl"
set_attribute 	ple_mode 		global
set_attribute 	interconnect_mode	ple

set 		analysis_type 		wc