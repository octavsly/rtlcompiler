################################################################################
## DfT settings
################################################################################
set_attribute dft_scan_output_preference 		non_inverted 	${DESIGN}
set_attribute dft_mix_clock_edges_in_scan_chains 	true 		$DESIGN


################################################################################
#Define clocks
################################################################################
::octopusRC::define_dft_test_clocks \
	--timing-modes "<shiftscan>"\
	--debug-level 0


################################################################################
## Defines test modes
################################################################################
# Shift enables
define_dft shift_enable -name se -default		-active high <se>
define_dft shift_enable -name tcb_clock_active_se	-active high <tcb_clock_active_se>

# Take DfT signals from SDC files
octopusRC::define_dft_test_signals \
	--timing-modes <scanshift> \
octopusRC::define_dft_test_signals \
	--timing-modes <capture>\
	--test-mode capture


################################################################################
## Read DfT abstracts
################################################################################
# ::octopusRC::read_dft_abstract_model reads the module directly from CTL. No need to specify the module name anymore
::octopusRC::read_dft_abstract_model\
	--assume-connected-shift-enable\
	--ctl \
		<TPR's>\
		<other ctl files> \
	--boundary-opto \
	--debug-level 2


################################################################################
## DfT no scan
################################################################################
# set_attribute dft_dont_scan true abl_dig_tapcn1 ;# TAP
# set_attribute dft_dont_scan true *_tcb ; # TCB's
# set_attribute dft_dont_scan true lkjh1 ; # The special BUMP module


################################################################################
## Preserve unconnected scan inputs/outputs
################################################################################
#Testmux si/so scan ports which will be connected at scan chains stitching stage
# set_attribute preserve true [find I0/u0_hrxc_ic_core_test/ -maxdepth 2 -pin si*]
# set_attribute preserve true [find I0/u0_hrxc_ic_core_test/ -maxdepth 2 -pin so*]
# TPR's scan outputs. Same reason as below
set_attribute preserve true [find / -pin tpr_sso]

################################################################################
## clock gating settings
################################################################################
if { "$::octopusRC::run_speed" != "fast"} {
check_dft_rules 		> $_REPORTS_PATH/${DESIGN}_check_dft_rules.rpt
report dft_setup		> $_REPORTS_PATH/${DESIGN}_report_dft_setup.rpt
report dft_registers -dont_scan	> $_REPORTS_PATH/${DESIGN}_report_dft_dont_scan.rpt

write_db ${DESIGN} -all_root_attributes -to_file ${DESIGN}_post_dft_settings.db
}