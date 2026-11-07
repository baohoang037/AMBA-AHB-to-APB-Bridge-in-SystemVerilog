// APB Transaction Class
// Converted from UVM: removed uvm_sequence_item base class and UVM macros

class apb_trans_item;
  logic             Penable;
  logic             Pwrite;
  rand logic [31:0] Prdata;
  logic [31:0]      Pwdata;
  logic [31:0]      Paddr;
  logic [2:0]       Pselx;

  constraint Prdata_dist { Prdata dist {[0:32'h0000_ffff]:/50, [32'h0001_ffff:32'hffff_ffff]:/50}; }

  function void print();
    $display("[APB_TRANS_ITEM] Paddr=%0h  Pwdata=%0h  Prdata=%0h  Pwrite=%0b  Penable=%0b  Pselx=%0b",
               Paddr, Pwdata, Prdata, Pwrite, Penable, Pselx);
  endfunction
endclass
