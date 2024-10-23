import Ehr :: *;

// The mutex interface allow to request read-only and read-write permissions
// about an index.

interface Mutex;
  method Action lock;

  // If true then the mutex is ready to be acquire
  method Bool isReady;

  method Action unlock;
endinterface

module mkMutex(Mutex);
  Ehr#(2, Bool) is_ready <- mkEhr(False);

  method Action lock if (is_ready[1]);
    action
      is_ready[1] <= False;
    endaction
  endmethod

  method Bool isReady;
    return is_ready[1];
  endmethod

  method Action unlock if (!is_ready[0]);
    action
      is_ready[0] <= True;
    endaction
  endmethod
endmodule
