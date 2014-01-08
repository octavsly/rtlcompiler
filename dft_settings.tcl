################################################################################
## DfT settings
set_attribute dft_scan_output_preference 		non_inverted 	${DESIGN}
set_attribute dft_mix_clock_edges_in_scan_chains 	true 		$DESIGN
################################################################################


################################################################################
#Define clocks
::octopusRC::define_dft_test_clocks \
	--timing-modes $diehardus::scanshift_timing_mode
################################################################################


################################################################################
## Defines test modes

# Shift enables
# Required for scan-enable connection of the scannable flip-flops.
define_dft shift_enable -name se -default		-active high $diehardus::scan_enable_flip_flop
# Required for clock-gating connection of the TE signal
define_dft shift_enable -name tcb_clock_active_se	-active high $diehardus::scan_enable_clock_gate

# Might be required for clock tracing. It solve all the other S type of TCB's signals.
define_dft shift_enable -name tcb_tc                    -active high [get_attribute instances [find -subdesign $JTAG_TAP]]/tcb_tc

# Take DfT signals from SDC files
octopusRC::define_dft_test_signals \
	--timing-modes $diehardus::scanshift_timing_mode \
octopusRC::define_dft_test_signals \
	--timing-modes $diehardus::capture_timing_mode\
	--test-mode capture
################################################################################


################################################################################
## Read DfT abstracts (CTL scan chains)
################################################################################
eval $diehardus::read_ctl


################################################################################
## DfT no scan
set_attribute dft_dont_scan true $diehardus::JTAG_TAP
################################################################################


################################################################################
## Preserve unconnected scan inputs/outputs
#Testmux si/so scan ports which will be connected at scan chains stitching stage
set_attribute preserve true $diehardus::scan_inputs
set_attribute preserve true $diehardus::scan_outputs
################################################################################


::octopus::abort_on error --suspend


################################################################################
## Writing reports
if { "$::octopusRC::run_speed" != "fast"} {
check_dft_rules
} else {
check_dft_rules 		> ${_REPORTS_PATH}/${DESIGN}_check_dft_rules.rpt
report dft_setup		> ${_REPORTS_PATH}/${DESIGN}_report_dft_setup.rpt
report dft_registers -dont_scan	> ${_REPORTS_PATH}/${DESIGN}_report_dft_dont_scan.rpt

shell mkdir -p db
write_db ${DESIGN} -all_root_attributes -to_file db/${DESIGN}_post_dft_settings.db
}
################################################################################
