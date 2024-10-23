import MemoryTypes :: *;
import Utils :: *;
import Fifo :: *;
import Ehr :: *;

typedef enum {
  MIN = 0, MAX = 1, MINU = 2, MAXU = 3, ADD = 4
} TL_ArithmeticParam deriving(Bits, Eq, FShow);

typedef enum {
  XOR = 0, OR = 1, AND = 2, SWAP = 3
} TL_LogicalParam deriving(Bits, Eq, FShow);

typedef enum {
  PrefetchRead = 0,
  PrefetchWrite = 1
} TL_IntentParam deriving(Bits, Eq, FShow);

typedef enum {
  // No permission
  Nothing,

  // No permission, but is a parent of the Tip in the hierarchy DAG
  Trunk,

  // Read-Write permission
  Tip,

  // Read-only permission
  Branch
} TL_Prems deriving(Bits, Eq, FShow);

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
} TL_AcquireParam
deriving(Bits, FShow, Eq);

typedef enum {
  ToT, ToB, ToN
} TL_GrantParam
deriving(Bits, FShow, Eq);

typedef enum {
  ToT, ToB, ToN
} TL_ProbParam
deriving(Bits, FShow, Eq);

typedef enum {
  TtoB,
  TtoN,
  BtoN,
  TtoT,
  BtoB,
  NtoN
} TL_ReleaseParam
deriving(Bits, FShow, Eq);

typedef enum {
  TtoB,
  TtoN,
  BtoN,
  TtoT,
  BtoB,
  NtoN
} TL_ProbeAckParam
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
} TL_PutFullData#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);


// Put a non-continuous data in memory
typedef struct { // Response: AccessAck
  Bit#(s) size;
  Bit#(o) source;
  // Must be aligned on size
  Bit#(a) address;
  Bit#(w) mask;
  Byte#(w) data;
} TL_PutPartialData#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

// Read a continuous data from memory
typedef struct { // Response AccessAckData
  // Logarithm of the size of the burst, in TL-UL it can't be larger
  // that the size of the data bus (w)
  // mask is ignored here because it only depend of address and size
  Bit#(s) size;
  Bit#(o) source;
  // Must be aligned to size
  Bit#(a) address;
} TL_Get#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

// Perform an arihtmetic operation on a continuous data in memory and
// return it's previous value
typedef struct { // Response AccessAckData
  TL_ArithmeticParam param;
  // mask is ignored here because it only depend of address and size
  Bit#(s) size;
  Bit#(o) source;
  // Must be aligned on size
  Bit#(a) address;
  Byte#(w) data;
} TL_ArithmeticData#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

// Perform a logical operation on a continuous data in memory and
// return it's previous value
typedef struct { // Response AccessAckData
  TL_LogicalParam param;
  Bit#(s) size;
  Bit#(o) source;
  // Must be aligned on size
  Bit#(a) address;
  Byte#(w) data;
} TL_LogicalData#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);


// Inform the caches that an operation will probably
// be performed in a few time
typedef struct {
  TL_IntentParam param;
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
  Bit#(w) mask;
} TL_Intent#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

// Request to acquire a new cache line
typedef struct {
  TL_AcquireParam param;
  // mask is ignored here because it only depend of address and size
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
} TL_Acquire#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

// Heavy version of the channel A
typedef union tagged {
  TL_PutFullData#(o, s, a, w) PutFullData;
  TL_PutPartialData#(o, s, a, w) PutPartialData;
  TL_ArithmeticData#(o, s, a, w) ArithmeticData;
  TL_LogicalData#(o, s, a, w) LogicalData;
  TL_Intent#(o, s, a, w) Intent;
  TL_Acquire#(o, s, a, w) Acquire;
  TL_Get#(o, s, a, w) Get;
} TL_ChannelA#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);


// Lightweight (TL-UL) version of the channel A
typedef union tagged {
  TL_PutFullData#(o, s, a, w) PutFullData;
  TL_PutPartialData#(o, s, a, w) PutPartialData;
  TL_Get#(o, s, a, w) Get;
} TL_LightChannelA#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);


typedef struct {
  TL_ProbParam param;
  Bit#(o) source;
  Bit#(s) size;
  Bit#(a) address;
} TL_Probe#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);


// Channel B definition
typedef union tagged {
  TL_PutFullData#(o, s, a, w) PutFullData;
  TL_PutPartialData#(o, s, a, w) PutPartialData;
  TL_ArithmeticData#(o, s, a, w) ArithmeticData;
  TL_LogicalData#(o, s, a, w) LogicalData;
  TL_Intent#(o, s, a, w) Intent;
  TL_Get#(o, s, a, w) Get;
  TL_Probe#(o, s, a, w) Probe;
} TL_ChannelB#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);


