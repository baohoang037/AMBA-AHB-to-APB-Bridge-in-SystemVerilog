// Implemented by Tho Lam Chip / Kairo IC
// Facebook1: facebook.com/tholamchip
// Facebook2: facebook.com/tholamchip.team
// Facebook Group: facebook.com/groups/tholamchip
// Youtube Channel1: youtube.com/@ThoLamChip
// Youtube Channel2: youtube.com/@Kairo_IC

interface ahb_if(input bit clk);

  logic[1:0]Htrans;
  logic[31:0]Haddr;
  logic[31:0]Hwdata;
  logic[31:0]Hrdata;
  logic[2:0]Hburst;
  logic Hwrite;
  logic Hresetn;
  logic Hreadyout;
  logic Hreadyin;
  logic[1:0]Hresp;
  
  clocking ahb_drv_cb@(posedge clk);
  
    default input#1 output#1;
    
    output Htrans;
    output Hresetn;
    output Hwrite;
    output Hreadyin;
    output Hwdata;
    output Haddr;
    output Hburst;
    input Hreadyout;
    input Hrdata;
    endclocking
  
  clocking ahb_mon_cb@(posedge clk);
  
    default input#1 output#1;
    
    input Htrans;
    input Hresetn;
    input Hwrite;
    input Hreadyin;
    input Hwdata;
    input Hrdata;
    input Haddr;
    input Hburst;
    input Hreadyout;
    input Hresp;
  endclocking
  
  modport AHB_MCB_MP(clocking ahb_drv_cb);
  modport AHB_SCB_MP(clocking ahb_mon_cb);

endinterface
