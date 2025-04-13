import RegFileUtils :: *;
import BuildVector :: *;
import RegFile :: *;
import Utils :: *;
import Decode :: *;
import Vector :: *;
import Fifo :: *;
import Ehr :: *;
import CSR :: *;
import OOO :: *;

interface PhysRegFile;
  // Run at stage 1 (commit and register read)
  method Action commit(ArchReg arch, PhysReg phys, Bool keep, Bool flush);
  //method Vector#(3, Bit#(32)) read(Vector#(3, PhysReg) phys);

  // Run at stage 2 (wakeup)
  method Action wakeup(PhysReg phys, Bit#(32) value);


  // Run at stage 3 (enter)
  method RegVal read1(PhysReg phys);
  method RegVal read2(PhysReg phys);
  method RegVal read3(PhysReg phys);
  method ActionValue#(PhysReg) enter(ArchReg arch);

  // Run at stage 4 (rename)
  method PhysReg rename1(ArchReg arch);
  method PhysReg rename2(ArchReg arch);
  method PhysReg rename3(ArchReg arch);
endinterface

(* synthesize *)
module mkPhysRegFile(PhysRegFile);
  ForwardRegFile#(Bit#(6), PhysReg) naming <- mkForwardRegFileFullGen(zeroExtend);
  ForwardRegFile#(ArchReg, PhysReg) backup <- mkForwardRegFileFull();
  Ehr#(3,Bit#(64)) speculated <- mkEhr(0);

  Ehr#(2,Bit#(NumPhysReg)) scoreboard <- mkEhr(0);

  ForwardRegFile#(PhysReg,Bit#(32)) registers <- mkForwardRegFileFullInit(0);

  /*** Free List ***/
  Ehr#(2, Maybe#(PhysReg)) head <- mkEhr(Valid(64));
  function Maybe#(PhysReg) genFreeList(PhysReg phys) = phys+1 <= 64 ? Invalid : Valid(phys+1);
  ForwardRegFile#(PhysReg, Maybe#(PhysReg)) freeList <- mkForwardRegFileFullGen(genFreeList);

  function Action free(PhysReg phys);
    action
      if (phys != 0) begin
        freeList.upd(phys, head[0]);
        head[0] <= Valid(phys);
      end
    endaction
  endfunction

  Bool canAlloc = isJust(head[1]);
  function ActionValue#(PhysReg) alloc();
    actionvalue
      let h = unJust(head[1]);
      head[1] <= freeList.forward(h);
      return h;
    endactionvalue
  endfunction

  /*** Stage 1 ***/
  method Action commit(ArchReg arch, PhysReg phys, Bool keep, Bool flush);
    action
      // no indirection or re-maping of `arch` since the allocation of `phys`
      let valid = speculated[0][pack(arch)] == 1 && backup.sub(arch) == phys;

      if (flush)
        speculated[0] <= 0;
      else if (valid)
        speculated[0][pack(arch)] <= 0;

      if (keep) begin
        free(naming.sub(pack(arch)));
        naming.upd(pack(arch), phys);
      end else free(phys);
    endaction
  endmethod

  /*** Stage 2 ***/
  method Action wakeup(PhysReg r, Bit#(32) value);
    action
      if (r != 0) begin
        registers.upd(r, value);
        scoreboard[0][r] <= 0;
      end
    endaction
  endmethod

  /*** Stage 3 ***/
  method RegVal read1(PhysReg phys);
    return scoreboard[1][phys] == 1 ? Wait(phys) : Value(registers.forward(phys));
  endmethod

  method RegVal read2(PhysReg phys);
    return scoreboard[1][phys] == 1 ? Wait(phys) : Value(registers.forward(phys));
  endmethod

  method RegVal read3(PhysReg phys);
    return scoreboard[1][phys] == 1 ? Wait(phys) : Value(registers.forward(phys));
  endmethod

  method ActionValue#(PhysReg) enter(ArchReg arch)
    if (canAlloc);
    actionvalue
      if (arch == zeroReg) return 0;
      else begin
        let phys <- alloc();
        speculated[1][pack(arch)] <= 1;
        scoreboard[1][phys] <= 1;
        backup.upd(arch, phys);
        return phys;
      end
    endactionvalue
  endmethod

  method PhysReg rename1(ArchReg arch);
    return speculated[2][pack(arch)] == 1 ? backup.forward(arch) : naming.forward(pack(arch));
  endmethod

  method PhysReg rename2(ArchReg arch);
    return speculated[2][pack(arch)] == 1 ? backup.forward(arch) : naming.forward(pack(arch));
  endmethod

  method PhysReg rename3(ArchReg arch);
    return speculated[2][pack(arch)] == 1 ? backup.forward(arch) : naming.forward(pack(arch));
  endmethod
endmodule
