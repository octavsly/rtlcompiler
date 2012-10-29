# Allow removal of assign statements in incremental optimization
set_attribute remove_assigns true /
set_remove_assign_options \
        -ignore_preserve_setting \
        -verbose

# Activate these multi-output cells. The tool will not pick them unless both
# outputs are used.
# iopt_enable_floating_output_check attribute make sure that no outputs are unconnected
# Thus no need to exclude them
set_attribute iopt_enable_floating_output_check true /
#set_attribute avoid false ${targetLibrary}${refCase}/lbrcHA*
#set_attribute avoid false ${targetLibrary}${refCase}/lbrcFA*

set_attribute iopt_force_constant_removal true /
# Allow tie connections in incremental optimization
#set_attribute -quiet avoid false [find -libcell lbrcTOLX7]
#set_attribute -quiet avoid false [find -libcell lbrcTOHX7]

set_attribute use_tiehilo_for_const unique /