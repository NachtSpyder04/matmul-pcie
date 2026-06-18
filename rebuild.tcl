create_project mat_mul_test ./mat_mul_test -part xc7a100tfgg484-2L

# RTL
add_files ./rtl/mat_mul.v
add_files ./rtl/row_col.v
add_files ./rtl/mat_mul_wrapper.v

# Constraints
add_files -fileset constrs_1 ./constraints/normal_constraints.xdc
add_files -fileset constrs_1 ./constraints/late_constraints.xdc

update_compile_order -fileset sources_1

# Build BD
source ./bd/design_1.tcl

# Save project
save_project_as mat_mul_test