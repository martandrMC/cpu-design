module memory_stage(
	input sig_clk,

	input [7:0] IF_addr_pgm,

	output reg [1:0] RF_addr_write,
	output [7:0] RF_data_write,
	output reg RF_sig_ctrl_RF,

	output reg [7:0] ID_EX_data_pgm,

	input [7:0] EX_data_result, EX_data_reg,
	input [1:0] EX_addr_reg, EX_sig_ctrl_DM,
	input EX_sig_ctrl_RF
);

(* ram_init_file = "dedotated_wam.mif" *) reg [7:0] dedotated_wam [255:0];
reg [7:0] data_membuf, data_resbuf;
reg sig_select;

always_ff @( posedge sig_clk ) begin
	RF_sig_ctrl_RF <= EX_sig_ctrl_RF;
	RF_addr_write <= EX_addr_reg;
	data_resbuf <= EX_data_result;
	sig_select <= EX_sig_ctrl_DM[1];

	ID_EX_data_pgm <= dedotated_wam[IF_addr_pgm];
	data_membuf <= dedotated_wam[EX_data_result];
	if(EX_sig_ctrl_DM[0]) dedotated_wam[EX_data_result] <= EX_data_reg;
end

always_comb begin
	if(sig_select) RF_data_write = data_membuf;
	else RF_data_write = data_resbuf;
end

endmodule
