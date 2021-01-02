module MEM_Control (
  input  wire                 clk_in,			// system clock signal
  input  wire                 rst_in,			// reset signal
  input  wire				  rdy_in,			// ready signal, pause cpu when low

  input  wire            take_jmp,
  input  wire [1: 0]     IF_op,
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
  output reg  [ 7:0]          mem_dout,		// data output bus
  output reg  [31:0]          mem_a,			// address bus (only 17:0 is used)
  output reg                  mem_wr			// write/read signal (1 for write)
);

reg[3: 0]  curSta;
reg[31: 0] data;
reg[31: 0] addr;
reg[1: 0]  op;
reg[1: 0]  len;
reg        source;
reg        mem_just_finished;


always @(posedge clk_in) begin
    if(rst_in) begin
        curSta <= `MEM_INIT;
        mem_just_finished <= 1'b0;
        IF_rdy <= 1'b0;
        MEM_rdy <= 1'b0;
    end else begin
        if(take_jmp) begin
            curSta <= `MEM_INIT;
        end else begin
            case(curSta)
                `MEM_STALL1: begin
                    MEM_rdy <= 1'b0;
                    IF_rdy <= 1'b0;
                    curSta <= `MEM_STALL2;
                end
                `MEM_STALL2: begin
                    curSta <= `MEM_INIT;
                end
                `MEM_INIT: begin
                    if(MEM_op != `MEM_NOP && !mem_just_finished) begin
                        MEM_rdy <= 1'b0;
                        IF_rdy <= 1'b0;

                        op <= MEM_op;
                        addr <= MEM_addr + 2;
                        data <= (MEM_op == `MEM_SAVE ? MEM_data : `ZeroWord) >> 8;
                        len <= MEM_len;
                        source <= 1'b1;

                        mem_a <= MEM_addr + 3;
                        mem_wr <= MEM_op == `MEM_SAVE ? 1'b1 : 1'b0;
                        mem_dout <= (MEM_op == `MEM_SAVE ? MEM_data[7: 0] : 8'h0);

                        case(MEM_len)
                            `MEM_WORD: begin
                                curSta <= `MEM_R1S2;
                            end
                            `MEM_HALF: begin
                                curSta <= `MEM_R3S4;
                            end
                            `MEM_BYTE: begin
                                curSta <= `MEM_R4;
                            end
                        endcase
                        mem_just_finished = 1'b1;
                    end else begin
                        IF_rdy <= 1'b0;

                        op <= IF_op;
                        addr <= IF_addr + 2;
                        data <= `ZeroWord;
                        len <= IF_len;
                        source <= 1'b0;

                        mem_a <= IF_addr + 3;
                        mem_wr <= 1'b0;
                        mem_dout <= 8'h0;

                        curSta <= `MEM_R1S2;
                        mem_just_finished = 1'b0;
                    end
                end
                `MEM_R1S2: begin
                    curSta <= `MEM_R1S2A;
                end
                `MEM_R1S2A: begin
                    if(op == `MEM_LOAD) begin
                        data <= (data << 8) | mem_din;
                        mem_a <= addr;
                        addr <= addr - 1;
                        mem_wr <= 1'b0;
                    end else begin
                        mem_dout <= data[7: 0];
                        data <= data >> 8;
                        mem_a <= addr;
                        addr <= addr - 1;
                        mem_wr <= 1'b1;
                    end

                    curSta <= `MEM_R2S3;
                end
                `MEM_R2S3: begin
                    curSta <= `MEM_R2S3A;
                end
                `MEM_R2S3A: begin
                    if(op == `MEM_LOAD) begin
                        data <= (data << 8) | mem_din;
                        mem_a <= addr;
                        addr <= addr - 1;
                        mem_wr <= 1'b0;
                    end else begin
                        mem_dout <= data[7: 0];
                        data <= data >> 8;
                        mem_a <= addr;
                        addr <= addr - 1;
                        mem_wr <= 1'b1;
                    end

                    curSta <= `MEM_R3S4;
                end
                `MEM_R3S4: begin
                    curSta <= `MEM_R3S4A;
                end
                `MEM_R3S4A: begin
                    if(op == `MEM_LOAD) begin
                        data <= (data << 8) | mem_din;
                        mem_a <= addr;
                        addr <= addr - 1;
                        mem_wr <= 1'b0;
                    end else begin
                        mem_dout <= data[7: 0];
                        data <= data >> 8;
                        mem_a <= addr;
                        addr <= addr - 1;
                        mem_wr <= 1'b1;
                    end

                    curSta <= `MEM_R4;
                end
                `MEM_R4: begin
                    curSta <= `MEM_R4A;
                end
                `MEM_R4A: begin
                    if(source) begin
                        MEM_rdy <= 1'b1;
                        if(op == `MEM_LOAD) begin
                            MEM_out <= (data << 8) | mem_din;
                        end
                    end else begin
                        IF_rdy <= 1'b1;
                        IF_out <= (data << 8) | mem_din;
                    end
                    mem_a <= `ZeroWord;
                    mem_wr <= 1'b0;
                    mem_dout <= 8'h00;
                    
                    curSta = `MEM_STALL1;
                end
            endcase
        end
    end
end

endmodule