// RISCV32I CPU top module
// port modification allowed for debugging purposes

module cpu(
  input  wire                 clk_in,			// system clock signal
  input  wire                 rst_in,			// reset signal
  input  wire				  rdy_in,			// ready signal, pause cpu when low

  input  wire [ 7:0]          mem_din,		// data input bus
  output wire [ 7:0]          mem_dout,		// data output bus
  output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
  output wire                 mem_wr,			// write/read signal (1 for write)
  input  wire                 io_buffer_full, // 1 if uart buffer is full
  output wire [31:0]		  dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read result will be returned in the next cycle. Write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

// link pc_reg, IF

wire[31: 0] pc;

// link IF, IF_ID

wire [31: 0] IF_output_pc;
wire [31: 0] IF_ins;

// link IF_ID, ID

wire [31: 0] IF_ID_pc;
wire [31: 0] IF_ID_ins;

// link ID, ID_EX

wire [31: 0]  ID_output_pc;
wire [4: 0]   ID_r1_addr;
wire [31: 0]  ID_r1_data;
wire [4: 0]   ID_r2_addr;
wire [31: 0]  ID_r2_data;
wire [31: 0]  ID_rd_addr;
wire [31: 0]  ID_imm;
wire [6: 0]   ID_ins_type;
wire [2: 0]   ID_ins_details;
wire          ID_ins_diff;

// link ID_EX, EX

wire [31: 0]   ID_EX_output_pc;
wire [31: 0]   ID_EX_output_r1_data;
wire [31: 0]   ID_EX_output_r2_data;
wire [4: 0]    ID_EX_output_rd_addr;
wire [31: 0]   ID_EX_output_imm;
wire [6: 0]    ID_EX_output_ins_type;
wire [2: 0]    ID_EX_output_ins_details;
wire           ID_EX_output_ins_diff;

// link EX, EX_MEM

wire [4: 0]    EX_output_rd_addr;
wire [31: 0]   EX_rd_val;
wire [6: 0]    EX_output_ins_type;
wire [2: 0]    EX_output_ins_details;
wire  [31: 0]  EX_mem_addr;
wire  [31: 0]  EX_mem_val;
wire           EX_stall_id;

// link EX_MEM, MEM

wire           EX_MEM_output_forward;
wire [4: 0]    EX_MEM_output_rd_addr;
wire [31: 0]   EX_MEM_output_rd_val;
wire [6: 0]    EX_MEM_output_ins_type;
wire [2: 0]    EX_MEM_output_ins_details;
wire [31: 0]   EX_MEM_output_mem_addr;
wire [31: 0]   EX_MEM_output_mem_val;

// link MEM, MEM_WB

wire [4: 0]     MEM_output_rd_addr;
wire [31: 0]    MEM_output_rd_val;
wire [6: 0]     MEM_output_ins_type;

// link MEM_WB, WB

wire [4: 0]     MEM_WB_output_rd_addr;
wire [31: 0]    MEM_WB_output_rd_val;
wire [6: 0]     MEM_WB_output_ins_type;

// link ALU

wire [1: 0]    alu_ins_type;
wire [2: 0]    alu_ins_details;
wire           alu_ins_diff;
wire [31: 0]   alu_r1;
wire [31: 0]   alu_r2;
wire[31: 0]    alu_out;


// link regfiles

wire            write_flag;
wire [4: 0]     reg_write;
wire [31: 0]    write_data;

wire            read_flag_1;
wire [4: 0]     reg_read_1;
wire[31: 0]     output_data_1;

wire            read_flag_2;
wire [4: 0]     reg_read_2;
wire[31: 0]     output_data_2;

// link stall_bus

wire            stall_IF;
wire            stall_ID;
wire            stall_MEM;
wire            stall_bus_output;

// link forwarding

wire            EX_forward_enabled; // read EX_forward info from EX, EX_MEM
wire            MEM_forward_enabled;
wire [4: 0]     MEM_forward_rd_addr;
wire [31: 0]    MEM_forward_rd_val;

// jmp

wire            EX_take_jmp;
wire [31: 0]    EX_jmp_pc;

// MEM_Control

wire [1: 0]      MEMCTL_IF_op;
wire [1: 0]      MEMCTL_IF_len;
wire [31: 0]     MEMCTL_IF_addr;
wire             MEMCTL_IF_rdy;
wire [31: 0]     MEMCTL_IF_out;

wire  [1: 0]     MEMCTL_MEM_op;
wire  [1: 0]     MEMCTL_MEM_len;
wire  [31: 0]    MEMCTL_MEM_addr;
wire  [31: 0]    MEMCTL_MEM_data;
wire             MEMCTL_MEM_rdy;
wire  [31: 0]    MEMCTL_MEM_out;

// modules

MEM_Control MEM_Control0(
    .clk_in(clk_in), .rst_in(rst_in), .rdy_in(rdy_in),
    .IF_op(MEMCTL_IF_op), .IF_len(MEMCTL_IF_len), .IF_addr(MEMCTL_IF_addr), .IF_rdy(MEMCTL_IF_rdy), .IF_out(MEMCTL_IF_out),
    .MEM_op(MEMCTL_MEM_op), .MEM_len(MEMCTL_MEM_len), .MEM_addr(MEMCTL_MEM_addr), .MEM_data(MEMCTL_MEM_data), .MEM_rdy(MEMCTL_MEM_rdy), .MEM_out(MEMCTL_MEM_out),
    .mem_din(mem_din), .mem_dout(mem_dout), .mem_a(mem_a), .mem_wr(mem_wr)
);

regfile regfile0(
    .clk_in(clk_in), .rst_in(rst_in), .rdy_in(rdy_in),
    .write_flag(write_flag), .reg_write(reg_write), .write_data(write_data),
    .read_flag_1(read_flag_1), .reg_read_1(reg_read_1), .output_data_1(output_data_1),
    .read_flag_2(read_flag_2), .reg_read_2(reg_read_2), .output_data_2(output_data_2)
);

stall_bus stall_bus0(
    .clk_in(clk_in), .rst_in(rst_in), .rdy_in(rdy_in),
    .stall_IF(stall_IF), .stall_ID(stall_ID), .stall_MEM(stall_MEM),
    .output_stall(stall_bus_output)
);

pc_reg pc_reg0(
    .clk_in(clk_in), .rst_in(rst_in), .rdy_in(rdy_in),
    .stall(stall_bus_output), .jmp_tak(EX_take_jmp), .jmp_tar(EX_jmp_pc),
    .output_pc(pc)
);

IF IF0(
    .clk_in(clk_in), .rst_in(rst_in), .rdy_in(rdy_in),
    .memctl_op(MEMCTL_IF_op), .memctl_len(MEMCTL_IF_len), .memctl_addr(MEMCTL_IF_addr), .memctl_rdy(MEMCTL_IF_rdy), .memctl_out(MEMCTL_IF_out),
    .input_pc(pc), .stall(stall_IF), .output_pc(IF_output_pc), .ins(IF_ins)
);

IF_ID IF_ID0(
    .clk_in(clk_in), .rst_in(rst_in), .rdy_in(rdy_in),
    .stall(stall_bus_output), .clear(EX_take_jmp),
    .if_pc(IF_output_pc), .if_ins(IF_ins),
    .id_pc(IF_ID_pc), .id_ins(IF_ID_ins)
);

ID ID0(
    .clk_in(clk_in), .rst_in(rst_in), .rdy_in(rdy_in),
    .pc(IF_ID_pc), .ins(IF_ID_ins),
    .read_flag_1(read_flag_1), .reg_read_1(reg_read_1), .read_data_1(output_data_1),
    .read_flag_2(read_flag_2), .reg_read_2(reg_read_2), .read_data_2(output_data_2),
    .is_mem(EX_stall_id), .stall(stall_ID),
    .output_pc(ID_output_pc), .r1_addr(ID_r1_addr), .r1_data(ID_r1_data), .r2_addr(ID_r2_addr), .r2_data(ID_r2_data),
    .rd_addr(ID_rd_addr), .imm(ID_imm), .ins_type(ID_ins_type), .ins_details(ID_ins_details), .ins_diff(ID_ins_diff)
);

ID_EX ID_EX0(
    .clk_in(clk_in), .rst_in(rst_in), .rdy_in(rdy_in),

    .clear(EX_take_jmp), .stall(stall_bus_output),

    .forward_ex_enable(EX_forward_enabled), .forward_ex_addr(EX_output_rd_addr), .forward_ex_data(EX_output_rd_val),
    .forward_mem_enable(MEM_forward_enabled), .forward_mem_addr(MEM_forward_rd_addr), .forward_mem_data(MEM_forward_rd_val),

    .pc(ID_output_pc), .r1_addr(ID_r1_addr), .r1_data(ID_r1_data), .r2_addr(ID_r2_addr), .r2_data(ID_r2_data), .rd_addr(ID_rd_addr),
    .imm(ID_imm), .ins_type(ID_ins_type), .ins_details(ID_ins_details), .ins_diff(ID_ins_diff),

    .output_pc(ID_EX_output_pc), .output_r1_data(ID_EX_output_r1_data), .output_r2_data(ID_EX_output_r2_data), .output_rd_addr(ID_EX_output_rd_addr),
    .output_imm(ID_EX_output_imm), .output_ins_type(ID_EX_output_ins_type), .output_ins_details(ID_EX_output_ins_details), .output_ins_diff(ID_EX_output_ins_diff)
);

EX EX0(
    .clk_in(clk_in), .rst_in(rst_in), .rdy_in(rdy_in),

    .pc(ID_EX_output_pc), .r1_data(ID_EX_output_r1_data), .r2_data(ID_EX_output_r2_data), .rd_addr(ID_EX_output_rd_addr),
    .imm(ID_EX_output_imm), .ins_type(ID_EX_output_ins_type), .ins_details(ID_EX_output_ins_details), .ins_diff(ID_EX_output_ins_diff),

    .alu_ins_type(alu_ins_type), .alu_ins_details(alu_ins_details), .alu_ins_diff(alu_ins_diff),
    .alu_r1(alu_r1), .alu_r2(alu_r2), .alu_out(alu_out),

    .take_jmp(EX_take_jmp), .jmp_pc(EX_jmp_pc), .forward(EX_forward_enabled), .stall_id(EX_stall_id),

    .output_rd_addr(EX_output_rd_addr), .rd_val(EX_rd_val), .output_ins_type(EX_output_ins_type), .output_ins_details(EX_output_ins_details),
    .mem_addr(EX_mem_addr), .mem_val(EX_mem_val)
);

ALU ALU0(
    .clk_in(clk_in), .rst_in(rst_in), .rdy_in(rdy_in),

    .ins_type(alu_ins_type), .ins_details(alu_ins_details), .ins_diff(alu_ins_diff),
    .r1(alu_r1), .r2(alu_r2), .out(alu_out)
);

EX_MEM EX_MEM0(
    .clk_in(clk_in), .rst_in(rst_in), .rdy_in(rdy_in),

    .stall(stall_bus_output),

    .forward(EX_forward_enabled), .rd_addr(EX_output_rd_addr), .rd_val(EX_rd_val),
    .ins_type(EX_output_ins_type), .ins_details(EX_output_ins_details), .mem_addr(EX_mem_addr), .mem_val(EX_mem_val),

    .output_forward(EX_MEM_output_forward), .output_rd_addr(EX_MEM_output_rd_addr), .output_rd_val(EX_MEM_output_ins_type),
    .output_ins_type(EX_MEM_output_ins_type), .output_ins_details(EX_MEM_output_ins_details),
    .output_mem_addr(EX_MEM_output_mem_addr), .output_mem_val(EX_MEM_output_mem_val)
);

MEM MEM0(
    .clk_in(clk_in), .rst_in(rst_in), .rdy_in(rdy_in),

    .memctl_op(MEMCTL_MEM_op), .memctl_len(MEMCTL_MEM_len), .memctl_addr(MEMCTL_MEM_addr),
    .memctl_data(MEMCTL_MEM_data), .memctl_fin(MEMCTL_MEM_rdy), .memctl_out(MEMCTL_MEM_out),

    .forward(EX_MEM_output_forward), .rd_addr(EX_MEM_output_rd_addr), .rd_val(EX_MEM_output_rd_val),
    .ins_type(EX_MEM_output_ins_type), .ins_details(EX_MEM_output_ins_details), .mem_addr(EX_MEM_output_mem_addr), .mem_val(EX_MEM_output_mem_val),

    .output_forward(MEM_forward_enabled), .forward_rd_addr(MEM_forward_rd_addr), .forward_rd_val(MEM_forward_rd_val),

    .output_rd_addr(MEM_output_rd_addr), .output_rd_val(MEM_output_rd_val), .output_ins_type(MEM_output_ins_type),

    .stall(stall_MEM)
);

MEM_WB MEM_WB0(
    .clk_in(clk_in), .rst_in(rst_in), .rdy_in(rdy_in),

    .stall(stall_bus_output),

    .rd_addr(MEM_output_rd_addr), .rd_val(MEM_output_rd_val), .ins_type(MEM_output_ins_type),

    .output_rd_addr(MEM_WB_output_rd_addr), .output_rd_val(MEM_WB_output_rd_val), .output_ins_type(MEM_WB_output_ins_type)
);

WB WB0(
    .clk_in(clk_in), .rst_in(rst_in), .rdy_in(rdy_in),

    .rd_addr(MEM_WB_output_rd_addr), .rd_val(MEM_output_rd_val), .ins_type(MEM_output_ins_type),

    .write_enable(write_flag), .write_addr(reg_write), .write_data(write_data)
);

endmodule