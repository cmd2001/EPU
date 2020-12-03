`define ChipRst 1'b1
`define ChipRdy 1'b1
`define MemoryRead 1'b0
`define MemoryWrite 1'b1
`define UartFull 1`b1

// instruction types
`define LUI 7'b0110111
`define AUIPC 7'b0010111
`define JAL 7'b110111
`define JALR 7'b1100111
`define JMPC 7'b1100011
`define LOAD 7'b0000011
`define SAVE 7'b0100011
`define ALOPI 7'b0010011
`define ALOP 7'b0110011


// conditional jump
`define BEQ 3'b000
`define BNE 3'b001
`define BLT 3'b100
`define BGE 3'b101
`define BLTU 3'b110
`define BGEU 3'b111

// memory load
`define LB 3'b000
`define LH 3'b001
`define LW 3'b010
`define LBU 3'b100
`define LHU 3'b101

// memory save
`define SB 3'b000
`define SH 3'b001
`define SW 3'b010

// Arithmetic and Logical Operation with 1 register
`define ADDI 3'b000
`define SLTI 3'b010
`define SLTIU 3'b011
`define XORI 3'b100
`define ORI 3'b110
`define ANDI 3'b111
`define SLLI 3'b001
`define SRLI_SRAI 3'b001
`define SRLT_Diff 1'b0
`define SRAI_Diff 1'b1

// Arithmetic and Logical Operation with 2 registers
`define ADD_SUB 3'b000
`define ADD_Diff 1'b0
`define SUB_Diff 1'b1
`define SLL 3'b001
`define SLT 3'b010
`define SLTU 3'b011
`define XOR 3'b100
`define SRL_SRA 3'b101
`define SRL_Diff 1'b0
`define SRA_Diff 1'b0
`define OR 3'b110
`define AND 3'b111

// memory control operations
`define MEM_READ 1'b0
`define MEM_WRITE 1'b1
`define MEM_BYTE 2'b00
`define MEM_HALF 2'b01
`define MEM_WORD 2'b10