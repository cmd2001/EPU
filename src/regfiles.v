module regfile(
  input  wire           clk_in,
  input  wire           rst_in,
  input  wire           rdy_in,

  input wire            write_flag,
  input wire [4: 0]     reg_write,
  input wire [31: 0]    write_data,

  input wire            read_flag_1,
  input wire [4: 0]     reg_read_1,
  output reg[31: 0]    output_data_1,

  input wire            read_flag_2,
  input wire [4: 0]     reg_read_2,
  output reg[31: 0]    output_data_2
);
reg[31: 0] regs[0: 31];

/*
always @(posedge clk) begin
    if(rst_in != `ChipRst && write_flag && reg_write) begin
        regs[reg_write] <= write_data;
    end
end
*/

always @(*) begin
    if(rst_in) begin // reset
        output_data_1 = `ZeroWord;
    end else if(reg_read_1 == 5'b0) begin // zero register
        output_data_1 = `ZeroWord;
    end else if(write_flag && reg_write == reg_read_1 && read_flag_1) begin // register same with write
        output_data_1 = write_data;
    end else if(read_flag_1) begin
        output_data_1 = regs[reg_read_1];
    end else begin
        output_data_1 = `ZeroWord;
    end
end

always @(*) begin
    if(rst_in) begin // reset
        output_data_2 = `ZeroWord;
    end else if(reg_read_2 == 5'b0) begin // zero register
        output_data_2 = `ZeroWord;
    end else if(write_flag && reg_write == reg_read_2 && read_flag_2) begin // register same with write
        output_data_2 = write_data;
    end else if(read_flag_2) begin
        output_data_2 = regs[reg_read_2];
    end else begin
        output_data_2 = `ZeroWord;
    end
end

integer i;

always @(posedge clk_in) begin
    if(rst_in) begin
        for(i = 0; i < 32; i=i+1) begin
            regs[i] <= `ZeroWord;
        end
    end else if(!rdy_in) begin
    end else if (write_flag && reg_write) begin
        regs[reg_write] <= write_data;
    end
end

endmodule