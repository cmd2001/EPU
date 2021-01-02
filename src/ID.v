module ID(
  input  wire           clk_in,
  input  wire           rst_in,
  input  wire           rdy_in,

  input  wire [31: 0]   pc,
  input  wire [31: 0]   ins,

  output reg           read_flag_1,
  output reg [4: 0]    reg_read_1,
  input  wire [31: 0]   read_data_1,

  output  reg           read_flag_2,
  output  reg [4: 0]    reg_read_2,
  input  wire [31: 0]   read_data_2,

  input   wire          is_mem,
  output  reg [2: 0]    stall,

  output  reg [31: 0]   output_pc,
  output  reg [4: 0]    r1_addr,
  output  reg [31: 0]   r1_data,
  output  reg [4: 0]    r2_addr,
  output  reg [31: 0]   r2_data,
  output  reg [4: 0]    rd_addr,
  output  reg [31: 0]   imm,
  output  reg [6: 0]    ins_type,
  output  reg [2: 0]    ins_details,
  output  reg           ins_diff
);

wire[6: 0] type1 = ins[6: 0];

always @(*) begin
    if(rst_in) begin
        read_flag_1 = 1'b0;
        reg_read_1 = 5'h0;
        read_flag_2 = 1'b0;
        reg_read_2 = 5'h0;

        output_pc = `ZeroWord;
        r1_addr = 5'h0;
        r1_data = `ZeroWord;
        r2_addr = 5'h0;
        r2_data = `ZeroWord;
        rd_addr = 5'h0;
        imm = `ZeroWord;
        ins_type = 7'h0;
        ins_details = 2'h0;
        ins_diff = 1'b0;
        stall = 3'b000;
    end else begin
        output_pc = pc;
        stall = is_mem ? `STALL_ID : 3'b000;
        case(type1)
            `LUI: begin
                read_flag_1 = 1'b0;
                reg_read_1 = 5'h0;
                read_flag_2 = 1'b0;
                reg_read_2 = 5'h0;
                r1_addr = reg_read_1;
                r2_addr = reg_read_2;

                ins_type = type1;
                r1_data = `ZeroWord;
                r2_data = `ZeroWord;
                rd_addr = ins[11: 7];
                imm = {ins[31: 12], {12{1'b0}}};
                ins_details = 2'h0;
                ins_diff = 1'b0;
            end
            `AUIPC: begin
                read_flag_1 = 1'b0;
                reg_read_1 = 5'h0;
                read_flag_2 = 1'b0;
                reg_read_2 = 5'h0;
                r1_addr = reg_read_1;
                r2_addr = reg_read_2;

                ins_type = type1;
                r1_data = `ZeroWord;
                r2_data = `ZeroWord;
                rd_addr = ins[11: 7];
                imm = {ins[31: 12], {12{1'b0}}};
                ins_details = 2'h0;
                ins_diff = 1'b0;
            end
            `JAL: begin
                read_flag_1 = 1'b0;
                reg_read_1 = 5'h0;
                read_flag_2 = 1'b0;
                reg_read_2 = 5'h0;
                r1_addr = reg_read_1;
                r2_addr = reg_read_2;

                ins_type = type1;
                r1_data = `ZeroWord;
                r2_data = `ZeroWord;
                rd_addr = ins[11: 7];
                imm = {{12{ins[31]}}, ins[19: 12], ins[20], ins[30: 21], 1'b0};
                ins_details = 2'h0;
                ins_diff = 1'b0;
            end
            `JALR: begin
                read_flag_1 = 1'b1;
                reg_read_1 = ins[19: 15];
                read_flag_2 = 1'b0;
                reg_read_2 = 5'h0;
                r1_addr = reg_read_1;
                r2_addr = reg_read_2;

                ins_type = type1;
                r1_data = read_data_1;
                r2_data = `ZeroWord;
                rd_addr = ins[11: 7];
                imm = {{21{ins[31]}}, ins[30: 20]};
                ins_details = ins[14: 12];
                ins_diff = 1'b0;
            end
            `JMPC: begin
                 read_flag_1 = 1'b1;
                 reg_read_1 = ins[19: 15];
                 read_flag_2 = 1'b1;
                 reg_read_2 = ins[24: 20];
                 r1_addr = reg_read_1;
                 r2_addr = reg_read_2;

                 ins_type = type1;
                 r1_data = read_data_1;
                 r2_data = read_data_2;
                 rd_addr = 5'h0;
                 imm = {{20{ins[31]}}, ins[7], ins[30: 25], ins[11: 8], 1'b0};
                 ins_details = ins[14: 12];
                 ins_diff = 1'b0;
            end
            `LOAD: begin
                 read_flag_1 = 1'b1;
                 reg_read_1 = ins[19: 15];
                 read_flag_2 = 1'b0;
                 reg_read_2 = 5'h0;
                 r1_addr = reg_read_1;
                 r2_addr = reg_read_2;

                 ins_type = type1;
                 r1_data = read_data_1;
                 r2_data = `ZeroWord;
                 rd_addr = ins[11: 7];
                 imm = {{21{ins[31]}}, ins[30: 20]};
                 ins_details = ins[14: 12];
                 ins_diff = 1'b0;
            end
            `SAVE: begin
                 read_flag_1 = 1'b1;
                 reg_read_1 = ins[19: 15];
                 read_flag_2 = 1'b1;
                 reg_read_2 = ins[24: 20];
                 r1_addr = reg_read_1;
                 r2_addr = reg_read_2;

                 ins_type = type1;
                 r1_data = read_data_1;
                 r2_data = read_data_2;
                 rd_addr = 5'h0;
                 imm = {{21{ins[31]}}, ins[30: 25], ins[11: 7]};
                 ins_details = ins[14: 12];
                 ins_diff = 1'b0;
            end
            `ALOPI: begin
                 read_flag_1 = 1'b1;
                 reg_read_1 = ins[19: 15];
                 read_flag_2 = 1'b0;
                 reg_read_2 = 5'h0;
                 r1_addr = reg_read_1;
                 r2_addr = reg_read_2;

                 ins_type = type1;
                 r1_data = read_data_1;
                 r2_data = `ZeroWord;
                 rd_addr = ins[11: 7];
                 imm = {{21{ins[31]}}, ins[30: 20]};
                 ins_details = ins[14: 12];
                 ins_diff = ins[30];
            end
            `ALOP: begin
                 read_flag_1 = 1'b1;
                 reg_read_1 = ins[19: 15];
                 read_flag_2 = 1'b1;
                 reg_read_2 = ins[24: 20];
                 r1_addr = reg_read_1;
                 r2_addr = reg_read_2;

                 ins_type = type1;
                 r1_data = read_data_1;
                 r2_data = read_data_2;
                 rd_addr = ins[11: 7];
                 imm = 32'h0;
                 ins_details = ins[14: 12];
                 ins_diff = ins[30];
            end
        endcase
    end
end

endmodule