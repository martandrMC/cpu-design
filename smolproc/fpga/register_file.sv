module register_file(
	input sig_clk,

	input [1:0] ID_addr_read_a, ID_addr_read_b,
	output [7:0] ID_data_read_a, ID_data_read_b,

	input [1:0] DM_addr_write,
	input [7:0] DM_data_write,
	input DM_sig_write
);

reg [7:0] regfile [3:0];
wire sig_fw_a = &( DM_addr_write ~^ ID_addr_read_a ) & DM_sig_write;
wire sig_fw_b = &( DM_addr_write ~^ ID_addr_read_b ) & DM_sig_write;

always_ff @( posedge sig_clk ) begin
	if(DM_sig_write) regfile[DM_addr_write] <= DM_data_write;
end

always_comb begin
	if(sig_fw_a) ID_data_read_a = DM_data_write;
	else ID_data_read_a = regfile[ID_addr_read_a];

	if(sig_fw_b) ID_data_read_b = DM_data_write;
	else ID_data_read_b = regfile[ID_addr_read_b];
end

endmodule
