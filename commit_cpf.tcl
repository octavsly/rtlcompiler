reload_cpf
commit_cpf
#verify_power_structure
report isolation -hier -detail > $_REPORTS_PATH/${DESIGN}_isolation_after_scan_insertion.rpt

::octopusRC::write --stage scn --change-names

if { "$::octopusRC::run_speed" != "fast"} {
::octopusRC::report_attributes  \
	--attributes power_domain \
	--objects [find / -instance *] \
	> ${_REPORTS_PATH}/${DESIGN}_instances_power_domains.rpt
}

write_sdf -delimiter "." -edges check_edge > generated/${DESIGN}_netlist_scn.sdf