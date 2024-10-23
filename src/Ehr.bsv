package Ehr;

// import Vector::*;
// import RWire::*;
// import RevertingVirtualReg::*;
//
// typedef  Vector#(n, Reg#(t)) Ehr#(numeric type n, type t);
//
// function Vector#(n, t) readVEhr(i ehr_index, Vector#(n, Ehr#(n2, t)) vec_ehr) provisos (PrimIndex#(i, __a));
//     function Reg#(t) get_ehr_index(Ehr#(n2, t) e) = e[ehr_index];
//     return readVReg(map(get_ehr_index, vec_ehr));
// endfunction
//
// // extract vector ports from vector of EHRs
// function Vector#(n, Reg#(t)) getVEhrPort(Vector#(n, Ehr#(m, t)) ehrs, Integer p);
//     function Reg#(t) get(Ehr#(m, t) e) = e[p];
//     return map(get, ehrs);
// endfunction
//
// module mkEhr#(t init)(Ehr#(n, t)) provisos(Bits#(t, tSz));
//   Vector#(n, RWire#(t)) lat <- replicateM(mkUnsafeRWire);
//
//   Vector#(n, Vector#(n, RWire#(Bool))) dummy <- replicateM(replicateM(mkUnsafeRWire));
//   Vector#(n, Reg#(Bool)) dummy2 <- replicateM(mkRevertingVirtualReg(True)); // this must be true
//
//   Reg#(t) rl <- mkReg(init);
//
//   Ehr#(n, t) r = newVector;
//
//   (* fire_when_enabled, no_implicit_conditions *)
//   rule canon;
//     t upd = rl;
//     for(Integer i = 0; i < valueOf(n); i = i + 1)
//       if(lat[i].wget matches tagged Valid .x)
//         upd = x;
//     rl <= upd;
//   endrule
//
//   for(Integer i = 0; i < valueOf(n); i = i + 1)
//     r[i] = (interface Reg;
//               method Action _write(t x);
//                 lat[i].wset(x);
//                 dummy2[i] <= True;
//                 for(Integer j = 0; j < i; j = j + 1)
//                   dummy[i][j].wset(isValid(lat[j].wget));
//               endmethod
//
//               method t _read;
//                 t upd = rl;
//                 Bool yes = True;
//                 for(Integer j = i; j < valueOf(n); j = j + 1)
//                   yes = yes && dummy2[j];
//                 for(Integer j = 0; j < i; j = j + 1)
//                 begin
//                   if(lat[j].wget matches tagged Valid .x)
//                     upd = x;
//                 end
//                 return yes? upd : unpack(0);
//                 // use a non-? val here! otherwise new BSV compiler will stop optimize at ? val
//                 // this affects judging if two rules are exclusive
//               endmethod
//             endinterface);
//
//    return r;
// endmodule

import Vector :: *;

typedef Vector#(n, Reg#(t)) Ehr#(numeric type n, type t);

module mkEhr#(t init) (Ehr#(n, t)) provisos(Bits#(t, tWidth));
  Vector#(n, RWire#(t)) wires <- replicateM(mkRWire);
  Reg#(t) register <- mkReg(init);
  Ehr#(n, t) out = newVector;

  (* fire_when_enabled, no_implicit_conditions *)
  rule canon;
    t value = register;

    for (Integer i=0; i < valueOf(n); i = i + 1)
      if (wires[i].wget matches tagged Valid .val)
        value = val;

    register <= value;
  endrule

  for (Integer i = 0; i < valueOf(n); i = i + 1) begin
    out[i] = (interface Reg;
      method t _read;
        t value = register;
        for (Integer j = 0; j < i; j = j + 1) begin
          if (wires[j].wget matches tagged Valid .val)
            value = val;
        end

        return value;
      endmethod

      method Action _write(t value);
        wires[i].wset(value);
      endmethod
    endinterface);
  end

  return out;

endmodule

endpackage
