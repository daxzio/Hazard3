/*****************************************************************************\
|                        Copyright (C) 2021 Luke Wren                         |
|                     SPDX-License-Identifier: Apache-2.0                     |
\*****************************************************************************/

localparam RV_RS1_LSB = 15;
localparam RV_RS1_BITS = 5;
localparam RV_RS2_LSB = 20;
localparam RV_RS2_BITS = 5;
localparam RV_RD_LSB = 7;
localparam RV_RD_BITS = 5;

// Base ISA (some of these are Z now)
localparam RV_BEQ         = 32'b?????????????????000?????1100011;
localparam RV_BNE         = 32'b?????????????????001?????1100011;
localparam RV_BLT         = 32'b?????????????????100?????1100011;
localparam RV_BGE         = 32'b?????????????????101?????1100011;
localparam RV_BLTU        = 32'b?????????????????110?????1100011;
localparam RV_BGEU        = 32'b?????????????????111?????1100011;
localparam RV_JALR        = 32'b?????????????????000?????1100111;
localparam RV_JAL         = 32'b?????????????????????????1101111;
localparam RV_LUI         = 32'b?????????????????????????0110111;
localparam RV_AUIPC       = 32'b?????????????????????????0010111;
localparam RV_ADDI        = 32'b?????????????????000?????0010011;
localparam RV_SLLI        = 32'b0000000??????????001?????0010011;
localparam RV_SLTI        = 32'b?????????????????010?????0010011;
localparam RV_SLTIU       = 32'b?????????????????011?????0010011;
localparam RV_XORI        = 32'b?????????????????100?????0010011;
localparam RV_SRLI        = 32'b0000000??????????101?????0010011;
localparam RV_SRAI        = 32'b0100000??????????101?????0010011;
localparam RV_ORI         = 32'b?????????????????110?????0010011;
localparam RV_ANDI        = 32'b?????????????????111?????0010011;
localparam RV_ADD         = 32'b0000000??????????000?????0110011;
localparam RV_SUB         = 32'b0100000??????????000?????0110011;
localparam RV_SLL         = 32'b0000000??????????001?????0110011;
localparam RV_SLT         = 32'b0000000??????????010?????0110011;
localparam RV_SLTU        = 32'b0000000??????????011?????0110011;
localparam RV_XOR         = 32'b0000000??????????100?????0110011;
localparam RV_SRL         = 32'b0000000??????????101?????0110011;
localparam RV_SRA         = 32'b0100000??????????101?????0110011;
localparam RV_OR          = 32'b0000000??????????110?????0110011;
localparam RV_AND         = 32'b0000000??????????111?????0110011;
localparam RV_LB          = 32'b?????????????????000?????0000011;
localparam RV_LH          = 32'b?????????????????001?????0000011;
localparam RV_LW          = 32'b?????????????????010?????0000011;
localparam RV_LBU         = 32'b?????????????????100?????0000011;
localparam RV_LHU         = 32'b?????????????????101?????0000011;
localparam RV_SB          = 32'b?????????????????000?????0100011;
localparam RV_SH          = 32'b?????????????????001?????0100011;
localparam RV_SW          = 32'b?????????????????010?????0100011;
localparam RV_FENCE       = 32'b????????????00000000000000001111;
localparam RV_FENCE_I     = 32'b00000000000000000001000000001111;
localparam RV_ECALL       = 32'b00000000000000000000000001110011;
localparam RV_EBREAK      = 32'b00000000000100000000000001110011;
localparam RV_CSRRW       = 32'b?????????????????001?????1110011;
localparam RV_CSRRS       = 32'b?????????????????010?????1110011;
localparam RV_CSRRC       = 32'b?????????????????011?????1110011;
localparam RV_CSRRWI      = 32'b?????????????????101?????1110011;
localparam RV_CSRRSI      = 32'b?????????????????110?????1110011;
localparam RV_CSRRCI      = 32'b?????????????????111?????1110011;
localparam RV_MRET        = 32'b00110000001000000000000001110011;
localparam RV_SYSTEM      = 32'b?????????????????????????1110011;
localparam RV_WFI         = 32'b00010000010100000000000001110011;

// M extension
localparam RV_MUL         = 32'b0000001??????????000?????0110011;
localparam RV_MULH        = 32'b0000001??????????001?????0110011;
localparam RV_MULHSU      = 32'b0000001??????????010?????0110011;
localparam RV_MULHU       = 32'b0000001??????????011?????0110011;
localparam RV_DIV         = 32'b0000001??????????100?????0110011;
localparam RV_DIVU        = 32'b0000001??????????101?????0110011;
localparam RV_REM         = 32'b0000001??????????110?????0110011;
localparam RV_REMU        = 32'b0000001??????????111?????0110011;

