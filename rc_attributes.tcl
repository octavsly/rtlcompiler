::octopusRC::set_design_maturity_level\
	--maturity-level ${maturity-level} \
	--rc-attributes-file rc_attributes.txt

set_attribute super_thread_batch_command		{bsub -o /dev/null -J RC_server}
set_attribute super_thread_kill_command 		{bkill}
shell mkdir -p /home/scratch/$env(USER)
set_attribute super_thread_cache			/home/scratch/$env(USER)
set_attribute super_thread_servers 			{localhost localhost localhost localhost}

# Search on support.cadence.com "RC can't find a pin specified in SDC file" or just "hdl_rename_cdn_flop_pins"
# TCB procedure will return Q instead of q
set hdl_rename_cdn_flop_pins {{q Q} {d D} {clk CP}}
set_attribute truncate false [find / -message TUI-6]
