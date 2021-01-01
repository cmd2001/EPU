module EX_MEM(
  input  wire           clk_in,
  input  wire           rst_in,
  input  wire           rdy_in,

  input  wire           stall,

  input  wire           forward,
  input  wire [4: 0]    rd_addr,
  input  wire [31: 0]   rd_val,
  input  wire [6: 0]    ins_type,
  input  wire [2: 0]    ins_details,
  input  wire [31: 0]   mem_addr,
  input  wire [31: 0]   mem_val,

  output  reg           output_forward,
  output  reg [4: 0]    output_rd_addr,
  output  reg [31: 0]   output_rd_val,
  output  reg [6: 0]    output_ins_type,
  output  reg [2: 0]    output_ins_details,
  output  reg [31: 0]   output_mem_addr,
  output  reg [31: 0]   output_mem_val
);
always @(posedge clk_in) begin
    if(rst_in) begin
        forward <= 1'b0;
        output_rd_addr <= 5'h0;
        output_rd_val <= `ZeroWord;
        output_ins_type <= `ADDI;
        output_ins_details <= 3'h0;
        output_mem_addr <= `ZeroWord;
        output_mem_val <= `ZeroWord;
    end else begin
        if(!stall) begin
            output_forward <= forward;
            output_rd_addr <= rd_addr;
            output_rd_val <= rd_val;
            output_ins_type <= ins_type;
            output_ins_details <= ins_details;
            output_mem_addr <= mem_addr;
            output_mem_val <= mem_val;
        end
    end
end

endmodule