// A extension
localparam RV_LR_W        = 32'b00010??00000?????010?????0101111;
localparam RV_SC_W        = 32'b00011????????????010?????0101111;
localparam RV_AMOSWAP_W   = 32'b00001????????????010?????0101111;
localparam RV_AMOADD_W    = 32'b00000????????????010?????0101111;
localparam RV_AMOXOR_W    = 32'b00100????????????010?????0101111;
localparam RV_AMOAND_W    = 32'b01100????????????010?????0101111;
localparam RV_AMOOR_W     = 32'b01000????????????010?????0101111;
localparam RV_AMOMIN_W    = 32'b10000????????????010?????0101111;
localparam RV_AMOMAX_W    = 32'b10100????????????010?????0101111;
localparam RV_AMOMINU_W   = 32'b11000????????????010?????0101111;
localparam RV_AMOMAXU_W   = 32'b11100????????????010?????0101111;

// Zba (address generation)
localparam RV_SH1ADD      = 32'b0010000??????????010?????0110011;
localparam RV_SH2ADD      = 32'b0010000??????????100?????0110011;
localparam RV_SH3ADD      = 32'b0010000??????????110?????0110011;

// Zbb (basic bit manipulation)
localparam RV_ANDN        = 32'b0100000??????????111?????0110011;
localparam RV_CLZ         = 32'b011000000000?????001?????0010011;
localparam RV_CPOP        = 32'b011000000010?????001?????0010011;
localparam RV_CTZ         = 32'b011000000001?????001?????0010011;
localparam RV_MAX         = 32'b0000101??????????110?????0110011;
localparam RV_MAXU        = 32'b0000101??????????111?????0110011;
localparam RV_MIN         = 32'b0000101??????????100?????0110011;
localparam RV_MINU        = 32'b0000101??????????101?????0110011;
localparam RV_ORC_B       = 32'b001010000111?????101?????0010011;
localparam RV_ORN         = 32'b0100000??????????110?????0110011;
localparam RV_REV8        = 32'b011010011000?????101?????0010011;
localparam RV_ROL         = 32'b0110000??????????001?????0110011;
localparam RV_ROR         = 32'b0110000??????????101?????0110011;
localparam RV_RORI        = 32'b0110000??????????101?????0010011;
localparam RV_SEXT_B      = 32'b011000000100?????001?????0010011;
localparam RV_SEXT_H      = 32'b011000000101?????001?????0010011;
localparam RV_XNOR        = 32'b0100000??????????100?????0110011;
localparam RV_ZEXT_H      = 32'b000010000000?????100?????0110011;

// Zbc (carry-less multiply)
localparam RV_CLMUL       = 32'b0000101??????????001?????0110011;
localparam RV_CLMULH      = 32'b0000101??????????011?????0110011;
localparam RV_CLMULR      = 32'b0000101??????????010?????0110011;

// Zbs (single-bit manipulation)
localparam RV_BCLR        = 32'b0100100??????????001?????0110011;
localparam RV_BCLRI       = 32'b0100100??????????001?????0010011;
localparam RV_BEXT        = 32'b0100100??????????101?????0110011;
localparam RV_BEXTI       = 32'b0100100??????????101?????0010011;
localparam RV_BINV        = 32'b0110100??????????001?????0110011;
localparam RV_BINVI       = 32'b0110100??????????001?????0010011;
localparam RV_BSET        = 32'b0010100??????????001?????0110011;
localparam RV_BSETI       = 32'b0010100??????????001?????0010011;

// Zbkb (basic bit manipulation for crypto) (minus those in Zbb)
localparam RV_PACK        = 32'b0000100??????????100?????0110011;
localparam RV_PACKH       = 32'b0000100??????????111?????0110011;
localparam RV_BREV8       = 32'b011010000111?????101?????0010011;
localparam RV_UNZIP       = 32'b000010001111?????101?????0010011;
localparam RV_ZIP         = 32'b000010001111?????001?????0010011;

// Zbkc is a subset of Zbc.

// Zbkx (crossbar permutation)
localparam RV_XPERM_B     = 32'b0010100??????????100?????0110011;
localparam RV_XPERM_N     = 32'b0010100??????????010?????0110011;

// Hazard3 custom instructions

// Xh3b (Hazard3 custom bitmanip): currently just a multi-bit version of bext/bexti from Zbs
localparam RV_H3_BEXTM    = 32'b000???0??????????000?????0001011; // custom-0 funct3=0
localparam RV_H3_BEXTMI   = 32'b000???0??????????100?????0001011; // custom-0 funct3=4

// C Extension
localparam RV_C_ADDI4SPN  = 16'b000???????????00; // *** illegal if imm 0
localparam RV_C_LW        = 16'b010???????????00;
localparam RV_C_SW        = 16'b110???????????00;

localparam RV_C_ADDI      = 16'b000???????????01;
localparam RV_C_JAL       = 16'b001???????????01;
localparam RV_C_J         = 16'b101???????????01;
localparam RV_C_LI        = 16'b010???????????01;
// addi16sp when rd=2:
localparam RV_C_LUI       = 16'b011???????????01; // *** reserved if imm 0 (for both LUI and ADDI16SP)
localparam RV_C_SRLI      = 16'b100000????????01; // On RV32 imm[5] (instr[12]) must be 0, else reserved NSE.
localparam RV_C_SRAI      = 16'b100001????????01; // On RV32 imm[5] (instr[12]) must be 0, else reserved NSE.
localparam RV_C_ANDI      = 16'b100?10????????01;
localparam RV_C_SUB       = 16'b100011???00???01;
localparam RV_C_XOR       = 16'b100011???01???01;
localparam RV_C_OR        = 16'b100011???10???01;
localparam RV_C_AND       = 16'b100011???11???01;
localparam RV_C_BEQZ      = 16'b110???????????01;
localparam RV_C_BNEZ      = 16'b111???????????01;

