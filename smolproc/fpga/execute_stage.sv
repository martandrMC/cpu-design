module execute_stage(
	input sig_clk,

	output [7:0] IF_addr_jmp,
	output IF_sig_jmp,

	input [7:0] ID_addr_pgm,
	input [6:0] ID_sig_ctrl_EX,
	input [1:0] ID_sig_ctrl_DM, ID_addr_a,
	input ID_sig_ctrl_RF,

	input [7:0] FW_data_fw_a, FW_data_fw_b,

	input [7:0] DM_data_imm,
	output reg [7:0] FW_DM_data_result, DM_data_reg,
	output reg [1:0] FW_DM_addr_reg, DM_sig_ctrl_DM,
	output reg FW_DM_sig_ctrl_RF
);

always_ff @( posedge sig_clk ) begin
	DM_data_reg <= FW_data_fw_a;
	FW_DM_sig_ctrl_RF <= ID_sig_ctrl_RF;
	DM_sig_ctrl_DM <= ID_sig_ctrl_DM;
	FW_DM_addr_reg <= ID_addr_a;
end

reg flag;

wire [7:0] data_comb_b, data_alu, data_addrgen;
wire [7:0] data_result_arithm, data_result_logic, data_result_shift, data_result_stack;
wire sig_flag_arithm, sig_flag_shift, sig_condition;

assign IF_sig_jmp = & ID_sig_ctrl_EX[6:5] & sig_condition;

always_ff @( posedge sig_clk ) begin
	if(~| ID_sig_ctrl_EX[6:5] & ~ID_sig_ctrl_EX[2]) begin
		if(ID_sig_ctrl_EX[3]) flag = sig_flag_shift;
		else flag = sig_flag_arithm;
	end

	if(ID_sig_ctrl_EX[6]) begin
		if(ID_sig_ctrl_EX[5]) FW_DM_data_result <= 8'h00;
		else FW_DM_data_result <= ID_addr_pgm;
	end else begin
		if(ID_sig_ctrl_EX[5]) FW_DM_data_result <= data_addrgen;
		else FW_DM_data_result <= data_alu;
	end
end

always_comb begin
	if(ID_sig_ctrl_EX[4]) data_comb_b = DM_data_imm;
	else data_comb_b = FW_data_fw_b;

	if(ID_sig_ctrl_EX[3]) begin
		if(ID_sig_ctrl_EX[2]) data_alu = data_result_stack;
		else data_alu = data_result_shift;
	end else begin
		if(ID_sig_ctrl_EX[2]) data_alu = data_result_logic;
		else data_alu = data_result_arithm;
	end

	if(ID_sig_ctrl_EX[4]) data_addrgen = DM_data_imm;
	else data_addrgen = DM_data_imm + data_comb_b;

	if(ID_sig_ctrl_EX[3]) IF_addr_jmp = FW_data_fw_a;
	else IF_addr_jmp = data_addrgen;

	if(ID_sig_ctrl_EX[1]) begin
		if(ID_sig_ctrl_EX[0]) sig_condition = ~| FW_data_fw_a;
		else sig_condition = flag;
	end else sig_condition = ID_sig_ctrl_EX[0];
end

alu_arithmetic _arithm(
	.sig_ctrl(ID_sig_ctrl_EX[1:0]),
	.data_a(FW_data_fw_a), 
	.data_b(data_comb_b),
	.sig_flag(flag),
	.data_result(data_result_arithm),
	.sig_flag_new(sig_flag_arithm)
);

alu_logic _logic(
	.sig_ctrl(ID_sig_ctrl_EX[1:0]),
	.data_a(FW_data_fw_a),
	.data_b(data_comb_b),
	.data_result(data_result_logic)
);

alu_shift _shift(
	.sig_ctrl(ID_sig_ctrl_EX[1:0]),
	.data_a(FW_data_fw_a),
	.data_b(data_comb_b),
	.sig_flag(flag),
	.data_result(data_result_shift),
	.sig_flag_new(sig_flag_shift)
);

stack _stack(
	.sig_clk(sig_clk),
	.sig_ctrl(ID_sig_ctrl_EX[3:0]),
	.data_a(FW_data_fw_a),
	.data_result(data_result_stack)
);

endmodule

module alu_arithmetic(
	input [1:0] sig_ctrl,
	input [7:0] data_a, data_b,
	input sig_flag,

	output [7:0] data_result,
	output sig_flag_new
);

wire [7:0] data_b_cinv = data_b ^ {8{sig_ctrl[0]}};
wire carry_in;

always_comb begin
	if(sig_ctrl[1]) carry_in = sig_flag;
	else carry_in = sig_ctrl[0];
	{sig_flag_new, data_result} = {1'b0, data_a} + {1'b0, data_b_cinv} + carry_in;
end

endmodule

module alu_logic(
	input [1:0] sig_ctrl,
	input [7:0] data_a, data_b,

	output [7:0] data_result
);

wire [7:0] data_or = data_a | data_b;
wire [7:0] data_and = data_a & data_b;
wire [7:0] data_xor = data_a ^ data_b;
wire [7:0] data_nor = ~(data_or);

always_comb begin
	if(sig_ctrl[1]) begin
		if(sig_ctrl[0]) data_result = data_xor;
		else data_result = data_nor;
	end else begin
		if(sig_ctrl[0]) data_result = data_or;
		else data_result = data_and;
	end
end

endmodule

module alu_shift(
	input [1:0] sig_ctrl,
	input [7:0] data_a, data_b,
	input sig_flag,

	output [7:0] data_result,
	output sig_flag_new
);

wire sig_bit_eight = sig_flag & sig_ctrl[0];
wire [8:0] data_shout = {sig_bit_eight, data_a} >> 1;

always_comb begin
	if(sig_ctrl[1]) begin
		data_result = data_b;
		sig_flag_new = sig_flag;
	end else begin
		data_result = data_shout[7:0];
		sig_flag_new = data_a[0];
	end
end

endmodule

module stack(
	input sig_clk,

	input [3:0] sig_ctrl,
	input [7:0] data_a,

	output [7:0] data_result
);

reg [7:0] stack_ptr;

wire sig_sp_write = & sig_ctrl[3:2] & (~sig_ctrl[1] | sig_ctrl[0]);
wire [7:0] data_sp_offset = {{7{sig_ctrl[0]}},1'b1};

always_ff @( posedge sig_clk ) begin
	if(sig_sp_write) begin
		if(sig_ctrl[1]) stack_ptr <= data_a;
		else stack_ptr <= stack_ptr + data_sp_offset;
	end
end

always_comb begin
	if(sig_ctrl[0]) data_result = stack_ptr + data_sp_offset;
	else data_result = stack_ptr;
end

endmodule
