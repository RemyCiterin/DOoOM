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

interface RenamingTable;
  // Stage 1 commit
  method Action commit(ArchReg arch, PhysReg phys, Bool keep, Bool flush);

  // Stage 2 wakeup
  method Action wakeup(PhysReg phys);

  // Stage 2 enter
  method Bool ready1(PhysReg phys);
  method Bool ready2(PhysReg phys);
  method Bool ready3(PhysReg phys);
  method Action allocate(ArchReg arch);
  method PhysReg allocated(ArchReg arch);

  // Stage 4 rename
  method PhysReg rename1(ArchReg arch);
  method PhysReg rename2(ArchReg arch);
  method PhysReg rename3(ArchReg arch);
endinterface

(* synthesize *)
module mkRenamingTable(RenamingTable);
  ForwardRegFile#(Bit#(6), PhysReg) naming <- mkForwardRegFileFullGen(zeroExtend);
  ForwardRegFile#(ArchReg, PhysReg) backup <- mkForwardRegFileFull();
  Ehr#(3,Bit#(NumArchReg)) speculated <- mkEhr(0);

  Ehr#(2,Bit#(NumPhysReg)) scoreboard <- mkEhr(0);

  /*** Free List ***/
  PhysReg initHead = fromInteger(valueOf(NumArchReg));
  PhysReg lastPhys = fromInteger(valueOf(NumPhysReg)-1);
  Ehr#(2, Maybe#(PhysReg)) head <- mkEhr(Valid(initHead));
  function Maybe#(PhysReg) genFreeList(PhysReg phys) =
    phys < initHead || phys == lastPhys ? Invalid : Valid(phys+1);
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
  method Action wakeup(PhysReg pdst);
    action
      if (pdst != 0) scoreboard[0][pdst] <= 0;
    endaction
  endmethod

  /*** Stage 3 ***/
  method Bool ready1(PhysReg phys);
    return scoreboard[1][phys] == 0;
  endmethod

  method Bool ready2(PhysReg phys);
    return scoreboard[1][phys] == 0;
  endmethod

  method Bool ready3(PhysReg phys);
    return scoreboard[1][phys] == 0;
  endmethod

  method PhysReg allocated(ArchReg arch) if (head[1] matches tagged Valid .hd);
    return arch == zeroReg ? 0 : hd;
  endmethod

  method Action allocate(ArchReg arch)
    if (canAlloc);
    action
      if (arch != zeroReg) begin
        let phys <- alloc();
        speculated[1][pack(arch)] <= 1;
        scoreboard[1][phys] <= 1;
        backup.upd(arch, phys);
      end
    endaction
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

interface PhysRegFile;
  // Stage 1 read
  method Bit#(32) read1(PhysReg phys);
  method Bit#(32) read2(PhysReg phys);
  method Bit#(32) read3(PhysReg phys);
  method Bit#(32) read4(PhysReg phys);
  method Bit#(32) read5(PhysReg phys);
  method Bit#(32) read6(PhysReg phys);
  method Bit#(32) read7(PhysReg phys);
  method Bit#(32) read8(PhysReg phys);

  // Stage 2 write
  method Action write(PhysReg phys, Bit#(32) value);
endinterface

(* synthesize *)
module mkPhysRegFile(PhysRegFile);
  // This register file doesn't respect the read < write rule, but
  // we know that the register was already ready in the register Issue Queue the
  // previous cycle, so we don't need to forward the value form the writeBack stage
  RegFile#(PhysReg, Bit#(32)) registers1 <- mkRegFile(0, fromInteger(valueOf(NumPhysReg)-1));
  RegFile#(PhysReg, Bit#(32)) registers2 <- mkRegFile(0, fromInteger(valueOf(NumPhysReg)-1));
  RWire#(Tuple2#(PhysReg, Bit#(32))) update <- mkRWire;

  Reg#(Bool) init <- mkReg(False);
  Reg#(PhysReg) index <- mkReg(0);

  (* fire_when_enabled, no_implicit_conditions *)
  rule do_update;
    if (init) begin
      if (update.wget matches tagged Valid {.phys, .value}) begin
        registers1.upd(phys,value);
        registers2.upd(phys,value);
      end
    end else begin
      registers1.upd(index, 0);
      registers2.upd(index, 0);
      index <= index + 1;

      if (index == fromInteger(valueOf(NumPhysReg)-1))
        init <= True;
    end
  endrule

  method Action write(PhysReg pdst, Bit#(32) value) if (init);
    action
      if (pdst != 0) update.wset(tuple2(pdst, value));
    endaction
  endmethod

  method read1 = when(init, registers1.sub);
  method read2 = when(init, registers1.sub);
  method read3 = when(init, registers1.sub);
  method read4 = when(init, registers1.sub);
  method read5 = when(init, registers2.sub);
  method read6 = when(init, registers2.sub);
  method read7 = when(init, registers2.sub);
  method read8 = when(init, registers2.sub);
endmodule
