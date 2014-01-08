# Replace scan-ff with normal FF in the shift registers
replace_scan -to_non_scan

#Insert the observability logic for the clock-gating instances
clock_gating insert_obs -hierarchical -max_cg 32
#Run the DFT rule checker, to determine the DFT status of the observability logic:
check_dft_rules

# make all test clocks compatible
set_compatible_test_clocks -all

::octopusRC::write --stage mapped_scn

eval $diehardus::scan_chains_insertion

report dft_chains > $_REPORTS_PATH/${DESIGN}_report_dft_chains.rpt
