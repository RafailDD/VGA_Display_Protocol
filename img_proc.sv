module img_proc (
	input logic clk,
	input logic rst,

	output logic hsync,
	output logic vsync,
	output logic[3:0] red,
	output logic[3:0] green,
	output logic[3:0] blue,

	//input logic sw_select,
	input logic sw_kernel,
	input logic sw_operator,
	input logic key,
	input logic button
);

logic [63:0] data_out;
logic [63:0] mult_fdata;
//logic [5:0] mult_faddr;
logic [5:0] address_in;
logic wr_en_i;
logic wr_en_i1;
logic wr_en_i2;
logic [5:0] wr_addr_i;
logic [63:0] wr_data_i;
logic [5:0] vga_address;
logic [5:0] mult_address;
logic [63:0] mult_data;
logic [63:0] ram1_data_out;
logic [63:0] ram2_data_out;
logic [5:0] r_add_img_filter;
logic [9:0] counter;
logic sw_kernel_new;
logic sw_operator_new;
logic out;
logic outs;
logic start;
logic starts;
logic enable;

char_rom (
	.rom_address (mult_address),
	.rom_data (data_out)
);

img_filter (
	.clk (clk),
	.rst (rst),

	.data_img_filter (mult_fdata),
	.r_add_img_filter (r_add_img_filter),

	.wr_address_ram (wr_addr_i),
	.wr_data_ram (wr_data_i),
	.wr_enable_ram (wr_en_i),
	.sw_kernel (sw_kernel_new),
	.sw_operator (sw_operator_new),
	.reset_enable (enable),
	//.counter (counter)
);

VGA (
	.clk (clk),
	.rst (rst),
	.hsync (hsync),
	.vsync (vsync),
	.red (red),
	.green (green),
	.blue (blue),

	.vga_address (vga_address),
	.vga_data (mult_data)

);
ram_infer1 r1(
	.clk(clk),

	.wr_addr_i (wr_addr_i),
	.wr_data_i (wr_data_i),
	.wr_en_i (wr_en_i1),

	.rd_addr_i (mult_address),
	.rd_data_o (ram1_data_out)
);

ram_infer1 r2(
	.clk(clk),

	.wr_addr_i (wr_addr_i),
	.wr_data_i (wr_data_i),
	.wr_en_i (wr_en_i2),

	.rd_addr_i (mult_address),
	.rd_data_o (ram2_data_out)
);

//filter data input logic (k-1)
always_comb begin
	if (counter==0)
		mult_fdata = data_out;
	else if (counter%2==1)
		mult_fdata = ram1_data_out;
	else
		mult_fdata = ram2_data_out;
end

//filter-VGA read address logic
always_comb begin
	if(wr_en_i==1) begin
		mult_address = r_add_img_filter;
	end else begin
		mult_address = vga_address;
	end
end

//RAM enable logic
always_comb begin
	if (counter%2==0) begin
		wr_en_i1=1;
		wr_en_i2=0;
	end else begin
		wr_en_i1=0;
		wr_en_i2=1;
	end
	
end
		
//VGA display logic (k-1)
always_comb begin
	if(counter==0) begin
		mult_data=data_out;
	end else if (counter%2==1) begin
		mult_data=ram1_data_out;
	end else begin
		mult_data=ram2_data_out;
	end
end

//edge-detection for filter
always_ff @(posedge clk, negedge rst) begin
	if (~rst) begin
		out<=1;
		start<=1;
	end else begin
		out<=key;
		start<=button;
	end
end
assign outs=out && ~key;
assign starts=start && ~button;

assign enable = starts;

always_ff @(posedge clk, negedge rst) begin
	if (~rst) begin
		sw_kernel_new<=0;
		sw_operator_new<=0;
		//enable<=0;
		//counter<=0;
	end else if (enable) begin
		sw_kernel_new<=sw_kernel;
		sw_operator_new<=sw_operator;
		//enable<=1;
		//counter<=counter+1;
	end
end

always_ff @(posedge clk, negedge rst) begin
	if (~rst) begin
		//sw_kernel_new<=0;
		//sw_operator_new<=0;
		//enable<=0;
		counter<=0;
	end else if (outs) begin
		//sw_kernel_new<=sw_kernel;
		//sw_operator_new<=sw_operator;
		//enable<=1;
		counter<=counter+1;
		//wr_addr_i<=0;
	end
end

endmodule
