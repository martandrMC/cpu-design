module forwarding_unit(
	input [7:0] EX_data_write,
	input [1:0] EX_addr_write,
	input EX_sig_write,

	input [7:0] DM_data_write,
	input [1:0] DM_addr_write,
	input DM_sig_write,

	input [7:0] ID_data_a, ID_data_b,
	input [1:0] ID_addr_a, ID_addr_b,

	output [7:0] EX_data_fw_a, EX_data_fw_b
);

wire EX_hazard_a = & (ID_addr_a ~^ EX_addr_write) & EX_sig_write;
wire EX_hazard_b = & (ID_addr_b ~^ EX_addr_write) & EX_sig_write;
wire DM_hazard_a = & (ID_addr_a ~^ DM_addr_write) & DM_sig_write;
wire DM_hazard_b = & (ID_addr_b ~^ DM_addr_write) & DM_sig_write;

always_comb begin
	if(EX_hazard_a | DM_hazard_a) begin
		if(EX_hazard_a) EX_data_fw_a = EX_data_write;
		else EX_data_fw_a = DM_data_write;
	end else EX_data_fw_a = ID_data_a;

	if(EX_hazard_b | DM_hazard_b) begin
		if(EX_hazard_b) EX_data_fw_b = EX_data_write;
		else EX_data_fw_b = DM_data_write;
	end else EX_data_fw_b = ID_data_b;
end

endmodule
