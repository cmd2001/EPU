module MEM_WB(
  input  wire           clk_in,
  input  wire           rst_in,
  input  wire           rdy_in,

  input  wire [4: 0]    rd_addr,
  input  wire [31: 0]   rd_val,
  input  wire [6: 0]    ins_type,

  output reg [4: 0]     output_rd_addr,
  output reg [31: 0]    output_rd_val,
  output reg [6: 0]     output_ins_type
);

always @(posedge clk_in) begin
    if(rst_in) begin
        output_ins_type <= `ALOPI;
        output_rd_addr = 5'h0;
        output_rd_val = `ZeroWord;
    end else begin
        output_ins_type <= ins_type;
        outout_rd_addr <= rd_addr;
        output_rd_val <= rd_val;
    end
end

endmodule