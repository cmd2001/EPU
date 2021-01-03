module pc_reg(
  input  wire           clk_in,
  input  wire           rst_in,
  input  wire           rdy_in,

  input  wire [2: 0]    stall,
  input  wire           jmp_tak,
  input  wire [31: 0]   jmp_tar,

  output reg  [31: 0]   output_pc
);

reg [31: 0] pc;
always @(posedge clk_in) begin
    if(rst_in) begin
        pc <= `ZeroWord;
        output_pc <= `ZeroWord;
    end else if(!rdy_in) begin
    end else begin
        if(jmp_tak) begin
            if(stall) begin
                pc <= jmp_tar;
            end else begin
                pc <= jmp_tar + 4;
            end
            output_pc <= jmp_tar;
        end else if(stall) begin
            output_pc <= pc;
        end else begin
            pc <= pc + 4;
            output_pc <= pc;
        end
    end
end
endmodule