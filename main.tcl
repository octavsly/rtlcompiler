#!/bin/sh
# the next line restarts using -*-Tcl-*-sh \
exec rc -64 -logfile rc.log -cmdfile rc.cmd -overwrite -f "$0" -execute "set argv \"\" ; set argv ${1+\"$@\"} ; set prog_name $0; set_attribute source_verbose true; set_attribute source_verbose_proc true ; set_attribute source_verbose_info true"

#This is the main RC script. It will source other files

if { [info exists env(OCTOPUS_INSTALL_PATH) ] } {
        lappend auto_path $env(OCTOPUS_INSTALL_PATH)
} else {
        puts "ERROR: Please set environmental variable OCTOPUS_INSTALL_PATH to point to the location of octopus.tcl file"
        exit 1
}


package require octopusRC 0.1
package require octopus   0.1
# Not importing functions due to potential conflict with RC
#namespace import ::octopusRC::*
#namespace import ::octopus::*
#::octopus::set_octopus_color --disable

set EXEC_PATH "" ; set DATA_PATH "" ; set CRT_LIB "" ; set CRT_CELL "" ; regexp {(.*/data/)([^/]+_lib)/([^/]+)/.*} [exec pwd] EXEC_PATH DATA_PATH CRT_LIB CRT_CELL
::octopus::add_option --name "--maturity-level" --valid-values "pre-alpha alpha beta release-candidate final" --help-text "Maturity level of the design."
::octopus::add_option --name "--design" --variable-name "DESIGN" --default "$CRT_CELL" --help-text "Top level design for which synthesis will be performed."
::octopus::add_option --name "--reports-path" --variable-name "_REPORTS_PATH" --default "[exec pwd]/rpt" --help-text "Directory holding the reports."
::octopus::add_option --name "--netlist-path" --variable-name "_NETLIST_PATH" --default "${DATA_PATH}/${CRT_LIB}/${CRT_CELL}/NETLIST" --help-text "Directory holding the netlist."
::octopus::add_option --name "--cpf" --variable-name "_CPF_FILE" --default "${DATA_PATH}/${CRT_LIB}/${CRT_CELL}/POWER/${CRT_CELL}.cpf" --help-text "CPF file location."
::octopus::add_option --name "--clean-rpt" --type "boolean" --default "false" --help-text "Clean all reports before the run. Otherwise reports are cleaned one by one."
::octopus::add_option --name "--run-speed" --default "slow" --valid-values "slow fast" --help-text "If set to fast a lot of reports will be skipped."

set ::octopus::prog_name $prog_name

::octopus::extract_check_options_data

::octopus::abort_on error --display-help


################################################################################
include ./design_specific_input.tcl
################################################################################


################################################################################
# Setting RC attributes
include rc_attributes.tcl
################################################################################


################################################################################
# Creating directories, cleaning files etc.
include house_keeping.tcl
################################################################################


################################################################################
#Library (including dont_use) and ple setup"
read_cpf -library $_CPF_FILE

include dont_use_list.tcl

include ple_setup.tcl
################################################################################


################################################################################
# Read, Elaborate and Check the Design"
include read_hdl.tcl

::octopusRC::elaborate
################################################################################


################################################################################
# Generate automatic constraints
include generate_constraints.tcl
################################################################################


################################################################################
#Read CPF in: power information, modes and constraints"
::octopusRC::read_cpf --cpf $_CPF_FILE
################################################################################


################################################################################
#Define DFT and clock gating"
include dft_settings.tcl

include clock_gating_settings.tcl
################################################################################


################################################################################
#Synthesizing to generic
include design_constraints.tcl
################################################################################


################################################################################
# synthesize. Different levels are picked based on design maturity level
::octopusRC::synthesize -to_generic
################################################################################


################################################################################
#Synthesizing to gates
::octopusRC::synthesize -to_mapped
################################################################################


################################################################################
#Connect scan chains
include connect_scan_chains.tcl
################################################################################


################################################################################
#Incremental Synthesis
include design_constraints_incremental.tcl

::octopusRC::delete_unloaded_undriven 

::octopusRC::synthesize -to_mapped -incremental
################################################################################


################################################################################
# Commit cpf
# This solves also the ports not deleted by delete_unloaded_undriven_new procedure at the power domain crossing
include ./commit_cpf.tcl
################################################################################


::octopus::summary_of_messages error warning fixme workaround


################################################################################
include ./esd_netlist.tcl
################################################################################

