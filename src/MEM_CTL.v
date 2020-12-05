module MEM_Control (
  input  wire                 clk_in,			// system clock signal
  input  wire                 rst_in,			// reset signal
  input  wire				  rdy_in,			// ready signal, pause cpu when low

  inout  wire [1: 0]     IF_op,
  input  wire [1: 0]     IF_len,
  input  wire [31: 0]    IF_addr,
  output reg             IF_rdy,
  output reg [31: 0]     IF_out,

  input wire  [1: 0]     MEM_op,
  input wire  [1: 0]     MEM_len,
  input wire  [31: 0]    MEM_addr,
  input wire  [31: 0]    MEM_data,
  output reg             MEM_rdy,
  output reg  [31: 0]    MEM_out,

  input  wire [ 7:0]          mem_din,		// data input bus
  output wire [ 7:0]          mem_dout,		// data output bus
  output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
  output wire                 mem_wr			// write/read signal (1 for write)
);

reg[3: 0]  curSta;
reg[31: 0] data;
reg[31: 0] addr;
reg[1: 0]  op;
reg[1: 0]  len;
reg        source;
reg[4: 0]  shift;


always @(posedge clk_in) begin
    if(rst_in) begin
    end else begin
        case(curSta)
            `MEM_INIT: begin
                shift = 5'h0;
                if(MEM_op != `MEM_NOP) begin
                    MEM_rdy <= 1'b0;
                    IF_rdy <= 1'b0;

                    op <= MEM_op;
                    addr <= MEM_addr + 4;
                    data <= (MEM_op == `MEM_SAVE ? MEM_data : `ZeroWord) >> 8;
                    len <= MEM_len;
                    source <= 1'b1;

                    mem_a <= MEM_addr;
                    mem_wr <= MEM_op == `MEM_SAVE ? 0'b1 : 0'b0;
                    mem_dout <= (MEM_op == `MEM_SAVE ? MEM_data[7: 0] : 8'h0);

                    case(MEM_len)
                        `MEM_WORD: begin
                            curSta <= MEM_R1S2;
                        end
                        `MEM_HALF: begin
                            curSta <= MEM_R3S4;
                        end
                        `MEM_BYTE: begin
                            curSta <= MEM_R4;
                        end
                    endcase
                end else begin
                    MEM_rdy <= 1'b1;
                    IF_rdy <= 1'b0;

                    op <= IF_op;
                    addr <= IF_addr + 4;
                    data <= `ZeroWord;
                    len <= IF_len;
                    source <= 1'b0;

                    mem_a <= IF_addr;
                    mem_wr <= 0'b0;
                    mem_dout <= 8'h0;

                    curSta <= MEM_R1S2;
                end
            end
            `MEM_R1S2: begin
                if(op == `MEM_LOAD) begin
                    data <= data | (mem_din << shift);
                    mem_a <= addr;
                    addr <= addr + 4;
                    mem_wr <= 1'b0;
                end else begin
                    mem_dout <= data[7: 0];
                    data <= data >> 8;
                    mem_a <= addr;
                    addr <= addr + 4;
                    mem_wr <= 1'b1;
                end
                shift <= shift + 4;

                curSta <= `MEM_R2S3;
            end
            `MEM_R2S3: begin
                if(op == `MEM_LOAD) begin
                    data <= data | (mem_din << shift);
                    mem_a <= addr;
                    addr <= addr + 4;
                    mem_wr <= 1'b0;
                end else begin
                    mem_dout <= data[7: 0];
                    data <= data >> 8;
                    mem_a <= addr;
                    addr <= addr + 4;
                    mem_wr <= 1'b1;
                end
                shift <= shift + 4;

                curSta <= `MEM_R3S4;
            end
            `MEM_R3S4: begin
                if(op == `MEM_LOAD) begin
                    data <= data | (mem_din << shift);
                    mem_a <= addr;
                    addr <= addr + 4;
                    mem_wr <= 1'b0;
                end else begin
                    mem_dout <= data[7: 0];
                    data <= data >> 8;
                    mem_a <= addr;
                    addr <= addr + 4;
                    mem_wr <= 1'b1;
                end
                shift <= shift + 4;

                curSta <= `MEM_R4;
            end
            `MEM_R4: begin
                if(op == `MEM_LOAD) begin
                    data <= data | (mem_din << shift);
                    mem_wr <= 1'b0;
                end

                if(source) begin
                    MEM_rdy <= 1'b1;
                    if(op == `MEM_LOAD) begin
                        MEM_out <= data;
                    end
                end else begin
                    IF_rdy <= 1'b1;
                    IF_out <= data;
                end
                mem_a <= `ZeroWord;
                mem_wr <= 0'b0;
                mem_dout <= 8'h00;
            end
        endcase
    end
end

endmodule