typedef struct {
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
  Bool error;
} TL_AccessAck#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
  Byte#(w) data;
  Bool error;
} TL_AccessAckData#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
  Bool error;
} TL_HintAck#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  TL_ProbeAckParam param;
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
  Bool error;
} TL_ProbeAck#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  TL_ProbeAckParam param;
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
  Byte#(w) data;
  Bool error;
} TL_ProbeAckData#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  TL_ReleaseParam param;
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
} TL_Release#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  TL_ReleaseParam param;
  Bit#(s) size;
  Bit#(o) source;
  Bit#(a) address;
  Byte#(w) data;
  Bool error;
} TL_ReleaseData#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef union tagged {
  TL_AccessAck#(o, s, a, w) AccessAck;
  TL_AccessAckData#(o, s, a, w) AccessAckData;
  TL_HintAck#(o, s, a, w) HintAck;
  TL_ProbeAck#(o, s, a, w) ProbeAck;
  TL_ProbeAckData#(o, s, a, w) ProbeAckData;
  TL_Release#(o, s, a, w) Release;
  TL_ReleaseData#(o, s, a, w) ReleaseData;
} TL_ChannelC#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  TL_GrantParam param;
  Bit#(s) size;
  Bit#(o) source;
  Bit#(i) sink;
} TL_Grant#(numeric type i, numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  TL_GrantParam param;
  Bit#(s) size;
  Bit#(o) source;
  Bit#(i) sink;
  Byte#(w) data;
  Bool error;
} TL_GrantData#(numeric type i, numeric type o,
  numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(s) size;
  Bit#(o) source;
  Bool error;
} TL_ReleaseAck#(numeric type i, numeric type o,
  numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef union tagged {
  TL_AccessAck#(o, s, a, w) AccessAck;
  TL_AccessAckData#(o, s, a, w) AccessAckData;
  TL_HintAck#(o, s, a, w) HintAck;
  TL_Grant#(i, o, s, a, w) Grant;
  TL_GrantData#(i, o, s, a, w) GrantData;
  TL_ReleaseAck#(i, o, s, a, w) ReleaseAck;
} TL_ChannelD#(numeric type i, numeric type o,
  numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef union tagged {
  TL_AccessAck#(o, s, a, w) AccessAck;
  TL_AccessAckData#(o, s, a, w) AccessAckData;
} TL_LightChannelD#(numeric type o, numeric type s, numeric type a, numeric type w)
deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(i) sink;
} TL_GrantAck#(numeric type i)
deriving(Bits, FShow, Eq);

typedef union tagged {
  TL_GrantAck#(i) GrantAck;
} TL_ChannelE#(numeric type i)
deriving(Bits, FShow, Eq);


// TileLink light master interface
interface TL_LightMaster#(numeric type o, numeric type s, numeric type a, numeric type w);
  interface FifoO#(TL_LightChannelA#(o, s, a, w)) channelA;
  interface FifoI#(TL_LightChannelD#(o, s, a, w)) channelD;
endinterface

// TileLink light slave interface
interface TL_LightSlave#(numeric type o, numeric type s, numeric type a, numeric type w);
  interface FifoI#(TL_LightChannelA#(o, s, a, w)) channelA;
  interface FifoO#(TL_LightChannelD#(o, s, a, w)) channelD;
endinterface

// TileLink master interface
interface TL_Master#(numeric type i, numeric type o,
  numeric type s, numeric type a, numeric type w);
  interface FifoO#(TL_ChannelA#(o, s, a, w)) channelA;
  interface FifoI#(TL_ChannelB#(o, s, a, w)) channelB;
  interface FifoO#(TL_ChannelC#(o, s, a, w)) channelC;
  interface FifoI#(TL_ChannelD#(i, o, s, a, w)) channelD;
  interface FifoO#(TL_ChannelE#(i)) channelE;
endinterface

// TileLink slave interface
interface TL_Slave#(numeric type i, numeric type o,
  numeric type s, numeric type a, numeric type w);
  interface FifoI#(TL_ChannelA#(o, s, a, w)) channelA;
  interface FifoO#(TL_ChannelB#(o, s, a, w)) channelB;
  interface FifoI#(TL_ChannelC#(o, s, a, w)) channelC;
  interface FifoO#(TL_ChannelD#(i, o, s, a, w)) channelD;
  interface FifoI#(TL_ChannelE#(i)) channelE;
endinterface

// Generate a TileLink master using a TileLink light interface
// This master has no permission on any cache block,
// and return an error if we try to acquire from it
// We must care about the size of the response beats:
//  According to the TileLink documentation, responses
// must have the size specified by the size field, even
// if the request return an error
module mkTileLink_LightMaster_to_Master
  #(TL_LightMaster#(o, s, a, w) master)
  (TL_Master#(i, o, s, a, w));

  interface FifoO channelA;
  endinterface

  interface FifoI channelB;
  endinterface

  interface FifoO channelC;
  endinterface

  interface FifoI channelD;
  endinterface

  interface FifoO channelE;
  endinterface
endmodule
