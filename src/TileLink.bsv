import MemoryTypes :: *;
import Utils :: *;
import Fifo :: *;
import Ehr :: *;

import Array :: *;
import StmtFSM :: *;
import Connectable :: *;

// Function for manipulating Byte Lanes, they allow to construct message and
// parse them respecting the alignment conditions of TileLink

// Given a byte lane and the address of the byte 0 of the data, return the given
// data
function Byte#(size) getData(Bit#(a) address, Byte#(w) lane);
  // offset of the data in the byte lane (w must be a power of two)
  Bit#(a) offset = address & fromInteger(valueOf(w)-1);
  return (lane >> (offset << 3))[valueOf(size)*8-1:0];
endfunction

function Byte#(w) getLane(Bit#(a) address, Byte#(size) data)
  provisos(Add#(__something, TMul#(8, size), TMul#(8, w)));
  // offset of the data in the byte lane (w must be a power of two)
  Bit#(a) offset = address & fromInteger(valueOf(w)-1);
  return zeroExtend(data) << (offset << 3);
endfunction

function Bit#(size) getMask(Bit#(a) address, Bit#(w) laneMask);
  // offset of the data in the byte lane (w must be a power of two)
  Bit#(a) offset = address & fromInteger(valueOf(w)-1);
  return (laneMask >> offset)[valueOf(size)-1:0];
endfunction

function Bit#(w) getLaneMask(Bit#(a) address, Bit#(size) mask)
  provisos(Add#(__something, size, w));
  // offset of the data in the byte lane (w must be a power of two)
  Bit#(a) offset = address & fromInteger(valueOf(w)-1);
  return zeroExtend(mask) << offset;
endfunction

typedef enum {
  MIN = 0, MAX = 1, MINU = 2, MAXU = 3, ADD = 4
} ArithmeticParam deriving(Bits, Eq, FShow);

typedef enum {
  XOR = 0, OR = 1, AND = 2, SWAP = 3
} LogicalParam deriving(Bits, Eq, FShow);

typedef enum {
  PrefetchRead = 0,
  PrefetchWrite = 1
} IntentParam deriving(Bits, Eq, FShow);

typedef enum {
  // No permission
  Nothing,

  // No permission, but is a parent of the Tip in the hierarchy DAG
  Trunk,

  // Read-Write permission
  Tip,

  // Read-only permission
  Branch
} Prems deriving(Bits, Eq, FShow);

// Infer a contiguous mask
function Bit#(w) inferMask(Bit#(a) min_address, Bit#(s) size);
  // Address of the last byte of the message
  Bit#(a) max_address = min_address + (1 << size) - 1;

  // Address of the current byte
  Bit#(a) addr = min_address & ~(fromInteger(valueOf(w) - 1));

  // Output mask
  Bit#(w) mask = 0;

  for (Integer i=0; i < valueOf(w); i = i + 1) begin
    mask[i] = (addr >= min_address && addr <= max_address ? 1 : 0);
    addr = addr + 1;
  end

  return mask;
endfunction

typedef enum {
  NtoB,
  NtoT,
  BtoT
} AcquireParam
deriving(Bits, FShow, Eq);

typedef enum {
  ToT, ToB, ToN
} GrantParam
deriving(Bits, FShow, Eq);

typedef enum {
  ToT, ToB, ToN
} ProbParam
deriving(Bits, FShow, Eq);

typedef enum {
  TtoB,
  TtoN,
  BtoN,
  TtoT,
  BtoB,
  NtoN
} ReleaseParam
deriving(Bits, FShow, Eq);

typedef enum {
  TtoB,
  TtoN,
  BtoN,
  TtoT,
  BtoB,
  NtoN
} ProbeAckParam
deriving(Bits, FShow, Eq);

// Definition of channel A message:
// - Each message have a definition in form of a struct,
//   with at least a field size, address and source, then
//   the conversion to the type FabChannelA is done using
//   interence of the other fields according to the
//   message

// Put a continuous data in memory
typedef  struct { // Response: AccessAck
  Bit#(s) size;
  Bit#(o) source;
  // Must be aligned on size
  Bit#(a) address;
  Byte#(w) data;
} PutFullData#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);


// Put a non-continuous data in memory
typedef struct { // Response: AccessAck
  Bit#(s) size;
  Bit#(o) source;
  // Must be aligned on size
  Bit#(a) address;
  Bit#(w) mask;
  Byte#(w) data;
} PutPartialData#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

// Read a continuous data from memory, Get is renamed in GetFull here to remove
// the ambiguity with GetPut::Get
typedef struct { // Response AccessAckData
  // Logarithm of the size of the burst, in TL-UL it can't be larger
  // that the size of the data bus (w)
  // mask is ignored here because it only depend of address and size
  Bit#(s) size;
  Bit#(o) source;
  // Must be aligned to size
  Bit#(a) address;
} GetFull#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

// Perform an arihtmetic operation on a continuous data in memory and
// return it's previous value
typedef struct { // Response AccessAckData
  ArithmeticParam param;
  // mask is ignored here because it only depend of address and size
  Bit#(s) size;
  Bit#(o) source;
  // Must be aligned on size
  Bit#(a) address;
  Byte#(w) data;
} ArithmeticData#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

// Perform a logical operation on a continuous data in memory and
// return it's previous value
typedef struct { // Response AccessAckData
  LogicalParam param;
  Bit#(s) size;
  Bit#(o) source;
  // Must be aligned on size
  Bit#(a) address;
  Byte#(w) data;
} LogicalData#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);


// Inform the caches that an operation will probably
// be performed in a few time
typedef struct {
  IntentParam param;
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
  Bit#(w) mask;
} Intent#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

// Request to acquire a new cache line
typedef struct {
  AcquireParam param;
  // mask is ignored here because it only depend of address and size
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
} Acquire#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

// Heavy version of the channel A
typedef union tagged {
  PutFullData#(o, s, a, w) PutFullData;
  PutPartialData#(o, s, a, w) PutPartialData;
  ArithmeticData#(o, s, a, w) ArithmeticData;
  LogicalData#(o, s, a, w) LogicalData;
  Intent#(o, s, a, w) Intent;
  Acquire#(o, s, a, w) Acquire;
  GetFull#(o, s, a, w) GetFull;
} ChannelA#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);


// Lightweight (TL-UL) version of the channel A
typedef union tagged {
  PutFullData#(o, s, a, w) PutFullData;
  PutPartialData#(o, s, a, w) PutPartialData;
  GetFull#(o, s, a, w) GetFull;
} LightChannelA#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);


typedef struct {
  ProbParam param;
  Bit#(o) source;
  Bit#(s) size;
  Bit#(a) address;
} Probe#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);


// Channel B definition
typedef union tagged {
  PutFullData#(o, s, a, w) PutFullData;
  PutPartialData#(o, s, a, w) PutPartialData;
  ArithmeticData#(o, s, a, w) ArithmeticData;
  LogicalData#(o, s, a, w) LogicalData;
  Intent#(o, s, a, w) Intent;
  GetFull#(o, s, a, w) GetFull;
  Probe#(o, s, a, w) Probe;
} ChannelB#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);


typedef struct {
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
  Bool error;
} AccessAck#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
  Byte#(w) data;
  Bool error;
} AccessAckData#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
  Bool error;
} HintAck#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  ProbeAckParam param;
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
  Bool error;
} ProbeAck#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  ProbeAckParam param;
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
  Byte#(w) data;
  Bool error;
} ProbeAckData#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  ReleaseParam param;
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
} Release#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  ReleaseParam param;
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
  Byte#(w) data;
  Bool error;
} ReleaseData#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef union tagged {
  AccessAck#(o, s, a, w) AccessAck;
  AccessAckData#(o, s, a, w) AccessAckData;
  HintAck#(o, s, a, w) HintAck;
  ProbeAck#(o, s, a, w) ProbeAck;
  ProbeAckData#(o, s, a, w) ProbeAckData;
  Release#(o, s, a, w) Release;
  ReleaseData#(o, s, a, w) ReleaseData;
} ChannelC#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  GrantParam param;
  Bit#(s) size;
  Bit#(o) source;
  Bit#(i) sink;
} Grant#(numeric type i, numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  GrantParam param;
  Bit#(s) size;
  Bit#(o) source;
  Bit#(i) sink;
  Byte#(w) data;
  Bool error;
} GrantData#(numeric type i, numeric type o,
  numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(s) size;
  Bit#(o) source;
  Bool error;
} ReleaseAck#(numeric type i, numeric type o,
  numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef union tagged {
  AccessAck#(o, s, a, w) AccessAck;
  AccessAckData#(o, s, a, w) AccessAckData;
  HintAck#(o, s, a, w) HintAck;
  Grant#(i, o, s, a, w) Grant;
  GrantData#(i, o, s, a, w) GrantData;
  ReleaseAck#(i, o, s, a, w) ReleaseAck;
} ChannelD#(numeric type i, numeric type o,
  numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef union tagged {
  AccessAck#(o, s, a, w) AccessAck;
  AccessAckData#(o, s, a, w) AccessAckData;
} LightChannelD#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(i) sink;
} GrantAck#(numeric type i)
deriving(Bits, FShow, Eq);

