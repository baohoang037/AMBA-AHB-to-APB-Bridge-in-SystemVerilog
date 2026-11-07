// Test 2 — Write-Back (Back-to-Back Single Writes) Test
// Drives 15 consecutive AHB single (NONSEQ) write transactions.
// Equivalent to UVM test_2 running write_back sequence.


class burst_seq_w_busy_in_read_trans extends base_test;
  function new(virtual ahb_if.AHB_MCB_MP ahb_drv_vif,
                 virtual ahb_if.AHB_SCB_MP ahb_mon_vif,
                 virtual apb_if.APB_MCB_MP apb_drv_vif,
                 virtual apb_if.APB_SCB_MP apb_mon_vif);
        super.new(ahb_drv_vif, ahb_mon_vif, apb_drv_vif, apb_mon_vif);
    endfunction

    task body();
      bit hwrite, busy_state_dis;
      $display("Burst sequence with inserting BUSY states in read transactions only");
      repeat (20) begin
        hwrite = 0;
        busy_state_dis = 0;
        randcase
          1: env.ahb_agt.gen.signle_transaction_gen (0, 1, busy_state_dis, hwrite);
          1: env.ahb_agt.gen.incr_burst_gen         (0, 1, busy_state_dis, hwrite);
          1: env.ahb_agt.gen.wrap4_burst_gen        (0, 1, busy_state_dis, hwrite);
          1: env.ahb_agt.gen.incr4_burst_gen        (0, 1, busy_state_dis, hwrite);
          1: env.ahb_agt.gen.wrap8_burst_gen        (0, 1, busy_state_dis, hwrite);
          1: env.ahb_agt.gen.incr8_burst_gen        (0, 1, busy_state_dis, hwrite);
          1: env.ahb_agt.gen.wrap16_burst_gen       (0, 1, busy_state_dis, hwrite);
          1: env.ahb_agt.gen.incr16_burst_gen       (0, 1, busy_state_dis, hwrite);
        endcase
        repeat ($urandom_range(1,10)) @(env.ahb_agt.drv.vif.ahb_drv_cb);
      end
    endtask  
endclass
