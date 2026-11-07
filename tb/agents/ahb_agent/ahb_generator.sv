// AHB Generator
// Replaces UVM sequences (test_sequence + write_back).
// Creates AHB transactions and puts them into the gen2drv mailbox.

class ahb_generator;

  mailbox #(ahb_trans_item) gen2drv;

  function new(mailbox #(ahb_trans_item) gen2drv);
    this.gen2drv          = gen2drv;
  endfunction

  task send_item(ahb_trans_item tr_item);
    gen2drv.put(tr_item);
  endtask
  
  // ---------------------------------------------------------------
  // Generating single transaction 
  // ---------------------------------------------------------------
  task signle_transaction_gen (bit error = 0, bit rst_dis = 1, bit busy_state_dis = 1, bit hwrite);
    ahb_trans_item xtn;
    ahb_trans_item xtn_next  ; // for next burst beats
    logic [31:0] haddr;
    logic [2:0]  hburst = 3'd0;  
    int          busy_cycles;

    // First beat: NONSEQ
    xtn = new();
    assert(xtn.randomize() with {
      Htrans == 2'b10;
      Hburst == hburst;
      Hwrite == hwrite;
      reset_dis == rst_dis;
      busy_cycles_dis == busy_state_dis;
      error_injection == error;  
    }) else $fatal(1, "AHB_GEN: randomize failed (burst first beat)");
    haddr  = xtn.Haddr;
    $display("[AHB_GEN] 0");
    xtn.print();
    gen2drv.put(xtn);
    $display("[GEN] length = %0d", xtn.length);
    if (xtn.Hresetn == 0) begin
      $display("[AHB_GEN] Reset transaction generated in burst sequence! Hresetn = %b", xtn.Hresetn);
      return;
    end 

    // Send IDLE after burst
    xtn = new();
    assert(xtn.randomize() with { Htrans == 2'b00; error_injection == error; reset_dis == rst_dis; busy_cycles_dis == busy_state_dis;});
    $display("[AHB_GEN] 8");
    xtn.print();
    gen2drv.put(xtn);
  endtask
  
  // ---------------------------------------------------------------
  // Generating INCR burst 
  // ---------------------------------------------------------------
  task incr_burst_gen (bit error = 0, bit rst_dis = 1, bit busy_state_dis = 1, bit hwrite);
    ahb_trans_item xtn;
    ahb_trans_item xtn_next  ; // for next burst beats
    logic [31:0] haddr;
    logic [2:0]  hburst = 3'd1;  
    int          busy_cycles;

    // First beat: NONSEQ
    xtn = new();
    assert(xtn.randomize() with {
      Htrans == 2'b10;
      Hburst == hburst;
      Hwrite == hwrite;
      reset_dis == rst_dis;
      busy_cycles_dis == busy_state_dis;
      error_injection == error;  
    }) else $fatal(1, "AHB_GEN: randomize failed (burst first beat)");
    haddr  = xtn.Haddr;
    $display("[AHB_GEN] 0");
    xtn.print();
    gen2drv.put(xtn);
    $display("[GEN] length = %0d", xtn.length);
    if (xtn.Hresetn == 0) begin
      $display("[AHB_GEN] Reset transaction generated in burst sequence! Hresetn = %b", xtn.Hresetn);
      return;
    end

    //Next beat: SEQ
    for (int i = 0; i < xtn.length - 1; i++) begin
      xtn_next = new();
      assert(xtn_next.randomize() with { Hburst==hburst; Hwrite==hwrite; Htrans==2'b11; Haddr==haddr+4; error_injection == error; reset_dis == rst_dis; busy_cycles_dis == busy_state_dis;});
      $display("[AHB_GEN] 1");
      xtn_next.print();
      haddr = xtn_next.Haddr;
      gen2drv.put(xtn_next);
      if (xtn_next.Hresetn == 0) begin
        $display("[AHB_GEN] Reset transaction generated in burst sequence! Hresetn = %b", xtn_next.Hresetn);
        break;
      end
    end  

    // Send IDLE after burst
    xtn = new();
    assert(xtn.randomize() with { Htrans == 2'b00; error_injection == error; reset_dis == rst_dis; busy_cycles_dis == busy_state_dis;});
    $display("[AHB_GEN] 8");
    xtn.print();
    gen2drv.put(xtn);
  endtask
  
  // ---------------------------------------------------------------
  // Generating WRAP4 burst 
  // ---------------------------------------------------------------
  task wrap4_burst_gen (bit error = 0, bit rst_dis = 1, bit busy_state_dis = 1, bit hwrite);
    ahb_trans_item xtn;
    ahb_trans_item xtn_next  ; // for next burst beats
    logic [31:0] haddr;
    logic [2:0]  hburst = 3'd2;
    int          busy_cycles;

    // First beat: NONSEQ
    xtn = new();
    assert(xtn.randomize() with {
      Htrans == 2'b10;
      Hburst == hburst;
      Hwrite == hwrite;
      reset_dis == rst_dis;
      busy_cycles_dis == busy_state_dis;
      error_injection == error;
    }) else $fatal(1, "AHB_GEN: randomize failed (burst first beat)");
    haddr  = xtn.Haddr;
    $display("[AHB_GEN] 0");
    xtn.print();
    gen2drv.put(xtn);
    $display("[GEN] length = %0d", xtn.length);
    if (xtn.Hresetn == 0) begin
      $display("[AHB_GEN] Reset transaction generated in burst sequence! Hresetn = %b", xtn.Hresetn);
      return;
    end

    // WRAP4 — hburst == 3'b010
    for (int i = 0; i < 3; i++) begin
      xtn_next = new();
      assert(xtn_next.randomize() with { Hburst==hburst; Hwrite==hwrite; Htrans==2'b11; Haddr=={haddr[31:4], haddr[3:2] + 1'b1, haddr[1:0]}; error_injection == error; reset_dis == rst_dis; busy_cycles_dis == busy_state_dis;});
      $display("[AHB_GEN] 5");
      xtn_next.print();
      haddr = xtn_next.Haddr;
      gen2drv.put(xtn_next);
      if (xtn_next.Hresetn == 0) begin
        $display("[AHB_GEN] Reset transaction generated in burst sequence! Hresetn = %b", xtn_next.Hresetn);
        break;
      end
    end  

    // Send IDLE after burst
    xtn = new();
    assert(xtn.randomize() with { Htrans == 2'b00; error_injection == error; reset_dis == rst_dis; busy_cycles_dis == busy_state_dis;});
    $display("[AHB_GEN] 8");
    xtn.print();
    gen2drv.put(xtn);
  endtask
  
  // ---------------------------------------------------------------
  // Generating INCR4 burst 
  // ---------------------------------------------------------------
  task incr4_burst_gen (bit error = 0, bit rst_dis = 1, bit busy_state_dis = 1, bit hwrite);
    ahb_trans_item xtn;
    ahb_trans_item xtn_next  ; // for next burst beats
    logic [31:0] haddr;
    logic [2:0]  hburst = 3'd3;
    int          busy_cycles;

    // First beat: NONSEQ
    xtn = new();
    assert(xtn.randomize() with {
      Htrans == 2'b10;
      Hburst == hburst;
      Hwrite == hwrite;
      reset_dis == rst_dis;
      busy_cycles_dis == busy_state_dis;
      error_injection == error;
    }) else $fatal(1, "AHB_GEN: randomize failed (burst first beat)");
    haddr  = xtn.Haddr;
    $display("[AHB_GEN] 0");
    xtn.print();
    gen2drv.put(xtn);
    $display("[GEN] length = %0d", xtn.length);
    if (xtn.Hresetn == 0) begin
      $display("[AHB_GEN] Reset transaction generated in burst sequence! Hresetn = %b", xtn.Hresetn);
      return;
    end

    // INCR4 — hburst == 3'b011
    for (int i = 0; i < 3; i++) begin
      xtn_next = new();
      assert(xtn_next.randomize() with { Hburst==hburst; Hwrite==hwrite; Htrans==2'b11; Haddr==haddr+4; error_injection == error; reset_dis == rst_dis; busy_cycles_dis == busy_state_dis;});
      $display("[AHB_GEN] 2");
      xtn_next.print();
      haddr = xtn_next.Haddr;
      gen2drv.put(xtn_next);
      if (xtn_next.Hresetn == 0) begin
        $display("[AHB_GEN] Reset transaction generated in burst sequence! Hresetn = %b", xtn_next.Hresetn);
        break;
      end
    end

    // Send IDLE after burst
    xtn = new();
    assert(xtn.randomize() with { Htrans == 2'b00; error_injection == error; reset_dis == rst_dis; busy_cycles_dis == busy_state_dis;});
    $display("[AHB_GEN] 8");
    xtn.print();
    gen2drv.put(xtn);
  endtask
  
  // ---------------------------------------------------------------
  // Generating WRAP8 burst 
  // ---------------------------------------------------------------
  task wrap8_burst_gen (bit error = 0, bit rst_dis = 1, bit busy_state_dis = 1, bit hwrite);
    ahb_trans_item xtn;
    ahb_trans_item xtn_next  ; // for next burst beats
    logic [31:0] haddr;
    logic [2:0]  hburst = 3'd4;
    int          busy_cycles;

    // First beat: NONSEQ
    xtn = new();
    assert(xtn.randomize() with {
      Htrans == 2'b10;
      Hburst == hburst;
      Hwrite == hwrite;
      reset_dis == rst_dis;
      busy_cycles_dis == busy_state_dis;
      error_injection == error;
    }) else $fatal(1, "AHB_GEN: randomize failed (burst first beat)");
    haddr  = xtn.Haddr;
    $display("[AHB_GEN] 0");
    xtn.print();
    gen2drv.put(xtn);
    $display("[GEN] length = %0d", xtn.length);
    if (xtn.Hresetn == 0) begin
      $display("[AHB_GEN] Reset transaction generated in burst sequence! Hresetn = %b", xtn.Hresetn);
      return;
    end

    // WRAP8 — hburst == 3'b100
    for (int i = 0; i < 7; i++) begin
      xtn_next = new();
      assert(xtn_next.randomize() with { Hburst==hburst; Hwrite==hwrite; Htrans==2'b11; Haddr=={haddr[31:5], haddr[4:2] + 1'b1, haddr[1:0]}; error_injection == error; reset_dis == rst_dis; busy_cycles_dis == busy_state_dis;});
      $display("[AHB_GEN] 6");
      xtn_next.print();
      haddr = xtn_next.Haddr;
      gen2drv.put(xtn_next);
      if (xtn_next.Hresetn == 0) begin
        $display("[AHB_GEN] Reset transaction generated in burst sequence! Hresetn = %b", xtn_next.Hresetn);
        break;
      end
    end
     
    // Send IDLE after burst
    xtn = new();
    assert(xtn.randomize() with { Htrans == 2'b00; error_injection == error; reset_dis == rst_dis; busy_cycles_dis == busy_state_dis;});
    $display("[AHB_GEN] 8");
    xtn.print();
    gen2drv.put(xtn);
  endtask
  
  // ---------------------------------------------------------------
  // Generating INCR8 burst 
  // ---------------------------------------------------------------
  task incr8_burst_gen (bit error = 0, bit rst_dis = 1, bit busy_state_dis = 1, bit hwrite);
    ahb_trans_item xtn;
    ahb_trans_item xtn_next  ; // for next burst beats
    logic [31:0] haddr;
    logic [2:0]  hburst = 3'd5;
    int          busy_cycles;

    // First beat: NONSEQ
    xtn = new();
    assert(xtn.randomize() with {
      Htrans == 2'b10;
      Hburst == hburst;
      Hwrite == hwrite;
      reset_dis == rst_dis;
      busy_cycles_dis == busy_state_dis;
      error_injection == error;
    }) else $fatal(1, "AHB_GEN: randomize failed (burst first beat)");
    haddr  = xtn.Haddr;
    $display("[AHB_GEN] 0");
    xtn.print();
    gen2drv.put(xtn);
    $display("[GEN] length = %0d", xtn.length);
    if (xtn.Hresetn == 0) begin
      $display("[AHB_GEN] Reset transaction generated in burst sequence! Hresetn = %b", xtn.Hresetn);
      return;
    end

    // INCR8 — hburst == 3'b101
    for (int i = 0; i < 7; i++) begin
      xtn_next = new();
      assert(xtn_next.randomize() with { Hburst==hburst; Hwrite==hwrite; Htrans==2'b11; Haddr==haddr+4; error_injection == error; reset_dis == rst_dis; busy_cycles_dis == busy_state_dis;});
      $display("[AHB_GEN] 3");
      xtn_next.print();
      haddr = xtn_next.Haddr;
      gen2drv.put(xtn_next);
      if (xtn_next.Hresetn == 0) begin
        $display("[AHB_GEN] Reset transaction generated in burst sequence! Hresetn = %b", xtn_next.Hresetn);
        break;
      end
    end
     
    // Send IDLE after burst
    xtn = new();
    assert(xtn.randomize() with { Htrans == 2'b00; error_injection == error; reset_dis == rst_dis; busy_cycles_dis == busy_state_dis;});
    $display("[AHB_GEN] 8");
    xtn.print();
    gen2drv.put(xtn);
  endtask
  
  // ---------------------------------------------------------------
  // Generating WRAP16 burst 
  // ---------------------------------------------------------------
  task wrap16_burst_gen (bit error = 0, bit rst_dis = 1, bit busy_state_dis = 1, bit hwrite);
    ahb_trans_item xtn;
    ahb_trans_item xtn_next  ; // for next burst beats
    logic [31:0] haddr;
    logic [2:0]  hburst = 3'd6;
    int          busy_cycles;

    // First beat: NONSEQ
    xtn = new();
    assert(xtn.randomize() with {
      Htrans == 2'b10;
      Hburst == hburst;
      Hwrite == hwrite;
      reset_dis == rst_dis;
      busy_cycles_dis == busy_state_dis;
      error_injection == error;
    }) else $fatal(1, "AHB_GEN: randomize failed (burst first beat)");
    haddr  = xtn.Haddr;
    $display("[AHB_GEN] 0");
    xtn.print();
    gen2drv.put(xtn);
    $display("[GEN] length = %0d", xtn.length);
    if (xtn.Hresetn == 0) begin
      $display("[AHB_GEN] Reset transaction generated in burst sequence! Hresetn = %b", xtn.Hresetn);
      return;
    end

    // WRAP16 — hburst == 3'b110
    for (int i = 0; i < 15; i++) begin
      xtn_next = new();
      assert(xtn_next.randomize() with { Hburst==hburst; Hwrite==hwrite; Htrans==2'b11; Haddr=={haddr[31:6], haddr[5:2] + 1'b1, haddr[1:0]}; error_injection == error; reset_dis == rst_dis; busy_cycles_dis == busy_state_dis;});
      $display("[AHB_GEN] 7");
      xtn_next.print();
      haddr = xtn_next.Haddr;
      gen2drv.put(xtn_next);
      if (xtn_next.Hresetn == 0) begin
        $display("[AHB_GEN] Reset transaction generated in burst sequence! Hresetn = %b", xtn_next.Hresetn);
        break;
      end
    end
    
    // Send IDLE after burst
    xtn = new();
    assert(xtn.randomize() with { Htrans == 2'b00; error_injection == error; reset_dis == rst_dis; busy_cycles_dis == busy_state_dis;});
    $display("[AHB_GEN] 8");
    xtn.print();
    gen2drv.put(xtn);
  endtask
  
  // ---------------------------------------------------------------
  // Generating INCR16 burst 
  // ---------------------------------------------------------------
  task incr16_burst_gen (bit error = 0, bit rst_dis = 1, bit busy_state_dis = 1, bit hwrite);
    ahb_trans_item xtn;
    ahb_trans_item xtn_next  ; // for next burst beats
    logic [31:0] haddr;
    logic [2:0]  hburst = 3'd7;
    int          busy_cycles;

    // First beat: NONSEQ
    xtn = new();
    assert(xtn.randomize() with {
      Htrans == 2'b10;
      Hburst == hburst;
      Hwrite == hwrite;
      reset_dis == rst_dis;
      busy_cycles_dis == busy_state_dis;
      error_injection == error;
    }) else $fatal(1, "AHB_GEN: randomize failed (burst first beat)");
    haddr  = xtn.Haddr;
    $display("[AHB_GEN] 0");
    xtn.print();
    gen2drv.put(xtn);
    $display("[GEN] length = %0d", xtn.length);
    if (xtn.Hresetn == 0) begin
      $display("[AHB_GEN] Reset transaction generated in burst sequence! Hresetn = %b", xtn.Hresetn);
      return;
    end

    // INCR16 — hburst == 3'b111
    for (int i = 0; i < 15; i++) begin
      xtn_next = new();
      assert(xtn_next.randomize() with { Hburst==hburst; Hwrite==hwrite; Htrans==2'b11; Haddr==haddr+4; error_injection == error; reset_dis == rst_dis; busy_cycles_dis == busy_state_dis;});
      $display("[AHB_GEN] 4");
      xtn_next.print();
      haddr = xtn_next.Haddr;
      gen2drv.put(xtn_next);
      if (xtn_next.Hresetn == 0) begin
        $display("[AHB_GEN] Reset transaction generated in burst sequence! Hresetn = %b", xtn_next.Hresetn);
        break;
      end
    end
    
    // Send IDLE after burst
    xtn = new();
    assert(xtn.randomize() with { Htrans == 2'b00; error_injection == error; reset_dis == rst_dis; busy_cycles_dis == busy_state_dis;});
    $display("[AHB_GEN] 8");
    xtn.print();
    gen2drv.put(xtn);
    
  endtask  
  
  // ---------------------------------------------------------------
  // burst_sequence — equivalent to test_sequence (INCR4/INCR8/INCR16)
  // ---------------------------------------------------------------
  task burst_sequence(bit error = 0, bit rst_dis = 1, bit busy_state_dis = 1, int transaction_num, virtual ahb_if.AHB_MCB_MP ahb_drv_vif);
    repeat (transaction_num) begin
      randcase
        1: signle_transaction_gen (error, rst_dis, busy_state_dis, $urandom_range(0,1));
        1: incr_burst_gen (error, rst_dis, busy_state_dis, $urandom_range(0,1));
        1: wrap4_burst_gen (error, rst_dis, busy_state_dis, $urandom_range(0,1));
        1: incr4_burst_gen (error, rst_dis, busy_state_dis, $urandom_range(0,1));
        1: wrap8_burst_gen (error, rst_dis, busy_state_dis, $urandom_range(0,1));
        1: incr8_burst_gen (error, rst_dis, busy_state_dis, $urandom_range(0,1));
        1: wrap16_burst_gen (error, rst_dis, busy_state_dis, $urandom_range(0,1));
        1: incr16_burst_gen (error, rst_dis, busy_state_dis, $urandom_range(0,1));
      endcase
      repeat ($urandom_range(1,10)) @(ahb_drv_vif.ahb_drv_cb);
    end 
  endtask

    // ---------------------------------------------------------------
    // Back-to-back SINGLE writes
    // ---------------------------------------------------------------
    task back_to_back_write_sequence(bit error = 0, bit rst_dis = 1, bit busy_state_dis = 1, int write_transaction_num, int read_transaction_num);
        ahb_trans_item xtn;

        repeat (write_transaction_num) begin
            xtn = new();
            assert(xtn.randomize() with {
                Htrans == 2'b10;
                Hburst == 3'b000;
                Hwrite == 1'b1; // Only write transactions in write-back sequence
                error_injection == 0;
                reset_dis == rst_dis;
                busy_cycles_dis == busy_state_dis;
            }) else $fatal(1, "AHB_GEN: randomize failed (write_back)");
            $display("[AHB_GEN] 9");
            xtn.print();
            gen2drv.put(xtn);
        end
        // Final IDLE
        xtn = new();
        assert(xtn.randomize() with { Htrans == 2'b00; Hresetn == 1'b1; Hwrite == 1'b1; error_injection == error; reset_dis == rst_dis; busy_cycles_dis == busy_state_dis; });
        gen2drv.put(xtn);

        #($urandom_range(1,10) * 10ns);
      
        repeat (read_transaction_num) begin
            xtn = new();
            assert(xtn.randomize() with {
                Htrans == 2'b10;
                Hburst == 3'b000;
                Hwrite == 1'b0; // Read transactions in second half of write-back sequence
                error_injection == 0;
                reset_dis == rst_dis;
                busy_cycles_dis == busy_state_dis;
            }) else $fatal(1, "AHB_GEN: randomize failed (write_back)");
            $display("[AHB_GEN] 9");
            xtn.print();
            gen2drv.put(xtn);
        end
        // Final IDLE
        xtn = new();
        assert(xtn.randomize() with { Htrans == 2'b00; Hresetn == 1'b1; Hwrite == 1'b0; error_injection == error; reset_dis == rst_dis; busy_cycles_dis == busy_state_dis; });
        gen2drv.put(xtn);
    endtask

endclass