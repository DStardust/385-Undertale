
module lab9_soc (
	clk_clk,
	keycode_export,
	otg_hpi_address_export,
	otg_hpi_cs_export,
	otg_hpi_data_in_port,
	otg_hpi_data_out_port,
	otg_hpi_r_export,
	otg_hpi_reset_export,
	otg_hpi_w_export,
	reset_reset_n,
	sdram_clk_clk,
	sdram_wire_addr,
	sdram_wire_ba,
	sdram_wire_cas_n,
	sdram_wire_cke,
	sdram_wire_cs_n,
	sdram_wire_dq,
	sdram_wire_dqm,
	sdram_wire_ras_n,
	sdram_wire_we_n,
	vga_port_red,
	vga_port_green,
	vga_port_blue,
	vga_port_hs,
	vga_port_vs,
	vga_port_blank,
	vga_port_pixel_clk,
	vga_port_sync,
	vga_port_status,
	vga_port_keycode);	

	input		clk_clk;
	output	[7:0]	keycode_export;
	output	[1:0]	otg_hpi_address_export;
	output		otg_hpi_cs_export;
	input	[15:0]	otg_hpi_data_in_port;
	output	[15:0]	otg_hpi_data_out_port;
	output		otg_hpi_r_export;
	output		otg_hpi_reset_export;
	output		otg_hpi_w_export;
	input		reset_reset_n;
	output		sdram_clk_clk;
	output	[12:0]	sdram_wire_addr;
	output	[1:0]	sdram_wire_ba;
	output		sdram_wire_cas_n;
	output		sdram_wire_cke;
	output		sdram_wire_cs_n;
	inout	[31:0]	sdram_wire_dq;
	output	[3:0]	sdram_wire_dqm;
	output		sdram_wire_ras_n;
	output		sdram_wire_we_n;
	output	[7:0]	vga_port_red;
	output	[7:0]	vga_port_green;
	output	[7:0]	vga_port_blue;
	output		vga_port_hs;
	output		vga_port_vs;
	output		vga_port_blank;
	output		vga_port_pixel_clk;
	output		vga_port_sync;
	input	[3:0]	vga_port_status;
	input	[7:0]	vga_port_keycode;
endmodule
