module EX(
  input  wire           clk_in,
  input  wire           rst_in,
  input  wire           rdy_in,

  input  wire [31: 0]   pc,
  input  wire [31: 0]   r1_data,
  input  wire [31: 0]   r2_data,
  input  wire [4: 0]    rd_addr,
  input  wire [31: 0]   imm,
  input  wire [6: 0]    ins_type,
  input  wire [2: 0]    ins_details,
  input  wire           ins_diff,

  output  reg [1: 0]    alu_ins_type, // compare, op, opi
  output  reg [2: 0]    alu_ins_details,
  output  reg           alu_ins_diff,
  output  reg [31: 0]   alu_r1,
  output  reg [31: 0]   alu_r2,
  input   wire[31: 0]   alu_out,

  output  reg           take_jmp,
  output  reg [31: 0]   jmp_pc,
  output  reg [4: 0]    output_rd_addr,
  output  reg [31: 0]   rd_val,
  output  reg           forward,
  output  reg [6: 0]    output_ins_type,
  output  reg [2: 0]    output_ins_details,
  output  reg  [31: 0]  mem_addr,
  output  reg  [31: 0]  mem_val,

  output reg            stall_id
);
always @(*) begin
    if(rst_in) begin
        alu_ins_type = `ALU_NOP;
        alu_ins_details = 3'b0;
        alu_ins_diff = 1'b0;
        alu_r1 = `ZeroWord;
        alu_r2 = `ZeroWord;

        take_jmp = 1'b0;
        jmp_pc = `ZeroWord;
        output_rd_addr = 5'h0;
        rd_val = 5'h0;
        forward = 1'b0;
        output_ins_type = 7'h0;
        output_ins_details = 3'h0;
        mem_addr = `ZeroWord;
        mem_val = `ZeroWord;
        stall_id = 1'b0;
    end else begin
        output_ins_type = ins_type;
        output_ins_details = ins_details;
        case(ins_type)
            `LUI: begin
                alu_ins_type = `ALU_NOP;
                alu_ins_details = 3'b0;
                alu_ins_diff = 1'b0;
                alu_r1 = `ZeroWord;
                alu_r2 = `ZeroWord;

                take_jmp = 1'b0;
                jmp_pc = `ZeroWord;
                output_rd_addr = rd_addr;
                rd_val = imm;
                forward = 1'b1;
                mem_addr = `ZeroWord;
                mem_val = `ZeroWord;
                stall_id = 1'b0;
            end
            `AUIPC: begin
                alu_ins_type = `ALU_NOP;
                alu_ins_details = 3'b0;
                alu_ins_diff = 1'b0;
                alu_r1 = `ZeroWord;
                alu_r2 = `ZeroWord;

                take_jmp = 1'b0;
                jmp_pc = `ZeroWord;
                output_rd_addr = rd_addr;
                rd_val = pc + imm;
                forward = 1'b1;
                mem_addr = `ZeroWord;
                mem_val = `ZeroWord;
                stall_id = 1'b0;
            end
            `JAL: begin
                alu_ins_type = `ALU_NOP;
                alu_ins_details = 3'b0;
                alu_ins_diff = 1'b0;
                alu_r1 = `ZeroWord;
                alu_r2 = `ZeroWord;

                take_jmp = 1'b1;
                jmp_pc = pc - 4 + imm;
                output_rd_addr = rd_addr;
                rd_val = pc;
                forward = 1'b1;
                mem_addr = `ZeroWord;
                mem_val = `ZeroWord;
                stall_id = 1'b0;
            end
            `JALR: begin
                alu_ins_type = `ALU_NOP;
                alu_ins_details = 3'b0;
                alu_ins_diff = 1'b0;
                alu_r1 = `ZeroWord;
                alu_r2 = `ZeroWord;

                take_jmp = 1'b1;
                jmp_pc = pc - 4 + imm;
                output_rd_addr = rd_addr;
                rd_val = pc;
                forward = 1'b1;
                mem_addr = `ZeroWord;
                mem_val = `ZeroWord;
                stall_id = 1'b0;
            end
            `JMPC: begin
                alu_ins_type = `ALU_CMP;
                alu_ins_details = ins_details;
                alu_ins_diff = ins_diff;
                alu_r1 = r1_data;
                alu_r2 = r2_data;

                if(alu_out) begin
                    take_jmp = 1'b1;
                    jmp_pc = pc - 4 + imm;
                    output_rd_addr = 5'h0;
                    rd_val = `ZeroWord;
                    forward = 1'b0;
                    mem_addr = `ZeroWord;
                    mem_val = `ZeroWord;
                end else begin
                    take_jmp = 1'b0;
                    jmp_pc = `ZeroWord;
                    output_rd_addr = 5'h0;
                    rd_val = `ZeroWord;
                    forward = 1'b0;
                    mem_addr = `ZeroWord;
                    mem_val = `ZeroWord;
                end
                stall_id = 1'b0;
            end
            `LOAD: begin
                alu_ins_type = `ALU_NOP;
                alu_ins_details = 3'b0;
                alu_ins_diff = 1'b0;
                alu_r1 = `ZeroWord;
                alu_r2 = `ZeroWord;

                take_jmp = 1'b0;
                jmp_pc = `ZeroWord;
                output_rd_addr = rd_addr;
                rd_val = `ZeroWord;
                forward = 1'b0;
                mem_addr = r1_data + imm;
                mem_val = `ZeroWord;
                stall_id = 1'b1;
            end
            `SAVE: begin
                alu_ins_type = `ALU_NOP;
                alu_ins_details = 3'b0;
                alu_ins_diff = 1'b0;
                alu_r1 = `ZeroWord;
                alu_r2 = `ZeroWord;

                take_jmp = 1'b0;
                jmp_pc = `ZeroWord;
                output_rd_addr = 5'b0;
                rd_val = `ZeroWord;
                forward = 1'b0;
                mem_addr = r1_data + imm;
                mem_val = r2_data;
                stall_id = 1'b0;
            end
            `ALOPI: begin
                alu_ins_type = `ALU_ALUOPI;
                alu_ins_details = ins_details;
                alu_ins_diff = ins_diff;
                alu_r1 = r1_data;
                alu_r2 = imm;

                take_jmp = 1'b0;
                jmp_pc = `ZeroWord;
                output_rd_addr = rd_addr;
                rd_val = alu_out;
                forward = 1'b1;
                mem_addr = `ZeroWord;
                mem_val = `ZeroWord;
                stall_id = 1'b0;
            end
            `ALOP: begin
                alu_ins_type = `ALU_ALUOP;
                alu_ins_details = ins_details;
                alu_ins_diff = ins_diff;
                alu_r1 = r1_data;
                alu_r2 = r2_data;

                take_jmp = 1'b0;
                jmp_pc = `ZeroWord;
                output_rd_addr = rd_addr;
                rd_val = alu_out;
                forward = 1'b1;
                mem_addr = `ZeroWord;
                mem_val = `ZeroWord;
                stall_id = 1'b0;
            end
        endcase
    end
end
endmodule