// APB Driver
// Converted from UVM: reactive driver — waits for Pselx assertion and
// drives Prdata for read transactions. No mailbox needed (no stimulus).

class apb_driver;
  virtual apb_if.APB_MCB_MP vif;

  static int drv_data_count = 0;

  function new(virtual apb_if.APB_MCB_MP vif);
    this.vif = vif;
  endfunction

  task run();
    forever begin
      send_to_dut();
    end
  endtask

  task send_to_dut();
    apb_trans_item apb_xtn = new();
    // Wait for slave select assertion
    do begin
      @(vif.apb_drv_cb);
    end
    while (vif.apb_drv_cb.Pselx == 0);

    assert(apb_xtn.randomize()) else $fatal(1, "APB_DRV: randomize failed");
    
    // If read, supply random read data
    if (vif.apb_drv_cb.Pwrite == 0)
        vif.apb_drv_cb.Prdata <= apb_xtn.Prdata;

    @(vif.apb_drv_cb);
    
    drv_data_count++;
  endtask

endclass
