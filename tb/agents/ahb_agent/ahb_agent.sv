// AHB Agent
// Converted from UVM: wraps generator, driver, and monitor.
// Uses mailboxes for inter-component communication.

class ahb_agent;

  virtual ahb_if.AHB_MCB_MP drv_vif;
  virtual ahb_if.AHB_SCB_MP mon_vif;

  ahb_generator gen;
  ahb_driver    drv;
  ahb_monitor   mon;

  mailbox #(ahb_trans_item) gen2drv;
  mailbox #(ahb_trans_item) mon2sb;

  function new(virtual ahb_if.AHB_MCB_MP drv_vif,
               virtual ahb_if.AHB_SCB_MP mon_vif,
               mailbox #(ahb_trans_item) mon2sb);
    this.drv_vif = drv_vif;
    this.mon_vif = mon_vif;
    this.mon2sb  = mon2sb;

    gen2drv = new(1); // depth-1 mailbox (handshake-style)

    gen = new(gen2drv);
    drv = new(drv_vif, gen2drv);
    mon = new(mon_vif, mon2sb);
  endfunction

  task start();
    fork
      drv.run();
      mon.run();
    join_none
  endtask
  
  task send_item(ahb_trans_item tr_item);
    gen.send_item(tr_item);
  endtask

endclass
