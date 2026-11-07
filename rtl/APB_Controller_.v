
// AHB to APG Bridge | Maven Silicon
//
//
//
// APB FSM Controller
// Date:25-06-2023
//
// By-Hrishikesh S Nair
//    20BES7080

module APB_FSM_Controller( Hclk,Hresetn,valid,data_outstanding_num,addr_outstanding_num,Haddr1,Haddr2,Hwdata1,Hwdata2,Prdata,Hwrite,Haddr,Hwdata,Hwrite_1d, Hwrite_2d,
			   Pwrite,Penable,Pselx,Paddr,Pwdata,Hreadyout);

input Hclk,Hresetn,valid,Hwrite,Hwrite_1d,Hwrite_2d;
input data_outstanding_num;
input [1:0] addr_outstanding_num;
input [31:0] Hwdata,Haddr,Haddr1,Haddr2,Hwdata1,Hwdata2,Prdata;
output reg Pwrite,Penable;
output reg Hreadyout;
output reg [2:0] Pselx;
output reg [31:0] Paddr,Pwdata;

//////////////////////////////////////////////////////PARAMETERS

parameter ST_IDLE=3'b000;
parameter ST_WWAIT=3'b001;
parameter ST_READ= 3'b010;
parameter ST_WRITE=3'b011;
parameter ST_WRITEP=3'b100;
parameter ST_RENABLE=3'b101;
parameter ST_WENABLE=3'b110;
parameter ST_WENABLEP=3'b111;


//////////////////////////////////////////////////// PRESENT STATE LOGIC

reg [2:0] PRESENT_STATE,NEXT_STATE;

always @(posedge Hclk or negedge Hresetn)
 begin:PRESENT_STATE_LOGIC
  if (~Hresetn)
    PRESENT_STATE<=ST_IDLE;
  else
    PRESENT_STATE<=NEXT_STATE;
 end


/////////////////////////////////////////////////////// NEXT STATE LOGIC

  always @(PRESENT_STATE,valid,Hwrite,Hwrite_1d)
 begin:NEXT_STATE_LOGIC
  case (PRESENT_STATE)

 	ST_IDLE:begin
		 if (~valid)
		  NEXT_STATE=ST_IDLE;
		 else if (valid && Hwrite)
		  NEXT_STATE=ST_WWAIT;
		 else
		  NEXT_STATE=ST_READ;
		end

	ST_WWAIT:begin
		 if (~valid)
		  NEXT_STATE=ST_WRITE;
		 else
		  NEXT_STATE=ST_WRITEP;
		end

	ST_READ: begin
		   NEXT_STATE=ST_RENABLE;
		 end

	ST_WRITE:begin
		  if (~valid)
		   NEXT_STATE=ST_WENABLE;
		  else
		   NEXT_STATE=ST_WENABLEP;
		 end

	ST_WRITEP:begin
		   NEXT_STATE=ST_WENABLEP;
		  end

	ST_RENABLE:begin
		     if (~valid)
		      NEXT_STATE=ST_IDLE;
		     else if (valid && Hwrite)
		      NEXT_STATE=ST_WWAIT;
		     else
		      NEXT_STATE=ST_READ;
		   end

	ST_WENABLE:begin
		     if (~valid)
		      NEXT_STATE=ST_IDLE;
		     else if (valid && Hwrite)
		      NEXT_STATE=ST_WWAIT;
		     else
		      NEXT_STATE=ST_READ;
		   end

	ST_WENABLEP:begin
             if (~valid && Hwrite_1d)
		       NEXT_STATE=ST_WRITE;
             else if (valid && Hwrite_1d)
		       NEXT_STATE=ST_WRITEP;
			// coverage off
			 else
		       NEXT_STATE=ST_READ;
		    end
		      // coverage on
	default: begin
		   NEXT_STATE=ST_IDLE;
		  end
  endcase
 end


////////////////////////////////////////////////////////OUTPUT LOGIC:COMBINATIONAL

reg Penable_temp,Hreadyout_temp,Pwrite_temp;
reg [2:0] Pselx_temp;
reg [31:0] Paddr_temp, Pwdata_temp;
reg [2:0] tempselx;
  
always @(Paddr_temp,Hresetn)
    begin
		tempselx=3'b000;
		if (Hresetn && Paddr_temp>=32'h8000_0000 && Paddr_temp<32'h8400_0000)
		    tempselx=3'b001;
		else if (Hresetn && Paddr_temp>=32'h8400_0000 && Paddr_temp<32'h8800_0000)
		    tempselx=3'b010;
		else if (Hresetn && Paddr_temp>=32'h8800_0000 && Paddr_temp<32'h8C00_0000)
			tempselx=3'b100;
	end

