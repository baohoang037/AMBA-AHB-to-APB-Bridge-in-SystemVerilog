// Test 1 — Burst Sequence Test
// Drives 2 AHB burst sequences (INCR4 / INCR8 / INCR16 / INCR)
// Equivalent to UVM test_1 running test_sequence.

class normal_burst_seq_test extends base_test;

    function new(virtual ahb_if.AHB_MCB_MP ahb_drv_vif,
                 virtual ahb_if.AHB_SCB_MP ahb_mon_vif,
                 virtual apb_if.APB_MCB_MP apb_drv_vif,
                 virtual apb_if.APB_SCB_MP apb_mon_vif);
        super.new(ahb_drv_vif, ahb_mon_vif, apb_drv_vif, apb_mon_vif);
    endfunction

    task body();
      $display("Normal burst sequence test");
      env.ahb_agt.gen.burst_sequence(0, 1, 1, 20, env.ahb_agt.drv.vif);
    endtask
  
endclass