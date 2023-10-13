module fetch_stage(
	input sig_clk,

	output reg [7:0] ID_addr_pgm,
	
	input [7:0] EX_addr_jmp,
	input EX_sig_jmp,

	output [7:0] DM_addr_pgm
);

reg [7:0] prog_cnt;

assign DM_addr_pgm = prog_cnt;

always_ff @( posedge sig_clk ) begin
	if(EX_sig_jmp) prog_cnt <= EX_addr_jmp;
	else prog_cnt <= prog_cnt + 8'h01;

	ID_addr_pgm <= prog_cnt + 8'h01;
end

endmodule
