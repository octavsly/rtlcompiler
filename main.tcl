#!/bin/sh
# the next line restarts using -*-Tcl-*-sh \
exec rc -64 -logfile rc.log -cmdfile rc.cmd -overwrite -f "$0" -execute "set argv ${1+\"$@\"}; set argv0 $0"

#This is the main RC script. It will source other files

lappend auto_path $env(PROJECT_WORK)/data/blpjk_ic_lib/blpjk_ic/octopus/

package require octopusRC 0.1
package require octopus   0.1
# Not importing functions due to potential conflict with RC
#namespace import ::octopusRC::*
#namespace import ::octopus::*
#::octopus::set_octopus_color --disable

regexp {(.*/data/)([^/]+_lib)/([^/]+)/.*} [exec pwd] EXEC_PATH DATA_PATH CRT_LIB CRT_CELL
set var_array(10,maturity-level)	[list "--maturity-level" "<none>" "string" "1" "1" "pyrite bronze silver gold diamond" "Maturity level of the design."]
set var_array(20,DESIGN)		[list "--design" "$CRT_CELL" "string" "1" "1" "" "Top level design for which synthesis will be performed."]
set var_array(30,_REPORTS_PATH)		[list "--reports-path" "${DATA_PATH}/${CRT_LIB}/${CRT_CELL}/rtlcompiler/rpt" "string" "1" "1" "" "Directory holding the reports."]
set var_array(40,_CPF_FILE)		[list "--cpf" "${DATA_PATH}/${CRT_LIB}/${CRT_CELL}/POWER/${CRT_CELL}.cpf" "string" "1" "1" "" "CPF file location."]
set var_array(90,run-speed)		[list "--run-speed" "slow" "string" "1" "1" "slow fast" "If set to fast a lot of reports will be skipped"]

::octopus::extract_check_options_data

::octopusRC::set_design_maturity_level\
	--maturity-level ${maturity-level} \
	--rc-attributes-file rc_attributes.txt

set_attribute super_thread_batch_command		{bsub -o /dev/null -J RC_server}
set_attribute super_thread_kill_command 		{bkill}
shell mkdir -p /home/scratch/$env(USER)
set_attribute super_thread_cache			/home/scratch/$env(USER)
set_attribute super_thread_servers 			{localhost localhost localhost localhost}
################################################################################
puts "\n>> General settings"
################################################################################
# These are varibles which are used in more than one place
# Thus it makes sense to define them here

# Specify location to dump reports generated
shell mkdir -p $_REPORTS_PATH

# Specify location to dump outputs generated
shell mkdir -p ${DATA_PATH}/${CRT_LIB}/${CRT_CELL}/NETLIST

set ::octopusRC::run_speed "${run-speed}"

# This is useful for creating test cases, to be sent to cadence
applet load create_tcase
################################################################################


################################################################################
puts "\n>>  Library (including dont_use) and ple setup"
################################################################################
read_cpf -library $_CPF_FILE

include dont_use_list.cmd

include ple_setup.cmd
################################################################################


################################################################################
puts "\n>>  Read, Elaborate and Check the Design"
################################################################################
::octopusRC::read_hdl --file ../../nccoex/cmd/file_set.tcl --type utel
::octopusRC::elaborate --design $DESIGN --reports-path $_REPORTS_PATH
################################################################################

################################################################################
puts "\n>>  Generate set_case_analysis statements from TCB test data files"
################################################################################
::octopusRC::set_case_analysis --tcb-td-file <TCB's test data file> --mode application --constraint-file ${DATA_PATH}/${CRT_LIB}/${CRT_CELL}/CONSTRAINTS/${DESIGN}_func_set_case_analysis.sdc
::octopusRC::set_case_analysis --tcb-td-file <TCB's test data file> --mode intest_logic_scan_stuckat --constraint-file ${DATA_PATH}/${CRT_LIB}/${CRT_CELL}/CONSTRAINTS/${DESIGN}_scan_set_case_analysis.sdc
################################################################################

################################################################################
puts "\n>> Read CPF in, thus power information, modes and constraints"
################################################################################
::octopusRC::read_cpf --design $DESIGN --reports-path $_REPORTS_PATH --cpf $_CPF_FILE

set design_modes [find /designs/${DESIGN}/ -vname -mode *]
puts "Created modes :    ${design_modes}"

display_message warning "Rumours say that displaying \$::dc::sdc_failed_commands might be wrong"
puts $::dc::sdc_failed_commands

