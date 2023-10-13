module clk_divider(
	input sig_clk,
	output sig_clk_div
);

reg [7:0] cnt;

assign sig_clk_div = cnt[7];

always_ff @( posedge sig_clk ) cnt <= cnt + 8'h01;

endmodule