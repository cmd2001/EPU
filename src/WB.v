module WB(
  input  wire           clk_in,
  input  wire           rst_in,
  input  wire           rdy_in,

  input  wire [4: 0]    rd_addr,
  input  wire [31: 0]   rd_val,
  input  wire [6: 0]    ins_type,

  output reg            write_enable,
  output reg [4: 0]     write_addr,
  output reg [31: 0]    write_data
);

always @(*) begin
    if(rst_in) begin
        write_enable = 1'b0;
        write_addr = 5'h0;
        write_data = `ZeroWord;
    end else begin
        if(ins_type != `JMPC && ins_type != `SAVE) begin
            write_enable = 1'b1;
            write_addr = rd_addr;
            write_data = rd_val;
        end else begin
            write_enable = 1'b0;
            write_addr = 5'h0;
            write_data = `ZeroWord;
        end
    end
end
endmodule