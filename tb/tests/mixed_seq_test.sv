
class mixed_seq_test extends base_test;
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
      hwrite = $urandom_range(0,1);
      busy_state_dis = hwrite;
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
    
    $display("Burst sequence with reset test");
    env.ahb_agt.gen.burst_sequence(0, 1, 1, 20, env.ahb_agt.drv.vif);
    repeat (20) @(env.ahb_agt.drv.vif.ahb_drv_cb);
    env.ahb_agt.gen.burst_sequence(0, 1, 1, 20, env.ahb_agt.drv.vif);
    
    repeat ($urandom_range(1,10)) @(env.ahb_agt.drv.vif.ahb_drv_cb);
    $display("Normal burst sequence test");
    env.ahb_agt.gen.burst_sequence(0, 1, 1, 20, env.ahb_agt.drv.vif);
    
    repeat ($urandom_range(1,10)) @(env.ahb_agt.drv.vif.ahb_drv_cb);
    $display("Burst sequence with reset test");
    env.ahb_agt.gen.burst_sequence(0, 1, 1, 20, env.ahb_agt.drv.vif);
    repeat (20) @(env.ahb_agt.drv.vif.ahb_drv_cb);
    env.ahb_agt.gen.burst_sequence(0, 1, 1, 20, env.ahb_agt.drv.vif);
    
    $display("Back-to-back write sequence test");
    env.ahb_agt.gen.back_to_back_write_sequence(0, 1, 1, 20, 15);
  endtask  
  
endclass
