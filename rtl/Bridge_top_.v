
// AHB to APG Bridge | Maven Silicon
//
//
//
// Bridge Top
// Date:14-06-2022
//
// By-Hrishikesh S Nair
//    20BES7080


module Bridge_Top(Hclk,Hresetn,Hwrite,Hreadyin,Hreadyout,Hwdata,Haddr,Htrans,Prdata,Penable,Pwrite,Pselx,Paddr,Pwdata,Hresp,Hrdata);

    input Hclk,Hresetn,Hwrite,Hreadyin;
    input [31:0] Hwdata,Haddr,Prdata;
    input[1:0] Htrans;
    output Penable,Pwrite,Hreadyout;
    output [1:0] Hresp;
    output [2:0] Pselx;
    output [31:0] Paddr,Pwdata;
    output [31:0] Hrdata;

    ///////////////////////////////////////////////////////////////INTERMEDIATE SIGNALS

    wire valid;
    wire [31:0] Haddr1,Haddr2,Hwdata1,Hwdata2;
    wire Hwrite_1d,Hwrite_2d;
    wire data_outstanding_num;
    wire [1:0] addr_outstanding_num;

    /////////////////////////////////////////////////////////////// MODULE INSTANTIATIONS


    AHB_slave_interface AHBSlave (Hclk,Hresetn,Hwrite,Hreadyin,Hreadyout,Htrans,Haddr,Hwdata,Prdata,valid,Haddr1,Haddr2,Hwdata1,Hwdata2,Hrdata,Hwrite_1d,Hwrite_2d,Hresp, data_outstanding_num, addr_outstanding_num);

    APB_FSM_Controller APBControl ( Hclk,Hresetn,valid,data_outstanding_num,addr_outstanding_num,Haddr1,Haddr2,Hwdata1,Hwdata2,Prdata,Hwrite,Haddr,Hwdata,Hwrite_1d,Hwrite_2d,Pwrite,Penable,Pselx,Paddr,Pwdata,Hreadyout);


endmodule
