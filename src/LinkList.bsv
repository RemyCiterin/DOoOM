import Utils :: *;
import Ehr :: *;
import Fifo :: *;

import RegFile :: *;
import RegFileUtils :: *;

// Return a free-list based allocator
interface FreeList#(numeric type indexW);
  // alloc a new unallocated index
  method ActionValue#(Bit#(indexW)) alloc;

  // free an index
  method Action free(Bit#(indexW) index);

  // return if the allocator is full (no element can be allocated)
  method Bool full;
endinterface

module mkFreeList (FreeList#(indexW)) provisos (Alias#(Bit#(indexW), indexT));
  function Maybe#(indexT) genFreeList(indexT index);
    return index + 1 == 0 ? Invalid : Valid(index+1);
  endfunction

  Reg#(Maybe#(indexT)) free_head <- mkReg(Valid(0));

  RegFile#(indexT, Maybe#(indexT)) free_list <- mkRegFileFullGen(genFreeList);

  method ActionValue#(indexT) alloc if (free_head matches tagged Valid .idx);
    actionvalue
      free_head <= free_list.sub(idx);
      free_list.upd(idx, Invalid);
      return idx;
    endactionvalue
  endmethod

  method Bool full;
    return free_head == Invalid;
  endmethod

  method Action free(indexT index);
    action
      free_list.upd(index, free_head);
      free_head <= Valid(index);
    endaction
  endmethod
endmodule


// Define a type a simply linked list
// As example they are used in caches to store all the requests associated with
// a Miss Status Handling Register
interface LinkList#(numeric type indexW);
  // create a new empty link list
  method ActionValue#(Bit#(indexW)) init;

  // return if their is still some place available
  method Bool full;

  // add an element to the head of the list and return the new head
  method ActionValue#(Bit#(indexW)) pushHead(Bit#(indexW) head);

  // add an element to the tail of the list and return the new tail
  method ActionValue#(Bit#(indexW)) pushTail(Bit#(indexW) tail);

  // remove the first element of the list
  method Action popHead(Bit#(indexW) head);

  // return the next element in a linked list
  method Maybe#(Bit#(indexW)) next(Bit#(indexW) index);
endinterface


module mkLinkList (LinkList#(indexW)) provisos (Alias#(Bit#(indexW), indexT));
  RegFile#(indexT, Maybe#(indexT)) link <- mkRegFileFullInit(Invalid);

  FreeList#(indexW) free_list <- mkFreeList;

  function Action addLink(indexT from, indexT to);
      return link.upd(from, Valid(to));
  endfunction

  function Action deleteLink(indexT from);
    return link.upd(from, Invalid);
  endfunction

  method full = free_list.full;

  method ActionValue#(indexT) init;
    actionvalue
      let index <- free_list.alloc();
      return index;
    endactionvalue
  endmethod

  method ActionValue#(Bit#(indexW)) pushHead(Bit#(indexW) head);
    actionvalue
      let index <- free_list.alloc();
      addLink(index, head);
      return index;
    endactionvalue
  endmethod

  method ActionValue#(Bit#(indexW)) pushTail(Bit#(indexW) tail);
    actionvalue
      let index <- free_list.alloc();
      addLink(tail, index);
      return index;
    endactionvalue
  endmethod

  method Action popHead(Bit#(indexW) head);
    action
      free_list.free(head);
      deleteLink(head);
    endaction
  endmethod

  method Maybe#(Bit#(indexW)) next(Bit#(indexW) index);
    return link.sub(index);
  endmethod
endmodule