foreach current_design_mode ${design_modes} {
	puts "Report timing for design mode: $current_design_mode"
	# Some modes are not found. Until we understand what is happening catch the error so RC continues
	if { [ catch {report timing -lint -mode [file tail $current_design_mode] >  ${_REPORTS_PATH}/${DESIGN}_${current_design_mode}_premap_timing.rpt} ] } {
		display_message error "Failed to generate report timing for $current_design_mode"
	}
}
################################################################################


################################################################################
puts ">> Define DFT and clock gating"
################################################################################
include dft_settings.tcl

include clock_gating_settings.tcl
################################################################################


################################################################################
puts ">> Synthesizing to generic"
################################################################################
include design_constraints.tcl

# Specify the effort required for Generic Synthesis. It is recommended to
# specify medium for Generic and non incremental synthesis for the first run
::octopusRC::synthesize --type to_generic --design $DESIGN --reports-path $_REPORTS_PATH
################################################################################


################################################################################
puts ">> Synthesizing to gates"
################################################################################
::octopusRC::synthesize --type to_mapped --design $DESIGN --reports-path $_REPORTS_PATH
################################################################################


################################################################################
puts ">> Connect scan chains"
################################################################################
include connect_scan_chains.tcl

::octopusRC::write --current-state mapped_scn
################################################################################


################################################################################
puts ">> Incremental Synthesis"
################################################################################
include design_constraints_incremental.tcl

delete_unloaded_undriven -all -force_bit_blast ${DESIGN}

::octopusRC::synthesize --type to_mapped_incremental --design $DESIGN --reports-path $_REPORTS_PATH


# Due to remove_assigns we might have crossing from DfT to AO like the signal going from
# iphgrf_jhxcv1_0/u0_iphgrf_jhxcv1_dig/clk_cp to iphgrf_jhxcv1_0/u0_iphgrf_jhxcv1_shell/clk_cp
# Thus commit the CPF later.
# This solves also the ports not deleted by delete_unloaded_undriven_new procedure at the power domain crossing
reload_cpf
commit_cpf
#verify_power_structure
report isolation -hier -detail > $_REPORTS_PATH/${DESIGN}_isolation_after_scan_insertion.rpt

::octopusRC::write --current-state scn

report_attributes  \
	--attributes power_domain \
	--objects [find / -instance *] \
	> ./rpt/${DESIGN}_instances_power_domains.rpt

write_sdf -delimiter "." -edges check_edge > generated/${DESIGN}_netlist_scn.sdf

::octopusRC::generate_list_of_clock_inverters_for_dft_shell > generated/dftshell_inverters_list.tcl

puts "Final Runtime & Memory."
timestat FINAL
puts "============================"
puts "Synthesis Finished ........."
puts "============================"

### report power -mode PM_dft_Off_MTP_Off_sleep   > ./rpt/power_sleep.rpt
### report power -mode PM_dft_Off_MTP_Off_standby > ./rpt/power_standby.rpt
### report power -mode PM_dft_Off_MTP_Off_normal  > ./rpt/power_normal.rpt
################################################################################


################################################################################
summary_of_messages error warning fixme workaround

if { ! [info exists env(RC_ESD_CONTINUE)] || "$env(RC_ESD_CONTINUE)" != "true" } {
	display_message info "RC suspended"
	display_message none "    by typing resume you will DELETE ALL DIGITAL, leaving only analog cells"
	display_message none "    this is done to generate the netlist used for 'ESD' simulations"
	display_message none ""
	display_message tip "If you never want to stop here, then set the environmental variable RC_ESD_CONTINUE to true"
	display_message none "  export RC_ESD_CONTINUE=true"
	flush stdout ; # write all log until now on disk
	suspend
}
################################################################################


################################################################################
display_message info "Generating ESD netlist"
################################################################################
set_attribute ui_respects_preserve false /
rm dft/*/*

include define_analog_instances.tcl

foreach avoided_analog_inst $AO_analog_inst_all {
	puts "Not regrouped: ${avoided_analog_inst}"
}
advanced_recursive_grouping \
	--group-children-of-instances  [find / -instance -maxdepth  4 *] \
	--exclude-parents-of-instances $AO_analog_inst_all \
	--debug-level 2

cd /
rm [find / -instance *new_Inst_group_sw_domain_*]

write_hdl >  ${DATA_PATH}/${CRT_LIB}/${CRT_CELL}/NETLIST/${DESIGN}_netlist_ESD_sim.v
display_message info "As requested, all digital logic has just been deleted"
################################################################################
