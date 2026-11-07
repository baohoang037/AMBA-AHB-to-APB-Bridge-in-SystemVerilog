// Scoreboard
// Converted from UVM: uses mailboxes instead of TLM analysis FIFOs.
// Compares AHB and APB transactions; includes functional coverage.

class scoreboard;

    mailbox #(ahb_trans_item) fifo_ahb;
    mailbox #(apb_trans_item) fifo_apb;

    ahb_trans_item ahb_data;
    apb_trans_item apb_data;

    // Coverage sample handles
    ahb_trans_item ahb_cov_data;
    apb_trans_item apb_cov_data;

    int data_verified_count;
    int mismatch_count;

    // ---------------------------------------------------------------
    // Coverage Groups
    // ---------------------------------------------------------------
    covergroup sb_ahb_cg;
        option.per_instance = 1;

        TRANS: coverpoint ahb_cov_data.Htrans {bins trans[] = {[2:3]};}

        ADDR:  coverpoint ahb_cov_data.Haddr {
            bins first_slave  = {[32'h8000_0000:32'h83ff_ffff]};
            bins second_slave = {[32'h8400_0000:32'h87ff_ffff]};
            bins third_slave  = {[32'h8800_0000:32'h8bff_ffff]};
        }

        DATA_IN:  coverpoint ahb_cov_data.Hwdata {
            bins low  = {[0:32'h0000_ffff]};
            bins mid = {[32'h0001_ffff:32'hffff_ffff]};
        }

        DATA_OUT: coverpoint ahb_cov_data.Hrdata {
            bins low  = {[0:32'h0000_ffff]};
            bins mid = {[32'h0001_ffff:32'hffff_ffff]};
        }

        WRITE: coverpoint ahb_cov_data.Hwrite;
    endgroup

    covergroup sb_apb_cg;
        option.per_instance = 1;

        ADDR: coverpoint apb_cov_data.Paddr {
            bins first_slave  = {[32'h8000_0000:32'h83ff_ffff]};
            bins second_slave = {[32'h8400_0000:32'h87ff_ffff]};
            bins third_slave  = {[32'h8800_0000:32'h8bff_ffff]};
        }

        DATA_IN: coverpoint apb_cov_data.Pwdata {
            bins low  = {[0:32'h0000_ffff]};
            bins mid = {[32'h0001_ffff:32'hffff_ffff]};
        }

        DATA_OUT: coverpoint apb_cov_data.Prdata {
            bins low = {[0:32'hffff_ffff]};
            bins mid = {[32'h0001_ffff:32'hffff_ffff]};
        }

        WRITE: coverpoint apb_cov_data.Pwrite;

        SEL: coverpoint apb_cov_data.Pselx {
          bins first_slave  = {3'b001};
          bins second_slave = {3'b010};
          bins third_slave  = {3'b100};
        }

        WRITEXSEL: cross WRITE, SEL;
    endgroup

    // ---------------------------------------------------------------
    // Constructor
    // ---------------------------------------------------------------
    function new(mailbox #(ahb_trans_item) fifo_ahb, mailbox #(apb_trans_item) fifo_apb);
        this.fifo_ahb = fifo_ahb;
        this.fifo_apb = fifo_apb;
        ahb_cov_data  = new();
        apb_cov_data  = new();
        sb_ahb_cg     = new();
        sb_apb_cg     = new();
    endfunction

    // ---------------------------------------------------------------
    // run — processes AHB and APB mailboxes concurrently
    // ---------------------------------------------------------------
    task run();
        fork
            forever begin
                fifo_ahb.get(ahb_data);

                if ((ahb_data.Haddr >= 32'h8000_0000) && (ahb_data.Haddr <= 32'h8BFF_FFFF)) begin
                    fifo_apb.get(apb_data);

                    ahb_cov_data = ahb_data;
                    sb_ahb_cg.sample();
                    apb_cov_data = apb_data;
                    sb_apb_cg.sample();

                    check_data(ahb_data, apb_data);
                end
            end
        join_none
    endtask
    // ---------------------------------------------------------------
    // check_data — pops one AHB entry and compares with APB data
    // ---------------------------------------------------------------
    function void check_data(ahb_trans_item ahb_data, apb_trans_item apb_data);
        logic [2:0] exp_Pselx;

        exp_Pselx = ((ahb_data.Haddr[31:24] >= 8'h80) & (ahb_data.Haddr[31:24] < 8'h84)) ? 3'b001 : 
                    (ahb_data.Haddr[31:24] < 8'h88) ? 3'b010 : 
                    (ahb_data.Haddr[31:24] < 8'h8C) ? 3'b100 : 3'b000;

        if (ahb_data.Hwrite) begin
            compare_data(ahb_data.Hwdata, apb_data.Pwdata, ahb_data.Haddr, apb_data.Paddr, exp_Pselx, apb_data.Pselx);
        end else begin
            compare_data(ahb_data.Hrdata, apb_data.Prdata, ahb_data.Haddr, apb_data.Paddr, exp_Pselx, apb_data.Pselx);
        end
    endfunction

    // ---------------------------------------------------------------
    // compare_data — prints pass/fail for address and data
    // ---------------------------------------------------------------
    function void compare_data(int Hdata, Pdata, Haddr, Paddr, logic [2:0] exp_Pselx, logic [2:0] Pselx);
        if (Haddr == Paddr)
            ;//$display("[SB] Address MATCH      HADDR=%0h  PADDR=%0h", Haddr, Paddr);
        else begin
          mismatch_count++;
          ;//$display("[SB] Address MISMATCH   HADDR=%0h  PADDR=%0h @time = %0t ", Haddr, Paddr, $time);
        end

        if (Hdata == Pdata)
            ;//$display("[SB] Data    MATCH      HDATA=%0h  PDATA=%0h", Hdata, Pdata);
        else begin
          mismatch_count++;
          ;//$display("[SB] Data    MISMATCH   HDATA=%0h  PDATA=%0h @time = %0t ", Hdata, Pdata, $time);
        end

        if (exp_Pselx == Pselx)
            ;//$display("[SB] PSELx   MATCH      EXP_PSELx=%0b  PSELx=%0b", exp_Pselx, Pselx);
        else begin
          mismatch_count++;
          ;//$display("[SB] PSELx   MISMATCH   EXP_PSELx=%0b  PSELx=%0b @time = %0t ",exp_Pselx, Pselx, $time);
        end

        data_verified_count++;
        ;//$display("[SB] Verified count = %0d", data_verified_count);
    endfunction
              
    task report();
        begin
            int pass_count;
            if (mismatch_count == 0)
                pass_count = data_verified_count;
            else if (data_verified_count > mismatch_count)
                pass_count = data_verified_count - mismatch_count;
            else
                pass_count = 0;

            $display("AHB2APB_BRIDGE_SCB_SUMMARY: total=%0d, pass=%0d, fail=%0d", 
                     data_verified_count, pass_count, mismatch_count);
            if (mismatch_count == 0 && data_verified_count > 0)
                $display ("TEST PASSED");
            else
                $display ("TEST FAILED!!!");
        end
    endtask
endclass
