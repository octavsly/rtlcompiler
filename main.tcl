#!/bin/sh
# the next line restarts using -*-Tcl-*-sh \
exec rc -64 -logfile rc.log -cmdfile rc.cmd -overwrite -f "$0" -execute "set argv \"\" ; set argv ${1+\"$@\"} ; set prog_name $0; set_attribute source_verbose true; set_attribute source_verbose_proc true ; set_attribute source_verbose_info true"

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
set var_array(40,_NETLIST_PATH)		[list "--netlist-path" "${DATA_PATH}/${CRT_LIB}/${CRT_CELL}/NETLIST" "string" "1" "1" "" "Directory holding the reports."]
set var_array(50,_CPF_FILE)		[list "--cpf" "${DATA_PATH}/${CRT_LIB}/${CRT_CELL}/POWER/${CRT_CELL}.cpf" "string" "1" "1" "" "CPF file location."]
set var_array(60,clean-rpt)		[list "--clean-rpt" "false" "boolean" "" "" "" "Clean all reports before the run."]
set var_array(90,run-speed)		[list "--run-speed" "slow" "string" "1" "1" "slow fast" "If set to fast a lot of reports will be skipped"]

set ::octopus::prog_name $prog_name

::octopus::extract_check_options_data

::octopus::abort_on error --display-help

################################################################################
puts "\n>> Attributes"
################################################################################
include rc_attributes.tcl
################################################################################


################################################################################
puts "\n>> House keeping"
################################################################################
include house_keeping.tcl
################################################################################


################################################################################
puts "\n>>  Library (including dont_use) and ple setup"
################################################################################
read_cpf -library $_CPF_FILE

include dont_use_list.tcl

include ple_setup.tcl
################################################################################


################################################################################
puts "\n>>  Read, Elaborate and Check the Design"
################################################################################
include read_hdl.tcl 

::octopusRC::elaborate
################################################################################

################################################################################
puts "\n>>  Generate set_case_analysis statements from TCB test data files"
################################################################################
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
################################################################################

################################################################################
puts "\n>> Read CPF in, thus power information, modes and constraints"
################################################################################
::octopusRC::read_cpf --cpf $_CPF_FILE
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
::octopusRC::synthesize --type to_generic 
################################################################################


################################################################################
puts ">> Synthesizing to gates"
################################################################################
::octopusRC::synthesize --type to_mapped 
################################################################################


################################################################################
puts ">> Connect scan chains"
################################################################################
include connect_scan_chains.tcl

::octopusRC::write --stage mapped_scn 
################################################################################


################################################################################
puts ">> Incremental Synthesis"
################################################################################
include design_constraints_incremental.tcl

::octopusRC::delete_unloaded_undriven 

::octopusRC::synthesize --type to_mapped_incremental 


# Due to remove_assigns we might have crossing from DfT to AO like the signal going from
# iphgrf_jhxcv1_0/u0_iphgrf_jhxcv1_dig/clk_cp to iphgrf_jhxcv1_0/u0_iphgrf_jhxcv1_shell/clk_cp
# Thus commit the CPF later.
# This solves also the ports not deleted by delete_unloaded_undriven_new procedure at the power domain crossing
reload_cpf
commit_cpf
#verify_power_structure
report isolation -hier -detail > $_REPORTS_PATH/${DESIGN}_isolation_after_scan_insertion.rpt

::octopusRC::write --stage scn --change-names

::octopusRC::report_attributes  \
	--attributes power_domain \
	--objects [find / -instance *] \
	> ${_REPORTS_PATH}/${DESIGN}_instances_power_domains.rpt

write_sdf -delimiter "." -edges check_edge > generated/${DESIGN}_netlist_scn.sdf

# Not necessary since dft_shell 9.5 can deal with neg-edge FF's
#::octopusRC::generate_list_of_clock_inverters_for_dft_shell > generated/dftshell_inverters_list.tcl

puts "Final Runtime & Memory."
timestat FINAL
puts "============================"
puts "Synthesis Finished ........."
puts "============================"
################################################################################


################################################################################
::octopus::summary_of_messages error warning fixme workaround

if { ! [info exists env(RC_ESD_CONTINUE)] || "$env(RC_ESD_CONTINUE)" != "true" } {
	::octopus::display_message info "RC suspended"
	::octopus::display_message none "    by typing resume you will DELETE ALL DIGITAL, leaving only analog cells"
	::octopus::display_message none "    this is done to generate the netlist used for 'ESD' simulations"
	::octopus::display_message none ""
	::octopus::display_message tip "If you never want to stop here, then set the environmental variable RC_ESD_CONTINUE to true"
	::octopus::display_message none "  export RC_ESD_CONTINUE=true"
	flush stdout ; # write all log until now on disk
	suspend
}
################################################################################


################################################################################
::octopus::display_message info "Generating ESD netlist"
################################################################################
set_attribute ui_respects_preserve false /
rm dft/*/*

include define_analog_instances.tcl

foreach avoided_analog_inst $AO_analog_inst_all {
	puts "Not regrouped: ${avoided_analog_inst}"
}
::octopusRC::advanced_recursive_grouping \
	--group-children-of-instances  [find / -instance -maxdepth  4 *] \
	--exclude-parents-of-instances $AO_analog_inst_all \
	--debug-level 2

cd /
rm [find / -instance *new_Inst_group_sw_domain_*]

write_hdl >  ${DATA_PATH}/${CRT_LIB}/${CRT_CELL}/NETLIST/${DESIGN}_netlist_ESD_sim.v
::octopus::display_message info "As requested, all digital logic has just been deleted"
################################################################################
