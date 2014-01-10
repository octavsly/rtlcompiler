################################################################################
# clock gating settings
################################################################################
# It will only use clock gating cells with observation capability for FC increase.
set_attribute lp_clock_gating_add_obs_port true ${DESIGN}

#set_attribute lp_clock_gating_exclude true [get_attribute instances [find / -subdesign $TAP_design]]
#set_attribute lp_clock_gating_exclude true [get_attribute instances [find / -subdesign <rcgu>]]
set_attribute lp_clock_gating_exclude true $diehardus::TCBs(module)
set_attribute lp_clock_gating_exclude true $diehardus::TPRs(module)

set_attribute lp_clock_gating_test_signal /designs/$DESIGN/dft/test_signals/[file tail $diehardus::scan_enable_clock_gate]  $DESIGN

::octopus::display_message tip "If stuckat FC is low ==> exclude clock gating from switchable domains"
#set_attribute lp_clock_gating_exclude true [filter power_domain /designs/$DESIGN/power/power_domains/<PD_dft_PSO> [find / -inst *]]
