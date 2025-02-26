import RevertingVirtualReg::*;
import Vector :: *;



// Type of generalized "permanant" registers:
// they are permanant in the sens that they don't
// have the constraint `r < w` so their value is
// visible during the complete cycle
typedef Vector#(n, Reg#(t)) PReg#(numeric type n, type t);

/*
This register type have the following constraints:
  forall i < j, w[i] < w[j]
  forall i < j, w[i] < r[j]
  forall i j, r[i] is conflict free with r[j]
  forall i, w[i] conflict with w[i]
*/

module mkPReg#(t init) (PReg#(n, t)) provisos(Bits#(t, tWidth));
  Vector#(n, RWire#(t)) wires <- replicateM(mkRWire);
  Reg#(t) register <- mkReg(init);
  PReg#(n, t) out = newVector;

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
module mkPReg0#(t init) (Reg#(t)) provisos(Bits#(t, tWidth));
  PReg#(1, t) ehr <- mkPReg(init);
  return ehr[0];
endmodule

typedef Vector#(n, Reg#(t)) Ehr#(numeric type n, type t);

module mkEhr#(t init) (Ehr#(n, t)) provisos(Bits#(t, tWidth));
  Vector#(n, Reg#(Bool)) order <- replicateM(mkRevertingVirtualReg(False));
  PReg#(n, t) preg <- mkPReg(init);

  Vector#(n, Reg#(t)) ifc = newVector;

  for(Integer i=0; i < valueOf(n); i = i + 1) begin
    ifc[i] = interface Reg;
      method Action _write(t x);
        order[i] <= True;
        preg[i] <= x;
      endmethod

      method t _read();
        Bool valid = True;

        for (Integer j=i; j < valueOf(n); j = j + 1) begin
          valid = valid && !order[j];
        end

        return valid ? preg[i] : ?;
      endmethod
    endinterface;
  end

  return ifc;
endmodule
