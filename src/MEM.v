module MEM(
  input  wire           clk_in,
  input  wire           rst_in,
  input  wire           rdy_in,


  output reg [1: 0]     memctl_op,
  output reg [1: 0]     memctl_len,
  output reg [31: 0]    memctl_addr,
  output reg [31: 0]    memctl_data,
  input  wire           memctl_fin,
  input  wire [31: 0]   memctl_out,

  input  wire           forward,
  input  wire [4: 0]    rd_addr,
  input  wire [31: 0]   rd_val,
  input  wire [6: 0]    ins_type,
  input  wire [2: 0]    ins_details,
  input  wire [31: 0]   mem_addr,
  input  wire [31: 0]   mem_val,

  output reg            output_forward,
  output reg [4: 0]     forward_rd_addr,
  output reg [31: 0]    forward_rd_val,

  output reg [4: 0]     output_rd_addr,
  output reg [31: 0]    output_rd_val,
  output reg [6: 0]     output_ins_type,
  output reg            stall
);
always @(*) begin
    if(rst_in) begin
        output_forward = 1'b0;
        forward_rd_addr = `ZeroWord;
        forward_rd_val = `ZeroWord;
        output_rd_addr = 5'h0;
        output_rd_val = 5'h0;
        output_ins_type = `ADDI;
        stall = 1'b0;
    end else begin
        output_ins_type = ins_type;
        if(ins_type == `LOAD) begin
            memctl_op = `MEM_LOAD;
            memctl_addr = mem_addr;
            memctl_val = `ZeroWord;
            output_rd_addr = rd_addr;
            case(ins_details)
                `LB: begin
                    memctl_len = `MEM_BYTE;
                    output_rd_addr = rd_addr;
                    if(memctl_fin) begin
                        output_rd_val = {25{memctl_out[7]}, memctl_out[6: 0]};
                        stall = 1'b0;
                    end else begin
                        output_rd_val = `ZeroWord;
                        stall = 1'b1;
                    end
                end
                `LH: begin
                    memctl_len = `MEM_HALF;
                    output_rd_addr = rd_addr;
                    if(memctl_fin) begin
                        output_rd_val = {17{memctl_out[15]}, memctl_out[14: 0]};
                        stall = 1'b0;
                    end else begin
                        output_rd_val = `ZeroWord;
                        stall = 1'b1;
                    end
                end
                `LW: begin
                    memctl_len = `MEM_WORD;
                    output_rd_addr = rd_addr;
                    if(memctl_fin) begin
                        output_rd_val = memctl_out;
                        stall = 1'b0;
                    end else begin
                        output_rd_val = `ZeroWord;
                        stall = 1'b1;
                    end
                end
                `LBU: begin
                    memctl_len = `MEM_BYTE;
                    output_rd_addr = rd_addr;
                    if(memctl_fin) begin
                        output_rd_val = {25{1'b0}, memctl_out[6: 0]};
                        stall = 1'b0;
                    end else begin
                        output_rd_val = `ZeroWord;
                        stall = 1'b1;
                    end
                end
                `LHU: begin
                    memctl_len = `MEM_HALF;
                    output_rd_addr = rd_addr;
                    if(memctl_fin) begin
                        output_rd_val = {17{1'b0}, memctl_out[14: 0]};
                        stall = 1'b0;
                    end else begin
                        output_rd_val = `ZeroWord;
                        stall = 1'b1;
                    end
                end
            endcase
            output_forward = 1'b1;
            forward_rd_addr = rd_addr;
            forward_rd_data = output_rd_val;
        end else if(ins_type == `SAVE) begin
            memctl_op = `MEM_SAVE;
            memctl_addr = mem_addr;
            memctl_val = mem_val;
            output_forward = 1'b0;
            forward_rd_addr = 5'b0;
            forward_rd_data = `ZeroWord;
            case(ins_details)
                `SB: begin
                    memctl_len = `MEM_BYTE;
                    stall = memctl_fin ? 1'b0 : 1'b1;
                end
                `SH: begin
                    memctl_len = `MEM_HALF;
                    stall = memctl_fin ? 1'b0 : 1'b1;
                end
                `SW: begin
                    memctl_len = `MEM_WORD;
                    stall = memctl_fin ? 1'b0 : 1'b1;
                end
            endcase
        end else begin
            output_forward = forward;
            forward_rd_addr = rd_addr;
            forward_rd_val = rd_val;
            output_rd_addr = rd_addr;
            output_rd_val = rd_val;
            stall = 1'b0;
        end
    end
end

endmodule