module IF(
  input  wire           clk_in,
  input  wire           rst_in,
  input  wire           rdy_in,

  output wire [31 :0]   mem_addr,
  output wire [1: 0]    mem_size,
  input  wire           mem_rdy,
  input  wire [31: 0]   mem_data,

  output wire           stall,
  output wire [31: 0]   ins
);
endmodule