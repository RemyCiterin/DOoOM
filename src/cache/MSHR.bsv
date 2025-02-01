import FIFOF :: *;
import SpecialFIFOs :: *;
import GetPut :: *;
import Vector :: *;
import BuildVector :: *;
import BlockRam :: *;
import AXI4 :: *;
import AXI4_Lite :: *;
import Utils :: *;
import OOO :: *;
import Ehr :: *;
import Fifo :: *;

import StmtFSM :: *;
import RegFile :: *;

interface MSHR#(
  numeric type mshrW, numeric type entryW,
  numeric type tagW, type entryT);

  // This action can fire only if the entry for this tag is not busy
  method ActionValue#(Bit#(mshrW)) allocMSHR(Bit#(tagW) tag, entryT entry);

  // Return the tag associated with a givent MSHR entry
  method Bit#(tagW) readTag(Bit#(mshrW) index);

  // Allocate an entry for a request given an already allocated MSHR
  method Action allocEntry(Bit#(tagW) tag, entryT entry);

  // Start the processus to free a MSHR, allow to iterate over all the requests
  // of the MSHR at the next cycle
  method Action freeMSHR(Bit#(tagW) tag);

  method ActionValue#(entryT) freeEntry;

  method Action freeDone;
endinterface

module mkMSHR (MSHR#(mshrW, entryW, tagW, entryT))
  provisos (Bits#(entryT, entryWidth), Add#(mshrW, _something, tagW));

  // Valid bit of a Miss Status Handling Register (MSHR)
  RegFile#(Bit#(mshrW), Bool) validV <- mkRegFileFullInit(False);

  // Tag of a MSHR
  RegFile#(Bit#(mshrW), Bit#(tagW)) tagV <- mkRegFileFull;

  // Entries that MSHR use to store their associated entries
  RegFile#(Bit#(entryW), entryT) entryV <- mkRegFileFull;

  RegFile#(Bit#(entryW), Maybe#(Bit#(entryW))) nextV <-
    mkRegFileFullInit(Invalid);

  function Maybe#(Bit#(entryW)) genFreeList(Bit#(entryW) entry);
    return entry + 1 == 0 ? Invalid : Valid(entry + 1);
  endfunction

  RegFile#(Bit#(entryW), Maybe#(Bit#(entryW))) freeList <-
    mkRegFileFullGen(genFreeList);

  // first element of the linked list of entries of this MSHR
  RegFile#(Bit#(mshrW), Maybe#(Bit#(entryW))) firstV <- mkRegFileFull;

  // last element of the linked list of entries of this MSHR
  RegFile#(Bit#(mshrW), Maybe#(Bit#(entryW))) lastV <- mkRegFileFull;

  // Head of the free list of entries
  Reg#(Maybe#(Bit#(entryW))) freeHead <- mkReg(Valid(0));

  // The MSHR we have to free because it's cache line has been acquire
  Reg#(Maybe#(Bit#(mshrW))) toFree <- mkReg(Invalid);

  method Bit#(tagW) readTag(Bit#(mshrW) index);
    return tagV.sub(index);
  endmethod

  method ActionValue#(Bit#(mshrW)) allocMSHR(Bit#(tagW) tag, entryT req)
    if (freeHead matches tagged Valid .entry);
    actionvalue
      Bit#(mshrW) index = truncate(tag);

      // The allocation is not permited if the index is busy
      when(!validV.sub(index), action
        freeHead <= freeList.sub(entry);
        freeList.upd(entry, Invalid);
        entryV.upd(entry, req);
        validV.upd(index, True);
        firstV.upd(index, Valid(entry));
        lastV.upd(index, Valid(entry));
        tagV.upd(index, tag);
      endaction);

      return index;
    endactionvalue
  endmethod

  method Action allocEntry(Bit#(tagW) tag, entryT req)
    if (freeHead matches tagged Valid .entry);
    action
      // Allocate entry
      freeHead <= freeList.sub(entry);
      freeList.upd(entry, Invalid);
      entryV.upd(entry, req);

      // Now inform it's MSHR of the allocation
      Bit#(mshrW) index = truncate(tag);

      if (tagV.sub(index) != tag)
        $display("MSHR tag error: no MSHR allocated for the tag %x", tag);

      // If the MSHR doesn't contain any element we must add the entry as a
      // first element
      if (firstV.sub(index) matches Invalid)
        firstV.upd(index, Valid(entry));

      // We must add a link to the free list of the MSHR
      if (lastV.sub(index) matches tagged Valid .e &&& e != entry) begin
        nextV.upd(e, Valid(entry));
      end

      // In any situation we set the new entry as the last entry of the MSHR
      lastV.upd(index, Valid(entry));
    endaction
  endmethod

  method Action freeMSHR(Bit#(tagW) tag) if (toFree matches Invalid);
    action
      toFree <= Valid(truncate(tag));
    endaction
  endmethod

  method ActionValue#(entryT) freeEntry
    if (
      toFree matches tagged Valid .idx &&&
      firstV.sub(idx) matches tagged Valid .entry
    ); actionvalue
      firstV.upd(idx, nextV.sub(entry));
      if (lastV.sub(idx) == Valid(entry))
        lastV.upd(idx, Invalid);

      nextV.upd(entry, Invalid);

      freeList.upd(entry, freeHead);
      freeHead <= Valid(entry);

      return entryV.sub(entry);
    endactionvalue
  endmethod

  method Action freeDone
    if (
      toFree matches tagged Valid .idx &&&
      firstV.sub(idx) matches Invalid
    ); action
      validV.upd(idx, False);
      toFree <= Invalid;
    endaction
  endmethod
endmodule
