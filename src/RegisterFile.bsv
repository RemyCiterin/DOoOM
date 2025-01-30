import ForwardRegFile :: *;
import RegFile :: *;
import Utils :: *;
import Decode :: *;
import Vector :: *;
import Ehr :: *;
import CSR :: *;
import OOO :: *;

// This module contain the register values and the scorebaord,
// each time we add an instruction in an issue queue, we must
// add it's reorder buffer index to the scorebaord.
// When we write back an instruction, we set the scoreboard as ready
// only if it's ROB index is the one stored in the scoreboard, otherwise
// The register is already reserved by another instruction and is still busy.
// The module must have setReady < read < setBusy otherwise a global deadlock
// may exist
interface RegisterFile;
  // set a register as ready, it must execute first so if we write back
  // into a register and allocate a new entry in the issue queue, then
  // the issue queue get the new retired value of the register and avoid deadlock
  // If clear is true the all the registers of the register file must be set to ready
  method Action setReady(RegName r, RobIndex index, Maybe#(Bit#(32)) value, Bool clear);

  // read into a register
  method RegVal rs1(RegName r);

  // read into a register
  method RegVal rs2(RegName r);

  // read the commited value of the register
  method Bit#(32) read_commited(RegName r);

  // set a register as busy
  method Action setBusy(RegName r, RobIndex index);
endinterface

(* synthesize *)
module mkRegisterFile(RegisterFile);
  // Register file with commited writes and forwarding logic
  ForwardRegFile#(Bit#(5), Bit#(32)) registers <- mkForwardRegFileFullInit(0);
  RWire#(Bit#(32)) forwardVal <- mkRWire;
  RWire#(Bit#(5)) forwardIdx <- mkRWire;

  // Index of the physical registers in the Reodrer Buffer
  RegFile#(Bit#(5), RobIndex) physicalRegs <- mkRegFileFull;
  // Return is an entry of the physical register remaping is valid
  Ehr#(2, Bit#(32)) scoreboard <- mkEhr(0);

  method Action setReady(RegName r, RobIndex index, Maybe#(Bit#(32)) value, Bool clear);
    action
      if (value matches tagged Valid .v &&& r.name != 0) begin
        registers.upd(r.name, v);
      end

      if (clear)
        scoreboard[0] <= 0;
      else if (scoreboard[0][r.name] == 1 && physicalRegs.sub(r.name) == index)
        scoreboard[0][r.name] <= 0;
    endaction
  endmethod

  method RegVal rs1(RegName r);
    return scoreboard[1][r.name] == 1 ?
      tagged Wait physicalRegs.sub(r.name) :
      tagged Value registers.forward(r.name);
  endmethod

  method RegVal rs2(RegName r);
    return scoreboard[1][r.name] == 1 ?
      tagged Wait physicalRegs.sub(r.name) :
      tagged Value registers.forward(r.name);
  endmethod

  method Bit#(32) read_commited(RegName r);
    return registers.forward(r.name);
  endmethod

  method Action setBusy(RegName r, RobIndex index);
    if (r.name != 0) begin
      scoreboard[1][r.name] <= 1;
      physicalRegs.upd(r.name, index);
    end
  endmethod
endmodule
