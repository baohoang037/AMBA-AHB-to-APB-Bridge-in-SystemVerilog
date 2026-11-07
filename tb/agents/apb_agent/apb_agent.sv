// APB Agent
// Converted from UVM: wraps APB driver and monitor.

class apb_agent;
  virtual apb_if.APB_MCB_MP drv_vif;
  virtual apb_if.APB_SCB_MP mon_vif;

  apb_driver  drv;
  apb_monitor mon;

  mailbox #(apb_trans_item) mon2sb;

  function new(virtual apb_if.APB_MCB_MP drv_vif,
               virtual apb_if.APB_SCB_MP mon_vif,
               mailbox #(apb_trans_item)        mon2sb);
    this.drv_vif = drv_vif;
    this.mon_vif = mon_vif;
    this.mon2sb  = mon2sb;

    drv = new(drv_vif);
    mon = new(mon_vif, mon2sb);
  endfunction

  task start();
    fork
      drv.run();
      mon.run();
    join_none
  endtask
endclass
