// coverage off
`include "ahb_if.sv"
`include "apb_if.sv"
`include "test_files.svh"
`include "ahb2apb_bridge_props.sv"

module top;

    //import ahb_apb_sv_pkg::*;

    // ---------------------------------------------------------------
    // Clock generation
    // ---------------------------------------------------------------
    bit clock;
    initial begin
        clock = 1'b0;
        forever #10 clock = ~clock;
    end

    // ---------------------------------------------------------------
    // Interface instances
    // ---------------------------------------------------------------
    ahb_if in0(clock);
    apb_if in1(clock);

    // ---------------------------------------------------------------
    // DUT instantiation
    // ---------------------------------------------------------------
    // coverage on
    Bridge_Top DUT (
        .Hclk      (clock),
        .Hresetn   (in0.Hresetn),
        .Htrans    (in0.Htrans),
        .Hreadyin  (in0.Hreadyin),
        .Hwdata    (in0.Hwdata),
        .Haddr     (in0.Haddr),
        .Hwrite    (in0.Hwrite),
        .Hrdata    (in0.Hrdata),
        .Hresp     (in0.Hresp),
        .Hreadyout (in0.Hreadyout),
        .Pselx     (in1.Pselx),
        .Pwrite    (in1.Pwrite),
        .Penable   (in1.Penable),
        .Prdata    (in1.Prdata),
        .Paddr     (in1.Paddr),
        .Pwdata    (in1.Pwdata)
    );// coverage off

    // ---------------------------------------------------------------
    // Testbench run
    // Select test at compile time with +define+TEST_NAME=test_2
    // Default: test_1
    // ---------------------------------------------------------------
`ifdef ASSERT_OFF
    initial begin
        force DUT.ahb2apb_bridge_props_inst.assert_off = 1'b1;  //Turn off all assertions
    end
`endif
  
`ifndef TEST_NAME
    `define TEST_NAME normal_burst_seq_test
`endif

    initial begin
        //base_test t;

        // Instantiate the selected test class using a derived handle,
        // then upcast to base_test.
        `TEST_NAME t_temp;
        t_temp = new(in0.AHB_MCB_MP, in0.AHB_SCB_MP,
                      in1.APB_MCB_MP, in1.APB_SCB_MP);
        //t = t_temp;

      t_temp.run();
        $display("[TOP] Simulation complete");
        $finish;
    end

    // ---------------------------------------------------------------
    // VCD dump
    // ---------------------------------------------------------------
    initial begin
        $dumpfile("AHB_APB_Bridge_dump.vcd");
        $dumpvars(0, DUT);
    end

endmodule