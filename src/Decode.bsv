package Decode;

import List :: *;
import Array :: *;

typedef struct { Bit#(5) name; } RegName deriving(Eq);

instance Bits#(RegName, 5);
  function Bit#(5) pack(RegName r);
    return  r.name;
  endfunction

  function RegName unpack(Bit#(5) r);
    return RegName{name: r};
  endfunction
endinstance

instance FShow#(RegName);
  function Fmt fshow(RegName r);
    String strs[32] = {
      "zero", "ra", "sp", "gp",
      "tp", "t0", "t1", "t2", "s0", "s1", "a0",
      "a1", "a2", "a3", "a4", "a5", "a6", "a7",
      "s2", "s3", "s4", "s5", "s6", "s7", "s8",
      "s9", "s10", "s11", "t3", "t4", "t5", "t6"
    };

    return $format(strs[r.name]);
  endfunction
endinstance

typedef Bit#(7) Opcode;

typedef enum {
  Rtype,
  Itype,
  Stype,
  Btype,
  Utype,
  Jtype
} Optype deriving(Bits, FShow, Eq);

function Maybe#(Optype) opcodeType(Opcode opcode);
  return case (opcode)
    7'b0000011 : Valid(Itype); // LOAD
    7'b0000111 : Invalid;     // LOAD-FP
    7'b0001011 : Invalid;     // custom-0
    7'b0001111 : Valid(Itype); // MISC-MEM (FENCE and FENCE_I)
    7'b0010011 : Valid(Itype); // OP-IMM
    7'b0010111 : Valid(Utype); // AUIPC
    7'b0011011 : Invalid;     // OP-IMM-32
    7'b0011111 : Invalid;     // 48b

    7'b0100011 : Valid(Stype); // STORE
    7'b0100111 : Invalid;     // STORE-FP
    7'b0101011 : Invalid;     // custom-1
    7'b0101111 : Invalid;     // AMO
    7'b0110011 : Valid(Rtype); // OP
    7'b0110111 : Valid(Utype); // LUI
    7'b0111011 : Invalid;     // OP-32
    7'b0111111 : Invalid;     // 64b

    7'b1000011 : Invalid;    // MADD (no float)
    7'b1000111 : Invalid;    // MSUB (no float)
    7'b1001011 : Invalid;    // NMSUB (no float)
    7'b1001111 : Invalid;    // NMADD (no float)
    7'b1010011 : Invalid;    // OP-FP (no float)
    7'b1010111 : Invalid;    // reserved
    7'b1011011 : Invalid;    // custom2/rv128
    7'b1011111 : Invalid;    // 48b

    7'b1100011 : Valid(Btype); // BRANCH
    7'b1100111 : Valid(Itype); // JALR
    7'b1101011 : Invalid;     // reserved
    7'b1101111 : Valid(Jtype); // JAL
    7'b1110011 : Valid(Itype); // SYSTEM
    7'b1110111 : Invalid;     // reserved
    7'b1111011 : Invalid;     // custom3/rv128
    7'b1111111 : Invalid;     // 64b

    default : Invalid; // Compressed instruction
  endcase;
endfunction

function Opcode getOpcode(Bit#(32) instr);
  return instr[6:0];
endfunction

function Bit#(3) getFunct3(Bit#(32) instr);
  return instr[14:12];
endfunction

function Bit#(7) getFunct7(Bit#(32) instr);
  return instr[31:25];
endfunction

function RegName getRs1(Bit#(32) instr);
  return unpack(instr[19:15]);
endfunction

function RegName getRs2(Bit#(32) instr);
  return unpack(instr[24:20]);
endfunction

function RegName getRs3(Bit#(32) instr);
  return unpack(instr[31:27]);
endfunction

function RegName getRd(Bit#(32) instr);
  return unpack(instr[11:7]);
endfunction

typeclass HasImmediate#(type t);
  function Bit#(32) immediateBits(t value);
    return pack(immediate(value));
  endfunction

  function Int#(32) immediate(t value);
    return unpack(immediateBits(value));
  endfunction
endtypeclass

typeclass HasOpcode#(type t);
  function Opcode opcode(t value);
endtypeclass

typeclass HasRegister1#(type t);
  function RegName register1(t value);
endtypeclass

typeclass HasRegister2#(type t);
  function RegName register2(t value);
endtypeclass

typeclass HasRegister3#(type t);
  function RegName register3(t value);
endtypeclass

typeclass HasDestination#(type t);
  function RegName destination(t value);
endtypeclass

typeclass HasFunction3#(type t);
  function Bit#(3) function3(t value);
endtypeclass

typeclass HasFunction7#(type t);
  function Bit#(7) function7(t value);
endtypeclass


typedef struct {Bit#(32) bits;} Rtype deriving(Eq, FShow);
typedef struct {Bit#(32) bits;} Itype deriving(Eq, FShow);
typedef struct {Bit#(32) bits;} Stype deriving(Eq, FShow);
typedef struct {Bit#(32) bits;} Btype deriving(Eq, FShow);
typedef struct {Bit#(32) bits;} Utype deriving(Eq, FShow);
typedef struct {Bit#(32) bits;} Jtype deriving(Eq, FShow);

// Show that each instruction type may be serialized

instance Bits#(Rtype, 32);
  function Bit#(32) pack(Rtype instr); return instr.bits; endfunction

  function Rtype unpack(Bit#(32) bits); return Rtype{bits:bits}; endfunction
endinstance

instance Bits#(Stype, 32);
  function Bit#(32) pack(Stype instr); return instr.bits; endfunction

  function Stype unpack(Bit#(32) bits); return Stype{bits:bits}; endfunction
endinstance

instance Bits#(Itype, 32);
  function Bit#(32) pack(Itype instr); return instr.bits; endfunction

  function Itype unpack(Bit#(32) bits); return Itype{bits:bits}; endfunction
endinstance

instance Bits#(Btype, 32);
  function Bit#(32) pack(Btype instr); return instr.bits; endfunction

  function Btype unpack(Bit#(32) bits); return Btype{bits:bits}; endfunction
endinstance

instance Bits#(Utype, 32);
  function Bit#(32) pack(Utype instr); return instr.bits; endfunction

  function Utype unpack(Bit#(32) bits); return Utype{bits:bits}; endfunction
endinstance

instance Bits#(Jtype, 32);
  function Bit#(32) pack(Jtype instr); return instr.bits; endfunction

  function Jtype unpack(Bit#(32) bits); return Jtype{bits:bits}; endfunction
endinstance

// Show that some instructions have a function3 field

instance HasFunction3#(Rtype);
  function Bit#(3) function3(Rtype instr); return getFunct3(instr.bits); endfunction
endinstance

instance HasFunction3#(Itype);
  function Bit#(3) function3(Itype instr); return getFunct3(instr.bits); endfunction
endinstance

instance HasFunction3#(Stype);
  function Bit#(3) function3(Stype instr); return getFunct3(instr.bits); endfunction
endinstance

instance HasFunction3#(Btype);
  function Bit#(3) function3(Btype instr); return getFunct3(instr.bits); endfunction
endinstance

// Show that some instruction types has a function7 field

instance HasFunction7#(Rtype);
  function Bit#(7) function7(Rtype instr); return getFunct7(instr.bits); endfunction
endinstance

// Show that some instruction types has an immediate

instance HasImmediate#(Itype);
  function Bit#(32) immediateBits(Itype instr);
    return signExtend(instr.bits[31:20]);
  endfunction
endinstance

instance HasImmediate#(Stype);
  function Bit#(32) immediateBits(Stype instr);
    return signExtend({instr.bits[31:25], instr.bits[11:7]});
  endfunction
endinstance

instance HasImmediate#(Btype);
  function Bit#(32) immediateBits(Btype instr);
    let imm = {instr.bits[31:31], instr.bits[7:7], instr.bits[30:25], instr.bits[11:8]};
    return signExtend({imm, 1'b0});
  endfunction
endinstance

instance HasImmediate#(Utype);
  function Bit#(32) immediateBits(Utype instr);
    return signExtend({instr.bits[31:12], 12'b0});
  endfunction
endinstance

instance HasImmediate#(Jtype);
  function Bit#(32) immediateBits(Jtype instr);
    let imm = {instr.bits[31:31], instr.bits[19:12], instr.bits[20:20], instr.bits[30:21]};
    return signExtend({imm, 1'b0});
  endfunction
endinstance

// show that each instruction type has an opcode

instance HasOpcode#(Rtype);
  function Opcode opcode(Rtype instr); return getOpcode(instr.bits); endfunction
endinstance

instance HasOpcode#(Itype);
  function Opcode opcode(Itype instr); return getOpcode(instr.bits); endfunction
endinstance

instance HasOpcode#(Stype);
  function Opcode opcode(Stype instr); return getOpcode(instr.bits); endfunction
endinstance

instance HasOpcode#(Btype);
  function Opcode opcode(Btype instr); return getOpcode(instr.bits); endfunction
endinstance

instance HasOpcode#(Utype);
  function Opcode opcode(Utype instr); return getOpcode(instr.bits); endfunction
endinstance

instance HasOpcode#(Jtype);
  function Opcode opcode(Jtype instr); return getOpcode(instr.bits); endfunction
endinstance

// Show that some instructions has a register 1

instance HasRegister1#(Rtype);
  function RegName register1(Rtype instr); return getRs1(instr.bits); endfunction
endinstance

instance HasRegister1#(Itype);
  function RegName register1(Itype instr); return getRs1(instr.bits); endfunction
endinstance

instance HasRegister1#(Stype);
  function RegName register1(Stype instr); return getRs1(instr.bits); endfunction
endinstance

instance HasRegister1#(Btype);
  function RegName register1(Btype instr); return getRs1(instr.bits); endfunction
endinstance

// Show that some instructions has a register 2

instance HasRegister2#(Rtype);
  function RegName register2(Rtype instr); return getRs2(instr.bits); endfunction
endinstance

instance HasRegister2#(Stype);
  function RegName register2(Stype instr); return getRs2(instr.bits); endfunction
endinstance

instance HasRegister2#(Btype);
  function RegName register2(Btype instr); return getRs2(instr.bits); endfunction
endinstance

// Show that some instructions has a destination register

instance HasDestination#(Rtype);
  function RegName destination(Rtype instr); return getRd(instr.bits); endfunction
endinstance

instance HasDestination#(Itype);
  function RegName destination(Itype instr); return getRd(instr.bits); endfunction
endinstance

instance HasDestination#(Utype);
  function RegName destination(Utype instr); return getRd(instr.bits); endfunction
endinstance

instance HasDestination#(Jtype);
  function RegName destination(Jtype instr); return getRd(instr.bits); endfunction
endinstance

typedef enum {
  BEQ, BNE, BLT, BGE, BLTU, BGEU
} BOp deriving(Bits, Eq);

instance FShow#(BOp);
  function Fmt fshow(BOp op);
    return case (op) matches
      BEQ : fshow("beq");
      BNE : fshow("bne");
      BLT : fshow("blt");
      BGE : fshow("bge");
      BLTU : fshow("bltu");
      BGEU : fshow("bgeq");
    endcase;
  endfunction
endinstance

function Maybe#(BOp) decodeBtype(Btype instr);
  return case (function3(instr))
    3'b000 : Valid(BEQ);
    3'b001 : Valid(BNE);
    3'b100 : Valid(BLT);
    3'b101 : Valid(BGE);
    3'b110 : Valid(BLTU);
    3'b111 : Valid(BGEU);
    default : Invalid;
  endcase;
endfunction

typedef enum {
  ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND,
  MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU
} ROp deriving(Bits, Eq);

instance FShow#(ROp);
  function Fmt fshow(ROp op);
    return case (op) matches
      ADD : fshow("add");
      SUB : fshow("sub");
      SLL : fshow("sll");
      SLT : fshow("slt");
      SLTU : fshow("sltu");
      XOR : fshow("xor");
      SRL : fshow("srl");
      SRA : fshow("sra");
      OR : fshow("or");
      AND : fshow("and");
      MUL : fshow("mul");
      MULH : fshow("mulh");
      MULHSU : fshow("mulhsu");
      MULHU : fshow("mulhu");
    endcase;
  endfunction
endinstance

function Maybe#(ROp) decodeRtype(Rtype instr);
  return case (Tuple2{fst:function7(instr), snd:function3(instr)}) matches
    Tuple2{fst: 7'b0000000, snd: 3'b000} : Valid(ADD);  // add
    Tuple2{fst: 7'b0100000, snd: 3'b000} : Valid(SUB);  // sub
    Tuple2{fst: 7'b0000000, snd: 3'b001} : Valid(SLL);  // shift left logic
    Tuple2{fst: 7'b0000000, snd: 3'b010} : Valid(SLT);  // less than
    Tuple2{fst: 7'b0000000, snd: 3'b011} : Valid(SLTU); // less than unsigned
    Tuple2{fst: 7'b0000000, snd: 3'b100} : Valid(XOR);  // xor
    Tuple2{fst: 7'b0000000, snd: 3'b101} : Valid(SRL);  // shift right logic
    Tuple2{fst: 7'b0100000, snd: 3'b101} : Valid(SRA);  // shift right arithmetic
    Tuple2{fst: 7'b0000000, snd: 3'b110} : Valid(OR);   // or
    Tuple2{fst: 7'b0000000, snd: 3'b111} : Valid(AND);  // and

    Tuple2{fst: 7'b0000001, snd: 3'b000} : Valid(MUL);
    Tuple2{fst: 7'b0000001, snd: 3'b001} : Valid(MULH);
    Tuple2{fst: 7'b0000001, snd: 3'b010} : Valid(MULHSU);
    Tuple2{fst: 7'b0000001, snd: 3'b011} : Valid(MULHU);
    Tuple2{fst: 7'b0000001, snd: 3'b100} : Valid(DIV);
    Tuple2{fst: 7'b0000001, snd: 3'b101} : Valid(DIVU);
    Tuple2{fst: 7'b0000001, snd: 3'b110} : Valid(REM);
    Tuple2{fst: 7'b0000001, snd: 3'b111} : Valid(REMU);
    default : Invalid;
  endcase;
endfunction

typedef enum {
  AUIPC, LUI
} UOp deriving(Bits, Eq);

instance FShow#(UOp);
  function Fmt fshow(UOp op);
    return case (op) matches
      AUIPC : fshow("auipc");
      LUI : fshow("lui");
    endcase;
  endfunction
endinstance

function UOp decodeUtype(Utype instr);
  if (opcode(instr) == 7'b0110111)
    return LUI;
  else return AUIPC;
endfunction

typedef enum {
  SB, SH, SW
} SOp deriving(Eq, Bits);

instance FShow#(SOp);
  function Fmt fshow(SOp op);
    return case (op) matches
      SB : fshow("sb");
      SH : fshow("sh");
      SW : fshow("sw");
    endcase;
  endfunction
endinstance

function Maybe#(SOp) decodeStype(Stype instr);
  return case (function3(instr))
    3'b000 : Valid(SB);
    3'b001 : Valid(SH);
    3'b010 : Valid(SW);
    default : Invalid;
  endcase;
endfunction


typedef enum {
  LB, LW, LH, LBU, LHU
} LoadOp deriving(Bits, Eq);

instance FShow#(LoadOp);
  function Fmt fshow(LoadOp op);
    return case (op) matches
      LB : fshow("lb");
      LH : fshow("lh");
      LW : fshow("lw");
      LHU : fshow("lhu");
      LBU : fshow("lbu");
    endcase;
  endfunction
endinstance

typedef enum {
  MRET, URET, SRET
} RetOp deriving(Bits, Eq);

instance FShow#(RetOp);
  function Fmt fshow(RetOp op);
    return case (op) matches
      MRET : fshow("mret");
      URET : fshow("uret");
      SRET : fshow("sret");
    endcase;
  endfunction
endinstance

typedef union tagged {
  void JALR;
  LoadOp Load;
  void ADDI;
  void SLTI;
  void SLTIU;
  void XORI;
  void ORI;
  void ANDI;
  void SLLI;
  void SRLI;
  void SRAI;
  void FENCE;
  void FENCE_I;
  void CBO_CLEAN;
  void CBO_FLUSH;
  void CBO_INVAL;
  void ECALL;
  void EBREAK;
  void CSRRW;
  void CSRRS;
  void CSRRC;
  void CSRRWI;
  void CSRRSI;
  void CSRRCI;
  RetOp Ret;
  void WFI;
  // SFENCE_VM
} IOp deriving(Bits, Eq);

typedef struct {
  Bool w;
  Bool r;
  Bool o;
  Bool i;
} MemEvent deriving(Bits, FShow, Eq);

typedef struct {
  MemEvent pred;
  MemEvent succ;
} FenceType deriving(Bits, FShow, Eq);

function FenceType getFenceType(Itype fence);
  return FenceType {
    pred: unpack(immediateBits(fence)[3:0]),
    succ: unpack(immediateBits(fence)[7:4])
  };
endfunction

instance FShow#(IOp);
  function Fmt fshow(IOp op);
    return case (op) matches
      JALR : fshow("jarl");
      tagged Load .l : fshow(l);
      ADDI : fshow("addi");
      SLTI : fshow("slti");
      SLTIU : fshow("sltiu");
      XORI : fshow("xori");
      ORI : fshow("ori");
      ANDI : fshow("andi");
      SLLI : fshow("slli");
      SRLI : fshow("srli");
      SRAI : fshow("srai");
      FENCE : fshow("fence");
      FENCE_I : fshow("fence.i");
      CBO_CLEAN : fshow("cbo.clean");
      CBO_FLUSH : fshow("cbo.flush");
      CBO_INVAL : fshow("cbo.inval");
      ECALL : fshow("ecall");
      EBREAK : fshow("ebreak");
      CSRRW : fshow("csrrw");
      CSRRS : fshow("csrrs");
      CSRRC : fshow("csrrc");
      CSRRWI : fshow("csrrwi");
      CSRRSI : fshow("csrrsi");
      CSRRCI : fshow("csrrci");
      tagged Ret .r : fshow(r);
      WFI : fshow("wfi");
    endcase;
  endfunction
endinstance

function Maybe#(IOp) decodeItype(Itype instr);
  case (opcode(instr))
    7'b1100111 : return ((function3(instr) == 0) ? Valid(JALR) : Invalid);

    7'b0000011 :
      return case (function3(instr))
        3'b000 : Valid(tagged Load LB);
        3'b001 : Valid(tagged Load LH);
        3'b010 : Valid(tagged Load LW);
        3'b100 : Valid(tagged Load LBU);
        3'b101 : Valid(tagged Load LHU);
        default : Invalid;
      endcase;

    7'b0010011 :
      return case (function3(instr))
        3'b000 : Valid(ADDI);
        3'b010 : Valid(SLTI);
        3'b011 : Valid(SLTIU);
        3'b100 : Valid(XORI);
        3'b110 : Valid(ORI);
        3'b111 : Valid(ANDI);
        3'b001 : ((immediateBits(instr)[11:5] == 0) ? Valid(SLLI) : Invalid);
        3'b101 : begin
          case (immediateBits(instr)[11:5])
            0 : Valid(SRLI);
            'b0100000 : Valid(SRAI);
            default : Invalid;
          endcase
        end
        default: Invalid;
      endcase;

    7'b0001111 :
      if (immediateBits(instr)[11:8] == 0 &&
          register1(instr).name == 0 &&
          destination(instr).name == 0)
        return
          case (function3(instr))
            0 : Valid(FENCE);
            1 : Valid(FENCE_I);
            2 : begin
              case (immediateBits(instr)[7:0]) matches
                1 : Valid(CBO_CLEAN);
                2 : Valid(CBO_FLUSH);
                0 : Valid(CBO_INVAL);
              endcase
            end
            default : Invalid;
          endcase;
      else return Invalid;

    7'b1110011 :
      case (function3(instr))
        3'b000 :
          if (register1(instr).name != 0 || destination(instr).name != 0)
            return Invalid;
          else return case (immediateBits(instr))
            //32'b000000000010 : Valid(tagged Ret URET);
            //32'b000100000010 : Valid(tagged Ret SRET);
            32'b001100000010 : Valid(tagged Ret MRET);
            32'b000100000101 : Valid(WFI);
            0 : Valid(ECALL);
            1 : Valid(EBREAK);
            default: Invalid;
          endcase;
        3'b001 : return Valid(CSRRW);
        3'b010 : return Valid(CSRRS);
        3'b011 : return Valid(CSRRC);
        3'b101 : return Valid(CSRRWI);
        3'b110 : return Valid(CSRRSI);
        3'b111 : return Valid(CSRRCI);
        default : return Invalid;
      endcase

    default: return Invalid;
  endcase
endfunction



typedef union tagged {
  struct{Rtype instr; ROp op;} Rtype;
  struct{Itype instr; IOp op;} Itype;
  struct{Stype instr; SOp op;} Stype;
  struct{Btype instr; BOp op;} Btype;
  struct{Utype instr; UOp op;} Utype;
  Jtype Jtype;
} Instr deriving(Bits, FShow, Eq);

instance HasImmediate#(Instr);
  function Bit#(32) immediateBits(Instr instr);
    return case (instr) matches
      tagged Itype {instr: .instr} : immediateBits(instr);
      tagged Stype {instr: .instr} : immediateBits(instr);
      tagged Btype {instr: .instr} : immediateBits(instr);
      tagged Utype {instr: .instr} : immediateBits(instr);
      tagged Jtype .instr : immediateBits(instr);
      default : 0;
    endcase;
  endfunction
endinstance

function Maybe#(Instr) decodeInstr(Bit#(32) instr);
  case (opcodeType(getOpcode(instr))) matches
    tagged Valid Rtype :
      return case (decodeRtype(unpack(instr))) matches
        tagged Valid .op : Valid(tagged Rtype{instr: unpack(instr), op:op});
        default: Invalid;
      endcase;
    tagged Valid Itype :
      return case (decodeItype(unpack(instr))) matches
        tagged Valid .op : Valid(tagged Itype{instr: unpack(instr), op:op});
        default: Invalid;
      endcase;
    tagged Valid Btype :
      return case (decodeBtype(unpack(instr))) matches
        tagged Valid .op : Valid(tagged Btype{instr: unpack(instr), op:op});
        default: Invalid;
      endcase;
    tagged Valid Stype :
      return case (decodeStype(unpack(instr))) matches
        tagged Valid .op : Valid(tagged Stype{instr: unpack(instr), op:op});
        default: Invalid;
      endcase;
    tagged Valid Utype :
      return Valid(tagged Utype {instr: unpack(instr), op: decodeUtype(unpack(instr))});
    tagged Valid Jtype :
      return Valid(tagged Jtype (unpack(instr)));
    default : return Invalid;
  endcase
endfunction

function Maybe#(RegName) hasRegister1(Instr instr);
  return case (instr) matches
    tagged Rtype {instr: .instr} : Valid(register1(instr));
    tagged Btype {instr: .instr} : Valid(register1(instr));
    tagged Stype {instr: .instr} : Valid(register1(instr));

    tagged Itype {op: FENCE} : Invalid;
    tagged Itype {op: FENCE_I} : Invalid;
    tagged Itype {op: ECALL} : Invalid;
    tagged Itype {op: EBREAK} : Invalid;
    tagged Itype {op: CSRRWI} : Invalid;
    tagged Itype {op: CSRRSI} : Invalid;
    tagged Itype {op: CSRRCI} : Invalid;
    tagged Itype {op: tagged Ret .v} : Invalid;
    tagged Itype {op: WFI} : Invalid;
    tagged Itype {instr: .instr} : Valid(register1(instr));
    default : Invalid;
  endcase;
endfunction

instance HasRegister1#(Instr);
  function RegName register1(Instr instr);
    return case (hasRegister1(instr)) matches
      tagged Valid .r : r;
      default : RegName{name: 0};
    endcase;
  endfunction
endinstance

function Maybe#(RegName) hasRegister2(Instr instr);
  return case (instr) matches
    tagged Rtype {instr: .instr} : Valid(register2(instr));
    tagged Btype {instr: .instr} : Valid(register2(instr));
    tagged Stype {instr: .instr} : Valid(register2(instr));
    default : Invalid;
  endcase;
endfunction

instance HasRegister2#(Instr);
  function RegName register2(Instr instr);
    return case (hasRegister2(instr)) matches
      tagged Valid .r : r;
      default : RegName{name: 0};
    endcase;
  endfunction
endinstance

function Maybe#(RegName) hasDestination(Instr instr);
  return case (instr) matches
      tagged Rtype {instr: .instr} : Valid(destination(instr));
      tagged Utype {instr: .instr} : Valid(destination(instr));
      tagged Jtype .instr : Valid(destination(instr));

      tagged Itype {op: FENCE} : Invalid;
      tagged Itype {op: FENCE_I} : Invalid;
      tagged Itype {op: ECALL} : Invalid;
      tagged Itype {op: EBREAK} : Invalid;
      tagged Itype {op: tagged Ret .val} : Invalid;
      tagged Itype {op: WFI} : Invalid;
      tagged Itype {instr: .instr} : Valid(destination(instr));

      default : Invalid;
  endcase;
endfunction

instance HasDestination#(Instr);
  function RegName destination(Instr instr);
    return case (hasDestination(instr)) matches
      tagged Valid .r : r;
      default : RegName{name: 0};
    endcase;
  endfunction
endinstance

function Fmt displayInstr(Instr instr);
  return case (instr) matches
    tagged Rtype {op: .op, instr: .instr} :
      $format(fshow(op), " ", fshow(destination(instr)), ", ", fshow(register1(instr)), ", ", fshow(register2(instr)));
    tagged Btype {op: .op, instr: .instr} :
      $format(fshow(op), " ", fshow(register1(instr)), ", ", fshow(register2(instr)), ", %d", immediate(instr));
    tagged Stype {op: .op, instr: .instr} :
      $format(fshow(op), " ", fshow(register1(instr)), ", ", fshow(register2(instr)), ", %d", immediate(instr));
    tagged Itype {op: .op, instr: .instr} :
      $format(fshow(op), " ", fshow(destination(instr)), ", ", fshow(register1(instr)), ", %d", immediate(instr));
    tagged Jtype .instr :
      $format("jal %h ", immediateBits(instr), fshow(destination(instr)));
    tagged Utype {op: .op, instr: .instr} :
      $format(fshow(op), " ", fshow(destination(instr)), ", %h", immediateBits(instr));
  endcase;
endfunction

endpackage
