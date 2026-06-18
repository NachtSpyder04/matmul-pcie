# Create project
create_project mat_mul_test ./mat_mul_test -part xc7a100tfgg484-2L

# RTL sources
add_files ./rtl/mat_mul.v
add_files ./rtl/row_col.v
add_files ./rtl/mat_mul_wrapper.v

# Constraints
add_files -fileset constrs_1 ./constraints/normal_constraints.xdc
add_files -fileset constrs_1 ./constraints/late_constraints.xdc

# Create block design
source ./bd/design_1.tcl

# Generate BD outputs
generate_target all [get_files design_1.bd]

# Create HDL wrapper
make_wrapper -files [get_files design_1.bd] -top

# Add generated wrapper
add_files -norecurse \
[get_files ./mat_mul_test/mat_mul_test.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v]

# Set top
set_property top design_1_wrapper [current_fileset]

update_compile_order -fileset sources_1

save_project_as mat_mul_pcie
