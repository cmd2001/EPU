module IF(
  input  wire           clk_in,
  input  wire           rst_in,
  input  wire           rdy_in,

  output wire [31 :0]   mem_addr,
  output wire [1: 0]    mem_size,
  input  wire           mem_rdy,
  input  wire [31: 0]   mem_data,

  input wire  [31: 0]   input_pc,
  output reg            stall,
  output reg  [31: 0]   output_pc,
  output reg  [31: 0]   ins
);
always @(posedge clk_in) begin
    mem_addr <= input_pc;
    mem_size <= MEM_WORD;
    if(mem_rdy) begin // wait until memory ready
        stall <= `ChipNotStall;
        out_pc <= input_pc;
        ins <= mem_data;
    end else begin
        stall <= `ChipStall;
        out_pc <= input_pc + 4;
        ins <= 0;
    end
end
endmodule