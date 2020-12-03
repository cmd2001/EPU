module ID(
  input  wire           clk_in,
  input  wire           rst_in,
  input  wire           rdy_in,

  input  wire [31: 0]   pc,
  input  wire [31: 0]   ins,

  input  wire           forward_ex_enable,
  input  wire [4: 0]    forward_ex_addr,
  input  wire[31: 0]    forward_ex_data,

  input  wire           forward_mem_enable,
  input  wire [4: 0]    forward_mem_addr,
  input  wire[31: 0]    forward_mem_data,

  output wire           read_flag_1,
  output wire [4: 0]    reg_read_1,
  input wire[31: 0]     read_data_1,

  output wire           read_flag_2,
  output wire [4: 0]    reg_read_2,
  input wire[31: 0]     read_data_2,

  output  reg[31: 0]    r1_data,
  output  reg[31: 0]    r2_data,
  output  reg[4: 0]     rd_addr,
  output  reg[31: 0]    imm,
  output  reg[6: 0]     ins_type,
  output  reg[2: 0]     ins_details,
  output  reg           ins_diff
);

assign type1 = ins[6: 0];

always @(*) begin
    if(rst_in) begin
        r1_data = `ZeroWord;
        r2_data = `ZeroWord;
        rd_addr = 5'h0;
        imm = `ZeroWord;
        ins_type = 7'h0;
        ins_details = 2'h0;
        ins_diff = 1'b0;
    end else begin
        case(type1)
            `LUI: begin
                read_flag_1 = 0'b0;
                reg_read_1 = 5'h0;
                read_flag_2 = 0'b0;
                reg_read_2 = 5'h0;

                ins_type = type1;
                r1_data = `ZeroWord;
                r2_data = `ZeroWord;
                rd_addr = ins[11: 7];
                imm = {ins[31: 12], 12{0}};
                ins_details = 2'h0;
                ins_diff = 1'b0;
            end
            `AUIPC: begin
                read_flag_1 = 0'b0;
                reg_read_1 = 5'h0;
                read_flag_2 = 0'b0;
                reg_read_2 = 5'h0;

                ins_type = type1;
                r1_data = `ZeroWord;
                r2_data = `ZeroWord;
                rd_addr = ins[11: 7];
                imm = {ins[31: 12], 12{0}};
                ins_details = 2'h0;
                ins_diff = 1'b0;
            end
            `JAL: begin
                read_flag_1 = 0'b0;
                reg_read_1 = 5'h0;
                read_flag_2 = 0'b0;
                reg_read_2 = 5'h0;

                ins_type = type1;
                r1_data = `ZeroWord;
                r2_data = `ZeroWord;
                rd_addr = ins[11: 7];
                imm = {12{ins[31]}, ins[19: 12], ins[20], ins[30: 21]};
                ins_details = 2'h0;
                ins_diff = 1'b0;
            end
            `JALR: begin
                read_flag_1 = 0'b1;
                reg_read_1 = ins[19: 15];
                read_flag_2 = 0'b0;
                reg_read_2 = 5'h0;

                ins_type = type1;
                r1_data = read_data_1;
                r2_data = `ZeroWord;
                rd_addr = ins[11: 7];
                imm = {21{ins[31]}, ins[30: 20]};
                ins_details = ins[14: 12];
                ins_diff = 1'b0;
            end
            `JMPC: begin
                 read_flag_1 = 0'b1;
                 reg_read_1 = ins[19: 15];
                 read_flag_2 = 0'b1;
                 reg_read_2 = ins[24: 20];

                 ins_type = type1;
                 r1_data = read_data_1;
                 r2_data = read_data_2;
                 rd_addr = 5'h0;
                 imm = {20{ins[31]}, ins[7], ins[30: 25], ins[11: 8]};
                 ins_details = ins[14: 12];
                 ins_diff = 1'b0;
            end
            `LOAD: begin
                 read_flag_1 = 0'b1;
                 reg_read_1 = ins[19: 15];
                 read_flag_2 = 0'b0;
                 reg_read_2 = 5'h0;

                 ins_type = type1;
                 r1_data = read_data_1;
                 r2_data = `ZeroWord;
                 rd_addr = ins[11: 7];
                 imm = {21{ins[31]}, ins[30: 20]};
                 ins_details = ins[14: 12];
                 ins_diff = 0'b0;
            end
            `SAVE: begin
                 read_flag_1 = 0'b1;
                 reg_read_1 = ins[19: 15];
                 read_flag_2 = 0'b1;
                 reg_read_2 = ins[24: 20];

                 ins_type = type1;
                 r1_data = read_data_1;
                 r2_data = read_data_2;
                 rd_addr = 5'h0;
                 imm = {21{ins[31]}, ins[30: 25], ins[11: 7]};
                 ins_details = ins[14: 12];
                 ins_diff = 0'b0;
            end
            `ALOPI: begin // fixme: solve shamt in EX.
                 read_flag_1 = 0'b1;
                 reg_read_1 = ins[19: 15];
                 read_flag_2 = 0'b0;
                 reg_read_2 = 5'h0;

                 ins_type = type1;
                 r1_data = read_data_1;
                 r2_data = `ZeroWord;
                 rd_addr = ins[11: 7];
                 imm = {21{ins[31]}, ins[30: 20]};
                 ins_details = ins[14: 12];
                 ins_diff = ins[30];
            end
            `ALOP: begin
                 read_flag_1 = 0'b1;
                 reg_read_1 = ins[19: 15];
                 read_flag_2 = 0'b1;
                 reg_read_2 = ins[24: 20];

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