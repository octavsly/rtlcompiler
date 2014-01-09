# This file is defining namespace variable that will be used or evaluated
# The idea is to put any customized steps here and evaluate/use them from the rest of the scripts.
# Whatever is customized should end up here.


namespace eval diehardus {
# File containing the RTL files. Supported formats rc,text,utel
variable read_hdl		"::octopusRC::read_hdl --type rc ../rtlcompiler/cmd/read_hdl.tcl"

variable lefs "
	 	$env(CADENV_HOME)/.caddata/krfdi/tools/cadence_edi/xkrfdix_5.6.lef\
	 	$env(CADENV_HOME)/.caddata/hfgerir/ABSTRACT/hfgerir.lef \
	 	$env(CADENV_HOME)/.caddata/hrxc5/ABSTRACT/hrxc5.lef\
	 	$env(CADENV_HOME)/.caddata/sderx/ABSTRACT/rexkrfdix.lef
	 	$env(CADENV_HOME)/.caddata/sderm/ABSTRACT/yxkrfdix.lef
 		"
	
variable cap_table_file "$env(CADENV_HOME)/.caddata/krfdi/tools/cadence_edi/xkrfdix_Cmax.capTbl"


# Scan enable ralated signals. Used for scan insertion and clock gate insertion
variable scan_enable_flip_flop		I0/u0_hrxc_ic_core_test/u_hrxc_ic_core_test_on_tcb/se
variable scan_enable_clock_gate		I0/u0_hrxc_ic_core_test/u_hrxc_ic_core_test_on_tcb/tcb_clock_active_se
# Module name of the JTAG TAP controller
variable JTAG_TAP			abl_dig_tapcn1

# Timing modes for test modes stuckat shift/capture. In the future @speed might be added.
variable scanshift_timing_mode		PM_scantest_dft_On_shiftmode
variable capture_timing_mode		PM_scantest_dft_On

# CTL files containing the scan-chains
variable read_ctl 		{
				::octopusRC::read_dft_abstract_model\
					-assume_connected_shift_enable\
					--ctl \
						$env(PROJECT_WORK)/data/hrxc_hrxc1_lib/hrxc_hrxc1/catviews/hrxc_hrxc1_ana_tpr.ctl \
						$env(PROJECT_WORK)/data/hrxc_hrxc1_lib/hrxc_hrxc1/catviews/hrxc_hrxc1_ana_tpr.ctl \
						$env(PROJECT_WORK)/data/hrxc_hrxc2_lib/hrxc_hrxc2/catviews/hrxc_hrxc2_ana_tpr.ctl \
						$env(PROJECT_WORK)/data/hrxc_hrxc2_lib/hrxc_hrxc2/catviews/hrxc_hrxc2_trim_tpr.ctl \
						$env(PROJECT_WORK)/data/hrxc_hrxc3_lib/hrxc_hrxc3/catviews/hrxc_hrxc3_ana_tpr.ctl \
						$env(PROJECT_WORK)/data/hrxc_hrxc3_lib/hrxc_hrxc3/catviews/hrxc_hrxc3_trim_tpr.ctl \
						$env(PROJECT_WORK)/data/hrxc_hrxc4_lib/hrxc_hrxc4/catviews/hrxc_hrxc4_ana_tpr.ctl \
						$env(PROJECT_WORK)/data/hrxc_hrxc4_lib/hrxc_hrxc4/catviews/hrxc_hrxc4_trim_tpr.ctl \
						$env(PROJECT_WORK)/data/hrxc_hrxc5_lib/hrxc_hrxc5/catviews/hrxc_hrxc5_ana_ao_tpr.ctl \
						$env(PROJECT_WORK)/data/hrxc_hrxc5_lib/hrxc_hrxc5/catviews/hrxc_hrxc5_ana_pso_tpr.ctl \
						$env(PROJECT_WORK)/data/hrxc_hrxc5_lib/hrxc_hrxc5/catviews/hrxc_hrxc5_trim_tpr.ctl \
						$env(PROJECT_WORK)/data/asfafe_sara_adfex_asdfuirfv1_lib/asfafe_sara_adfex_asdfuirfv1/catviews/asfafe_sara_adfex_asdfuirfv1_ana_tpr.ctl \
						$env(PROJECT_WORK)/data/asfafe_sara_adfex_asdfuirfv1_lib/asfafe_sara_adfex_asdfuirfv1/catviews/asfafe_sara_adfex_asdfuirfv1_trim_tpr.ctl \
						$env(PROJECT_WORK)/data/asfafe_sara_adfex_testmuxn1_lib/asfafe_sara_adfex_testmuxn1/catviews/asfafe_sara_adfex_testmuxn1_tpr.ctl \
						$env(PROJECT_WORK)/data/iphgrf_aseifbfn1_lib/iphgrf_aseifbfn1/catviews/iphgrf_aseifbfn1_ana_tpr.ctl \
						$env(PROJECT_WORK)/data/iphgrf_aseifbfn1_lib/iphgrf_aseifbfn1/catviews/iphgrf_aseifbfn1_trim_tpr.ctl \
						$env(PROJECT_WORK)/data/iphgrf_jhxcv1_lib/iphgrf_jhxcv1/catviews/iphgrf_jhxcv1_ana_tpr.ctl \
						$env(PROJECT_WORK)/data/iphgrf_jhxcv1_lib/iphgrf_jhxcv1/catviews/iphgrf_jhxcv1_trim_tpr.ctl  \
						$env(PROJECT_WORK)/data/iphgrf_asdafevsdd1_lib/iphgrf_asdafevsdd1/catviews/iphgrf_asdafevsdd1_ana_tpr.ctl \
						$env(PROJECT_WORK)/data/iphgrf_asdafevsdd1_lib/iphgrf_asdafevsdd1/catviews/iphgrf_asdafevsdd1_trim_tpr.ctl \
						$env(PROJECT_WORK)/data/iphgrf_asdof1_lib/iphgrf_asdof1/catviews/iphgrf_asdof1_ana_on_tpr.ctl \
						$env(PROJECT_WORK)/data/iphgrf_asdof1_lib/iphgrf_asdof1/catviews/iphgrf_asdof1_ana_off_tpr.ctl \
						$env(PROJECT_WORK)/data/iphgrf_ada2048_lib/iphgrf_ada2048/catviews/iphgrf_ada2048_tpr.ctl \
						$env(PROJECT_WORK)/data/iphgrf_asdfwecrg1_lib/iphgrf_asdfwecrg1/catviews/iphgrf_asdfwecrg1_ana_tpr.ctl \
						$env(PROJECT_WORK)/data/iphgrf_pmwozbftr1_lib/iphgrf_pmwozbftr1/catviews/iphgrf_pmwozbftr1_ana_tpr.ctl \
						\
					--boundary-opto \
					--debug-level 2

				::octopusRC::read_dft_abstract_model \
					--ctl \
						$env(PROJECT_WORK)/data/ltthf_lib/ltthf_asdopefsd_asdcsda/TEST/ltthf_asdopefsd_asdcsda_chains.ctl \
					--debug-level 2
				}

# TCB's and TPR's
set TCBs(module) "" ; # will be found automatically after elaborate
set TPRs(module) "" ; # will be found automatically after elaborate

set TCBs(td)	"
		$env(PROJECT_WORK)/data/hrxc_ic_lib/hrxc_ic_core/catviews/hrxc_ic_core_test_off_tcbreg.td \
		$env(PROJECT_WORK)/data/hrxc_ic_lib/hrxc_ic_core/catviews/hrxc_ic_core_test_on_tcbreg.td \
	"



# Test data files of TCB's
variable constraints_from_tcbs	{
				::octopusRC::constraints_from_tcbs \
					--tcb-td-file $diehardus::TCBs(td) \
					--mode application \
					--exclude-ports tcb_capture \
					--constraint-file ${DATA_PATH}/${CRT_LIB}/${CRT_CELL}/CONSTRAINTS/${DESIGN}_func_tcb_settings.sdc

				::octopusRC::constraints_from_tcbs \
					--tcb-td-file $diehardus::TCBs(td) \
					--mode intest_logic_scan_stuckat \
					--exclude-ports tcb_capture \
					--constraint-file ${DATA_PATH}/${CRT_LIB}/${CRT_CELL}/CONSTRAINTS/${DESIGN}_scan_tcb_settings.sdc

					#--ports <consider only few TCB ports>
				}

# Test point insertion
variable test_point_insertion {
		display_message workaround "Extreme measure: activated testpoints insertion for MFIO cells"
		foreach crt_txcv [find / -vname -maxdepth 4 -inst txcv_*] {
			if { 	"$crt_txcv" == "txcv_hex" || \
				"$crt_txcv" == "txcv_oeg" || \
				"$crt_txcv" == "txcv_psdncvuier" || \
				"$crt_txcv" == "txcv_lszx" || \
				"$crt_txcv" == "txcv_asdfsrg_0" } {
				continue
			}
			foreach crt_pin "pin1 pin2 pin3" {
				lappend pins ${crt_txcv}/$crt_pin
			}
		}
		display_message info "Inserting XOR tree observe testpoint with clock clk_testshell on pins: $pins"
		insert_dft test_point \
			-location ${pins} \
			-type observe_scan \
			-test_clock_pin I0/u0_hrxc_ic_core_test/ccb_testshell_ccb/func_clk
		}


# Scan chains inputs/outputs
variable scan_inputs	I0/u0_hrxc_ic_core_test/si*
variable scan_outputs	I0/u0_hrxc_ic_core_test/so*

# Scan chain insertion
set scan_chains_insertion {
		# Define floating segment with falling edge FF's. They will be put in front of the chain.
		define_dft floating_segment \
			-name falling_edge_flops [::octopus::find_fall_edge_objects]

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
}

# Analog instances, in case you wanna have an ESD netlist
variable analog_instances ""
#variable analog_instances [get_attribute instances [find -subdesign analog_modules]]

}
