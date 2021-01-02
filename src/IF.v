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
  output reg  [2: 0]   stall,
  output reg  [31: 0]   output_pc,
  output reg  [31: 0]   ins
);

always @(*) begin
    if(rst_in) begin
        memctl_op = `MEM_NOP;
        memctl_addr = `ZeroWord;
        stall = 3'b000;
        output_pc = `ZeroWord + 4;
        ins = `ZeroWord;
    end else begin
        memctl_op = `MEM_LOAD;
        memctl_len = `MEM_WORD;
        memctl_addr = input_pc;
        if(memctl_rdy) begin // wait until memory ready
            stall = 3'b000;
            output_pc = input_pc + 4;
            ins = memctl_out;
        end else begin
            stall = `STALL_IF;
            output_pc = input_pc + 4;
        end
    end
end
endmodule