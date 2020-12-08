module ID_EX(
  input  wire           clk_in,
  input  wire           rst_in,
  input  wire           rdy_in,
  input  wire           clear,

  input  wire           stall,

  inout  wire           forward_ex_enable,
  inout  wire [4: 0]    forward_ex_addr,
  input  wire [31: 0]   forward_ex_data,

  input  wire           forward_mem_enable,
  input  wire [4: 0]    forward_mem_addr,
  input  wire [31: 0]   forward_mem_data,

  input  wire [31: 0]   pc,
  input  wire [4: 0]    r1_addr,
  input  wire [31: 0]   r1_data,
  input  wire [4: 0]    r2_addr,
  input  wire [31: 0]   r2_data,
  input  wire [4: 0]    rd_addr,
  input  wire [31: 0]   imm,
  input  wire [6: 0]    ins_type,
  input  wire [2: 0]    ins_details,
  input  wire           ins_diff,

  output  reg [31: 0]   output_pc,
  output  reg [31: 0]   output_r1_data,
  output  reg [31: 0]   output_r2_data,
  output  reg [4: 0]    output_rd_addr,
  output  reg [31: 0]   output_imm,
  output  reg [6: 0]    output_ins_type,
  output  reg [2: 0]    output_ins_details,
  output  reg           output_ins_diff
);

always @(posedge clk_in) begin
    if(rst_in || clear) begin // output NOP
        output_r1_data <= `ZeroWord;
        output_r2_data <= `ZeroWord;
        output_rd_addr <= 0'h0;
        output_imm <= `ZeroWord;
        output_ins_type <= `ADDI;
        output_ins_details <= 3'h0;
        output_ins_diff <= 1'h0;
    end else begin
        if(!stall) begin
            output_rd_addr <= rd_addr;
            output_imm <= imm;
            output_ins_type <= ins_type;
            output_ins_details <= ins_details;
            output_ins_diff <= ins_diff;

            if(forward_mem_enable && forward_ex_enable) begin
                output_r1_data <= r1_addr == forward_ex_addr ? forward_ex_data : (r1_addr == forward_mem_addr ? forward_mem_data : r1_data);
                output_r2_data <= r2_addr == forward_ex_addr ? forward_ex_data : (r2_addr == forward_mem_addr ? forward_mem_data : r2_data);
            end else if(forward_ex_enable) begin
                output_r1_data <= r1_addr == forward_ex_addr ? forward_ex_data : r1_data;
                output_r2_data <= r2_addr == forward_ex_addr ? forward_ex_data : r2_data;
            end else if(forward_mem_enable) begin
                output_r1_data <= r1_addr == forward_mem_addr ? forward_mem_data : r1_data;
                output_r2_data <= r2_addr == forward_mem_addr ? forward_mem_data : r2_data;
            end
        end
    end
end

endmodule