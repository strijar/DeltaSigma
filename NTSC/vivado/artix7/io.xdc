
set_property PACKAGE_PIN N11 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

set_property PACKAGE_PIN K5 [get_ports reset_n]
set_property IOSTANDARD LVCMOS33 [get_ports reset_n]

set_property PACKAGE_PIN A7 [get_ports dout]
set_property IOSTANDARD LVCMOS33 [get_ports dout]

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

