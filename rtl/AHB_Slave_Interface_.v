module AHB_slave_interface(Hclk,Hresetn,Hwrite,Hreadyin,Hreadyout,Htrans,Haddr,Hwdata,
			   Prdata,valid,Haddr1,Haddr2,Hwdata1,Hwdata2,Hrdata,Hwrite_1d, Hwrite_2d,Hresp, data_outstanding_num, addr_outstanding_num);
    input Hclk,Hresetn;
    input Hwrite,Hreadyin,Hreadyout;
    input [1:0] Htrans;
    input [31:0] Haddr,Hwdata,Prdata;
    output reg valid;
    output reg [31:0] Haddr1,Haddr2,Hwdata1,Hwdata2;
    output [31:0] Hrdata;
    output reg Hwrite_1d, Hwrite_2d;
    output  [1:0] Hresp;
    output reg data_outstanding_num;
    output reg [1:0] addr_outstanding_num;
  // coverage off
    reg [31:0] Haddr_under_handling;
    reg        Hwrite_under_handling;

    always@(posedge Hclk,negedge Hresetn) begin
	    if(!Hresetn)
	        addr_outstanding_num <= 2'b00;
	    else if (addr_outstanding_num == 0) begin
	        if ((Htrans == 2'b10 || Htrans == 2'b11) & Hreadyin & Hreadyout )
		        addr_outstanding_num <= addr_outstanding_num + 1;
	    end else begin
	        if ((Htrans == 2'b00) & Hreadyin & Hreadyout )
		        addr_outstanding_num <= addr_outstanding_num - 1;
        end
    end

	always@(posedge Hclk,negedge Hresetn) begin
		if(!Hresetn)
			data_outstanding_num <= 2'b00;
		else if (data_outstanding_num == 0) begin
			if (Hreadyin & Hreadyout & (addr_outstanding_num > 0) & (Htrans != 2'b01))
				data_outstanding_num <= 1;
		end else begin
			if (addr_outstanding_num == 0)
				data_outstanding_num <= 0;
		end
	end
  // coverage on

	always @(posedge Hclk) begin
		if (~Hresetn) begin
			Haddr1<=0;
			Haddr2<=0;
		end else begin
			Haddr1<=Haddr;
			Haddr2<=Haddr1;
		end
	end

	always @(posedge Hclk) begin
		if (~Hresetn) begin
			Hwdata1<=0;
			Hwdata2<=0;
		end else begin
			Hwdata1<=Hwdata;
			Hwdata2<=Hwdata1;
		end
	end

	always @(posedge Hclk) begin
        if (~Hresetn) begin
			Hwrite_1d<=0;
            Hwrite_2d<=0;
        end else begin
			Hwrite_1d<=Hwrite;
            Hwrite_2d<=Hwrite_1d;
        end
	end

  // coverage off
	always @(Hreadyin,Haddr,Htrans,Hresetn) begin
		valid=0;
		if (Hresetn && Hreadyin && (Haddr>=32'h8000_0000 && Haddr<32'h8C00_0000) && (Htrans==2'b10 || Htrans==2'b11) )
			valid=1;
	end
  // coverage on

    assign Hrdata = Prdata;
    assign Hresp=2'b00;

endmodule