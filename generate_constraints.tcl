#Generate set_case_analysis statements from TCB test data files"
::octopusRC::constraints_from_tcbs \
	--tcb-td-file <TCB's test data file> \
	--mode application \
	--exclude-ports tcb_capture \
	--constraint-file ${DATA_PATH}/${CRT_LIB}/${CRT_CELL}/CONSTRAINTS/${DESIGN}_func_tcb_settings.sdc
::octopusRC::constraints_from_tcbs \
	--tcb-td-file <TCB's test data file> \
	--mode intest_logic_scan_stuckat \
	--exclude-ports tcb_capture \
	--ports <consider only few TCB ports>
	--constraint-file ${DATA_PATH}/${CRT_LIB}/${CRT_CELL}/CONSTRAINTS/${DESIGN}_scan_tcb_settings.sdc
::octopus::abort_on error --suspend