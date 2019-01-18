module DynamicBars (
// VGA In-OutW
input logic clk,
input logic rst,
output logic hsync,
output logic vsync,
output logic[3:0] red,
output logic[3:0] green,
output logic[3:0] blue,
// Buttons-Switch Inputs
input logic key_right,
input logic key_left,
input logic sw_select
);

logic pixelclk;
logic[9:0] count_x;
logic[9:0] count_y;
logic[8:0] indentation_red;
logic[8:0] indentation_blue;
logic outl;
logic outr;
logic outb;
logic outc;



always_ff @(posedge clk, negedge rst) begin
	if (~rst) pixelclk<=0;
	else pixelclk<=~pixelclk;
end

//task indentation(key_left,key_right,sw_select);
always_ff @(posedge clk, negedge rst) begin
	if (~rst) begin outb<=1;
	end else begin
		outb<=key_right;
	end
end
assign outr=outb && ~key_right;

always_ff @(posedge clk, negedge rst) begin
	if (~rst) begin outc<=1;
	end else begin
		outc<=key_left;
	end
end
assign outl=outc && ~key_left;

always_ff @(posedge clk, negedge rst) begin
	if (~rst) begin
		indentation_red<=0;
		indentation_blue<=0;
	end else if (sw_select==1) begin
		if (outl && indentation_red>=32)
			indentation_red<=indentation_red-32;
		else if (outr && indentation_red<=288)
			indentation_red<=indentation_red+32;
		
	end else begin
		if (outl && indentation_blue>=32)
			indentation_blue<=indentation_blue-32;
		else if (outr && indentation_blue<=288)
			indentation_blue<=indentation_blue+32;
	end
end
always_ff @(posedge clk, negedge rst) begin
	if (~rst) begin
		count_x<=1;
		count_y<=1;
		red<=0;
		green<=0;
		blue<=0;
		hsync<=1;
		vsync<=1;
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
			/*
				//blackening rest of screen
			if (~((count_x>120 && count_x<345+indentation_blue) || (count_x>120 && count_x<345+indentation_red))
					|| (~(count_y>160 && count_y<261) 
			    && ~(count_y>360 && count_y<461))) begin
					red=4'b0000;
					green=4'b0000;
					blue=4'b0000;
			end
			*/
			
			if (count_x >= 640 || count_y >= 480)
			begin			
				   red=4'b0000;
					green=4'b0000;
					blue=4'b0000;
			end
			else 
			begin
			//active display
				//line 1
				if (count_x>120 && count_x<=345+indentation_blue && count_y>160 && count_y<261) begin
					red=4'b0000;
					green=4'b0000;
					blue=4'b1111;
				end
				// line 2
				else if (count_x>120 && count_x<345+indentation_red && count_y>360 && count_y<461) begin
					red=4'b1111;
					green=4'b0000;
					blue=4'b0000;
		      end
				// anywhere else
				else begin
					red=4'b0000;
					green=4'b0000;
					blue=4'b0000;
				end
				
				
				
			end
			
			//blue line
			/*if (count_x>120 && count_x<345+indentation_blue) begin
				if (count_y>160 && count_y<261) begin
					red=4'b0000;
					green=4'b0000;
					blue=4'b1111;
				end
			end
			
			//red line
			if (count_x>120 && count_x<345+indentation_red) begin
				if (count_y>360 && count_y<461) begin
					red=4'b1111;
					green=4'b0000;
					blue=4'b0000;
				end
			end
		*/		
			
		end
	end
end


endmodule
