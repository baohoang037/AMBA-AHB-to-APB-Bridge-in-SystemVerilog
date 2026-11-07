module ahb2apb_bridge_props();
  reg assert_off = 0;
  reg write_val_in_burst;
  
  //Define auxiliary logic
  always @(posedge Bridge_Top.Hclk or negedge Bridge_Top.Hresetn) begin
    if (~Bridge_Top.Hresetn) 
      write_val_in_burst <= 1'b0;
    else if (Bridge_Top.Hreadyout & Bridge_Top.Hreadyin & (Bridge_Top.Htrans == 2'd2))
      write_val_in_burst <= Bridge_Top.Hwrite;
  end
  
  //Define properties/assertions
  property ahb_hwrite_same_in_burst;
    @(posedge Bridge_Top.Hclk) disable iff (~Bridge_Top.Hresetn || assert_off)
    (Bridge_Top.Hreadyout & Bridge_Top.Hreadyin & ((Bridge_Top.Htrans == 2'd1) | (Bridge_Top.Htrans == 2'd3))) |-> (Bridge_Top.Hwrite == write_val_in_burst);
  endproperty
  ahb_hwrite_same_in_burst_assert: assert property (ahb_hwrite_same_in_burst);
    
  property apb_trans;
    @(posedge Bridge_Top.Hclk) disable iff (~Bridge_Top.Hresetn || assert_off)
    (Bridge_Top.Pselx!=0) & ~Bridge_Top.Penable |=> (Bridge_Top.Pselx!=0) & Bridge_Top.Penable;
  endproperty
  apb_trans_assert: assert property (apb_trans);
  
endmodule
bind Bridge_Top ahb2apb_bridge_props ahb2apb_bridge_props_inst(.*);