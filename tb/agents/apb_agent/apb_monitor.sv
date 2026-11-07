// APB Monitor
// Converted from UVM: uses a mailbox instead of uvm_analysis_port.
// Observes the APB bus and forwards captured transactions to the scoreboard.

class apb_monitor;
  virtual apb_if.APB_SCB_MP vif;
  mailbox #(apb_trans_item) mon2sb;

  static int mon_data_count = 0;

  function new(virtual apb_if.APB_SCB_MP vif, mailbox #(apb_trans_item) mon2sb);
    this.vif    = vif;
    this.mon2sb = mon2sb;
  endfunction

  task run();
  wait (top.DUT.Hresetn == 1'b1);
    repeat (2) @(vif.apb_mon_cb);
    forever begin
      collect_data();
    end
  endtask

  task collect_data();
    apb_trans_item xtn;
    xtn = new();

    // Wait for APB enable (setup + enable phase complete)
    do
      @(vif.apb_mon_cb);
    while (!(vif.apb_mon_cb.Penable & (vif.apb_mon_cb.Pselx != 0)));

    xtn.Paddr   = vif.apb_mon_cb.Paddr;
    xtn.Pwrite  = vif.apb_mon_cb.Pwrite;
    xtn.Pselx   = vif.apb_mon_cb.Pselx;

    if (xtn.Pwrite == 1)
        xtn.Pwdata = vif.apb_mon_cb.Pwdata;
    else
        xtn.Prdata = vif.apb_mon_cb.Prdata;

    //xtn.print();
    mon2sb.put(xtn);

    mon_data_count++;
  endtask

endclass
