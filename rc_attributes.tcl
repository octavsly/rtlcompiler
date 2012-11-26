::octopusRC::set_design_maturity_level\
	--maturity-level ${maturity-level} \
	--rc-attributes-file rc_attributes.txt

set_attribute super_thread_batch_command		{bsub -o /dev/null -J RC_server}
set_attribute super_thread_kill_command 		{bkill}
shell mkdir -p /home/scratch/$env(USER)
set_attribute super_thread_cache			/home/scratch/$env(USER)
set_attribute super_thread_servers 			{localhost localhost localhost localhost}

set_attribute truncate false [find / -message TUI-6]