typedef union tagged {
  GrantAck#(i) GrantAck;
} ChannelE#(numeric type i)
deriving(Bits, FShow, Eq);


// TileLink light master interface
interface LightMaster#(numeric type o, numeric type s, numeric type a, numeric type w);
  interface FifoO#(LightChannelA#(o, s, a, w)) channelA;
  interface FifoI#(LightChannelD#(o, s, a, w)) channelD;
endinterface

// TileLink light slave interface
interface LightSlave#(numeric type o, numeric type s, numeric type a, numeric type w);
  interface FifoI#(LightChannelA#(o, s, a, w)) channelA;
  interface FifoO#(LightChannelD#(o, s, a, w)) channelD;
endinterface

// TileLink master interface
interface Master#(numeric type i, numeric type o,
  numeric type s, numeric type a, numeric type w);
  interface FifoO#(ChannelA#(o, s, a, w)) channelA;
  interface FifoI#(ChannelB#(o, s, a, w)) channelB;
  interface FifoO#(ChannelC#(o, s, a, w)) channelC;
  interface FifoI#(ChannelD#(i, o, s, a, w)) channelD;
  interface FifoO#(ChannelE#(i)) channelE;
endinterface

// TileLink slave interface
interface Slave#(numeric type i, numeric type o,
  numeric type s, numeric type a, numeric type w);
  interface FifoI#(ChannelA#(o, s, a, w)) channelA;
  interface FifoO#(ChannelB#(o, s, a, w)) channelB;
  interface FifoI#(ChannelC#(o, s, a, w)) channelC;
  interface FifoO#(ChannelD#(i, o, s, a, w)) channelD;
  interface FifoI#(ChannelE#(i)) channelE;
endinterface

// Generate a TileLink master using a TileLink light interface
// This master has no permission on any cache block,
// and return an error if we try to acquire from it
// We must care about the size of the response beats:
//  According to the TileLink documentation, responses
// must have the size specified by the size field, even
// if the request return an error
module connectLightMaster_to_Slave
  #(LightMaster#(o, s, a, w) master, Slave#(i, o, s, a, w) slave) (Empty);



endmodule
