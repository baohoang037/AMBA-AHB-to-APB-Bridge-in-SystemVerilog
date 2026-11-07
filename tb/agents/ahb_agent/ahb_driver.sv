// AHB Driver
// Converted from UVM: uses a mailbox instead of seq_item_port.
// Drives AHB transactions onto the AHB interface.

class ahb_driver;

    virtual ahb_if.AHB_MCB_MP vif;
  mailbox #(ahb_trans_item) gen2drv;

    static int outstanding_num = 0; // Number of transactions sent but not yet acknowledged by the DUT
    static int drv_data_count = 0;

    function new(virtual ahb_if.AHB_MCB_MP vif, mailbox #(ahb_trans_item) gen2drv);
        this.vif     = vif;
        this.gen2drv = gen2drv;
    endfunction
  
    task init();
        //Activate reset at the begining of simulation
        @(vif.ahb_drv_cb);
        vif.ahb_drv_cb.Hresetn <= 1'b0;
        repeat(3) @(vif.ahb_drv_cb);
        vif.ahb_drv_cb.Hresetn <= 1'b1;
    endtask
    

    // Drive transactions from the mailbox
    task run();
        ahb_trans_item xtn;      

        forever begin
            gen2drv.get(xtn);
            //xtn.print();
            send_to_dut(xtn);
        end
    endtask

    task send_to_dut(ahb_trans_item xtn);
        if (xtn.Hresetn) begin
            if (xtn.busy_cycles > 0) begin
                $display("[AHB_DRV] Simulating backpressure: waiting for %0d cycles before driving transaction", xtn.busy_cycles);
                repeat (xtn.busy_cycles) begin
                    vif.ahb_drv_cb.Hwrite   <= xtn.Hwrite;
                    vif.ahb_drv_cb.Htrans   <= 2'b01;
                    vif.ahb_drv_cb.Haddr    <= xtn.Haddr;
                    vif.ahb_drv_cb.Hreadyin <= 1'b1;
                    vif.ahb_drv_cb.Hwdata   <= xtn.Hwdata;
                    vif.ahb_drv_cb.Hresetn  <= xtn.Hresetn;

                    do @(vif.ahb_drv_cb);
                    while (!vif.ahb_drv_cb.Hreadyout);
                end
            end
            // Wait until slave is ready, then drive write data
            vif.ahb_drv_cb.Hwrite   <= xtn.Hwrite;
            vif.ahb_drv_cb.Htrans   <= xtn.Htrans;
            vif.ahb_drv_cb.Haddr    <= xtn.Haddr;
            vif.ahb_drv_cb.Hreadyin <= 1'b1;
            vif.ahb_drv_cb.Hwdata   <= xtn.Hwdata;
            vif.ahb_drv_cb.Hresetn  <= xtn.Hresetn;

            do @(vif.ahb_drv_cb);
            while (!vif.ahb_drv_cb.Hreadyout);

            if (outstanding_num == 0) begin
                if (xtn.Htrans == 2'b10 || xtn.Htrans == 2'b11)
                    outstanding_num++;

            end else begin
                if (xtn.Htrans == 2'b00)
                    outstanding_num--;
            end

            if (outstanding_num != 0)
                drv_data_count++;
            //$display("[AHB_DRV] Packets driven = %0d", drv_data_count);
        end
        else begin
            $display("[AHB_DRV] Reset transaction driven! Hresetn = %b", xtn.Hresetn);
            vif.ahb_drv_cb.Hresetn  <= xtn.Hresetn;
            repeat (2)
                @(vif.ahb_drv_cb);
        end
    endtask

endclass