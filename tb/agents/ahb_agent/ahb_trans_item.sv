// AHB Transaction Class
// Converted from UVM: removed uvm_sequence_item base class and UVM macros

class ahb_trans_item;

  rand logic        Hwrite;
  rand logic [1:0]  Htrans;
  rand logic [2:0]  Hsize;
  rand logic [31:0] Haddr;
  rand logic [2:0]  Hburst;
  rand logic [31:0] Hwdata;
       logic [31:0] Hrdata;
  rand logic [7:0]  length;
  rand logic        Hresetn;
  rand bit          reset_dis;       //Disable activating reset
  rand bit          busy_cycles_dis; //Disable inserting BUSY states in burst
  rand int          busy_cycles;     // Number of cycles to wait before driving the transaction (for backpressure simulation)
  rand bit          error_injection;  // Whether to inject an error response for this transaction
  
  constraint fixed_word_transfer {Hsize == 3'b010;};
  
  constraint valid_length { ((4 * length) + Haddr[9:0]) < 1024; }

  constraint valid_haddr  { Haddr % 4 == 0; }
  constraint haddr_dist   {if (error_injection == 0) Haddr dist {[32'h8000_0000:32'h83ff_ffff]:/33, [32'h8400_0000:32'h87ff_ffff]:/33, [32'h8800_0000:32'h8bff_ffff]:/34}; }

  constraint valid_haddr1 { if (error_injection == 0) Haddr inside {[32'h8000_0000 : 32'h8BFF_FFFF]}; else Haddr inside {[32'h8C00_0000 : 32'h8FFF_FFFF]}; }
  constraint hwdata_dist  {Hwdata dist {[0:32'h0000_ffff]:/50, [32'h0001_ffff:32'hffff_ffff]:/50}; }

  constraint busy_disable_const       { if (busy_cycles_dis == 1) busy_cycles == 0; }
  constraint busy_cycles_limit        { busy_cycles <= 10; }
  constraint busy_cycles_at_nonseq    { if (Htrans != 2'b11) busy_cycles == 0; }
  constraint busy_dist_const          { if (busy_cycles_dis == 0) busy_cycles dist {0 := 95, [1:10] := 5}; }

  constraint reset_disable_const      { if (reset_dis == 1) Hresetn == 1; }
  constraint reset_dist_const         { if (reset_dis == 0) Hresetn dist {1 := 95, 0 := 5}; }

  function void print();
    $display("[AHB_TRANS_ITEM] Haddr=%0h  Hwdata=%0h  Hrdata=%0h  Hwrite=%0b  Htrans=%0b Hsize = %0b Hburst=%0b Hresetn=%b reset_dis=%0b busy_cycles_dis=%0b busy_cycles=%0d error_injection=%0b",
              Haddr, Hwdata, Hrdata, Hwrite, Htrans, Hsize, Hburst, Hresetn, reset_dis, busy_cycles_dis, busy_cycles, error_injection);
  endfunction

  function void copy(ahb_trans_item other);
    Hwrite = other.Hwrite;
    Htrans = other.Htrans;
    Hsize  = other.Hsize;
    Haddr  = other.Haddr;
    Hburst = other.Hburst;
    Hwdata = other.Hwdata;
    Hrdata = other.Hrdata;
    length = other.length;
    Hresetn = other.Hresetn;
    reset_dis = other.reset_dis;
    busy_cycles_dis = other.busy_cycles_dis;
    busy_cycles = other.busy_cycles;
	error_injection = other.error_injection;
  endfunction

endclass