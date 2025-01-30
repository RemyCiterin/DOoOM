package Ehr;

import Vector :: *;

typedef Vector#(n, Reg#(t)) Ehr#(numeric type n, type t);

module mkEhr#(t init) (Ehr#(n, t)) provisos(Bits#(t, tWidth));
  Vector#(n, RWire#(t)) wires <- replicateM(mkRWire);
  Reg#(t) register <- mkReg(init);
  Ehr#(n, t) out = newVector;

  (* fire_when_enabled, no_implicit_conditions *)
  rule ehr_canon;
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

// like a register but without the dependency read < write
module mkEhr0#(t init) (Reg#(t)) provisos(Bits#(t, tWidth));
  Ehr#(1, t) ehr <- mkEhr(init);
  return ehr[0];
endmodule

endpackage
