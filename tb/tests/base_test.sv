// Base Test Class
// Holds the environment and provides a virtual configure() hook
// for sub-tests to set generator parameters before run.
`include "environment.sv"

class base_test;

    environment env;

    function new(virtual ahb_if.AHB_MCB_MP ahb_drv_vif,
                 virtual ahb_if.AHB_SCB_MP ahb_mon_vif,
                 virtual apb_if.APB_MCB_MP apb_drv_vif,
                 virtual apb_if.APB_SCB_MP apb_mon_vif);
        env = new(ahb_drv_vif, ahb_mon_vif, apb_drv_vif, apb_mon_vif);
    endfunction

    virtual task configure();
    endtask
  
    virtual task pre_test();
      env.ahb_agt.drv.init();
    endtask
  
    virtual task body();
    endtask
  
    virtual task post_test();
        int wait_cycles = 0;
        repeat (100) @(env.ahb_agt.drv_vif.ahb_drv_cb);
        forever begin
            if ((env.ahb_agt.gen2drv.num() == 0 && env.ahb_agt.mon2sb.num() == 0) || (wait_cycles > 300))
                break;
            wait_cycles++;
            @(env.ahb_agt.drv_vif.ahb_drv_cb);
        end
        
        repeat (50) @(env.ahb_agt.drv_vif.ahb_drv_cb);
        env.report();
        $finish;
    endtask
  
    task run();
        configure();
        env.start();
        pre_test();
        body();
        post_test();
    endtask

endclass
