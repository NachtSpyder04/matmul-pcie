# Late constraints

# PCIe lane 0
set_property PACKAGE_PIN A10 [get_ports {pcie_mgt_rxn[0]}]
set_property PACKAGE_PIN B10 [get_ports {pcie_mgt_rxp[0]}]
set_property PACKAGE_PIN A6 [get_ports {pcie_mgt_txn[0]}]
set_property PACKAGE_PIN B6 [get_ports {pcie_mgt_txp[0]}]

# PCIe refclock
set_property PACKAGE_PIN F6 [get_ports {pcie_clkin_clk_p[0]}]
set_property PACKAGE_PIN E6 [get_ports {pcie_clkin_clk_n[0]}]

# Other PCIe signals
set_property PACKAGE_PIN G1 [get_ports {pcie_clkreq_l[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pcie_clkreq_l[0]}]

set_property PACKAGE_PIN J1 [get_ports pcie_reset]
set_property IOSTANDARD LVCMOS33 [get_ports pcie_reset]