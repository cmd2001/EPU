module stall_bus(
  input  wire           clk_in,
  input  wire           rst_in,
  input  wire           rdy_in,

  input  wire [2: 0]         stall_IF,
  input  wire [2: 0]         stall_ID,
  input  wire [2: 0]         stall_MEM,

  output reg  [2: 0]         output_stall
);

always @(*) begin
    if(rst_in) begin
        output_stall = 3'b000;
    end else begin
        output_stall = stall_IF | stall_ID | stall_MEM;
    end
end

endmodule