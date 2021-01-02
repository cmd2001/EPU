`define ChipRst 1'b1
`define ChipRdy 1'b1
`define MemoryRead 1'b0
`define MemoryWrite 1'b1
`define UartFull 1`b1

// instruction types
`define LUI 7'b0110111
`define AUIPC 7'b0010111
`define JAL 7'b1101111
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
`define SRLI_SRAI 3'b101
`define SRLI_Diff 1'b0
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

// stall bus and stage clear
`define StageClear 1'b1

// nop
`define NOP_PC 32'h0000
`define NOP_INS 32'b00000000000000000000000000010011

// regfiles
`define ZeroWord 32'h0000

// ALU
`define ALU_NOP 2'b00
`define ALU_CMP 2'b01
`define ALU_ALUOPI 2'b10
`define ALU_ALUOP 2'b11
`define TrueWord 32'h0001
`define FalseWord 32'h0000

// memctl
`define MEM_NOP 2'b00
`define MEM_LOAD 2'b01
`define MEM_SAVE 2'b10
`define MEM_BYTE 2'b01
`define MEM_HALF 2'b10
`define MEM_WORD 2'b11

// memctl2
`define MEM_INIT 4'b0000
`define MEM_R1S2 4'b0001
`define MEM_R2S3 4'b0010
`define MEM_R3S4 4'b0011
`define MEM_R4 4'b0100

`define MEM_R1S2A 4'b1001
`define MEM_R2S3A 4'b1010
`define MEM_R3S4A 4'b1011
`define MEM_R4A 4'b1100
`define MEM_STALL1 4'b1000
`define MEM_STALL2 4'b1111
`define MEM_HIT 4'b1110
`define MEM_HIT2 4'b0111

// stall bus
`define STALL_MEM 3'b001
`define STALL_ID 3'b010
`define STALL_IF 3'b100
`define STALL_MASK_PCREG 3'b111
`define STALL_MASK_IFID 3'b011
`define STALL_MASK_IDEX_EXMEM 3'b001
