// Test 2 — Write-Back (Back-to-Back Single Writes) Test
// Drives 15 consecutive AHB single (NONSEQ) write transactions.
// Equivalent to UVM test_2 running write_back sequence.

class back_to_back_write_seq_test extends base_test;

    function new(virtual ahb_if.AHB_MCB_MP ahb_drv_vif,
                 virtual ahb_if.AHB_SCB_MP ahb_mon_vif,
                 virtual apb_if.APB_MCB_MP apb_drv_vif,
                 virtual apb_if.APB_SCB_MP apb_mon_vif);
        super.new(ahb_drv_vif, ahb_mon_vif, apb_drv_vif, apb_mon_vif);
    endfunction

    task body();
      $display("Back-to-back write sequence test");
      env.ahb_agt.gen.back_to_back_write_sequence(0, 1, 1, 20, 15);
    endtask

endclass