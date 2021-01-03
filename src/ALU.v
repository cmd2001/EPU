module ALU(
  input  wire           clk_in,
  input  wire           rst_in,
  input  wire			rdy_in,

  input  wire [1: 0]    ins_type, // compare, op, opi
  input  wire [2: 0]    ins_details,
  input  wire           ins_diff,
  input  wire [31: 0]   r1,
  input  wire [31: 0]   r2,
  output reg  [31: 0]   out
);

always @(*) begin
    if(rst_in) begin
        out = `ZeroWord;
    end else begin
        case(ins_type)
            `ALU_CMP: begin
                case(ins_details)
                    `BEQ: begin
                        out = r1 == r2 ? `TrueWord : `FalseWord;
                    end
                    `BNE: begin
                        out = r1 != r2 ? `TrueWord : `FalseWord;
                    end
                    `BLT: begin
                        out = $signed(r1) < $signed(r2) ? `TrueWord : `FalseWord;
                    end
                    `BLTU: begin
                        out = r1 < r2 ? `TrueWord : `FalseWord;
                    end
                    `BGE: begin
                        out = $signed(r1) >= $signed(r2) ? `TrueWord : `FalseWord;
                    end
                    `BGEU: begin
                        out = r1 >= r2 ? `TrueWord : `FalseWord;
                    end
                    default: begin
                        out = `ZeroWord;
                    end
                endcase
            end
            `ALU_ALUOPI: begin // now imm in r2.
                case(ins_details)
                    `ADDI: begin
                        out = r1 + r2;
                    end
                    `SLTI: begin
                        out = $signed(r1) < $signed(r2) ? `TrueWord : `FalseWord;
                    end
                    `SLTIU: begin
                        out = r1 < r2 ? `TrueWord : `FalseWord;
                    end
                    `XORI: begin
                        out = r1 ^ r2;
                    end
                    `ORI: begin
                        out = r1 | r2;
                    end
                    `ANDI: begin
                        out = r1 & r2;
                    end
                    `SLLI: begin
                        out = r1 << (r2[4: 0]);
                    end
                    `SRLI_SRAI: begin
                        out = ins_diff == `SRLI_Diff ? (r1 >> (r2[4: 0])) : ($signed(r1) >> (r2[4: 0]));
                    end
                    default: begin
                        out = `ZeroWord;
                    end
                endcase
            end
            `ALU_ALUOP: begin
                case(ins_details)
                    `ADD_SUB: begin
                        out = ins_diff == `ADD_Diff ? r1 + r2 : r1 - r2;
                    end
                    `SLL: begin
                        out = r1 << (r2[4: 0]);
                    end
                    `SLT: begin
                        out = $signed(r1) < $signed(r2) ? `TrueWord : `FalseWord;
                    end
                    `SLTU: begin
                        out = r1 < r2 ? `TrueWord : `FalseWord;
                    end
                    `XOR: begin
                        out = r1 ^ r2;
                    end
                    `SRL_SRA: begin
                        out = ins_diff == `SRL_Diff ? (r1 >> (r2[4: 0])) : ($signed(r1) >> (r2[4: 0]));
                    end
                    `OR: begin
                        out = r1 | r2;
                    end
                    `AND: begin
                        out = r1 & r2;
                    end
                    default: begin
                        out = `ZeroWord;
                    end
                endcase
            end
            default: begin
                out = `ZeroWord;
            end
        endcase
    end
end
endmodule