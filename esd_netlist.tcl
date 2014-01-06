# ESD netlist is used for ESD simulations with the analog modules. All digital logic is hust removed

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

set_attribute ui_respects_preserve false /
rm dft/*/*

set AO_analog_inst_all ""

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

