import AXI4_Lite :: *;
import Decode :: *;
import Utils :: *;
import OOO :: *;

typedef enum {
  Word, Half, Byte
} Size deriving(Bits, FShow, Eq);

typedef enum {
  Signed, Unsigned
} Signedness deriving(Bits, FShow, Eq);

function Size loadSize(LoadOp ltype);
  return case (ltype) matches
    LB : Byte; LBU : Byte;
    LH : Half; LHU : Half;
    LFP: Word;
    LW : Word;
  endcase;
endfunction

function Signedness loadSignedness(LoadOp ltype);
  return case (ltype) matches
    LB : Signed; LBU : Unsigned;
    LH : Signed; LHU : Unsigned;
    LFP: Signed;
    LW : Signed;
  endcase;
endfunction

function Size storeSize(SOp ltype);
  return case (ltype) matches
    SFP: Word;
    SB : Byte;
    SH : Half;
    SW : Word;
  endcase;
endfunction

typedef struct {
  // Index in the reorder buffer
  RobIndex index;

  // Program counter of the store operation
  Bit#(32) pc;

  // Epoch of the operation, a store can only forward
  // it's data to a load of the same epoch
  Epoch epoch;

  // Age of the operation, a store can only forward
  // it's data to a younger load
  Age age;

  // Size of the memory access
  Size size;

  // Physical destination pointer
  PhysReg pdst;
} StoreQueueEntry deriving(Bits, FShow, Eq);

typedef struct {
  // Index in the reorder buffer
  RobIndex index;

  // Program counter of the load operation
  Bit#(32) pc;

  // Epoch of the operation, a load can only forward
  // data from a store of the same epoch
  Epoch epoch;

  // Age of the operation, a store can only forward
  // it's data to a younger load
  Age age;

  // Size of the memory access
  Size size;

  // Return if the input operation is signed
  Signedness signedness;

  // Physical destination pointer
  PhysReg pdst;
} LoadQueueEntry deriving(Bits, FShow, Eq);

typedef struct {
  Bool found;
  Bit#(32) data;
  Bit#(4) mask;
} StoreConflict deriving(Bits, FShow);

typedef struct {
  Bit#(32) data;
  Bit#(32) addr;
  Bit#(4) mask;
} StbEntry deriving(Bits, FShow, Eq);


typedef struct {
  Age age;
  Epoch epoch;
  LqIndex lindex;
  AXI4_Lite_RRequest#(32) request;
} LoadIssue deriving(Bits, FShow, Eq);
