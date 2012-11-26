# Specify location to dump reports generated
shell mkdir -p $_REPORTS_PATH

# Specify location to dump outputs generated
shell mkdir -p ${DATA_PATH}/${CRT_LIB}/${CRT_CELL}/NETLIST

set ::octopusRC::run_speed "${run-speed}"

::octopusRC::clean_reports

# This is useful for creating test cases, to be sent to cadence
applet load create_tcase
