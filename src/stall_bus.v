module stall_bus(
  input  wire           clk_in,
  input  wire           rst_in,
  input  wire           rdy_in,

  input  wire           stall_IF,
  input  wire           stall_ID,
  input  wire           stall_MEM,

  output reg           output_stall
);

always @(*) begin
    if(rst_in) begin
        output_stall = 1'b0;
    end else begin
        output_stall = stall_IF | stall_ID | stall_MEM;
    end
end

endmodule