import AXI4_Lite :: *;
import Decode :: *;
import Utils :: *;
import OOO :: *;

// Store Buffer Size
typedef 2 StbSize;

// Store Queue Size
typedef 8 SqSize;

// Load Queue Size
typedef 8 LqSize;

// Store issue queue size
typedef 4 SiqSize;

// Load issue queue size
typedef 4 LiqSize;

// Store Buffer Index
typedef Bit#(TLog#(StbSize)) StbIndex;

// Store Queue Index
typedef Bit#(TLog#(SqSize)) SqIndex;

// Load Queue Index
typedef Bit#(TLog#(LqSize)) LqIndex;

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
    LW : Word;
  endcase;
endfunction

function Signedness loadSignedness(LoadOp ltype);
  return case (ltype) matches
    LB : Signed; LBU : Unsigned;
    LH : Signed; LHU : Unsigned;
    LW : Signed;
  endcase;
endfunction

function Size storeSize(SOp ltype);
  return case (ltype) matches
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


typedef union tagged {
  struct {
    RobIndex index;
    ExecOutput result;
  } Failure; // Tell to the Reorder Buffer that the access is misaligned
  AXI4_Lite_RRequest#(32) Success; // Ask a value to the data cache
} LoadWakeup deriving(Bits, FShow, Eq);
