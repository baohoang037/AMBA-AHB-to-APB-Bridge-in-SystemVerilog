// Test 2 — Write-Back (Back-to-Back Single Writes) Test
// Drives 15 consecutive AHB single (NONSEQ) write transactions.
// Equivalent to UVM test_2 running write_back sequence.

class back_to_back_transfer_seq_test extends base_test;
    function new(virtual ahb_if.AHB_MCB_MP ahb_drv_vif,
                 virtual ahb_if.AHB_SCB_MP ahb_mon_vif,
                 virtual apb_if.APB_MCB_MP apb_drv_vif,
                 virtual apb_if.APB_SCB_MP apb_mon_vif);
        super.new(ahb_drv_vif, ahb_mon_vif, apb_drv_vif, apb_mon_vif);
    endfunction

    task body();
      ahb_trans_item xtn;
      bit hwrite = 1;

      $display("Back-to-back transfer test");
      repeat (15) begin
          xtn = new();
          assert(xtn.randomize() with {
              Htrans == 2'b10;
              Hburst == 3'b000;
              Hwrite == hwrite;
              Hwdata inside {[0:32'h0000_ffff]};
              reset_dis == 1;
              busy_cycles_dis == 1;
              error_injection == 0;
          }) else $fatal(1, "AHB_GEN: randomize failed (write_back)");
          xtn.print();
          env.ahb_agt.gen.send_item(xtn);
          hwrite = ~hwrite;
      end
      
      // Final IDLE
      xtn = new();
      assert(xtn.randomize() with { Htrans == 2'b00; error_injection == 0; reset_dis == 1; busy_cycles_dis == 1; });
      env.ahb_agt.gen.send_item(xtn);
      
    endtask

endclass