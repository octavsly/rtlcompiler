# make all test clocks compatible
set_compatible_test_clocks -all

# Find all falling edge FF, or segments clocked on falling edge
set ff_fall_edge_no_dft_part_of_segment [filter -invert dft_part_of_segment "*" [filter dft_test_clock_edge "fall" [filter flop "true" [find / -inst *]] ] ]
set ff_fall_edge____dft_part_of_segment [filter         dft_part_of_segment "*" [filter dft_test_clock_edge "fall" [filter flop "true" [find / -inst *]] ] ]
foreach jjj $ff_fall_edge____dft_part_of_segment {
	foreach iii [find / -scan_segment *] {
		if { [string match "* $jjj *" " [get_attribute elements $iii] "] } {
			lappend sg_fall_edge $iii
			break
		}
	}
}
if { [info exists sg_fall_edge] } {
	set sg_fall_edge [lsort -unique $sg_fall_edge]
} else {
	set sg_fall_edge ""
}

# Define floating segment with falling edge FF's. They will be put in front of the chain.
define_dft floating_segment \
	-name falling_edge_flops \
	"$ff_fall_edge_no_dft_part_of_segment $sg_fall_edge"

## Define scan chains
define_dft scan_chain \
	-name allFF_0 \
	-sdi I0/u0_hrxc_ic_core_test/si[0] \
	-sdo I0/u0_hrxc_ic_core_test/so[0] \
	-non_shared_output \
	-head falling_edge_flops \
	-terminal_lockup level_sensitive

define_dft scan_chain \
	-name allFF_1 \
	-sdi I0/u0_hrxc_ic_core_test/si[1] \
	-sdo I0/u0_hrxc_ic_core_test/so[1] \
	-non_shared_output \
	-terminal_lockup level_sensitive

connect_scan_chains -incremental

fix_scan_path_inversions allFF_0
fix_scan_path_inversions allFF_1

report dft_chains > $_REPORTS_PATH/${DESIGN}_report_dft_chains.rpt