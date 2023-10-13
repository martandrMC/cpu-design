module output_module #(
	parameter [7:0] TARGET_ADDR = 8'hFF
)(
	input sig_clk,
	
	input [7:0] EX_data, EX_addr,
	input [1:0] EX_sig_ctrl_DM,

	output reg [7:0] IO_data_out,
	output [1:0] DM_sig_ctrl_DM
);

wire sig_active = & (EX_addr ~^ TARGET_ADDR);

assign DM_sig_ctrl_DM = {EX_sig_ctrl_DM[1], EX_sig_ctrl_DM[0] & ~sig_active};

always_ff @( posedge sig_clk ) begin
	if(sig_active) IO_data_out <= EX_data;
end

endmodule
