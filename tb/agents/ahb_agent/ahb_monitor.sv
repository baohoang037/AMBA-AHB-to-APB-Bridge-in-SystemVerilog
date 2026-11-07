// AHB Monitor
// Converted from UVM: uses a mailbox instead of uvm_analysis_port.
// Observes the AHB bus and forwards captured transactions to the scoreboard.

class ahb_monitor;

  virtual ahb_if.AHB_SCB_MP vif;
  mailbox #(ahb_trans_item) mon2sb;

  static int outstanding_num = 0; // Number of transactions sent but not yet acknowledged by the DUT
  static int mon_data_count = 0;
  ahb_trans_item xtn, xtn_next;
  
  // ---------------------------------------------------------------
  // Coverage Groups
  // ---------------------------------------------------------------
  logic [1:0] cur_htrans = 0;
  logic [1:0] prev_htrans = 0;
  covergroup mon_ahb_cg;
    option.per_instance = 1;

    PREV_HTRANS: coverpoint prev_htrans {bins trans[] = {[0:3]};}
    CUR_HTRANS : coverpoint cur_htrans  {bins trans[] = {[0:3]};}

    CROSS_HTRANS: cross PREV_HTRANS, CUR_HTRANS {
      illegal_bins bad_transition0 = binsof(PREV_HTRANS) intersect {0} && binsof(CUR_HTRANS) intersect {1};
      illegal_bins bad_transition1 = binsof(PREV_HTRANS) intersect {0} && binsof(CUR_HTRANS) intersect {3};
      illegal_bins bad_transition2 = binsof(PREV_HTRANS) intersect {1} && binsof(CUR_HTRANS) intersect {0};
      illegal_bins bad_transition3 = binsof(PREV_HTRANS) intersect {1} && binsof(CUR_HTRANS) intersect {2};
      illegal_bins bad_transition4 = binsof(PREV_HTRANS) intersect {3} && binsof(CUR_HTRANS) intersect {2};
    }
  endgroup
  
  covergroup mon_ahb_rst_cg;
    option.per_instance = 1;
    ACTIVE_RST: coverpoint vif.ahb_mon_cb.Hresetn {bins low = {1'b0};}
    CUR_HTRANS : coverpoint cur_htrans {
      bins idle = {2'b00};
      ignore_bins unused_rst = {2'b01, 2'b10, 2'b11};
    }
    CROSS_RST_HTRANS: cross ACTIVE_RST, CUR_HTRANS;
  endgroup
  
  /*covergroup mon_ahb_hready_cg;
    option.per_instance = 1;
    
    HREADY: coverpoint vif.ahb_mon_cb.Hreadyout {
      bins low  = {1'b0};
      bins high = {1'b1};
    }
    CUR_HTRANS : coverpoint cur_htrans {bins trans[] = {[0:3]};}
    CROSS_HREADY_HTRANS: cross HREADY, CUR_HTRANS;
  endgroup*/
  covergroup mon_ahb_hready_cg;
    option.per_instance = 1;
    HREADY : coverpoint vif.ahb_mon_cb.Hreadyout;
    HTRANS : coverpoint vif.ahb_mon_cb.Htrans;
    HREADY_X_HTRANS : cross HREADY, HTRANS {
      ignore_bins illegal_wait = binsof(HTRANS) intersect {2'b00, 2'b01} && binsof(HREADY) intersect {1'b0};
    }
  endgroup
  // ---------------------------------------------------------------
  // End of Coverage Groups
  // ---------------------------------------------------------------
  

  function new(virtual ahb_if.AHB_SCB_MP vif, mailbox #(ahb_trans_item) mon2sb);
    this.vif    = vif;
    this.mon2sb = mon2sb;
    mon_ahb_cg = new();
    mon_ahb_rst_cg = new();
    mon_ahb_hready_cg = new();
  endfunction

  task run();
    @(vif.ahb_mon_cb);
    fork
      signal_for_cover_calculate();
      sample_cover();
      outstanding_num_calculate();
      collect_data();
    join_any
  endtask

  task outstanding_num_calculate();
    forever begin
      // Monitor the Hreadyout and Htrans signals to calculate the number of outstanding transactions
      @(vif.ahb_mon_cb);
       if (!vif.ahb_mon_cb.Hresetn)
         outstanding_num = 0;
       else if (vif.ahb_mon_cb.Hreadyout & vif.ahb_mon_cb.Hreadyin) begin
         if (vif.ahb_mon_cb.Htrans == 2'b10 || vif.ahb_mon_cb.Htrans == 2'b11) begin
           outstanding_num = (outstanding_num == 0) ? 1 : outstanding_num;;
         end else if (vif.ahb_mon_cb.Htrans == 2'b00) begin
           if (outstanding_num > 0)
             outstanding_num--;
         end
       end
    end
  endtask

  task collect_data();
    xtn = new();
    xtn_next = new();

    fork
      forever begin
        do
          @(vif.ahb_mon_cb);
        while (vif.ahb_mon_cb.Hresetn);

        while (mon2sb.num() > 0)
          mon2sb.get(xtn); // Clear out any pending transactions in the mailbox on reset
      end
      forever begin
        #2;
        if (outstanding_num == 0) begin
          // If there are no outstanding transactions, wait for a new one to start
          do
            @(vif.ahb_mon_cb);
          while (!vif.ahb_mon_cb.Hresetn || !(vif.ahb_mon_cb.Hreadyout && vif.ahb_mon_cb.Hreadyin &&
                (vif.ahb_mon_cb.Htrans == 2'b10 || vif.ahb_mon_cb.Htrans == 2'b11)));

          // Collect address/control phase info
          xtn.Htrans = vif.ahb_mon_cb.Htrans;
          xtn.Hwrite = vif.ahb_mon_cb.Hwrite;
          xtn.Haddr  = vif.ahb_mon_cb.Haddr;
          xtn.Hburst = vif.ahb_mon_cb.Hburst;
        end

        #5;
        // Collect data phase of current transaction and address/control phase of the next transaction
        fork
          do
            @(vif.ahb_mon_cb);
          while (!vif.ahb_mon_cb.Hresetn || !(vif.ahb_mon_cb.Hreadyout && vif.ahb_mon_cb.Hreadyin));

          do
            @(vif.ahb_mon_cb);
          while (vif.ahb_mon_cb.Hresetn);
        join_any;
        disable fork;

        if (vif.ahb_mon_cb.Hresetn & (vif.ahb_mon_cb.Htrans != 2'b01)) begin

          // Collect address/control phase info
          xtn_next.Htrans = vif.ahb_mon_cb.Htrans;
          xtn_next.Hwrite = vif.ahb_mon_cb.Hwrite;
          xtn_next.Haddr  = vif.ahb_mon_cb.Haddr;
          xtn_next.Hburst = vif.ahb_mon_cb.Hburst;

          if (xtn.Hwrite == 1'b1)
              xtn.Hwdata = vif.ahb_mon_cb.Hwdata;
          else
              xtn.Hrdata = vif.ahb_mon_cb.Hrdata;

          //$display("[AHB_MON] Captured transaction: time = %t", $time);
          //xtn.print();
          mon2sb.put(xtn);

          xtn = new(); // Clear current transaction for next round
          xtn.copy(xtn_next); // Move to the next transaction for burst handling
        end
      end
    join_any
  endtask
            
  task signal_for_cover_calculate();
    forever begin
      @(vif.ahb_mon_cb);
      if (!vif.ahb_mon_cb.Hresetn) begin
        prev_htrans = 2'b0;
        cur_htrans = 2'b0;
      end
      else if (vif.ahb_mon_cb.Hreadyout && vif.ahb_mon_cb.Hreadyin) begin
        prev_htrans = cur_htrans;
        cur_htrans = vif.ahb_mon_cb.Htrans;
      end          
    end       
  endtask
        
  task sample_cover();
    forever begin
      @(vif.ahb_mon_cb);
      mon_ahb_cg.sample();
      mon_ahb_hready_cg.sample();
      mon_ahb_rst_cg.sample(); 
    end       
  endtask

endclass