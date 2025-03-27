import RegFileUtils :: *;
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
interface RegisterFileOOO;
  // set a register as ready, it must execute first so if we write back
  // into a register and allocate a new entry in the issue queue, then
  // the issue queue get the new retired value of the register and avoid deadlock
  // If clear is true the all the registers of the register file must be set to ready
  method Action setReady(ArchReg r, RobIndex index, Maybe#(Bit#(32)) value, Bool clear);

  // read into a register
  method RegVal rs1(ArchReg r);

  // read into a register
  method RegVal rs2(ArchReg r);

  // read into a register
  method RegVal rs3(ArchReg r);

  // set a register as busy
  method Action setBusy(ArchReg r, RobIndex index);
endinterface

(* synthesize *)
module mkRegisterFileOOO(RegisterFileOOO);
  // Register file with commited writes and forwarding logic
  ForwardRegFile#(Bit#(6), Bit#(32)) registers <- mkForwardRegFileFullInit(0);

  // Index of the physical registers in the Reodrer Buffer
  RegFile#(Bit#(6), RobIndex) physicalRegs <- mkRegFileFull;
  // Return is an entry of the physical register remaping is valid
  Ehr#(2, Bit#(64)) scoreboard <- mkEhr(0);

  method Action setReady(ArchReg r, RobIndex index, Maybe#(Bit#(32)) value, Bool clear);
    action
      if (value matches tagged Valid .v &&& r != zeroReg) begin
        registers.upd(pack(r), v);
      end

      if (clear)
        scoreboard[0] <= 0;
      else if (scoreboard[0][pack(r)] == 1 && physicalRegs.sub(pack(r)) == index)
        scoreboard[0][pack(r)] <= 0;
    endaction
  endmethod

  method RegVal rs1(ArchReg r);
    return scoreboard[1][pack(r)] == 1 ?
      tagged Wait physicalRegs.sub(pack(r)) :
      tagged Value registers.forward(pack(r));
  endmethod

  method RegVal rs2(ArchReg r);
    return scoreboard[1][pack(r)] == 1 ?
      tagged Wait physicalRegs.sub(pack(r)) :
      tagged Value registers.forward(pack(r));
  endmethod

  method RegVal rs3(ArchReg r);
    return scoreboard[1][pack(r)] == 1 ?
      tagged Wait physicalRegs.sub(pack(r)) :
      tagged Value registers.forward(pack(r));
  endmethod

  method Action setBusy(ArchReg r, RobIndex index);
    if (r != zeroReg) begin
      scoreboard[1][pack(r)] <= 1;
      physicalRegs.upd(pack(r), index);
    end
  endmethod
endmodule
