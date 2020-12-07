module IF_ID(
  input  wire           clk_in,
  input  wire           rst_in,
  input  wire           rdy_in,

  input wire            stall, // chip stall
  input wire            clear, // stage clear

  input  reg [31: 0]   if_pc,
  input  reg [31: 0]   if_ins,
  output reg [31: 0]   id_pc,
  output reg [31: 0]   id_ins
);
always @(posedge clk_in) begin
    if(rst_in == `ChipRst || stall == `ChipStall || clear == `StageClear) begin
        id_pc <= `NOP_PC;
        id_ins <= `NOP_INS;
    end else begin
        id_pc <= if_pc;
        id_ins <= if_ins;
    end
end
endmodule