// Environment
// Converted from UVM: creates AHB agent, APB agent, and scoreboard.
// Connects them via mailboxes.
`include "ahb_agent_files.svh"
`include "apb_agent_files.svh"
`include "scoreboard.sv"

class environment;

    virtual ahb_if.AHB_MCB_MP ahb_drv_vif;
    virtual ahb_if.AHB_SCB_MP ahb_mon_vif;
    virtual apb_if.APB_MCB_MP apb_drv_vif;
    virtual apb_if.APB_SCB_MP apb_mon_vif;

    ahb_agent   ahb_agt;
    apb_agent   apb_agt;
    scoreboard  sb;

    mailbox #(ahb_trans_item) ahb_mon2sb;
    mailbox #(apb_trans_item) apb_mon2sb;

    function new(virtual ahb_if.AHB_MCB_MP ahb_drv_vif,
                 virtual ahb_if.AHB_SCB_MP ahb_mon_vif,
                 virtual apb_if.APB_MCB_MP apb_drv_vif,
                 virtual apb_if.APB_SCB_MP apb_mon_vif);
        this.ahb_drv_vif = ahb_drv_vif;
        this.ahb_mon_vif = ahb_mon_vif;
        this.apb_drv_vif = apb_drv_vif;
        this.apb_mon_vif = apb_mon_vif;

        ahb_mon2sb = new();
        apb_mon2sb = new();

        ahb_agt = new(ahb_drv_vif, ahb_mon_vif, ahb_mon2sb);
        apb_agt = new(apb_drv_vif, apb_mon_vif, apb_mon2sb);
        sb      = new(ahb_mon2sb, apb_mon2sb);
    endfunction

    task start();
        ahb_agt.start();
        apb_agt.start();
        sb.run();
    endtask

    task report();
        sb.report();
        $display("SB_AHB_CG: %3.2f%% coverage achieved.", sb.sb_ahb_cg.get_inst_coverage());
        $display("SB_APB_CG: %3.2f%% coverage achieved.", sb.sb_apb_cg.get_inst_coverage());
        $display("MON_AHB_CG: %3.2f%% coverage achieved.", ahb_agt.mon.mon_ahb_cg.get_inst_coverage());
        $display("MON_AHB_RST_CG: %3.2f%% coverage achieved.", ahb_agt.mon.mon_ahb_rst_cg.get_inst_coverage());
        $display("MON_AHB_HREADY_CG: %3.2f%% coverage achieved.", ahb_agt.mon.mon_ahb_hready_cg.get_inst_coverage());
    endtask

endclass
