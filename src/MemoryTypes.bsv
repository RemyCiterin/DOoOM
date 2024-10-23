package MemoryTypes;

import Utils :: *;
import GetPut :: *;
import Connectable :: *;

// This file present the internal represantation of memory requests of the CPU, then we have to convert them to AXI4_Lite or AXI4 to communicate
// with the caches

// Load size doesn't care aobout signe, the CPU has to overwrite the result in function of the sign of the load

typedef enum {Byte, Half, Word} Data_Size deriving(Bits, Eq, FShow);

typedef enum {OK, ERR} Riscv_Mem_Response deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(32) addr;
  Data_Size size;
  Bit#(32) bytes;
} Riscv_WRequest deriving(Bits, FShow, Eq);

typedef struct {
  Riscv_Mem_Response resp;
} Riscv_WResponse deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(32) addr;
  Data_Size size;
} Riscv_RRequest deriving(Bits, FShow, Eq);

typedef struct {
  Bit#(32) bytes;
  Riscv_Mem_Response resp;
} Riscv_RResponse deriving(Bits, FShow, Eq);

typedef union tagged {
  Riscv_RRequest Rd;
  Riscv_WRequest Wr;
} Riscv_Request deriving(Bits, FShow, Eq);

typedef union tagged {
  Riscv_RResponse Rd;
  Riscv_WResponse Wr;
} Riscv_Response deriving(Bits, FShow, Eq);

interface Riscv_Read_Master;
  interface Get#(Riscv_RRequest) request;
  interface Put#(Riscv_RResponse) response;
endinterface

interface Riscv_Write_Master;
  interface Get#(Riscv_WRequest) request;
  interface Put#(Riscv_WResponse) response;
endinterface

interface Riscv_Read_Slave;
  interface Put#(Riscv_RRequest) request;
  interface Get#(Riscv_RResponse) response;
endinterface

interface Riscv_Write_Slave;
  interface Put#(Riscv_WRequest) request;
  interface Get#(Riscv_WResponse) response;
endinterface

instance Connectable#(Riscv_Read_Master, Riscv_Read_Slave);
  module mkConnection#(Riscv_Read_Master master, Riscv_Read_Slave slave)(Empty);
    mkConnection(master.request, slave.request);
    mkConnection(master.response, slave.response);
  endmodule
endinstance

instance Connectable#(Riscv_Read_Slave, Riscv_Read_Master);
  module mkConnection#(Riscv_Read_Slave slave, Riscv_Read_Master master)(Empty);
    mkConnection(master, slave);
  endmodule
endinstance

instance Connectable#(Riscv_Write_Master, Riscv_Write_Slave);
  module mkConnection#(Riscv_Write_Master master, Riscv_Write_Slave slave)(Empty);
    mkConnection(master.request, slave.request);
    mkConnection(master.response, slave.response);
  endmodule
endinstance

instance Connectable#(Riscv_Write_Slave, Riscv_Write_Master);
  module mkConnection#(Riscv_Write_Slave slave, Riscv_Write_Master master)(Empty);
    mkConnection(master, slave);
  endmodule
endinstance

endpackage
