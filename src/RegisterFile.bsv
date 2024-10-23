package RegisterFile;

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
  Vector#(32, Ehr#(2, Bit#(32))) registers <- replicateM(mkEhr(0));
  Vector#(32, Ehr#(2, Maybe#(RobIndex))) scoreboard <- replicateM(mkEhr(Invalid));

  method Action setReady(RegName r, RobIndex index, Maybe#(Bit#(32)) value, Bool clear);
    action
      if (value matches tagged Valid .v &&& r.name != 0) begin
        //$display("    ", fshow(r), " <= %h", v);
        registers[r.name][0] <= v;
      end

      if (clear) begin
        for (Integer i=0; i < 32; i = i + 1) scoreboard[i][0] <= Invalid;
      end else if (scoreboard[r.name][0] matches tagged Valid .idx &&& idx == index) begin
        scoreboard[r.name][0] <= Invalid;
      end

    endaction
  endmethod

  method RegVal rs1(RegName r);
    return case (scoreboard[r.name][1]) matches
      tagged Valid .index : tagged Wait index;
      Invalid : tagged Value registers[r.name][1];
    endcase;
  endmethod

  method RegVal rs2(RegName r);
    return case (scoreboard[r.name][1]) matches
      tagged Valid .index : tagged Wait index;
      Invalid : tagged Value registers[r.name][1];
    endcase;
  endmethod

  method Bit#(32) read_commited(RegName r);
    return registers[r.name][1];
  endmethod

  method Action setBusy(RegName r, RobIndex index);
    if (r.name != 0) scoreboard[r.name][1] <= tagged Valid index;
  endmethod
endmodule

endpackage