always @(*)
 begin:OUTPUT_COMBINATIONAL_LOGIC
   case(PRESENT_STATE)

	ST_IDLE: begin
			  if (valid && ~Hwrite)
			   begin:IDLE_TO_READ
			        Paddr_temp=Haddr;
				Pwrite_temp=Hwrite;
				Pselx_temp=tempselx;
				Penable_temp=0;
				Hreadyout_temp=0;
			   end

			  else if (valid && Hwrite)
			   begin:IDLE_TO_WWAIT
			        Pselx_temp=0;
				Penable_temp=0;
				Hreadyout_temp=1;
			   end

			  else
               begin:IDLE_TO_IDLE
			        Pselx_temp=0;
				Penable_temp=0;
				Hreadyout_temp=1;
			   end
		     end

	ST_WWAIT:begin
	          if (~valid)
			   begin:WAIT_TO_WRITE
			    Paddr_temp=Haddr1;
				Pwrite_temp=1;
				Pselx_temp=tempselx;
				Penable_temp=0;
				Pwdata_temp=Hwdata;
				Hreadyout_temp=0;
			   end

			  else
			   begin:WAIT_TO_WRITEP
			    Paddr_temp=Haddr1;
				Pwrite_temp=1;
				Pselx_temp=tempselx;
				Pwdata_temp=Hwdata;
				Penable_temp=0;
				Hreadyout_temp=0;
			   end

		     end

	ST_READ: begin:READ_TO_RENABLE
			  Penable_temp = (data_outstanding_num > 0) ? 1 : (addr_outstanding_num > 0);
			  Hreadyout_temp=1;
		     end

	ST_WRITE:begin
              if (~valid)
			   begin:WRITE_TO_WENABLE
				Penable_temp=1;
				Hreadyout_temp=1;
			   end

			  else
			   begin:WRITE_TO_WENABLEP ///DOUBT
				Penable_temp=1;
				Hreadyout_temp=1;
			   end
		     end

	ST_WRITEP:begin:WRITEP_TO_WENABLEP
			Penable_temp=(data_outstanding_num > 0);
			Hreadyout_temp=1;
		      end

	ST_RENABLE:begin
	            if (valid && ~Hwrite)
				 begin:RENABLE_TO_READ
					Paddr_temp=Haddr;
					Pwrite_temp=Hwrite;
					Pselx_temp=tempselx;
					Penable_temp=0;
					Hreadyout_temp=0;
				 end

			  else if (valid && Hwrite)
			    begin:RENABLE_TO_WWAIT
			     Pselx_temp=0;
				 Penable_temp=0;
				 Hreadyout_temp=1;
			    end

			  else
                begin:RENABLE_TO_IDLE
			     Pselx_temp=0;
				 Penable_temp=0;
				 Hreadyout_temp=1;
			    end

		       end

	ST_WENABLEP:begin
                if (~valid && Hwrite_1d)
			      begin:WENABLEP_TO_WRITEP
			       Paddr_temp=Haddr2;
				   Pwrite_temp=Hwrite_2d;
				   Pselx_temp=(data_outstanding_num > 0) ? tempselx : 3'b000;
				   Penable_temp=0;
				   Pwdata_temp=Hwdata;
				   Hreadyout_temp=0;
				  end
                else if (valid && (addr_outstanding_num == 0))
			      begin
			       Paddr_temp=Haddr;
				   Pwrite_temp=Hwrite;
                   Pselx_temp=Hwrite ? ((data_outstanding_num > 0) ? tempselx : 3'b000) : tempselx;
				   Penable_temp=0;
				   Pwdata_temp=Hwdata;
				   Hreadyout_temp=0;
				  end
			    else
			     begin:WENABLEP_TO_WRITE_OR_READ /////DOUBT
			        Paddr_temp=Haddr2;
				  Pwrite_temp=Hwrite_2d;
				  Pselx_temp=tempselx;
				  Pwdata_temp=Hwdata;
				  Penable_temp=0;
				  Hreadyout_temp=0;
			     end
		        end

	ST_WENABLE :begin
                 if (~valid && Hwrite_1d)
			      begin:WENABLE_TO_IDLE
				   Pselx_temp=0;
				   Penable_temp=0;
				   Hreadyout_temp=0;
				  end
                 else if (valid && (addr_outstanding_num == 0))
			      begin
			       Paddr_temp=Haddr;
				   Pwrite_temp=Hwrite;
                   Pselx_temp=Hwrite ? ((data_outstanding_num > 0) ? tempselx : 3'b000) : tempselx;
				   Penable_temp=0;
				   Pwdata_temp=Hwdata;
                    Hreadyout_temp=Hwrite ? ((data_outstanding_num == 0) ? 1 : 0) : 0;;
				  end
			    else
			     begin:WENABLE_TO_WAIT_OR_READ /////DOUBT
				  Pselx_temp=0;
				  Penable_temp=0;
				  Hreadyout_temp=0;
			     end

		        end

 endcase
end


////////////////////////////////////////////////////////OUTPUT LOGIC:SEQUENTIAL

always @(posedge Hclk)
 begin

  if (~Hresetn)
   begin
    Paddr<=0;
	Pwrite<=0;
	Pselx<=0;
	Pwdata<=0;
	Penable<=0;
	Hreadyout<=0;
   end

  else
   begin
        Paddr<=Paddr_temp;
	Pwrite<=Pwrite_temp;
	Pselx<=Pselx_temp;
	Pwdata<=Pwdata_temp;
	Penable<=Penable_temp;
	Hreadyout<=Hreadyout_temp;
   end
 end

endmodule