# More information searching "What value should be set for “max_leakage_power” attribute?" on support.cadence.com
set_attribute	lp_multi_vt_optimization_effort		medium
set_attribute	lp_power_optimization_weight		0.3	${DESIGN}

# pre-alpha is know to have plenty of missing blocks, which should not be optimized away
if { "[get_attribute octopusRC_design_maturity_level /]" == "pre-alpha" } { set_attribute boundary_opto false [find /des* -subdesign *] }

#set preserve to sparecells
#set_attribute preserve true [filter -invert flop "true" [find / -instance iphgrf_asdof1_1/u_iphgrf_asdof1_dig/u0_iphgrf_asdof1_dig_pso/u0_iphgrf_sparelogic/*]]

# Metal programable cells. Need to be preserved.
#set_attribute preserve true [find / -subdesign *filter_up*]
# Observable ports
#set_attribute preserve true [find I0/u0_hrxc_ic_core_test/*bolton*/ -pin observe_out*]

# Allow more aggressive optimization for redundancy removal.
#set_attribute boundary_optimize_invert_hier_pins 	true  [find / -subdes hrxc_ic_core_func]

# Avoid signals (e.g. clocks) passing around some modules
#set_attribute boundary_optimize_feedthrough_hier_pins 	false [find / -subdes iphgrf_jhxcv1_dig ]

# RC 11 seems to optimize better the feedthrough of hierarchical pins. This is not nice for TCB's.
# One example is the tcb_capture which disappears from tcbreg_inst. dft_shell complains since the test-data
# is not in sync with the design
#set_attribute boundary_opto false [find / -subdes ${DESIGN}_core_test_on_tcbreg]

# Autoungroup is a nice feature but it is too aggressive. It ungroups instances in the CPF, thus
# CPF is not valid anymore after synthesis. Until we find a more tuned solution, use this brute force attribute
# It should be mentioned that auto_aungroup is active only in optimization high
set_attribute auto_ungroup none  /