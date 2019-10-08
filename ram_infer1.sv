/*
* @info SRAM Module
*
* @author VLSI Lab, EE dept., Democritus University of Thrace
*
* @brief A dual port, non-resetable SRAM module.
*
* @param DW    : Data Width in Bits
* @param WORDS : # of addressable entries (lines) in the array
* @param ADDRW : Auto-Calculated Address Width
*/

module ram_infer1 #(
  parameter int DW    = 64,            // Data Width
  parameter int WORDS = 48,            // RAM Depth
  parameter int ADDRW = $clog2(WORDS)  // Auto-Calculated Address Width
) (
  input  logic            clk,

  input  logic[ADDRW-1:0] rd_addr_i,
  output logic[DW-1:0]    rd_data_o,

  input  logic            wr_en_i,
  input  logic[ADDRW-1:0] wr_addr_i,
  input  logic[DW-1:0]    wr_data_i
);

//logic[DW-1:0] mem[0:WORDS-1];
logic[DW-1:0] mem[0:WORDS-1];
//initial $readmemh("my_init.txt", mem);

always @(posedge clk) rd_data_o <= mem[rd_addr_i];
//assign rd_data_o = mem[rd_addr_i];

always @(posedge clk) begin
  if(wr_en_i) mem[wr_addr_i] <= wr_data_i;
end

endmodule
