module img_filter (

input logic clk,
input logic rst,

input logic [63:0] data_img_filter,
input logic sw_kernel,
input logic sw_operator,
input logic reset_enable,

output logic [5:0] r_add_img_filter,

output logic wr_enable_ram,
output logic [5:0]wr_address_ram,
output logic [63:0]wr_data_ram
//output logic [9:0]counter
);

logic [5:0] address_counter;
logic [2:0][65:0] line_buffer;
logic [63:0] new_pixel;
logic [5:0] address_counter_ram;


assign r_add_img_filter=address_counter;
assign wr_address_ram=address_counter_ram;

//filter
always_ff @(posedge clk, negedge rst) begin
	if (~rst) begin
		address_counter<=0;
		line_buffer<=0;
		address_counter_ram<=-3;
		wr_enable_ram<=0;
		//counter<=0;
	end else begin
		if (address_counter==0 & reset_enable==1) begin
			address_counter<=address_counter+1;
			address_counter_ram<=address_counter_ram+1;
			//line_buffer<=0;
			line_buffer[0]<=line_buffer[1];
			line_buffer[1]<=line_buffer[2];
			line_buffer[2][64:1]<=data_img_filter[63:0];
			wr_enable_ram<=1;
			//counter<=counter+1;
		end else if (address_counter<=49 & address_counter>=1) begin
			address_counter<=address_counter+1;
			address_counter_ram<=address_counter_ram+1;
			line_buffer[0]<=line_buffer[1];
			line_buffer[1]<=line_buffer[2];
			line_buffer[2][64:1]<=data_img_filter[63:0];
			wr_enable_ram<=1;
		end else if (address_counter==50) begin
			line_buffer<=0;
			address_counter<=0;
			address_counter_ram<=-3;
			wr_enable_ram<=0;
		end
	end
end

always_comb begin

	//operator+kernel
	if(address_counter<=49 & address_counter>=1) begin
		
		//new_pixel[63:0]='1;//{64{1'b1}};
		for(int i=1;i<=64;i++) begin
			//new_pixel[i-1]=1;
			if (sw_kernel==1) begin
				if(sw_operator==1) begin
					new_pixel[i-1]= (line_buffer[0][i] & line_buffer[1][i-1] & line_buffer[1][i] & line_buffer[2][i] & line_buffer[1][i+1]);
				end else begin
					new_pixel[i-1]= (line_buffer[0][i] | line_buffer[1][i-1] | line_buffer[1][i] | line_buffer[2][i] | line_buffer[1][i+1]);
				end
			end else begin
				if(sw_operator==1) begin
					new_pixel[i-1]= (line_buffer[0][i] & line_buffer[1][i-1] & line_buffer[2][i] & line_buffer[1][i+1]);
				end else begin
					new_pixel[i-1]= (line_buffer[0][i] | line_buffer[1][i-1] | line_buffer[2][i] | line_buffer[1][i+1]);
				end
			end
		end
		//new_pixel[63:0]={64{1'b1}};
		wr_data_ram[63:0]=new_pixel[63:0];
	end else begin
		new_pixel[63:0]={64{1'b0}};	
		wr_data_ram[63:0]={64{1'b0}};
	end

end

endmodule