localparam RV_C_SLLI      = 16'b0000??????????10; // On RV32 imm[5] (instr[12]) must be 0, else reserved NSE.
// jr if !rs2:
localparam RV_C_MV        = 16'b1000??????????10; // *** reserved if JR and !rs1 (instr[11:7])
// jalr if !rs2:
localparam RV_C_ADD       = 16'b1001??????????10; // *** EBREAK if !instr[11:2]
localparam RV_C_LWSP      = 16'b010???????????10;
localparam RV_C_SWSP      = 16'b110???????????10;

// Copies provided here with 0 instead of ? so that these can be used to build 32-bit instructions in the decompressor

localparam RV_NOZ_BEQ         = 32'b00000000000000000000000001100011;
localparam RV_NOZ_BNE         = 32'b00000000000000000001000001100011;
localparam RV_NOZ_BLT         = 32'b00000000000000000100000001100011;
localparam RV_NOZ_BGE         = 32'b00000000000000000101000001100011;
localparam RV_NOZ_BLTU        = 32'b00000000000000000110000001100011;
localparam RV_NOZ_BGEU        = 32'b00000000000000000111000001100011;
localparam RV_NOZ_JALR        = 32'b00000000000000000000000001100111;
localparam RV_NOZ_JAL         = 32'b00000000000000000000000001101111;
localparam RV_NOZ_LUI         = 32'b00000000000000000000000000110111;
localparam RV_NOZ_AUIPC       = 32'b00000000000000000000000000010111;
localparam RV_NOZ_ADDI        = 32'b00000000000000000000000000010011;
localparam RV_NOZ_SLLI        = 32'b00000000000000000001000000010011;
localparam RV_NOZ_SLTI        = 32'b00000000000000000010000000010011;
localparam RV_NOZ_SLTIU       = 32'b00000000000000000011000000010011;
localparam RV_NOZ_XORI        = 32'b00000000000000000100000000010011;
localparam RV_NOZ_SRLI        = 32'b00000000000000000101000000010011;
localparam RV_NOZ_SRAI        = 32'b01000000000000000101000000010011;
localparam RV_NOZ_ORI         = 32'b00000000000000000110000000010011;
localparam RV_NOZ_ANDI        = 32'b00000000000000000111000000010011;
localparam RV_NOZ_ADD         = 32'b00000000000000000000000000110011;
localparam RV_NOZ_SUB         = 32'b01000000000000000000000000110011;
localparam RV_NOZ_SLL         = 32'b00000000000000000001000000110011;
localparam RV_NOZ_SLT         = 32'b00000000000000000010000000110011;
localparam RV_NOZ_SLTU        = 32'b00000000000000000011000000110011;
localparam RV_NOZ_XOR         = 32'b00000000000000000100000000110011;
localparam RV_NOZ_SRL         = 32'b00000000000000000101000000110011;
localparam RV_NOZ_SRA         = 32'b01000000000000000101000000110011;
localparam RV_NOZ_OR          = 32'b00000000000000000110000000110011;
localparam RV_NOZ_AND         = 32'b00000000000000000111000000110011;
localparam RV_NOZ_LB          = 32'b00000000000000000000000000000011;
localparam RV_NOZ_LH          = 32'b00000000000000000001000000000011;
localparam RV_NOZ_LW          = 32'b00000000000000000010000000000011;
localparam RV_NOZ_LBU         = 32'b00000000000000000100000000000011;
localparam RV_NOZ_LHU         = 32'b00000000000000000101000000000011;
localparam RV_NOZ_SB          = 32'b00000000000000000000000000100011;
localparam RV_NOZ_SH          = 32'b00000000000000000001000000100011;
localparam RV_NOZ_SW          = 32'b00000000000000000010000000100011;
localparam RV_NOZ_FENCE       = 32'b00000000000000000000000000001111;
localparam RV_NOZ_FENCE_I     = 32'b00000000000000000001000000001111;
localparam RV_NOZ_ECALL       = 32'b00000000000000000000000001110011;
localparam RV_NOZ_EBREAK      = 32'b00000000000100000000000001110011;
localparam RV_NOZ_CSRRW       = 32'b00000000000000000001000001110011;
localparam RV_NOZ_CSRRS       = 32'b00000000000000000010000001110011;
localparam RV_NOZ_CSRRC       = 32'b00000000000000000011000001110011;
localparam RV_NOZ_CSRRWI      = 32'b00000000000000000101000001110011;
localparam RV_NOZ_CSRRSI      = 32'b00000000000000000110000001110011;
localparam RV_NOZ_CSRRCI      = 32'b00000000000000000111000001110011;
localparam RV_NOZ_SYSTEM      = 32'b00000000000000000000000001110011;
