module pc_reg(
  input  wire           clk_in,
  input  wire           rst_in,
  input  wire           rdy_in,

  input  wire           stall,
  input  wire           jmp_tak,
  input  wire [31: 0]   jmp_tar,

  output reg  [31: 0]   output_pc
);

reg [31: 0] pc;
always @(posedge clk_in) begin
    if(rst_in) begin
        pc <= `ZeroWord + 4;
        output_pc <= `ZeroWord;
    end else begin
        if(stall) begin
            output_pc <= pc;
        end else if(jmp_tak) begin
            pc <= jmp_tar + 4;
            output_pc <= jmp_tar;
        end else begin
            pc <= pc + 4;
            output_pc <= pc;
        end
    end
end
endmodule