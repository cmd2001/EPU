module EX(
  input  wire           clk_in,
  input  wire           rst_in,

  input  wire [31: 0]   pc,
  input  wire [31: 0]   r1_data,
  input  wire [31: 0]   r2_data,
  input  wire [4: 0]    rd_addr,
  input  wire [31: 0]   imm,
  input  wire [6: 0]    ins_type,
  input  wire [2: 0]    ins_details,
  input  wire           ins_diff,

  output  reg           take_jmp,
  output  reg [31: 0]   jmp_pc,
  output  reg [4: 0]    output_rd_addr,
  output  reg [31: 0]   rd_val,
  output  reg [6: 0]    output_ins_type,
  output  reg [2: 0]    output_ins_details,
  output reg  [31: 0]   mem_addr,
  output reg  [31: 0]   mem_val
);
always @(*) begin
    if(rst_in) begin
        take_jmp = 1'b0;
        jmp_pc = `ZeroWord;
        output_rd_addr = 5'h0;
        rd_val = 5'h0;
        output_ins_type = 7'h0;
        output_ins_details = 3'h0;
        mem_addr = `ZeroWord;
        mem_val = `ZeroWord;
    end else begin
        case(ins_type)
            `LUI: begin
                take_jmp = 1'b0;
                jmp_pc = `ZeroWord;
                output_rd_addr = rd_addr;
                rd_val = imm;
                output_ins_type = ins_type;
                output_ins_details = ins_details;
                mem_addr = `ZeroWord;
                mem_val = `ZeroWord;
            end
            `AUIPC: begin
                take_jmp = 1'b0;
                jmp_pc = `ZeroWord;
                output_rd_addr = rd_addr;
                rd_val = pc + imm;
                output_ins_type = ins_type;
                output_ins_details = ins_details;
                mem_addr = `ZeroWord;
                mem_val = `ZeroWord;
            end
            `JAL: begin // todo: here.

            end
            `JALR: begin
            end
            `JMPC: begin
            end
            `LOAD: begin
            end
            `SAVE: begin
            end
            `ALOPI: begin
            end
            `ALOP: begin
            end
        endcase
    end
end
endmodule