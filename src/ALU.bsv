package ALU;

import Decode :: *;

typedef struct {
  Instr instr;
  Bit#(32) rs1;
  Bit#(32) rs2;
} ALU_Query deriving(Bits, FShow, Eq);

function Bit#(32) fn_ALU(ALU_Query query);
  Instr instr = query.instr;
  Bit#(32) rs1 = query.rs1;
  Bit#(32) rs2 = query.rs2;

  Int#(32) i_imm = immediate(instr);
  Bit#(32) imm   = immediateBits(instr);
  Int#(32) i_rs1 = unpack(rs1);
  Int#(32) i_rs2 = unpack(rs2);
  Bit#(5) itype_shamt = imm[4:0];
  Bit#(5) rtype_shamt = rs2[4:0];

  return case (query.instr) matches
    tagged Itype {op: .op} :
      case (op) matches
        ADDI : rs1 + imm;
        XORI : rs1 ^ imm;
        ORI  : rs1 | imm;
        ANDI : rs1 & imm;
        SLTI : (i_rs1 < i_imm ? 1 : 0);
        SLTIU: (rs1 < imm ? 1 : 0);
        SLLI : rs1 << itype_shamt;
        SRLI : rs1 >> itype_shamt;
        SRAI : signedShiftRight(rs1, itype_shamt);
        default : 0;
      endcase

    tagged Rtype {op: .op} :
      case (op) matches
        ADD  : rs1 + rs2;
        SUB  : rs1 - rs2;
        XOR  : rs1 ^ rs2;
        AND  : rs1 & rs2;
        OR   : rs1 | rs2;
        SLT  : (i_rs1 < i_rs2 ? 1 : 0);
        SLTU : (rs1 < rs2 ? 1 : 0);
        SLL  : rs1 << rtype_shamt;
        SRL  : rs1 >> rtype_shamt;
        SRA  : signedShiftRight(rs1, rtype_shamt);
        default: 0;
      endcase
    default : 0;
  endcase;
endfunction


endpackage
