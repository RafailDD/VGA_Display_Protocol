module VGA (
// VGA In-OutW
input logic clk,
input logic rst,
output logic hsync,
output logic vsync,
output logic[3:0] red,
output logic[3:0] green,
output logic[3:0] blue,
// Sprite
input logic [63:0] vga_data,
output logic [5:0] vga_address

);
logic pixelclk;
logic[9:0] count_x;
logic[9:0] count_y;
logic [5:0] address_counter;
logic [6:0] data_counter;

assign vga_address=address_counter;

//25Mhz clock
always_ff @(posedge clk, negedge rst) begin
	if (~rst) pixelclk<=0;
	else pixelclk<=~pixelclk;
end

//main behavior
always_ff @(posedge clk, negedge rst) begin
	if (~rst) begin
		count_x<=1;
		count_y<=1;
		red<=0;
		green<=0;
		blue<=0;
		hsync<=1;
		vsync<=1;
		data_counter<=0;
		address_counter<=0;
	end else begin
		if (pixelclk) begin //25MHz clock
			//pixels coordinates
			if (count_x==800) begin
				count_x<=1;

				if (count_y==524) begin
				count_y<=1;
				end else count_y<=count_y+1;
			end
			else begin
				count_x<=count_x+1;
			end

			//hsync,vsync
			if (count_x<=656) hsync<=1;
			else if (count_x<=752) hsync<=0;
			else hsync<=1;

			if (count_y<=491) vsync<=1;
			else if (count_y<=493) vsync<=0;
			else vsync<=1;

			//front porch / back porch
			if (count_x >= 640 || count_y >= 480)
			begin
				   red=4'b0000;
					green=4'b0000;
					blue=4'b0000;
			end
			else
			begin
			//active display
				//sprite
				if (count_x>200 & count_x<265 & count_y>209 & count_y<238) begin
					if (vga_data[264-count_x]==1) begin
						red=4'b1111;
						green=4'b1111;
						blue=4'b1111;
					end else begin
						red=4'b0000;
 						green=4'b0000;
 						blue=4'b0000;
					end
					//data_counter<=data_counter+1;
				end
				// anywhere else
				else begin
					if (count_x==300) begin
						address_counter<=count_y-200;
					end
					/*if (count_y==248) begin
						address_counter<=0;
					end
					*/
					data_counter<=0;
					//address_counter<=0;
					red=4'b0000;
					green=4'b0000;
					blue=4'b0000;
				end
			end
		end
	end
end
endmodule
