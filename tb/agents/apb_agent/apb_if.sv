// Implemented by Tho Lam Chip / Kairo IC
// Facebook1: facebook.com/tholamchip
// Facebook2: facebook.com/tholamchip.team
// Facebook Group: facebook.com/groups/tholamchip
// Youtube Channel1: youtube.com/@ThoLamChip
// Youtube Channel2: youtube.com/@Kairo_IC


interface apb_if(input bit clk);

logic[31:0]Paddr;
logic[31:0]Pwdata;
logic[31:0]Prdata;
logic[2:0] Pselx;
logic Penable;
logic Pwrite;

clocking apb_drv_cb@(posedge clk);
default input#1 output#1;
input Pselx;
input Pwrite;
output Prdata;

endclocking

clocking apb_mon_cb@(posedge clk);
default input#1 output#1;
input Paddr;
input Pwdata;
input Prdata;
input Pselx;
input Penable;
input Pwrite;

endclocking

modport APB_MCB_MP(clocking apb_drv_cb);
modport APB_SCB_MP(clocking apb_mon_cb);

endinterface

