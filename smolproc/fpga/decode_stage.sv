module decode_stage(
	input sig_clk,
	output sig_hlt,

	input [7:0] IF_addr_pgm,

	input [7:0] RF_data_read_a, RF_data_read_b,
	output [1:0] RF_addr_read_a, RF_addr_read_b,

	output reg [7:0] EX_addr_pgm,
	output [6:0] EX_sig_ctrl_EX,
	output [1:0] EX_sig_ctrl_DM,
	output EX_sig_ctrl_RF,

	output reg [7:0] FW_data_a, FW_data_b,
	output reg [1:0] EX_FW_addr_a, FW_addr_b,

	input [7:0] DM_data_pgm
);

always_ff @( posedge sig_clk ) begin
	FW_data_a <= RF_data_read_a;
	FW_data_b <= RF_data_read_b;
	EX_addr_pgm <= IF_addr_pgm;
	EX_FW_addr_a <= DM_data_pgm[1:0];
	FW_addr_b <= DM_data_pgm[3:2];
end

wire instr_type = ~& DM_data_pgm[7:6];
wire [4:0] instr_id;

assign RF_addr_read_a = DM_data_pgm[1:0];
assign RF_addr_read_b = DM_data_pgm[3:2];

always_comb begin
	instr_id[4] = instr_type;
	if(instr_type) instr_id[3:0] = DM_data_pgm[7:4];
	else instr_id[3:0] = DM_data_pgm[5:2];
end

control_rom _rom(
	.sig_clk(sig_clk),
	.sig_hlt(sig_hlt),
	.addr_instr_code(instr_id),
	.sig_ctrl_EX(EX_sig_ctrl_EX),
	.sig_ctrl_DM(EX_sig_ctrl_DM),
	.sig_ctrl_RF(EX_sig_ctrl_RF)
);

endmodule

module control_rom(
	input sig_clk,
	output sig_hlt,

	input [4:0] addr_instr_code,

	output [6:0] sig_ctrl_EX,
	output [1:0] sig_ctrl_DM,
	output sig_ctrl_RF
);

reg [11:0] ctrl_word;

assign sig_ctrl_EX = ctrl_word[6:0];
assign sig_ctrl_RF = ctrl_word[7];
assign sig_ctrl_DM = ctrl_word[9:8];
assign sig_hlt = ctrl_word[11];

always_ff @( posedge sig_clk ) begin
	if(ctrl_word[10]) ctrl_word <= 12'h000;
	else begin
		case(addr_instr_code)
			5'h00: ctrl_word <= 12'h088;
			5'h01: ctrl_word <= 12'h089;
			5'h02: ctrl_word <= 12'h490;
			5'h03: ctrl_word <= 12'h494;

			5'h04: ctrl_word <= 12'h10C;
			5'h05: ctrl_word <= 12'h28D;
			5'h06: ctrl_word <= 12'h00F;
			5'h07: ctrl_word <= 12'h472;

			5'h08: ctrl_word <= 12'h0C0;
			5'h09: ctrl_word <= 12'h069;
			5'h0A: ctrl_word <= 12'h471;
			5'h0B: ctrl_word <= 12'h473;

			5'h0C: ctrl_word <= 12'h530;
			5'h0D: ctrl_word <= 12'h6B0;
			5'h0E: ctrl_word <= 12'h4B0;
			5'h0F: ctrl_word <= 12'h800;
			
			5'h10: ctrl_word <= 12'h080;
			5'h11: ctrl_word <= 12'h082;
			5'h12: ctrl_word <= 12'h081;
			5'h13: ctrl_word <= 12'h083;

			5'h14: ctrl_word <= 12'h084;
			5'h15: ctrl_word <= 12'h085;
			5'h16: ctrl_word <= 12'h086;
			5'h17: ctrl_word <= 12'h087;

			5'h18: ctrl_word <= 12'h08A;
			5'h19: ctrl_word <= 12'h463;
			5'h1A: ctrl_word <= 12'h520;
			5'h1B: ctrl_word <= 12'h6A0;

			default: ctrl_word <= 12'h000;
		endcase
	end
end

endmodule
