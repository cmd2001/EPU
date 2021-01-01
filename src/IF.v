module IF(
  input  wire           clk_in,
  input  wire           rst_in,
  input  wire           rdy_in,

  output reg [1: 0]     memctl_op,
  output reg [1: 0]     memctl_len,
  output reg [31: 0]    memctl_addr,
  input  wire           memctl_rdy,
  input  wire [31: 0]   memctl_out,

  input wire  [31: 0]   input_pc,
  output reg            stall,
  output reg  [31: 0]   output_pc,
  output reg  [31: 0]   ins
);

always @(*) begin
    memctl_op = `MEM_LOAD;
    memctl_len = `MEM_WORD;
    memctl_addr = input_pc;
    if(memctl_rdy) begin // wait until memory ready
        stall = `ChipNotStall;
        output_pc = input_pc;
        ins = memctl_out;
    end else begin
        stall = `ChipStall;
        output_pc = input_pc + 4;
        ins = 0;
    end
end
endmodule