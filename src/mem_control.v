module memcontrol(
  input  wire                 clk_in,			// system clock signal
  input  wire                 rst_in,			// reset signal
  input  wire				  rdy_in,			// ready signal, pause cpu when low

  input wire  [31:0]          addr,
  input wire  [1: 0]          size,
  input wire                  op_tpe, // 1 for write
  output wire                 mem_ready,
  output wire [31:0]          data,

  input  wire [ 7:0]          mem_din,		// data input bus
  output wire [ 7:0]          mem_dout,		// data output bus
  output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
  output wire                 mem_wr			// write/read signal (1 for write)
);
endmodule